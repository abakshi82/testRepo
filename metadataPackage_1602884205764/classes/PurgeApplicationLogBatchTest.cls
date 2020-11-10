@isTest
private class PurgeApplicationLogBatchTest {

    @isTest
    static void runPurgeExceptionLogBatch(){
        Integer logNumForEach = 20;
        List<Application_Log__c> appLogs = TestDataFactory.createExceptionIntegrationAppLogs(logNumForEach);
        for(Application_Log__c log : appLogs){
            Test.setCreatedDate(log.Id, DateTime.newInstance(2018,01,01));
        }
        System.assertequals(logNumForEach, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Exception'].size());
        Test.startTest();
        Database.executeBatch(new PurgeApplicationLogBatch(
                                PurgeApplicationLogBatch.LogCategory.EXCEPTION_LOG), 2000);
        Test.stopTest();
        System.assertequals(0, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Exception' AND CreatedDate < TODAY].size());
    }

    @isTest
    static void runPurgeIntegrationLogBatch(){
        Integer logNumForEach = 20;
        List<Application_Log__c> appLogs = TestDataFactory.createExceptionIntegrationAppLogs(logNumForEach);
        for(Application_Log__c log : appLogs){
            Test.setCreatedDate(log.Id, DateTime.newInstance(2018,01,01));
        }
        System.assertequals(logNumForEach, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].size());
        Test.startTest();
                Database.executeBatch(new PurgeApplicationLogBatch(
                                PurgeApplicationLogBatch.LogCategory.INTEGRATION_LOG), 2000);
        Test.stopTest();
        System.assertequals(0, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].size());
    }

     @isTest
    static void runPurgeAllLogsBatch(){
        Integer logNumForEach = 20;
        List<Application_Log__c> appLogs = TestDataFactory.createExceptionIntegrationAppLogs(logNumForEach);
        for(Application_Log__c log : appLogs){
            Test.setCreatedDate(log.Id, DateTime.newInstance(2018,01,01));
        }
        System.debug([SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].size());
        System.debug([SELECT Id FROM Application_Log__c WHERE Category__c = 'Exception'].size());
        Test.startTest();
        Database.executeBatch(new PurgeApplicationLogBatch(null), 2000);
        Test.stopTest();
        System.debug([SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].size());
        System.debug([SELECT Id FROM Application_Log__c WHERE Category__c = 'Exception'].size());
        System.assertequals(3, [SELECT Id FROM Application_Log__c].size(),'All logs should be removed except 3 productive exceptions');
    }

}