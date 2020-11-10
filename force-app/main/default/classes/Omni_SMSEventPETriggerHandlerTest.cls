/**
* @description Test class for Omni_SMSEventPETriggerHandler
* @author      Damian Kazior
* @date        05/11/2019                     
*/ 
@isTest
public with sharing class Omni_SMSEventPETriggerHandlerTest {

    static List<Id> liveMessageIds; 
    static FINAL Integer NUMBER_OF_COMM_CONTACTS = TestDataFactory.TEST_SIZE_LARGE * TestDataFactory.TEST_SIZE_LARGE;

    @isTest
    private static void prepareSMSEventData(){  
        List<Case> roles = TestDataFactory.createCases(NUMBER_OF_COMM_CONTACTS, false);
        
        List<Account> accounts = TestDataFactory.createPersonAccounts(NUMBER_OF_COMM_CONTACTS, true);
        List<Case> roleCases = TestDataFactory.createCases(NUMBER_OF_COMM_CONTACTS, false);
        for(Integer k =0; k<roleCases.size(); k++){
            roleCases[k].PartyAccount__c = accounts[k].Id;  
        }
        insert roleCases; 

        for(Integer k=0; k<roles.size(); k++){ 
            roles[k].PartyAccount__c = accounts[k].Id;   
            roles[k].ClaimForRole__c = roleCases[k].Id;
        }
        insert roles;
        List<LiveMessage__c> liveMessages = new List<LiveMessage__c>();  
        for(Case role : roles){
            liveMessages.add(TestDataFactory.createLiveMessages(1, false, role)[0]);
        }
        insert liveMessages;
        liveMessageIds = new List<Id>(); 
        for(LiveMessage__c liveMessage : liveMessages){
            liveMessageIds.add(liveMessage.Id);
        }

    }

    @isTest 
    static void handleAfterInsertPositive(){
        Test.startTest();
        prepareSMSEventData();
        List<SMS_Event__e> platformEvents = new List<SMS_Event__e>();
        for(Id liveMessageId : liveMessageIds){
            platformEvents.add(new SMS_Event__e(
                Live_Message_Id__c = liveMessageId
            ));
        } 
        System.Test.setMock(HttpCalloutMock.class, new Omni_WebserviceCalloutMock(
                           200, 'Success', true, Omni_SMSConstant.WEBTEXT_SUCCESS_JSON));
        
        List<Database.SaveResult> results = EventBus.publish(platformEvents);
        
        Integer processedEvents = 0;
        //process all events on the bus. Calling Test.getEventBus().deliver() forces outstanding events to be retried
        while(processedEvents<NUMBER_OF_COMM_CONTACTS){
            Test.getEventBus().deliver();
            processedEvents+=Omni_SMSConstant.MAX_NUMBER_EVENTS_PER_PAYLOAD;
        }
        Test.stopTest();
        List<Application_Log__c> applicationLogs = [SELECT Id 
                                                    FROM Application_Log__c 
                                                    WHERE Application_Name__c =:Omni_SMSConstant.SMS_APPLICATION_NAME 
                                                    AND Category__c = :Omni_SMSConstant.SMS_EVENT_CATEGROY_INTEGRATION];
        System.assertEquals(NUMBER_OF_COMM_CONTACTS, applicationLogs.size(), 'there should be 100 integration logs');                                   
    }

    @isTest
    static void coverageMethods(){
        Test.startTest();
        Omni_SMSEventPETriggerHandler handler = new Omni_SMSEventPETriggerHandler();
        handler.handleBeforeDelete(null);
        handler.handleBeforeUpdate(null, null);
        handler.handleAfterUpdate(null, null);
        handler.handleAfterUndelete(null);
        handler.handleAfterDelete(null);
        handler.handleBeforeInsert(null);
        Test.stopTest();
        System.assertEquals('SMS_Event__e', handler.getObjectAPIName(),'Object name should be ContentVersion');
    }
}