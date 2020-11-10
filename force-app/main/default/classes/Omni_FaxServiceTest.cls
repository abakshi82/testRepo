@isTest
private class Omni_FaxServiceTest {

    @isTest
    static void testFeedCreationForFax() {
        Communication_Configuration__c config = TestDataFactory.createCommConfigForChannel('Fax');
        List<Case> exposures = TestDataFactory.createOtherExposures(1);
        Case role = TestDataFactory.createExposureRoles(exposures)[0];
        List<Application_Log__c> appLogs = TestDataFactory.createApplicationLogs(TestDataFactory.TEST_SIZE_SMALL, true);
        Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> commConfigByRole = new Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>>();
        commConfigByRole.put(new Omni_CommunicationDispatcher.RoleWithLog(appLogs[0], role),  new Set<Communication_Configuration__c>{config});
        System.assertEquals(true,[SELECT Id FROM FeedItem].isEmpty(),'No FeedItem should exist');
        Test.startTest();
        Omni_FaxService faxService = new Omni_FaxService(commConfigByRole);
        faxService.handleFax();
        Test.stopTest();
        System.assertEquals(false,[SELECT Id FROM FeedItem].isEmpty(),'FeedItem should be created');
    }
}