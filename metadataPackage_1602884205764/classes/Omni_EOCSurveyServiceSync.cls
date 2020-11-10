/**
* @description Create and send End of Claim surveys synchronously
* @author      Kejia Hu
* @date        27/04/2020                     
*/
public with sharing class Omni_EOCSurveyServiceSync {
    public static String[] rolesRTIds = new String[]{Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM_ROLE, Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPO_ROLE};
    Public List<String> propertyTypeCodes = new List<String>{'PropertyDamage', 'PropDamage', 'building', 'Contents'};
	Public List<String> serviceCentreCodes = new List<String>{'vehiclerepairshop', 'repairshop'};
	Public Map<String, Omni_SurveyRequest> mapCaseConfig;
    Public static String CLAIM_IDENTIFIER = '-Claim';
    Public static String EXPOSURE_IDENTIFIER = '-Exposure';
    Public String parentLogId;    
    public Map<String, MessageRequest> msgRequestByRoleId = new Map<String, MessageRequest>();
    
    public Omni_EOCSurveyServiceSync(Map<String,Omni_SurveyRequest> mapCaseConfig) {
        This.mapCaseConfig = mapCaseConfig;
        List<String> keyArray = new List<String>(mapCaseConfig.keySet());
        This.parentLogId = mapCaseConfig.get(keyArray[0]).parentLogId;
    }
    
    /**
    * @Description: Creates Survey Link and Sends it to Role indicated on the Survey Config Mtd
    * @author:      Luis Merinero, PwC
    * @Date:        2020-02-14
    */ 
    public void createAndSendSurveys(){
        try {
            String communityName = Label.Omni_Survey_CommunityName;
            Network community = [select id from Network where name = :communityName];
            Set<String> claimExternalIdSet = new Set<String>();
            Set<String> exposureExternalIdSet = new Set<String>();
            Map<String, String> mapEmailTemplateNameId = new Map<String, String>();
            Map<String, String> mapSurveyNameId = new Map<String, String>();
            Map<String, Case> mapInvitationRole = new Map<String, Case>();
            Map<String, SurveyConfig__mdt> mapSurveyConfigs = new Map<String, SurveyConfig__mdt>();
            Map<String, Survey_Template_Config__mdt> mapSurveyTemplateConfigs = new Map<String, Survey_Template_Config__mdt>();
            List<Case> rolesToUpdate = new List<Case>();
            List<Omni_CommunicationDispatcher.Message> messages = new List<Omni_CommunicationDispatcher.Message>();
            Map<Id,Case> mapRoleExposure = new Map<Id, Case>();
            Map<Id,Id> mapUserManager = new Map<id,id>();
            List<Case> exposures;
            
            //Create Map of Email Template by DeveloperName
            for (EmailTemplate template : EmailMessageTriggerHandlerHelper.SURVEY_TEMPLATS){
                mapEmailTemplateNameId.put(template.DeveloperName, template.Id);
            }
            
			//Create Map of Users and Managers Ids
            for (User user : Omni_UserSelector.USER_BY_ID.values()){
                mapUserManager.put(user.id, user.ManagerId);
            }
            
            //Create Map of Survey by Name
            for(SurveyVersion surveyVersion :[SELECT id, SurveyId, Survey.Name FROM SurveyVersion WHERE SurveyStatus = 'Active']){
                mapSurveyNameId.put(surveyVersion.Survey.Name, surveyVersion.SurveyId);
            }

            //Keep retrying access to survey until survey gets unlocked
            Boolean shouldLockSurvey = true;
            while (shouldLockSurvey) {
                try {
                    System.debug('shouldLockSurvey before query: ' + shouldLockSurvey);
                    List<Survey> surveys = [SELECT Id FROM Survey WHERE Id IN : mapSurveyNameId.values() FOR UPDATE];
                    shouldLockSurvey = false;
                    System.debug('shouldLockSurvey after query: ' + shouldLockSurvey);
                } catch (Exception e) {
                    System.debug(e.getMessage() + ' ' + e.getStackTraceString());
                    if (Limits.getQueries() >= Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('SurveyMaxQueryNum'))) {
                        System.enqueueJob(new Omni_EOCSurveyRequest(mapCaseConfig)); 
                        throw new EOCSurveyToIgnoreException('Please ignore this exception, surveys will be re-sent shortly!');
                    }
                }
            }

            //Create Map SurveyConfig by Flag
            for(SurveyConfig__mdt config : [SELECT id, Active__c, SurveyIndicatorAPIName__c, Type__c, (SELECT id, Explicit__c, RoleName__c FROM SurveyRoles__r WHERE Active__c = true) FROM SurveyConfig__mdt WHERE Active__c = true]){
                mapSurveyConfigs.put(config.SurveyIndicatorAPIName__c, config);
            }
            //Create Map TemplateSurveyConfig by Type-Issuing Group
            for(Survey_Template_Config__mdt templateConfig : [SELECT Claim_Type__c, Policy_Issuing_Groups__c, Survey_Name__c, 
                                                              TemplateNameEN__c, TemplateNameFR__c, 
                                                              Survey_Environment_Variable__r.FromEmail__c, logoId__c 
                                                              FROM Survey_Template_Config__mdt]){
                for(String issuingGroup : templateConfig.Policy_Issuing_Groups__c.split(';')){
                	String TypeIssuingGroup = templateConfig.Claim_Type__c + '' + issuingGroup;
                	mapSurveyTemplateConfigs.put(TypeIssuingGroup, templateConfig);    
                }
            }
            for(String caseExternalId : mapCaseConfig.keySet()){
                Omni_SurveyRequest request = mapCaseConfig.get(caseExternalId);
                if(request.type == 'Claim'){
                    claimExternalIdSet.add(caseExternalId.substringBefore('-'));    
                }else{
                    if(request.type == 'Exposure'){
                    	exposureExternalIdSet.add(caseExternalId.substringBefore('-'));
                    }
                }
            }
            if(claimExternalIdSet.size() >0){
                List<Case> claims = [SELECT id, ClaimId__c, TotalLoss__c, OwnerId,
                                     (SELECT id, ExposureType__r.TypeCode__c FROM ExposuresByClaim__r),
                                     (SELECT id, RoleNature__c, RoleNature__r.TypeCode__c, Language_Preference__c, PartyContact__c, PartyContact__r.Email, ClaimForRole__c, RoleId__c FROM RolesByClaim__r WHERE recordTypeId IN :rolesRTIds) 
                                     FROM Case WHERE ClaimId__c IN :claimExternalIdSet];
            
                //Create Survey Invitations for Claims
                for(Case claim : claims){
                    String UniqueExternalId = claim.ClaimId__c + CLAIM_IDENTIFIER;
                    for(String surveyIndicator : mapCaseConfig.get(UniqueExternalId).surveyIndicators){
                        parentLogId = mapCaseConfig.get(UniqueExternalId).parentLogId;
                        String claimType = '';
                        if(surveyIndicator == 'SendAutoPropertySurvey__c'){
                        	claimType = (claim.TotalLoss__c == 'TOT') ? 'Total Loss' : getClaimType(claim.ExposuresByClaim__r, claim.RolesByClaim__r);
                        }
                        String policyIssuingGroup = mapCaseConfig.get(UniqueExternalId).policyIssuingGroup;
                        String typeIssuingGroup = claimType + '' + policyIssuingGroup;
                        if(mapSurveyTemplateConfigs.get(typeIssuingGroup) != null){
                            //Get TemplateNames
                            String SurveyName = mapSurveyTemplateConfigs.get(typeIssuingGroup).Survey_Name__c;
                            String emailTemplateEN = mapSurveyTemplateConfigs.get(typeIssuingGroup).TemplateNameEN__c;
                            String emailTemplateFR = mapSurveyTemplateConfigs.get(typeIssuingGroup).TemplateNameFR__c;
                            String fromAddress = mapSurveyTemplateConfigs.get(typeIssuingGroup).Survey_Environment_Variable__r.FromEmail__c;
                            String logoId = mapSurveyTemplateConfigs.get(typeIssuingGroup).logoId__c;
                            //Get TemplateIds
                            String surveyId = mapSurveyNameId.get(SurveyName);
                            String emailTemplateENId = mapEmailTemplateNameId.get(emailTemplateEN);
                            String emailTemplateFRId = mapEmailTemplateNameId.get(emailTemplateFR);
                            
                            SurveyConfig__mdt config = mapSurveyConfigs.get(surveyIndicator);
                            for(Survey_Role__mdt roleConfig :config.SurveyRoles__r){
                                for(Case relatedCase : claim.RolesByClaim__r){
                                    if(relatedCase.RoleNature__r.TypeCode__c == roleConfig.RoleName__c){
                                        String invitationId = surveyInvitationId(surveyId, relatedCase.ClaimForRole__c, 
                                                                                 community.Id, 
                                                                                 claim.OwnerId, 
                                                                                 logoId, 
                                                                                 mapUserManager,
                                                                                 relatedCase.PartyContact__c,
                                                                                 relatedCase.PartyContact__r.Email);
                                        mapInvitationRole.put(invitationId, relatedCase);
                                        if(relatedCase.PartyContact__r.Email != null){
                                        	String templateId = (relatedCase.Language_Preference__c == 'F') ? emailTemplateFRId:emailTemplateENId;
                                            msgRequestByRoleId.put(
                                                relatedCase.RoleId__c, 
                                                new MessageRequest(templateId, relatedCase, parentLogId, fromAddress));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(exposureExternalIdSet.size() >0){
                exposures = [SELECT id, ExposureId__c, RecordType.DeveloperName, ClaimForExposure__c, OwnerId, ExposureType__c
                             FROM Case WHERE ExposureId__c IN :exposureExternalIdSet];
                Set<id> claimIdsForExposures = new Set<id>();
                for(Case exp : exposures){
                    claimIdsForExposures.add(exp.ClaimForExposure__c);
                }
                List<Case> claimsForExposures = [SELECT id, ExposureForRole__c,
                                                 (SELECT id, RoleNature__c, RoleNature__r.TypeCode__c, Language_Preference__c, PartyContact__c, PartyContact__r.Email, ClaimForRole__c, ExposureForRole__c, RoleId__c, ExposureForRole__r.ExposureType__c FROM RolesByClaim__r WHERE recordTypeId IN :rolesRTIds)
                                                 FROM Case WHERE Id IN :claimIdsForExposures];
                Map<id, Case[]> expIdRolesMap = new Map<id, Case[]>();
                for(Case claimExp : claimsForExposures){
                	   expIdRolesMap.put(claimExp.Id, claimExp.RolesByClaim__r);
                }
                //Create Survey Invitations for Exposures
                for(Case exposure : exposures){
                    String UniqueExternalId = exposure.ExposureId__c + EXPOSURE_IDENTIFIER;
                    parentLogId = mapCaseConfig.get(UniqueExternalId).parentLogId;
                    String claimType = exposure.RecordType.DeveloperName;
                    String policyIssuingGroup = mapCaseConfig.get(UniqueExternalId).policyIssuingGroup;
                    String typeIssuingGroup = claimType + '' + policyIssuingGroup;
                    if(mapSurveyTemplateConfigs.get(typeIssuingGroup) != null){
                        //Get TemplateNames
                        String SurveyName = mapSurveyTemplateConfigs.get(typeIssuingGroup).Survey_Name__c;
                        String emailTemplateEN = mapSurveyTemplateConfigs.get(typeIssuingGroup).TemplateNameEN__c;
                        String emailTemplateFR = mapSurveyTemplateConfigs.get(typeIssuingGroup).TemplateNameFR__c;
                        String fromAddress = mapSurveyTemplateConfigs.get(typeIssuingGroup).Survey_Environment_Variable__r.FromEmail__c;
                        //Get TemplateIds
                        String logoId = mapSurveyTemplateConfigs.get(typeIssuingGroup).logoId__c;
                        String surveyId = mapSurveyNameId.get(SurveyName);
                        String emailTemplateENId = mapEmailTemplateNameId.get(emailTemplateEN);
                        String emailTemplateFRId = mapEmailTemplateNameId.get(emailTemplateFR);
                        
                        for(String surveyIndicator : mapCaseConfig.get(UniqueExternalId).surveyIndicators){
                            SurveyConfig__mdt config = mapSurveyConfigs.get(surveyIndicator);
                            for(Survey_Role__mdt roleConfig :config.SurveyRoles__r){
                                for(Case relatedCase : expIdRolesMap.get(exposure.ClaimForExposure__c)){
                                    if(relatedCase.RoleNature__r.TypeCode__c == roleConfig.RoleName__c){
                                        if(relatedCase.ExposureForRole__c == exposure.Id){
                                            String invitationId = surveyInvitationId(surveyId, 
                                                                                     exposure.Id,
                                                                                     community.Id, 
                                                                                     exposure.OwnerId, 
                                                                                     logoId, mapUserManager,
                                                                                     relatedCase.PartyContact__c,
                                                                                     relatedCase.PartyContact__r.Email);
                                            mapInvitationRole.put(invitationId, relatedCase);
                                            if(relatedCase.PartyContact__r.Email != null){
                                            	String templateId = (relatedCase.Language_Preference__c == 'F') ? emailTemplateFRId : emailTemplateENId;
                                                msgRequestByRoleId.put(
                                                    relatedCase.RoleId__c, 
                                                    new MessageRequest(templateId, relatedCase, parentLogId, fromAddress));
                                            }
                                        }else{
                                            if(!roleConfig.Explicit__c){
                                                mapRoleExposure.put(relatedCase.Id, exposure);      
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(mapRoleExposure.size()>0){
                    List<Case> shadowRolesList = new List<Case>();
                    Set<Id> setRoleIds = mapRoleExposure.keySet();
					String soql = Omni_Utils.getCreatableFieldsSOQL('Case','id IN :setRoleIds');
        			List<Case> roles = (List<Case>)Database.query(soql);
                    String ShadowRoleRecordTypeId = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_SHADOW_ROLE;
                    Set<id> partyContactIdSet = new Set<id>();
                    for(Case role :roles){
                        if(!partyContactIdSet.contains(role.PartyContact__c)){
                            partyContactIdSet.add(role.PartyContact__c);
                        }
                        Case shadowRole = role.clone(false, true);
        				shadowRole.RecordTypeId = ShadowRoleRecordTypeId;
                        shadowRole.OriginRoleForShadow__c = role.Id;
                        shadowRole.ExposureForRole__c = mapRoleExposure.get(role.id).Id;
                        shadowRole.RoleId__c = shadowRole.RoleId__c + Utility.generateRandomChar(8) + DateTime.now().getTime();
                    	shadowRolesList.add(shadowRole);
                    }
                    if(!shadowRolesList.isEmpty()){
                        //Create Map to obtain Email Address associated to the Role
                        Map<id, String> partyContactEmailMap = new Map<id, String>();
                        for(Contact partyContact : [SELECT Id, Email FROM Contact WHERE Id IN :partyContactIdSet]){
                            if(partyContact.Email != null){
                            	partyContactEmailMap.put(partyContact.Id, partyContact.Email);
                            }
                        }
                        for(Case shadowRole : shadowRolesList){
                            Case exposure = mapRoleExposure.get(shadowRole.OriginRoleForShadow__c);
                            String UniqueExternalId = exposure.ExposureId__c + EXPOSURE_IDENTIFIER;
                            parentLogId = mapCaseConfig.get(UniqueExternalId).parentLogId;
                            String claimType = exposure.RecordType.DeveloperName;
                            String policyIssuingGroup = mapCaseConfig.get(UniqueExternalId).policyIssuingGroup;
                            String typeIssuingGroup = claimType + '' + policyIssuingGroup;
                            //Get TemplateNames
                            String SurveyName = mapSurveyTemplateConfigs.get(typeIssuingGroup).Survey_Name__c;
                            String emailTemplateEN = mapSurveyTemplateConfigs.get(typeIssuingGroup).TemplateNameEN__c;
                            String emailTemplateFR = mapSurveyTemplateConfigs.get(typeIssuingGroup).TemplateNameFR__c;
                            String fromAddress = mapSurveyTemplateConfigs.get(typeIssuingGroup).Survey_Environment_Variable__r.FromEmail__c;
                            //Get TemplateIds
                            String logoId = mapSurveyTemplateConfigs.get(typeIssuingGroup).logoId__c;
                            String surveyId = mapSurveyNameId.get(SurveyName);
                            String emailTemplateENId = mapEmailTemplateNameId.get(emailTemplateEN);
                            String emailTemplateFRId = mapEmailTemplateNameId.get(emailTemplateFR);

                            String invitationId = surveyInvitationId(surveyId, 
                                                                     shadowRole.ExposureForRole__c,
                                                                     community.Id, 
                                                                     shadowRole.OwnerId, 
                                                                     logoId, 
                                                                     mapUserManager,
                                                                     shadowRole.PartyContact__c,
																	 partyContactEmailMap.get(shadowRole.PartyContact__c));
                            mapInvitationRole.put(invitationId, shadowRole);
                            if(partyContactEmailMap.get(shadowRole.PartyContact__c) != null){
                                String templateId = (shadowRole.Language_Preference__c == 'F') ? emailTemplateFRId : emailTemplateENId;
                                msgRequestByRoleId.put(
                                    shadowRole.RoleId__c, 
                                    new MessageRequest(templateId, shadowRole, parentLogId, fromAddress));
                            }
                        }
                    }
                }
            }
            //Retrieve existing roles
            updateRolesInRequests(msgRequestByRoleId);

            Set<String> rolesSet = new Set<String>();
            for(SurveyInvitation invitation : [SELECT id, InvitationLink, logoId__c FROM surveyInvitation WHERE Id IN :mapInvitationRole.KeySet()]){
                Case role = mapInvitationRole.get(invitation.Id);
                if(!rolesSet.contains(role.RoleId__c)){
                    rolesSet.add(role.RoleId__c);
                    String link =invitation.InvitationLink + '&bid=' + invitation.logoId__c;
                    msgRequestByRoleId.get(role.RoleId__c).role.SurveyLink__c = link;
                }
            }

            //Create template records for emails sending, delete them once sent
            //Create temporary Account records
            Map<String, Account> accountById = createAccounts(msgRequestByRoleId.values());
            //Create temporary Contact records
            Map<String, Contact> contactById = createContacts(msgRequestByRoleId.values(), accountById);
            //Create temporary Survey Builder records
            Map<String, SurveyBuilder__c> surveyBuildersByRoleId = createSurveyBuilders(msgRequestByRoleId.values(),
                                                                                        accountById,
                                                                                        contactById);
            messages = createEmailMessages(msgRequestByRoleId, surveyBuildersByRoleId);

            if(messages.size() > 0) {
                Omni_EmailServiceSync emailService = new Omni_EmailServiceSync(messages, false, false);
            	emailService.sendEmails();
                //Delete temporary records
                delete surveyBuildersByRoleId.values();
                delete contactById.values();
                delete accountById.values();

                //Create feeds
                try {
                    createTextFeeds(msgRequestByRoleId.values(), exposures);
                } catch(exception e){
                    System.debug(e.getMessage() + ' ' + e.getStackTraceString());
                    if (parentLogId != null) {
                        ApplicationLogHandler.saveExceptionLog('EOC Survey Feed Creation Exception', e, parentLogId);
                    } else {
                        ApplicationLogHandler.saveExceptionLog('EOC Survey Feed Creation Exception', e, null);
                    }    
                }
            }
        }catch(exception e){
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
        	if(parentLogId != null){
          		ApplicationLogHandler.saveExceptionLog('EOC Survey Exception', e, parentLogId);
            }else{
                ApplicationLogHandler.saveExceptionLog('EOC Survey Exception', e, null);
            }    
        }
    }
    
    /**
    * @Description: Creates Survey Invitation and Survey Subject
    * @author:      Luis Merinero, PwC
    * @Date:        2020-02-14
    */ 
    public static String surveyInvitationId(String surveyId, String caseId, String communityId, String OwnerId, String logoId, Map<id,id> mapUserManager, String participantId, String participantEmail){
        surveyInvitation invitation = new surveyInvitation(Name = 'End of Claim Survey Invitation ' + String.valueOf(System.now()), 
                                                           SurveyId = surveyId,
                                                           CommunityId = communityId,
                                                           OptionsAllowGuestUserResponse = true, 
                                                           logoId__c = logoId,
                                                           Participant_Email__c = participantEmail,
                                                           ParticipantId = participantId);
		if(OwnerId.startsWith('005') && mapUserManager.get(OwnerId) != null){
            OwnerId = mapUserManager.get(OwnerId);
        	invitation.OwnerId = OwnerId;
        }else{
            OwnerId = null;
        }
        insert invitation;

        insert new surveySubject(Name = 'End of Claim Survey', 
                                 ParentId = invitation.id,
                                 Survey_Invitation__c = invitation.id,
                                 SubjectId = caseId, 
                                 Survey_Owner__c = ownerId, 
                                 Case__c = caseId);
        return invitation.Id;
    }
    
    /**
    * @Description: Returns Auto Claim Type based on
    * @author:      Luis Merinero, PwC
    * @Date:        2020-02-18
    */ 
    private String getClaimType(List<Case> exposures, List<Case> roles){
        String claimType = 'Auto';
        Boolean propertyClaim = false;
        Boolean serviceCentre = false;
        for(Case exposure : exposures){
            if(propertyTypeCodes.contains(exposure.ExposureType__r.TypeCode__c)){
                propertyClaim = true;
            }
        }
        for(Case role : roles){
            if(serviceCentreCodes.contains(role.RoleNature__r.TypeCode__c)){
                serviceCentre = true;
            }
        }
        if(propertyClaim){
            claimType = 'Property';
        }else{
            if(serviceCentre){
                claimType  = 'Service Centre';  
            }
        }
        return claimType;
    }

    /**
    * @Description create text feed for role
    * @Author      Kejia Hu
    * @Date        06/04/2020                     
    */
    public List<FeedItem> createTextFeeds(List<MessageRequest> msgRequests, List<Case> exposures) {
        List<FeedItem> feeds = new List<FeedItem>();
        Map<Id, EmailTemplate> templateById = new Map<Id, EmailTemplate>();
        for (EmailTemplate template : EmailMessageTriggerHandlerHelper.SURVEY_TEMPLATS){
            templateById.put(template.Id, template);
        }
        for (MessageRequest req : msgRequests){
            case role = req.role;
            FeedItem newfeed = new FeedItem();
            newfeed.parentId = (null != role.ExposureForRole__c) 
                                ? role.ExposureForRole__c
                                : role.ClaimForRole__c;
            newFeed.Type = Omni_ClaimEventConstant.COMM_FEED_TYPE;
            newFeed.Status = Omni_ClaimEventConstant.COMM_FEED_STATUS;
            newFeed.Revision = 1;
            newFeed.Body =  String.format(System.Label.Omni_FeedBodyForSurvey_Claim_Exposure_EN, 
                                          new List<String>{
                                                Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_ID.get(role.RoleNature__c).L_EN_CA__c
                                              }
                            ) + ' / ' + 
                            String.format(System.Label.Omni_FeedBodyForSurvey_Claim_Exposure_FR, 
                                          new List<String>{
                                                Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_ID.get(role.RoleNature__c).L_FR_CA__c
                                              }
                            ) + ' - ' + templateById.get(req.templateId).Subject;
            feeds.add(newFeed);
            if (null != role.ExposureForRole__c) {
                feeds.add(createTextFeedForClaim(templateById.get(req.templateId).Subject, role, getExposureType(role.ExposureForRole__c, exposures)));
            }
        }
        if (!feeds.isEmpty()) {
           insert feeds;
        }
        return feeds;
    }

    /**
    * @Description create text feed on claim for exposure role
    * @Author      Kejia Hu
    * @Date        06/04/2020                     
    */
    public FeedItem createTextFeedForClaim(String subject, Case exposureRole, String exposureType) {
        FeedItem newfeed = new FeedItem();
        newfeed.parentId = exposureRole.ClaimForRole__C;
        newFeed.Type = Omni_ClaimEventConstant.COMM_FEED_TYPE;
        newFeed.Status = Omni_ClaimEventConstant.COMM_FEED_STATUS;
        newFeed.Revision = 1;
        newFeed.Body =  String.format(System.Label.Omni_FeedBodyForSurvey_ExposureToClaim_EN, 
                                          new List<String>{
                                                Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID.get(exposureType).L_EN_CA__c,             
                                                Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_ID.get(exposureRole.RoleNature__c).L_EN_CA__c
                                          }
                        ) + ' / ' +
                        String.format(System.Label.Omni_FeedBodyForSurvey_ExposureToClaim_FR, 
                                          new List<String>{
                                                Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID.get(exposureType).L_FR_CA__c,             
                                                Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_ID.get(exposureRole.RoleNature__c).L_FR_CA__c
                                          }
                        ) + ' - ' + subject;
        return newfeed;
    }

    public String getExposureType(String exposureId, List<Case> exposures){
        String exposureType;
        for (Case exposure : exposures) {
            if (exposureId == exposure.Id) {
                exposureType =exposure.ExposureType__c;
                break;
            }
        }
        return exposureType;
    }

    /**
	* @Description: Creates Email Message list for sending
	* @author:      Kejia Hu
	* @Date:        2020-05-11
	*/ 
    public List<Omni_CommunicationDispatcher.Message> createEmailMessages(Map<String, MessageRequest> msgRequestByRoleId, 
                                                                         Map<String, SurveyBuilder__c> surveyBuildersByRoleId){
        List<Omni_CommunicationDispatcher.Message> messages = new List<Omni_CommunicationDispatcher.Message>();
        for (String roleId : msgRequestByRoleId.keySet()) {
            Omni_CommunicationDispatcher.Message message = new Omni_CommunicationDispatcher.Message();
            MessageRequest msgRequest = msgRequestByRoleId.get(roleId);
            SurveyBuilder__c builder = surveyBuildersByRoleId.get(roleId);
            message.templateid = msgRequest.templateId;
            message.targetobjectid = builder.PartyContact__c;
            message.whatid = builder.Id;
            message.logId = msgRequest.logId;
            message.fromAddress = msgRequest.fromAddress;
            messages.add(message);
        }
        return messages;
    }

    /**
	* @Description: create Survey Builder records
	* @author:      Kejia Hu    
	* @Date:        2020-05-11
	*/ 
    public Map<String, SurveyBuilder__c> createSurveyBuilders(List<MessageRequest> msgRequests, 
                                                                Map<String, Account> accountById,
                                                                Map<String, Contact> contactById) {
        Map<String, SurveyBuilder__c> surveyBuildersByRoleId = new Map<String, SurveyBuilder__c>();
        for (MessageRequest req : msgRequests) {
            if (!surveyBuildersByRoleId.containsKey(req.role.RoleId__c)) {
                surveyBuildersByRoleId.put(req.role.RoleId__c, 
                                new SurveyBuilder__c(
                                    RoleId__c = req.role.RoleId__c,
                                    PIG_EN__c = req.role.PIG_EN__c,
                                    PIG_Logo_EN__c = req.role.PIG_Logo_EN__c,
                                    ClaimNumber__c = req.role.ClaimNumber__c,
                                    Adjustor_Name__c = req.role.Adjustor_Name__c,
                                    Broker_Name__c = req.role.Broker_Name__c,
                                    Claim_LOB__c = req.role.Claim_LOB__c,
                                    PIG_Name_EN__c = req.role.PIG_Name_EN__c,
                                    Party_Name__c = req.role.Party_Name__c,
                                    Party_Address_Line__c = req.role.Party_Address_Line__c,
                                    Party_City__c = req.role.Party_City__c,
                                    Party_Province__c = req.role.Party_Province__c,
                                    Party_Postal_Code__c = req.role.Party_Postal_Code__c,
                                    LiabilityConfirmed__c = req.role.LiabilityConfirmed__c,
                                    ProvinceOfIssuanceId__c = req.role.ProvinceOfIssuanceId__c,
                                    PIG_FR__c = req.role.PIG_FR__c,
                                    PIG_Name_FR__c = req.role.PIG_Name_FR__c,
                                    ClaimForRole__c = req.role.ClaimForRole__c,
                                    ExposureForRole__c = req.role.ExposureForRole__c,
                                    SurveyLink__c = req.role.SurveyLink__c,
                                    PartyContact__c = contactById.get(req.role.PartyContact__c).Id)
                                );
            }
        }
        if (!surveyBuildersByRoleId.isEmpty()) {
            insert surveyBuildersByRoleId.values();
        }
        return surveyBuildersByRoleId;
    }

    /**
	* @Description: create Contact records
	* @author:      Kejia Hu    
	* @Date:        2020-05-11
	*/ 
    public Map<String, Contact> createContacts(List<MessageRequest> msgRequests, Map<String, Account> accountById) {
        Map<String, Contact> contactById = new Map<String, Contact>();
        for (MessageRequest req : msgRequests) {
            if (!contactById.containsKey(req.role.PartyContact__c)) {
                contactById.put(req.role.PartyContact__c, 
                                new Contact(
                                    FirstName = req.role.PartyContact__r.FirstName,
                                    LastName = req.role.PartyContact__r.LastName,
                                    Email = req.role.PartyContact__r.Email,
                                    AccountId = accountById.get(req.role.PartyAccount__c).Id)
                                );
            }
        }
        if (!contactById.isEmpty()) {
            insert contactById.values();
        }
        return contactById;
    }

    /**
	* @Description: create Account records
	* @author:      Kejia Hu    
	* @Date:        2020-05-11
	*/ 
    public Map<String, Account> createAccounts(List<MessageRequest> msgRequests) {
        Map<String, Account> accountById = new Map<String, Account>();
        for (MessageRequest req : msgRequests) {
            if (!accountById.containsKey(req.role.PartyAccount__c)) {
                accountById.put(req.role.PartyAccount__c, new Account(Name = req.role.Party_Name__c));
            }
        }
        if (!accountById.isEmpty()) {
            insert accountById.values();
        }
        return accountById;
    }

    /**
	* @Description: update roles in message request
	* @author:      Kejia Hu    
	* @Date:        2020-05-08
	*/ 
    public void updateRolesInRequests(Map<String, MessageRequest> msgRequestByRoleId) {
        Set<Id> existingRoleIds = getExistingRoleIds(msgRequestByRoleId.values()); 
        Map<String, Case> exsitingRoleByRoleId = Omni_CaseSelector.getRoleByRoleId(existingRoleIds);
        if (!exsitingRoleByRoleId.isEmpty()) {
            for (String key : msgRequestByRoleId.keySet()) {
                if (exsitingRoleByRoleId.containsKey(key)) {
                    msgRequestByRoleId.get(key).role =  exsitingRoleByRoleId.get(key);
                }
            }
        }
    }

    /**
	* @Description: get exsiting role record ids
	* @author:      Kejia Hu    
	* @Date:        2020-05-08
	*/ 
    public Set<Id> getExistingRoleIds(List<MessageRequest> msgRequests) {
        Set<Id> existingRoleIds = new Set<Id>();
        for (MessageRequest req : msgRequests) {
            if (req.roleExists) {
                existingRoleIds.add(req.role.Id);
            }
        }
        return existingRoleIds;
    }

    /**
	* @Description: Email Message request holds email related information
	* @author:      Kejia Hu    
	* @Date:        2020-05-08
	*/ 
    public class MessageRequest {
        public Id templateId;
        public Case role;
        public String logId;
        public String fromAddress;
        public Boolean roleExists;

        public MessageRequest(Id templateId, Case role, String logId, String fromAddress) {
            this.templateid = templateId;
            this.role = role;
            this.logId = logId;
            this.fromAddress = fromAddress;
            this.roleExists = (role.Id != null);
        }
    }

    public class EOCSurveyToIgnoreException extends Exception {}
}