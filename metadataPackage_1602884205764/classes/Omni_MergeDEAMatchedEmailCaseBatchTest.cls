@isTest
private class Omni_MergeDEAMatchedEmailCaseBatchTest {

    @isTest
    static void testDEAMatching() {
        Integer numToInsert = 1;
        Case role = TestDataFactory.createClaimRole();
        Case emailCase = TestDataFactory.createEmailCase();
        System.assertEquals(true, [SELECT Id From EmailMessage].isEmpty(), 'No Email should exist');
        System.assertEquals(true, [SELECT Id From FeedItem].isEmpty(), 'No FeedItem should exist');
        String contactId = [SELECT PersonContactId FROM Account WHERE Id = :role.PartyAccount__c].PersonContactId;
        Case claim = [SELECT Id, ClaimNumber__c, DEA_Email__c FROM Case WHERE Id = :role.ClaimForRole__c];
        Group mergeQueue = [SELECT Id, Name FROM Group WHERE developerName = 'Intact_DEA_Matching' AND Type = 'Queue'];
        emailCase.OwnerId = mergeQueue.Id;
        update emailCase;
        EmailMessage email = new EmailMessage();
        email.RelatedToId = emailCase.Id;
        email.ParentId = emailCase.Id;
        email.HtmlBody = 'test';
        email.TextBody = 'test';
        email.Subject = 'test';
        email.ToAddress = '9999999' + Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('DEA_Email_Address_Domain');
        email.FromAddress = 'test@intact.net';
        email.Incoming = true;
        insert email;
        claim.ClaimNumber__c = '9999999';
        update claim;
        System.debug(email.ToAddress);
        System.debug([SELECT Id, ClaimNumber__c, DEA_Email__c FROM Case WHERE Id = :claim.Id].DEA_Email__c);
        Test.startTest();
        Integer nextYear = System.Today().year() + 1;
        String datetimeString = nextYear + '-04-24T00:00:00Z';
        Database.executeBatch(new Omni_MergeDEAMatchedEmailCaseBatch(datetimeString, mergeQueue.Name), 100);
        Test.stopTest();
        System.assertEquals(claim.Id, [SELECT Id, ParentId From EmailMessage WHERE Id = :email.Id].ParentId, 'Email should be merged to claim');
    }



}