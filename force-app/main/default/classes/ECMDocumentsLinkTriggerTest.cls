@isTest
private class ECMDocumentsLinkTriggerTest {

    @isTest
    static void testManualTriggerHandler() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createClaimRole();
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        EmailMessage email = new EmailMessage();
        email.relatedToId = role.Id;
        email.headers = 'Return-Path:returnpath@intact.net\\\nReceived:Received from [1.1.1.1]\\\nMessage-ID:<message-id=0000>';
        email.htmlBody = 'test';
        email.subject = 'test';
        email.ToAddress = 'toaddress@intact.net';
        insert email;
        TestDataFactory_ECM.createContentDocumentLink(email.Id);
        Test.startTest();
        ECMDocumentsLinkTriggerHandler.manualTriggerHandler(new List<EmailMessage>{email});
        Test.stopTest();
        System.assertEquals(true, [SELECT Id FROM File_MetaData__c].size() > 0, 'File metadata should be created!');
    }
    
    @isTest
    static void coverMethods() {
        Test.startTest();
        ECMDocumentsLinkTriggerHandler handler = new ECMDocumentsLinkTriggerHandler();
        handler.handleBeforeDelete(null);
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('ContentDocumentLink', handler.getObjectAPIName(),'Object name should be ContentDocumentLink');
    }
}