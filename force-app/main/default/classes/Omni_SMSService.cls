/**
 * @Description: Perform webservice callout to webtext which sends sms to customers
 * @author:      Damian Kazior, PwC
 * @Date:        2019-08-24
 */
global with sharing class Omni_SMSService {   

    public List<SMSDataWrapper> smsDataWrappers;
    public List<Id> exposureForRolesIds;
    //retry sms follows different logic since its body is already populated and does not reed a role
    public Boolean isRetry = false;

    public static final String RECORD_TYPE_ID_AUTOMATIC_NOTIFICATION = Schema.SObjectType.LiveMessage__c.getRecordTypeInfosByDeveloperName().get(
                                                                    'Automatic_Notification').getRecordTypeId();

    public Omni_SMSService(){
        smsDataWrappers = new List<SMSDataWrapper>();
        exposureForRolesIds = new List<Id>();
    }  
    
    /**
    * @Description: Make HTTPS request to webtext 
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-24
    */
    public void sendSMS(Map<String, Account> accountIdToAccount, Map<Omni_CommunicationDispatcher.RoleWithLog, Map<Communication_Configuration__c, List<String>>> toSendSMSCaseWithConfig) {
        if(!toSendSMSCaseWithConfig.isEmpty()){
            prepareSmsWrapper(toSendSMSCaseWithConfig);
            updateExposureForRole();
            findAccountForCaseAndExtractPhoneNumber(toSendSMSCaseWithConfig.keyset(), accountIdToAccount); 
            prepareLiveMessageRecords();
            createPlatformEventRecords(); 
        }
    }   

    private void prepareSmsWrapper(Map<Omni_CommunicationDispatcher.RoleWithLog, Map<Communication_Configuration__c, List<String>>> toSendSMSCaseWithConfig){
        for(Omni_CommunicationDispatcher.RoleWithLog roleWithLog : toSendSMSCaseWithConfig.keyset()){
            createSmSWrapperAndMergeTemplates(toSendSMSCaseWithConfig.get(roleWithLog), roleWithLog.role, roleWithLog.log.Id);
        } 
    }

    /**
    * @Description: Map account to cases and extract phone number for each case
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-19
    */
    private void findAccountForCaseAndExtractPhoneNumber(Set<Omni_CommunicationDispatcher.RoleWithLog> rolesWithLogs, Map<String, Account> accountIdToAccount) {
        for(Omni_CommunicationDispatcher.RoleWithLog roleWithLog : rolesWithLogs){
            assignPhoneNumberToSmsData(roleWithLog.role, accountIdToAccount.get(roleWithLog.role.PartyAccount__c));
        }
    }   

    /**
    * @Description: Update smsDataWrapper with phone number from associated account
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-19
    */
    private void assignPhoneNumberToSmsData(Case cas, Account acc) {
        for(SMSDataWrapper smsData : this.smsDataWrappers){
            if(smsData.cas.Id == cas.Id){
                //person account has first name. Business account has Name only
                if(acc.FirstName == null){
                    smsData.recipientName = acc.Name;
                }else{
                    smsData.recipientName = acc.FirstName + ' ' + acc.LastName;
                }
                smsData.phoneNumber = acc.Phone;
            }
        } 
    }   

    /**
    * @Description: Create wrapper records for each role. Merge sms templates
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-24 
    */
    private void createSmSWrapperAndMergeTemplates(Map<Communication_Configuration__c, List<String>> communicationConfigs, Case cas, String integrationLogId) { 
        for(Communication_Configuration__c communicationConfig : communicationConfigs.keyset()){            
           // List<Messaging.RenderEmailTemplateBodyResult> smsTemplateBody = Messaging.renderEmailTemplate(cas.PartyAccount__c, cas.Id, new List<String>(communicationConfigs.get(communicationConfig)));
     
            for(String smsTemplate : communicationConfigs.get(communicationConfig)){
                SMSDataWrapper smsWrapper = new SMSDataWrapper();
                smsWrapper.cas = cas;
                smsWrapper.parentIntegrationLogId = integrationLogId;
                if(cas.ExposureForRole__c != null){
                    exposureForRolesIds.add(cas.ExposureForRole__c);
                }
                smsWrapper.smsTemplate = smsTemplate;
                smsWrapper.communicationConfig = communicationConfig;
                this.smsDataWrappers.add(smsWrapper); 
            }    
        } 
    }

    /**
    * @Description: Assign exposures to each role
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-24 
    */
    private void updateExposureForRole(){
        Map<Id, Case> exposuresForRole = Omni_CaseSelector.getCaseById(exposureForRolesIds);
        for(SMSDataWrapper smsData : smsDataWrappers){
            if(smsData.cas.ExposureForRole__c != null){
                smsData.exposureForRole = exposuresForRole.get(smsData.cas.ExposureForRole__c);
            }
        }
    }
    /** 
    * @Description: Make HTTPS request to webtext
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-24 
    */
    public void sendSMSMessages(){
        for(SMSDataWrapper smsData : this.smsDataWrappers){ 
            try{
                Id jobID = System.enqueueJob(new Omni_SMSServiceAsync(smsData.liveMessage, smsData.parentIntegrationLogId, isRetry));   
            }catch (Exception e) {
                ApplicationLogHandler.saveExceptionLog('Omni_SMSService', e, null);
            }
        }
    } 

    /**
    * @description Merge raw sms templates with case information and create live message records
    * @author      Damian Kazior, PwC
    * @date        2019-09-18                 
    */
    private void prepareLiveMessageRecords() {
       List<LiveMessage__c> livemessages = new List<LiveMessage__c>();
        for(SMSDataWrapper smsData : this.smsDataWrappers){

            smsData.liveMessage = new LiveMessage__c(
            Case__c                         = smsData.cas.Id,  
            Message_Text__c                 = smsData.smsTemplate,
            Phone_Number__c                 = smsData.phoneNumber,
            Recipient_Name__c               = smsData.recipientName,
            Exposure_For_Role__c            = smsData.exposureForRole == null ? null : smsData.exposureForRole.Id,
            Claim_For_Role__c               = smsData.cas.ClaimForRole__c,
            Exposure_Type_Id__c             = smsData.exposureForRole == null ? null : smsData.exposureForRole.ExposureType__c,
            Communication_Configuration__c  = smsData.communicationConfig.Id,
            Parent_Integration_Log__c       = smsData.parentIntegrationLogId,
            Status__c                       = Omni_SMSConstant.SMS_STATUS_CREATED,
            RecordTypeId                    = RECORD_TYPE_ID_AUTOMATIC_NOTIFICATION
            );
            livemessages.add(smsData.liveMessage);
        }
        insert livemessages;
    }


    private void createPlatformEventRecords() { 
       List<SMS_Event__e> platformEvents = new List<SMS_Event__e>();
        for(SMSDataWrapper smsData : this.smsDataWrappers){
            platformEvents.add(new SMS_Event__e(
                Live_Message_Id__c = smsData.liveMessage.Id
            ));
        }
        List<Database.SaveResult> results = EventBus.publish(platformEvents);
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    ApplicationLogHandler.saveExceptionLog('SMS Platform Event Invocation'+err.getMessage(), null, null);
                }}
        }
    }

    /**
    * @description Wrapper class to store data for one SMS payload. This sms payload might potenitally be broken down 
                   into multiple messages if it's length is too large. 
    * @author      Damian Kazior, PwC
    * @date        2019-09-18                 
    */
    public class SMSDataWrapper{
        public Boolean isMergeSucessfull;
        public String parentIntegrationLogId;
        public Case cas;
        public LiveMessage__c liveMessage;
        public String smsTemplate;
        public String phoneNumber;
        public String recipientName;
        public Case exposureForRole;

        public Communication_Configuration__c communicationConfig;
    }

}