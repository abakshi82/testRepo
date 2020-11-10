/**
* @description Test class for Omni_SMSServiceAsync
* @author      Damian Kazior
* @date        29/08/2019                     
*/ 
@isTest
private class Omni_SMSServiceAsyncTest {

    static List<LiveMessage__c> liveMessages; 
    static String parentLogId;

    @isTest
    private static void prepareSmsData(){
     
        List<Case> roles = TestDataFactory.createCases(1, false);
        List<Account> accounts = TestDataFactory.createPersonAccounts(1, true);
        List<Case> roleCases = TestDataFactory.createCases(1, false);
        for(Integer k =0; k<roleCases.size(); k++){
            roleCases[k].PartyAccount__c = accounts[k].Id;  
        }
        insert roleCases;

        for(Integer k =0; k<roles.size(); k++){
            roles[k].PartyAccount__c = accounts[k].Id;  
            roles[k].ClaimForRole__c = roleCases[k].Id;
        }
        insert roles; 

        for(Case role : roles){
            liveMessages = TestDataFactory.createLiveMessages(1, false, role);
        }
        insert liveMessages;
        Application_Log__c aplog = TestDataFactory.createApplicationLogs(1, true)[0];
        parentLogId = aplog.Id;
   }

   @isTest
    static void sendSMSMessagePositive(){ 
  
       prepareSmsData();

       System.Test.setMock(HttpCalloutMock.class, new Omni_WebserviceCalloutMock(
                           200, 'Success', true, Omni_SMSConstant.WEBTEXT_SUCCESS_JSON));
       System.Test.startTest();
       List<Id> liveMessageIds = new List<Id>();
       for(LiveMessage__c liveMessage : liveMessages){
           Id jobID = System.enqueueJob(new Omni_SMSServiceAsync(liveMessage, parentLogId, false));
           liveMessageIds.add(liveMessage.Id);
       }
       System.Test.stopTest();

       List<LiveMessage__c> updatedLiveMessages = [SELECT Id, Status__c
                                                   FROM LiveMessage__c
                                                   WHERE Id IN:liveMessageIds];
       for(LiveMessage__c updatedLiveMessage : updatedLiveMessages){
           System.assertEquals(Omni_SMSConstant.SMS_STATUS_SUBMITTED, updatedLiveMessage.Status__c, 'SMS should be sent sucessfully');
       }

       List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE Type =: Omni_ClaimNotificationConstant.COMM_FEED_TYPE];
       System.assertEquals(liveMessageIds.size(), feedItems.size(), 'There should be the same amount of FeedItems created as liveMessages');                                            
    } 

    @isTest
    static void sendSMSMessageNegative(){ 

           prepareSmsData();

        System.Test.setMock(HttpCalloutMock.class, new Omni_WebserviceCalloutMock(
                            401, 'Fail', true, Omni_SMSConstant.WEBTEXT_FAIL_JSON));
        System.Test.startTest();
        List<Id> liveMessageIds = new List<Id>();
        for(LiveMessage__c liveMessage : liveMessages){
            Id jobID = System.enqueueJob(new Omni_SMSServiceAsync(liveMessage, parentLogId, false));
            liveMessageIds.add(liveMessage.Id);
        }
        System.Test.stopTest();
        List<LiveMessage__c> updatedLiveMessages = [SELECT Id, Status__c
                                                    FROM LiveMessage__c
                                                    WHERE Id IN:liveMessageIds]; 
        for(LiveMessage__c updatedLiveMessage : updatedLiveMessages){
            System.assertEquals(Omni_SMSConstant.SMS_STATUS_FAILED, updatedLiveMessage.Status__c, 'SMS should fail');
        }      
        List<Application_Log__c> integrationAppLogs = [SELECT Id, Application_Name__c
                                                       FROM Application_Log__c
                                                       WHERE Application_Name__c = : Omni_SMSConstant.SMS_APPLICATION_NAME
                                                       AND Category__c = :Omni_SMSConstant.SMS_EVENT_CATEGROY_INTEGRATION];
        System.assertEquals(liveMessages.size(), integrationAppLogs.size(), 'Every message should create an integration log');

        List<Application_Log__c> failureAppLogs = [SELECT Id, Application_Name__c
                                                       FROM Application_Log__c
                                                       WHERE Application_Name__c = : Omni_SMSConstant.SMS_APPLICATION_NAME
                                                       AND Category__c = :Omni_SMSConstant.SMS_EVENT_CATEGROY_EXCEPTION];

        System.assertEquals(liveMessages.size(), failureAppLogs.size(), 'Every message should create an error log');         
    } 

    @isTest
    static void preprocessMessageBodyPositive(){
        
       prepareSmsData();
       Omni_SMSServiceAsync smsServiceAsync = new Omni_SMSServiceAsync(liveMessages[0], parentLogId, false);
       String longMessageTriple = TestDataFactory.generateRandomStringWithSpaces(2*Omni_SMSConstant.MAX_TEXT_LENGTH+1, 8);
       List<String> messages = smsServiceAsync.preprocessMessageBody(longMessageTriple);
       System.assertEquals(3, messages.size(), 'Message body should be split into three messages');

       String longMessageSingle = TestDataFactory.generateRandomStringWithSpaces(Omni_SMSConstant.MAX_TEXT_LENGTH, 6);
       messages = smsServiceAsync.preprocessMessageBody(longMessageSingle);
       System.assertEquals(1, messages.size(), 'One message should be created'); 
    }
}