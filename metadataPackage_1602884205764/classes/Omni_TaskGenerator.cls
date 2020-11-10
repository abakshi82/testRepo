/**
* @Description: Class that generates tasks for adjustors and associates them with appropiate records
* @Author:      Damian Kazior, PwC
* @Date:        06/01/2020
*/
public without sharing class Omni_TaskGenerator {

    //Emails
    public static FINAL String TASK_NEW_PIORITY                 = 'High';
    public static FINAL String TASK_NEW_STATUS                  = 'Open';
    public static FINAL String TASK_NEW_SUBJECT                 = 'New Email/Tâche Courriel'; 

    //Surveys
    public static FINAL String PULSE_GOOD_SCORE                 = 'green'; 
    public static FINAL String PULSE_BAD_SCORE                  = 'red';

    //Record types 
    public static final String RECORD_TYPE_ID_SURVEY = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(
                                                                'Survey').getRecordTypeId();
    public static final String RECORD_TYPE_ID_EMAIL = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(
                                                                'Email').getRecordTypeId();
    public static Group pkiQueue;

    public static Map<String, String> queueNameToId;
    /**
    * @Description: 
    * @Author:      Damian Kazior, PwC
    * @Date:        06/01/2020
    */
    public static void createTaskForPulseSurveyResult(List<Pulse_Survey_Result__c> surveyResults){  
         
        List<Task> tasks = new List<Task>();
        try{
            Set<Id> surveyResultIds = new Set<Id>();
            for(Pulse_Survey_Result__c surveyResult : surveyResults){
                surveyResultIds.add(surveyResult.Id);
            }
            List<Pulse_Survey_Result__c> pulseSurveys = [SELECT Id, Case__r.OwnerId, Case__r.CaseNumber, Case__r.AssignedUserId__c, Score__c, Comments__c 
                                                        FROM Pulse_Survey_Result__c 
                                                        WHERE Id IN:surveyResultIds];
      
            Set<Id> surveyOwnerIds = new Set<Id>();
            for(Pulse_Survey_Result__c survey : pulseSurveys){
                surveyOwnerIds.add(survey.Case__r.OwnerId);
            }
            Map<Id, User> userDetails = new Map<Id, User>([
                                        SELECT Street, City, PostalCode, Title_1_FR__c ,Title_2_FR__c ,CompanyName ,Email ,Fax, 
                                                Name, Phone, State, Title_1__c, Title_2__c, Delegated_User__c, IsActive, Delegated_User__r.IsActive
                                        FROM User 
                                        WHERE Id IN:surveyOwnerIds]);

            getQueueNames();
            for(Pulse_Survey_Result__c surveyResult : pulseSurveys){
                if(surveyResult.Score__c != PULSE_GOOD_SCORE){
                    tasks.add(createSurveyTask(surveyResult, userDetails.get(surveyResult.Case__r.OwnerId)));
                }
            }
            if(!tasks.isEmpty()){
                insert tasks;
            }
        }catch(Exception e){
            System.debug('e::'+e);
            ApplicationLogHandler.saveExceptionLog('Omni_TaskGenerator', e , null); 
        }
    }

    /**
    * @Description: Once DEA email is matched and merged into master case, create task for master case owner
    * @Author:      Damian Kazior, PwC
    * @Date:        06/01/2020
    */
    public static void createTaskForMatchedDEAEmail(List<Omni_EmailProcessingEntity> emailMessageEntites){
        List<Task> tasks = new List<Task>();
        //grap case owner info
        Set<Id> caseOwnerIds = new Set<Id>();
        for(Omni_EmailProcessingEntity emailEntity : emailMessageEntites){
            caseOwnerIds.add(emailEntity.masterCase.OwnerId);
        }
        try{
            Map<Id, User> userDetails = Omni_UserSelector.getUserDetailsById(caseOwnerIds);
            getQueueNames();

            for(Omni_EmailProcessingEntity emailEntity : emailMessageEntites){
                for(EmailMessage emailMsg : emailEntity.emailByCaseId.values()){
                    if(isParentCaseValidForTask(emailEntity.masterCase)){
                        tasks.add(createEmailTask(emailEntity.masterCase, emailMsg, userDetails.get(emailEntity.masterCase.OwnerId), true));
                    }
                }
            }
            System.debug('tasks::'+tasks);
            if(!tasks.isEmpty()){
                insert tasks;
            }
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_TaskGenerator', e , null); 
        }
    }

    public static void createTaskForMatchedDEAEmail(Case masterCase, List<EmailMessage> emailMessages){
        List<Task> tasks = new List<Task>();
        Set<Id> caseId = new Set<Id>();
        caseId.add(masterCase.Id);
        Case cas = Omni_CaseSelector.getCasesByIds(caseId).values()[0];
        try{
            Map<Id, User> userDetails = Omni_UserSelector.getUserDetailsById(new Set<Id>{cas.OwnerId});
            getQueueNames();

            if(isParentCaseValidForTask(cas)){
                for(EmailMessage emailMessage : emailMessages){
                    tasks.add(createEmailTask(cas, emailMessage, userDetails.get(cas.OwnerId), true));
                }
            }

            if(!tasks.isEmpty()){
                insert tasks;
            }
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_TaskGenerator', e , null); 
        }
    }


    /**
    * @Description: Any matched incoming email (email-to-case) must create a task for adjustor
    * @Author:      Damian Kazior, PwC
    * @Date:        06/01/2020
    */
    public static void createTaskForMatchedIncomingEmail(List<EmailMessage> emailMessages){
        try{
            if(isInbound(emailMessages)){
                Map<Id, Id> emailMessageIdToCaseId = getEmailMessageIdToCaseId(emailMessages);
                List<Task> tasks = new List<Task>();
                Map<Id, Case> cases = Omni_CaseSelector.getCasesByIds(new Set<Id>(emailMessageIdToCaseId.values()));  
                Map<Id, Case> emailMessageIdToCase = new Map<Id, Case>();
                for(Id emailId : emailMessageIdToCaseId.keyset()){
                    emailMessageIdToCase.put(emailId, cases.get(emailMessageIdToCaseId.get(emailId)));
                }
                //grab case owner info
                Set<Id> caseOwnerIds = new Set<Id>();
                for(Case cas : cases.values()){
                    caseOwnerIds.add(cas.OwnerId);
                }
                Map<Id, User> userDetails = Omni_UserSelector.getUserDetailsById(caseOwnerIds);
                getQueueNames();

                //create tasks assigned to the same user as email message's case
                for(EmailMessage emailMsg: emailMessages){
                    if(emailMsg.Incoming && isParentCaseValidForTask(emailMessageIdToCase.get(emailMsg.Id))){
                        tasks.add(createEmailTask(emailMessageIdToCase.get(emailMsg.Id), emailMsg, userDetails.get(emailMessageIdToCase.get(emailMsg.Id).OwnerId), false));
                    }
                }
                
                if(!tasks.isEmpty()){
                    System.debug('tasks::'+tasks[0].Claimant_Name__c);
                    insert tasks;
                }
            }
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_TaskGenerator', e , null); 
        }   
    }

    /**
    * @Description: Return true if at least one of the messages is inbound
    * @Author:      Damian Kazior, PwC
    * @Date:        06/01/2020
    */
    private static Boolean isInbound(List<EmailMessage> emailMessages){
        for(EmailMessage emailMessage : emailMessages){
            if(emailMessage.Incoming){
                return true;
            }
        }
        return false;
    }

    private static Map<Id, Id> getEmailMessageIdToCaseId(List<EmailMessage> emails) {
        Map<Id, Id> relatedCaseIds = new Map<Id, Id>();
        for(EmailMessage email : emails) {
            if(null != email.RelatedToId && email.RelatedToId.getSobjectType() == Case.SObjectType) {
                relatedCaseIds.put(email.Id, email.RelatedToId);
            }
            if(null == email.RelatedToId && null != email.ParentId && email.ParentId.getSobjectType() == Case.SObjectType) {
                relatedCaseIds.put(email.Id, email.ParentId);
            }
        }
        return relatedCaseIds;
    }

    private static boolean isParentCaseValidForTask(Case cas){
        if(cas != null){
            return ((cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM ||
                 cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPOSURE_BENEFITS ||
                 cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPOSURE_BODILY_INJURY ||
                 cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_OTH_EXPOSURE));
        }
        return false;
        
    }

    /**
    * @Description: Each incoming email matched to an adjustor creates a task
    * @Author:      Damian Kazior, PwC
    * @Date:        06/01/2020
    */
    private static Task createEmailTask(Case cas, EmailMessage emailMsg, User caseOwner, boolean isDeaTask){
        String taskOwner = getTaskOwner(caseOwner, cas);
        Boolean isOwnerAUser = taskOwner.startsWith('005');
        return 
            new Task(description            = Label.Omni_Task_EmailTaskDescription + ' ' + cas.ClaimNumber__c,
                    EmailMessage_Id__c      = emailMsg.Id,
                    priority                = TASK_NEW_PIORITY,
                    status                  = TASK_NEW_STATUS,
                    subject                 = isOwnerAUser ? TASK_NEW_SUBJECT : 'Unassigned Email Task / Tâche courriel non assignée',
                    ActivityDate            = Date.today(),
                    IsReminderSet           = false,
					reminderDateTime        = DateTime.now(),
                    OwnerId                 = taskOwner,
                    //only assign whatid if owner is an active user
                    whatId                  = isOwnerAUser ? cas.Id : null,
                    RecordTypeId            = RECORD_TYPE_ID_EMAIL,
                    Claim_Number__c         = cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM ? cas.ClaimNumber__c : cas.ClaimForExposure__r.ClaimNumber__c,
                    Claimant_Name__c        = String.isBlank(cas.Claimant__r.Name) ? '' : cas.Claimant__r.Name,
                    Email_Subject__c        = String.isBlank(emailMsg.Subject) ? '' : emailMsg.Subject.left(254),
                    Exposure_Type__c        = cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM ? null : cas.ExposureType__r.L_EN_CA__c + ' ' + cas.ExposureType__r.L_FR_CA__c,
                    Insured_Name__c         = getInsuredName(cas),
                    LanID__c                = cas.AssignedUserId__c,
                    LOB__c                  = cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM ? cas.Claim_LOB__c : cas.ClaimForExposure__r.Claim_LOB__c,
                    Province_of_Issuance__c = cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM ? cas.ProvinceOfIssuance__r.TypeCode__c : cas.ClaimForExposure__r.ProvinceOfIssuance__r.TypeCode__c
                );
    }

    private static String getInsuredName(Case cas){
        if(cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM){
            if(String.isBlank(cas.InsuredParty__r.Name)){
                return '';
            }else{
                return cas.InsuredParty__r.Name;
            }
        }else{
            if(String.isBlank(cas.ClaimForExposure__r.InsuredParty__r.Name)){
                return '';
            }else{
                return cas.ClaimForExposure__r.InsuredParty__r.Name;
            }
        }
    }

    private static Id getTaskOwner(User caseOwner, Case relatedCase){
        //owner is a queue or error
        if(caseOwner == null){
            return getQueueIdForCase(relatedCase);
        //owner is an inactive user
        }else if(!caseOwner.IsActive){
            return getQueueIdForCase(relatedCase);
        //owner is an active user that does not have a delegated user
        }else if(String.isBlank(caseOwner.Delegated_User__c)){
            return caseOwner.Id;
        }else{
            //delegated user is incative
            if(!caseOwner.Delegated_User__r.IsActive){
                return getQueueIdForCase(relatedCase);
            //delegated user is active
            }else{
                return caseOwner.Delegated_User__c;    
            }   
        }
    }

    private static Id getQueueIdForCase(Case relatedCase){
        if(relatedCase.AssignedUserId__c == null){
            return queueNameToId.get('Intact_PKI');
        }else if(String.isEmpty(relatedCase.AssignedUserId__c)){
            return queueNameToId.get('Intact_PKI');
        }else{
            if(SALVAGE_LAN_ID_TO_QUEUE.containsKey(relatedCase.AssignedUserId__c)){
                return queueNameToId.get(SALVAGE_LAN_ID_TO_QUEUE.get(relatedCase.AssignedUserId__c));
            }else{
                return queueNameToId.get('Intact_PKI');
            }
        }
    }

    private static Task createSurveyTask(Pulse_Survey_Result__c pulseSurvey, User surveyOwner){
        String taskOwner = getTaskOwner(surveyOwner, pulseSurvey.Case__r);
        Boolean isOwnerAUser = taskOwner.startsWith('005');
        return 
            new Task(description        = Label.Omni_Task_SurveyTaskDescription + '\n Score: ' + pulseSurvey.Score__c + ' Case Number: '+ pulseSurvey.Case__r.CaseNumber, 
                    priority            = TASK_NEW_PIORITY,
                    status              = TASK_NEW_STATUS,
                    subject             = Label.Omni_Task_EmailTaskDescription,
                    IsReminderSet       = false,
					reminderDateTime    = DateTime.now(),
                    ActivityDate        = Date.today(),
                    OwnerId             = taskOwner,
                    whatId              = isOwnerAUser ? pulseSurvey.Id : null,
                    RecordTypeId        = RECORD_TYPE_ID_SURVEY
                );
    }


    public static final Map<String, String> SALVAGE_LAN_ID_TO_QUEUE {
        get {
            if(null == SALVAGE_LAN_ID_TO_QUEUE) {
                SALVAGE_LAN_ID_TO_QUEUE = new Map<String, String>(); 
                Salvage_Queues_Assignment__mdt[] elementsForMappings = [
                    SELECT Lan_ID__c, Queue_API_Name__c FROM Salvage_Queues_Assignment__mdt];
                for(Salvage_Queues_Assignment__mdt element : elementsForMappings) {
                    SALVAGE_LAN_ID_TO_QUEUE.put(element.Lan_ID__c, element.Queue_API_Name__c);
                }
            }
            return SALVAGE_LAN_ID_TO_QUEUE;
        }
        set;
    }

    private static void getQueueNames(){
        List<String> queueNames = new List<String>();
        queueNames.add('Intact_PKI');
        for(String queueName : SALVAGE_LAN_ID_TO_QUEUE.values()){
            queueNames.add(queueName);
        }
        List<Group> queues = [SELECT Id, DeveloperName FROM GROUP WHERE Type = 'Queue' and DeveloperName IN : queueNames];
        queueNameToId = new Map<String, String>();
        for(Group gr : queues){
            queueNameToId.put(gr.DeveloperName, gr.Id);
        }
    }

}