/**
* @description Test class for Omni_MessagingSessionFeedConstructor
* @author      Damian Kazior
* @date        29/01/2020                     
*/ 
@isTest
public with sharing class Omni_MessagingSessionFeedConstructorTest {

    @TestSetup
    private static void prepareData(){
        MessagingEndUser msgUser1 = TestDataFactory.createMessagingEndUser(true); 
        MessagingEndUser msgUser2 = TestDataFactory.createMessagingEndUser(true); 
        MessagingSession msgSessionForClaim = TestDataFactory.createMessagingSessionForEndUser(msgUser1, false);
        msgSessionForClaim.Status = 'Ended';
        MessagingSession msgSessionForExposure = TestDataFactory.createMessagingSessionForEndUser(msgUser2, false);
        msgSessionForExposure.Status = 'Ended';
        Case claim = TestDataFactory.createClaim();
        Case exposure = TestDataFactory.createOtherExposures(1)[0];
        exposure.RecordtypeId=Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPOSURE_BODILY_INJURY;
        update exposure;
        msgSessionForClaim.CaseId = claim.Id;
        msgSessionForExposure.CaseId = exposure.Id;
        insert msgSessionForClaim;
        insert msgSessionForExposure;
        //create conversations
        TestDataFactory.createConversationEntriesForMessagingSession(msgSessionForClaim, TestDataFactory.TEST_SIZE_SMALL);
        TestDataFactory.createConversationEntriesForMessagingSession(msgSessionForExposure, TestDataFactory.TEST_SIZE_SMALL);
    }


    @isTest
    private static void Omni_MessagingSessionFeedConstructorSuccess(){
        
        Test.startTest();
        Omni_MessagingSessionFeedConstructor smessagingSessions = new Omni_MessagingSessionFeedConstructor();   
        DataBase.executeBatch(smessagingSessions);
        Test.stopTest();
        List<LiveMessage__c> msgSessions = [SELECT Id FROM LiveMessage__c];
        System.assertEquals(2, msgSessions.size(), 'There should be two Livemessage records');
    }
    

}