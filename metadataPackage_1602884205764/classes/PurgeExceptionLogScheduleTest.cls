@isTest
private class PurgeExceptionLogScheduleTest {

    @isTest
    static void runPurgeExceptionLogSchedule(){
        Integer logNumForEach = 20;
        List<Application_Log__c> appLogs = TestDataFactory.createExceptionIntegrationAppLogs(logNumForEach);
        for(Application_Log__c log : appLogs){
            Test.setCreatedDate(log.Id, DateTime.newInstance(2018,01,01));
        }
        System.assertequals(logNumForEach, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Exception'].size());
        Test.startTest();
        String jobId = System.schedule('Purge Exception Logs', '0 1 * * * ?', new PurgeExceptionLogSchedule());
        Test.stopTest();
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ct.size(), 'new job should be scheduled');
    }
}