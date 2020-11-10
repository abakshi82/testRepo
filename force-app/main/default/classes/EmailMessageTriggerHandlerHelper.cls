/**
* @description Helper class for EmailMessageHandler
* @author      Kejia Hu
* @date        17/09/2019                     
*/
public with sharing class EmailMessageTriggerHandlerHelper {

    /**
    * @Description exclude no attachment emails
    * @Author      Kejia Hu
    * @Date        17/04/2020                     
    */
    public static void excludeNoAttachmentEmails(List<EmailMessage> emails) {
        for (Integer i = 0; i < emails.size(); i++) {
            if (!emails[i].HasAttachment) {
                emails.remove(i);
            }
        }
    }

    /**
    * @Description remove emails that matched to multiple DEA address
    * @Author      Kejia Hu
    * @Date        22/04/2020                     
    */
    public static void removeEmailsWithMultipleDEAMatced(Map<String, EmailMessage> emailByDEA) {
        List<EmailMessage> emailsMatchToOneDEAOnly = new List<EmailMessage>();
        List<EmailMessage> emailsMatchToMultipleDEA = new List<EmailMessage>();
        for (String dea : emailByDEA.keySet()) {
            if (emailsMatchToOneDEAOnly.contains(emailByDEA.get(dea))) {
                emailsMatchToMultipleDEA.add(emailByDEA.get(dea));
            } else {
                emailsMatchToOneDEAOnly.add(emailByDEA.get(dea));
            }
        }
        for (String dea : emailByDEA.keySet()) {
            if (emailsMatchToMultipleDEA.contains(emailByDEA.get(dea))) {
                emailByDEA.remove(dea);
            }
        }
    }

    /**
    * @Description remove invalid DEA address 
    * @Author      Kejia Hu
    * @Date        22/04/2020                     
    */
    public static void removeInvalidDEA(Map<String, EmailMessage> emailByDEA, Map<String, Case> caseByDEA) {
        for (String oneDEAOfEmailMap : emailByDEA.keySet()) {
            if (!caseByDEA.containsKey(oneDEAOfEmailMap.toUpperCase())) {
                emailByDEA.remove(oneDEAOfEmailMap);
            }
        }
    }

    /**
    * @Description get DEA Addresses related Emails
    * @Author      Kejia Hu
    * @Date        14/04/2020                     
    */
    public static void updateDEARelatedEmails(Map<String, EmailMessage> emailByDEA, Map<String, Case> caseByDEAAddress) {
        for (String deaKeyForEmail : emailByDEA.keySet()) {
            String deaKey = deaKeyForEmail.toUpperCase();
            if (caseByDEAAddress.containsKey(deaKey)) {
                emailByDEA.get(deaKeyForEmail).ParentId = caseByDEAAddress.get(deaKey).Id;
                emailByDEA.get(deaKeyForEmail).RelatedToId = caseByDEAAddress.get(deaKey).Id;
                String regExThreadId = 'ref\\:_[a-z0-9A-Z]{5,}\\._[a-z0-9A-Z]{5,}\\:ref'; 
                if (!String.isBlank(emailByDEA.get(deaKeyForEmail).TextBody)) {
                    String txtBodyNoTheadId = emailByDEA.get(deaKeyForEmail).TextBody.replaceAll(regExThreadId, '').replace('[  ]', '');
                    emailByDEA.get(deaKeyForEmail).TextBody = txtBodyNoTheadId;
                }
                if (!String.isBlank(emailByDEA.get(deaKeyForEmail).HtmlBody)) {
                    String htmlBodyNoTheadId = emailByDEA.get(deaKeyForEmail).HtmlBody.replaceAll(regExThreadId, '').replace('[  ]', '');
                    emailByDEA.get(deaKeyForEmail).HtmlBody = htmlBodyNoTheadId;
                }
                if (!String.isBlank(emailByDEA.get(deaKeyForEmail).Subject)) {
                    String subjectNoThreadId = emailByDEA.get(deaKeyForEmail).Subject.replaceAll(regExThreadId, '').replace('[  ]', '');
                    emailByDEA.get(deaKeyForEmail).Subject = subjectNoThreadId;
                }
            }
        }
    }

    /**
    * @Description exclude DEA Addresses related Emails from email list
    * @Author      Kejia Hu
    * @Date        14/04/2020                     
    */
    public static List<EmailMessage> excludeDEARelatedEmails(List<EmailMessage> emails, Map<String, Case> caseByDEAAddress) {
        for (Integer i = 0; i < emails.size(); i++) {
            String deaKey = (!String.isBlank(emails[i].ToAddress))
                                ? emails[i].ToAddress.toUpperCase()
                                : '';
            if (!emails[i].Incoming || String.isBlank(deaKey)) {
                continue;
            }
            if (caseByDEAAddress.containsKey(deaKey)) {
                emails.remove(i);
            }
        }
        return emails;
    }

    /**
    * @Description get Email by DEA Addresse map from Emails
    * @Author      Kejia Hu
    * @Date        13/04/2020                     
    */
    public static Map<String, EmailMessage> getEmailByDEAAddress(List<EmailMessage> emails) {
        Map<String, EmailMessage> emailByDEAAddress = new Map<String, EmailMessage>();
        for (EmailMessage email : emails) {
            emailByDEAAddress.putAll(getDEAAddressesFromEmail(email)); 
        }
        return emailByDEAAddress;
    }

    /**
    * @Description get DEA Addresses from an email
    * @Author      Kejia Hu
    * @Date        21/04/2020                     
    */
    public static Map<String, EmailMessage> getDEAAddressesFromEmail(EmailMessage email) {
        Map<String, EmailMessage> emailByDEAAddress = new Map<String, EmailMessage>();
        if (!String.isBlank(email.ToAddress)) {
            emailByDEAAddress.putAll(getDEAAddressFromEmailAddressLines(email.ToAddress, email));
        }
        if (!String.isBlank(email.CcAddress)) {
            emailByDEAAddress.putAll(getDEAAddressFromEmailAddressLines(email.CcAddress, email));
        }
        return emailByDEAAddress;
    }

    /**
    * @Description get all DEA Addresses from an email address lines, address lines may contain multiple addresses separated by ';'
    * @Author      Kejia Hu
    * @Date        21/04/2020                     
    */
    public static Map<String, EmailMessage> getDEAAddressFromEmailAddressLines(String addressLine, EmailMessage email){
        Map<String, EmailMessage> emailByDEAAddress = new Map<String, EmailMessage>();
        String deaSuffix = Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('DEA_Email_Address_Domain');
        for (String oneAddress : addressLine.split(';')) {
            if (oneAddress.containsIgnoreCase(deaSuffix)) {
                emailByDEAAddress.put(oneAddress.trim(), email);
            }
        }
        return emailByDEAAddress;
    }

    /**
    * @Description get survey emails from email list
    * @Author      Kejia Hu
    * @Date        06/04/2020                     
    */
    public static List<EmailMessage> getSurveyEmails(List<EmailMessage> emails, List<String> surveySubjects) {
        List<EmailMessage> surveyEmails = new List<EmailMessage>();
        for (EmailMessage email : emails){
            if (surveySubjects.contains(email.subject)) {
                surveyEmails.add(email);
            }
        }
        return surveyEmails;
    }

    /**
    * @Description remove survey emails from email list
    * @Author      Kejia Hu
    * @Date        06/04/2020                     
    */
    public static List<EmailMessage> removeSurveyEmails(List<EmailMessage> emails, List<String> surveySubjects) {
        List<EmailMessage> nonSurveyEmails = new List<EmailMessage>();
        for (EmailMessage email : emails){
            if (!surveySubjects.contains(email.subject)) {
                nonSurveyEmails.add(email);
            }
        }
        return nonSurveyEmails;
    }

    /**
    * @Description retrieve subjects from email template folder <Surveys>
    * @Author      Kejia Hu
    * @Date        30/04/2020                     
    */
    public static final List<String> SURVEY_SUBJECTS {
        get{
            if (null == SURVEY_SUBJECTS) {
                SURVEY_SUBJECTS =  new List<String>();
                for (EmailTemplate template : SURVEY_TEMPLATS){
                    SURVEY_SUBJECTS.add(template.Subject);
                }
            }
            return SURVEY_SUBJECTS;
        }
        set;
    }

    /**
    * @Description retrieve subjects from email template folder <Surveys>
    * @Author      Kejia Hu
    * @Date        30/04/2020                     
    */
    public static final List<EmailTemplate> SURVEY_TEMPLATS {
        get{
            if (null == SURVEY_TEMPLATS) {
                SURVEY_TEMPLATS =  Omni_EmailTemplateSelector.getAllEmailTemplatesByFolderName('Surveys');
            }
            return SURVEY_TEMPLATS;
        }
        set;
    }

    /**
    * @Description aync delete email feeds for roles
    * @Author      Kejia Hu
    * @Date        06/04/2020                     
    */
    @future
    public static void deleteSurveyEmailsForRolesAync(String input) {
        List<Omni_CommunicationDispatcher.Message> messages = (List<Omni_CommunicationDispatcher.Message>) JSON.deserialize(
                                                                input, List<Omni_CommunicationDispatcher.Message>.Class);
        Set<String> roleIds = retrieveRoleIdsFromMessage(messages);
        List<FeedItem> emailFeedsForRoles = [SELECT Id FROM FeedItem WHERE ParentId IN :roleIds AND Type = 'EmailMessageEvent'];
        delete emailFeedsForRoles;
        //retrieve survey subjects from survey folder and delete survey emails for roles
        List<String> surveySujects = EmailMessageTriggerHandlerHelper.SURVEY_SUBJECTS;
        List<EmailMessage> surveyEmails = [SELECT Id FROM EmailMessage WHERE RelatedToId IN :roleIds AND Subject IN :surveySujects];
        delete surveyEmails;
    }

    /**
    * @Description retrieve role Ids from messages
    * @Author      Kejia Hu
    * @Date        06/04/2020                     
    */
    public static Set<String> retrieveRoleIdsFromMessage(List<Omni_CommunicationDispatcher.Message> messages) {
        Set<String> roleIds = new Set<String>();
        for (Omni_CommunicationDispatcher.Message msg : messages) {
            roleIds.add(msg.whatid);
        }
        return roleIds;
    }

    /**
    * @Description merge cases and send unmerge cases to Omni queue
    * @Author      Kejia Hu
    * @Date        31/01/2020                     
    */
    @future
    public static void MergeCaseAsyn(String input, String emailKeySet) {
        Omni_EmailProcessingList eList = (Omni_EmailProcessingList) JSON.deserialize(input, Omni_EmailProcessingList.class);
        eList.mergeCases();
        //get DEA Emails not reparent to Claim/Exposure and invoke ECM for file and attachments processing
        Set<String> emailCaseIdsAfterMerge = EmailMessageTriggerHandlerHelper.getEmailCaseIdsAfterMergeAndInvokeECM(
                                               (Set<String>) JSON.deserialize(emailKeySet, Set<String>.class));
        List<Case> casesToAssign = [SELECT Id, OwnerId FROM Case WHERE Id IN:emailCaseIdsAfterMerge];
        //get Email Case records and send to PKI queue
        if (!emailCaseIdsAfterMerge.isEmpty()) {
            EmailMessageTriggerHandlerHelper.sendCaseToPKIQueue(casesToAssign);
        }
    }

    /**
    * @Description get case Ids which are email case after merge, send the merge emails for ECM processing
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    public static Set<String> getEmailCaseIdsAfterMergeAndInvokeECM(Set<String> emailIds){
        Set<String> ids = new Set<String>();
        List<EmailMessage> emails = Omni_EmailProcessingDAOHandler.getEmailsFromIds(emailIds);
        List<EmailMessage> emailsForECM = new List<EmailMessage>();
        for (EmailMessage email : emails) {
            if (email.Parent.recordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_EMAIL_CASE) {
                ids.add(email.parentId);
            } else {
                emailsForECM.add(email);
            }                                
        }
        excludeNoAttachmentEmails(emailsForECM);
        if (!emailsForECM.isEmpty()) {
            //Invoke ECM process for files and attachments
            ECMDocumentsLinkTriggerHandler.manualTriggerHandler(emailsForECM);
        }
        return ids;
    }

    /**
    * @Description get case record from a case map
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    public static List<Case> getCasesFromId(Set<String> ids, Map<String, Case> caseById) {
        List<Case> cases = new List<Case>();
        for (String aId : ids) {
            cases.add(caseById.get(aId));
        }
        return cases;
    }

    /**
    * @Description assign cases to PKI queue
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    public static void sendCaseToPKIQueue(List<Case> cases) {
        Id omniQueue = Omni_EmailProcessingDAOHandler.QUEUE_BY_NAME.get(Utility.EMAIL_CONFIG_BY_KEY.get('PKIQueueName')).Id;
        for (Case c : cases) {
            c.OwnerId = omniQueue;
        }
        update cases;
    }

    /**
    * @description get DEA matching queue Email Case related incoming emails, email need to have ToAddress or CcAddress
    * @author      Kejia Hu
    * @date        28/01/2020                     
    */
    public static Map<String, EmailMessage> getDEAQueueEmailCaseRelatedIncomingEmails(List<EmailMessage> emails, Map<String, Case> emailCaseById) {
        Map<String, EmailMessage> deaQueueEmailCaseRelatedIncomingEmails = new Map<String, EmailMessage>();
        for (EmailMessage email : emails) {
            Case emailParentCase = emailCaseById.get(email.ParentId);
            if ((!String.isBlank(email.ToAddress)||!String.isBlank(email.CcAddress)) && email.Incoming) {
                deaQueueEmailCaseRelatedIncomingEmails.put(email.Id, email);
            }
        }
        return deaQueueEmailCaseRelatedIncomingEmails;
    }

    /**
    * @description get Claim/Exposure related incoming emails, email need to have ToAddress or CcAddress and from address is Intact domaine
    * @author      Kejia Hu
    * @date        28/01/2020                     
    */
    public static Map<String, EmailMessage> getClaimExposureRelatedIncomingEmailsForIntact(List<EmailMessage> emails, Map<String, Case> claimExposureById) {
        Map<String, EmailMessage> claimExposureRelatedIncomingEmailsForIntact = new Map<String, EmailMessage>();
        for (EmailMessage email : emails) {
            Case emailParentCase = claimExposureById.get(email.ParentId);
            //if ((!String.isBlank(email.ToAddress)||!String.isBlank(email.CcAddress)) && email.Incoming && email.FromAddress.containsIgnoreCase('intact.net')) {
            if ((!String.isBlank(email.ToAddress)||!String.isBlank(email.CcAddress)) && email.Incoming) {
                claimExposureRelatedIncomingEmailsForIntact.put(email.Id, email);
            }
        }
        return claimExposureRelatedIncomingEmailsForIntact;
    }

    /**
    * @description get Email Case related emails
    * @author      Kejia Hu
    * @date        28/01/2020                     
    */
    public static Map<String, EmailMessage> getEmailCaseRelatedEmails(List<EmailMessage> emails, Map<String, Case> caseById) {
        Map<String, EmailMessage> emailCaseRelatedEmails = new Map<String, EmailMessage>();
        for (EmailMessage email : emails) {
            Case emailCase = caseById.get(email.ParentId);
            if (emailCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_EMAIL_CASE
                && hasDEAKeyInHeader(email)) {
                emailCaseRelatedEmails.put(email.Id, email);
            }
        }
        return emailCaseRelatedEmails;
    }

    /**
    * @description check if email has DEA key in header
    * @author      Kejia Hu
    * @date        28/01/2020                     
    */
    public static Boolean hasDEAKeyInHeader(EmailMessage email) {
        return (String.isNotBlank(getDEAValFromEmailHeaders(email)));
    }

    /**
    * @description get DEA value from headers
    * @author      Kejia Hu
    * @date        28/01/2020                     
    */
    public static String getDEAValFromEmailHeaders(EmailMessage email) {
        String valToReturn;
        String deaKey = Utility.EMAIL_CONFIG_BY_KEY.get('DEAAddressKeyInHeader');
        Map<String, String> headerMap = Utility.parseHeaders(email.Headers);
        if (headerMap != null && headerMap.get(deaKey) != null) {
            valToReturn = (headerMap.get(deaKey).contains('<'))
                			? headerMap.get(deaKey).substringAfter('<').substringBefore('>')
                			: headerMap.get(deaKey);
        }
        return (String.isBlank(valToReturn)) 
                ? valToReturn
                : valToReturn.trim();
    }
    
    /**
    * @description get all Role records from a Case map
    * @author      Kejia Hu
    * @date        21/01/2020                     
    */
    public static Map<String, Case> getRoleMapFromCaseMap(Map<String, Case> caseById) {
        Map<String, Case> roleById = new Map<String, Case>();
        for(Case oneCase : caseById.values()) {
            if (oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_ADHOC_ROLE) {
                roleById.put(oneCase.Id, oneCase);
            }
        }
        return roleById;
    }

    /**
    * @description get all Exposure records from a Case map
    * @author      Kejia Hu
    * @date        21/01/2020                     
    */
    public static Map<String, Case> getExpoMapFromCaseMap(Map<String, Case> caseById) {
        Map<String, Case> expoById = new Map<String, Case>();
        for(Case oneCase : caseById.values()) {
            if (oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BI
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE) {
                expoById.put(oneCase.Id, oneCase);
            }
        }
        return expoById;
    }

    /**
    * @description get all Email Case records from a Case map
    * @author      Kejia Hu
    * @date        28/01/2020                     
    */
    public static Map<String, Case> getDEAQueueEmailCaseMapFromCaseMap(Map<String, Case> caseById) {
        Map<String, Case> emailCaseById = new Map<String, Case>();
        for(Case oneCase : caseById.values()) {
            if (oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_EMAIL_CASE
                && oneCase.OwnerId == Omni_EmailProcessingDAOHandler.QUEUE_BY_NAME.get(
                                        Utility.EMAIL_CONFIG_BY_KEY.get('DEAMatchingQueueName')).Id) {
                emailCaseById.put(oneCase.Id, oneCase);
            }
        }
        return emailCaseById;
    }

    /**
    * @description get all claims and exposures records from a Case map
    * @author      Kejia Hu
    * @date        22/04/2020                     
    */
    public static Map<String, Case> getClaimExposureRoleFromCaseMap(Map<String, Case> caseById) {
        Map<String, Case> claimExposureById = new Map<String, Case>();
        for(Case oneCase : caseById.values()) {
            if (oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BI
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE
                || oneCase.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_ADHOC_ROLE) {
                claimExposureById.put(oneCase.Id, oneCase);
            }
        }
        return claimExposureById;
    }

    /**
    * @description get all Case records Ids that related to given EmailMessage records
    *              if related Id is null, then use the parentId
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    public static Set<String> getRelatedCaseIdsFromEmails(List<EmailMessage> emails) {
        Set<String> relatedCaseIds = new Set<String>();
        for(EmailMessage email : emails) {
            if(null != email.RelatedToId && email.RelatedToId.getSobjectType() == Case.SObjectType) {
                relatedCaseIds.add(email.RelatedToId);
            }
            if(null == email.RelatedToId && null != email.ParentId && email.ParentId.getSobjectType() == Case.SObjectType) {
                relatedCaseIds.add(email.ParentId);
            }
        }
        return relatedCaseIds;
    }

    /**
    * @description update EmailMessage records based on Roles
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    public static List<EmailMessage> updateEmailMessageRelationship(List<EmailMessage> emails, Map<String, Case> roleById) {
        for(EmailMessage email : emails) {
            email = (null != email.RelatedToId) 
                        ? updateEmailMessageRelationship(email, roleById.get(email.RelatedToId))
                        : updateEmailMessageRelationship(email, roleById.get(email.ParentId));
        }
        return emails;
    }

    /**
    * @description update EmailMessage record based on Role
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    private static EmailMessage updateEmailMessageRelationship(EmailMessage email, Case role) {
        if (null != role) {
            if (role.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE) {
                email.parentId = role.ClaimForRole__c;
                email.Claim__c = role.ClaimForRole__c;
            } else if (role.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                        || role.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE
                        || role.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_ADHOC_ROLE) {
                email.parentId = role.ExposureForRole__c;
                email.Claim__c = role.ClaimForRole__c;
                email.Exposure__c = role.ExposureForRole__c;
            }
            }
        return email;
    }

    /**
    * @description generate map of role (Case) by record Id from emails
    * @author      Kejia Hu
    * @date        06/04/2020                     
    */
    public static Map<String, Case> generateRoleById(List<EmailMessage> emails, Map<String, Case> roleById) {
        Map<String, Case> roleByIdToReturn = new Map<String, Case>();
        for(EmailMessage email : emails) {
            roleByIdToReturn.put(email.relatedToId, roleById.get(email.relatedToId));
        }
        return roleByIdToReturn;
    }

    /**
    * @description generate map of Exposure (Case) by communication record Id
    * @author      Kejia Hu
    * @date        21/01/2020                     
    */
    public static Map<String, Case> generateExpoByComRecordId(List<EmailMessage> emails, Map<String, Case> expoById) {
        Map<String, Case> expoByComRecordId = new Map<String, Case>();
        for(EmailMessage email : emails) {
            expoByComRecordId.put(email.Id, expoById.get(email.ParentId));
        }
        return expoByComRecordId;
    }

    /**
    * @description generate map of role (Case) by communication record Id
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    public static Map<String, Case> generateRoleByComRecordId(List<EmailMessage> emails, Map<String, Case> roleById) {
        Map<String, Case> roleByComRecordId = new Map<String, Case>();
        for(EmailMessage email : emails) {
            roleByComRecordId.put(email.Id, roleById.get(email.relatedToId));
        }
        return roleByComRecordId;
    }

    /**
    * @description save FeedItems for Exposures only
    * @author      Kejia Hu
    * @date        21/01/2020                     
    */
    public static List<Omni_Feed> saveTextFeedsFromExpos(Map<String, Case> ExpoByRecordId, Map<Id, EmailMessage> caseRelatedEmailMap) {
        List<Omni_Feed> feeds = new List<Omni_Feed>();
        if(!ExpoByRecordId.isEmpty()) {
            for(String recordId: ExpoByRecordId.keySet()) {
                Case exposure = ExpoByRecordId.get(recordId);
                EmailMessage email = caseRelatedEmailMap.get(recordId);
                Omni_Feed feedEmail = new Omni_Feed();
                feedEmail.channel = email.MessageType__c;
                feedEmail.Exposure = Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID.get(exposure.ExposureType__c).Name;
                feedEmail.parentId = exposure.ClaimForExposure__c;
                feedEmail.recordId = recordId;
                feeds.add(feedEmail);
            }
        }
        return feeds;
    }

    /**
    * @description save FeedItems for Exposure Roles only
    * @author      Kejia Hu
    * @date        20/09/2019                     
    */
    public static List<Omni_Feed> saveTextFeedsFromRoles(Map<String, Case> roleByRecordId, Map<Id, EmailMessage> caseRelatedEmailMap) {
        List<Omni_Feed> feeds = new List<Omni_Feed>();
        if(!roleByRecordId.isEmpty()) {
            for(String recordId: roleByRecordId.keySet()) {
                Case role = roleByRecordId.get(recordId);
                EmailMessage email = caseRelatedEmailMap.get(recordId);
                if(role.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                   	|| role.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE) {
                    Omni_Feed feedEmail = new Omni_Feed();
                    feedEmail.channel = email.MessageType__c;
                    feedEmail.Exposure = Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID.get(role.ExposureForRole__r.ExposureType__c).Name;
                    feedEmail.parentId = role.ClaimForRole__c;
                    feedEmail.recordId = recordId;
                    feeds.add(feedEmail);
                }
            }
        }
        return feeds;
    }

    /**
    * @description filter out non case related emailMessage from the map
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    public static Map<Id, EmailMessage> getCaseRelatedEmails(Map<Id, EmailMessage> emailMap) {
        Map<Id, EmailMessage> caseRelatedEmailMap = new Map<Id, EmailMessage>(); 
        for(String key : emailMap.keySet()) {
            EmailMessage email = emailMap.get(key);
            if (null != email.RelatedToId && email.RelatedToId.getSobjectType() == Case.SObjectType) {
                caseRelatedEmailMap.put(key, email);
            }
            if (null == email.RelatedToId && null != email.ParentId && email.ParentId.getSobjectType() == Case.SObjectType) {
                caseRelatedEmailMap.put(key, email);
            }
        }
        return caseRelatedEmailMap;
    }
}