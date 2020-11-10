@isTest
private class EmailMessageTriggerTest {

    @isTest
    static void testDeleteEmail() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createClaimRole();
        String threadId = 'ref:_00D4m8cEG._5004m11Xbg:ref';
        Case exposure = TestDataFactory.createOtherExposures(numToInsert)[0];
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        Case claim = [SELECT Id, DEA_Email__c FROM Case WHERE Id = :role.ClaimForRole__c];
        EmailMessage email = new EmailMessage();
        email.RelatedToId = exposure.Id;
        email.ParentId = exposure.Id;
        email.HtmlBody = 'test' + threadId;
        email.TextBody = 'test' + threadId;
        email.Subject = 'test';
        email.ToAddress = claim.DEA_Email__c;
        email.FromAddress = 'test@intact.net';
        email.Incoming = true;
        insert email;
        Test.startTest();
        String errorMessage;
        try {
            delete email;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, [SELECT Id, ParentId From EmailMessage WHERE Id = :email.Id].size()>0, 'Email should not be deleted');
        System.assertEquals(true, errorMessage.contains(System.Label.Omni_EmailDeleteNotAllowed), 'Error message should display');
    }

    @isTest
    static void testDEAMatchingIntactToIntact() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createClaimRole();
        String threadId = 'ref:_00D4m8cEG._5004m11Xbg:ref';
        Case exposure = TestDataFactory.createOtherExposures(numToInsert)[0];
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        Case claim = [SELECT Id, DEA_Email__c FROM Case WHERE Id = :role.ClaimForRole__c];
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.RelatedToId = exposure.Id;
        email.ParentId = exposure.Id;
        email.HtmlBody = 'test' + threadId;
        email.TextBody = 'test' + threadId;
        email.Subject = 'test';
        email.ToAddress = claim.DEA_Email__c;
        email.FromAddress = 'test@intact.net';
        email.Incoming = true;
        insert email;
        Test.stopTest();
        System.assertEquals(false, [SELECT Id, ParentId, TextBody From EmailMessage WHERE Id = :email.Id].TextBody.contains(threadId), 'Thread Id in email body should be removed');
    }

    @isTest
    static void testNewEmailMessageForClaimRole() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createClaimRole();
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.relatedToId = role.Id;
        email.headers = 'Return-Path:returnpath@intact.net\\\nReceived:Received from [1.1.1.1]\\\nMessage-ID:<message-id=0000>';
        email.htmlBody = 'test';
        email.subject = 'test';
        email.ToAddress = 'toaddress@intact.net';
        insert email;
        Test.stopTest();
        System.assertEquals(false, [SELECT Id From EmailMessage].isEmpty(), 'EmailMessage should exist after email created');
    }

    @isTest
    static void testNewEmailMessageForExposureRole() {
        Integer numToInsert = 1;
        TestDataFactory.createExposureStatus();
        TestDataFactory.createContactTypeRole();
        TestDataFactory.createPolicyIssuingGroup();
        Case exposure = TestDataFactory.createOtherExposures(1)[0];
        Case role = TestDataFactory.createExposureRole(exposure);
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.relatedToId = role.Id;
        email.headers = 'Return-Path:returnpath@intact.net\\\nReceived:Received from [1.1.1.1]\\\nMessage-ID:<message-id=0000>';
        email.htmlBody = 'test';
        email.subject = 'test';
        email.ToAddress = 'toaddress@intact.net';
        insert email;
        Test.stopTest();
        System.assertEquals(false, [SELECT Id From EmailMessage].isEmpty(), 'EmailMessage should exist after email created');
    }

    @isTest
    static void testNewEmailMessageForShadowRole() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createShadowRoles(numToInsert)[0];
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.relatedToId = role.Id;
        email.headers = 'Return-Path:returnpath@intact.net\\\nReceived:Received from [1.1.1.1]\\\nMessage-ID:<message-id=0000>';
        email.htmlBody = 'test';
        email.subject = 'test';
        email.ToAddress = 'toaddress@intact.net';
        insert email;
        Test.stopTest();
        System.assertEquals(false, [SELECT Id From EmailMessage].isEmpty(), 'EmailMessage should exist after email created');
        System.assertEquals(false, [SELECT Id From FeedItem].isEmpty(), 'FeedItem should exist');
    }

    @isTest
    static void testDEAMatching() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createClaimRole();
        Case emailCase = TestDataFactory.createEmailCase();
        emailCase.OwnerId = Omni_EmailProcessingDAOHandler.QUEUE_BY_NAME.get(
                                Utility.EMAIL_CONFIG_BY_KEY.get('DEAMatchingQueueName')).Id;
        update emailCase;
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        Case claim = [SELECT Id, DEA_Email__c FROM Case WHERE Id = :role.ClaimForRole__c];
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.relatedToId = emailCase.Id;
        email.parentId = emailCase.Id;
        email.headers = 'Return-Path:returnpath@intact.net\\\nReceived:Received from [1.1.1.1]\\\nMessage-ID:<message-id=0000>\\\nTo:' 
                            + claim.DEA_Email__c;
        email.htmlBody = 'test';
        email.subject = 'test';
        email.ToAddress = 'toaddress@intact.net';
        insert email;
        Test.stopTest();
        //System.assertEquals(claim.Id, [SELECT Id, ParentId From EmailMessage WHERE Id = :email.Id].ParentId, 'Email sent');
    }

     @isTest
    static void testDEAMatchingAsyn() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createClaimRole();
        Case emailCase = TestDataFactory.createEmailCase();
        emailCase.OwnerId = Omni_EmailProcessingDAOHandler.QUEUE_BY_NAME.get(
                                Utility.EMAIL_CONFIG_BY_KEY.get('DEAMatchingQueueName')).Id;
        update emailCase;
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        Case claim = [SELECT Id, DEA_Email__c FROM Case WHERE Id = :role.ClaimForRole__c];
        Test.startTest();
        EmailMessage email = new EmailMessage();
        email.relatedToId = emailCase.Id;
        email.headers = 'Return-Path:returnpath@intact.net\\\nReceived:Received from [1.1.1.1]\\\nMessage-ID:<message-id=0000>\\\nTo:' 
                            + claim.DEA_Email__c;
        email.htmlBody = 'test';
        email.subject = 'test';
        email.ToAddress = 'toaddress@intact.net';
        email.ParentId = emailCase.Id;
        emailCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :emailCase.Id];
        Map<String, Case> caseById = new Map<String, Case>{emailCase.Id => emailCase};
        Omni_EmailProcessingList eList = new Omni_EmailProcessingList(new List<EmailMessage>{email}, caseById);
        eList.populateMasterCases();
        EmailMessageTriggerHandlerHelper.MergeCaseAsyn(
                        JSON.serialize(elist), JSON.serialize(caseById.keySet()));
        Test.stopTest();
        System.assertEquals(0, [SELECT Id From Case WHERE Id = :emailCase.Id AND Status != 'Closed'].size(), 'Email Case should be merged');
    }

    @isTest
    static void coverMethods() {
        Test.startTest();
        EmailMessageTriggerHandler handler = new EmailMessageTriggerHandler();
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('EmailMessage', handler.getObjectAPIName(),'Object name should be EmailMessage');
    }
}