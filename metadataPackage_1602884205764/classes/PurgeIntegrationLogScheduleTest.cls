@isTest
private class PurgeIntegrationLogScheduleTest {

    @isTest
    static void runPurgeIntegrationLogSchedule(){
        Integer logNumForEach = 20;
        List<Application_Log__c> appLogs = TestDataFactory.createExceptionIntegrationAppLogs(logNumForEach);
        for(Application_Log__c log : appLogs){
            Test.setCreatedDate(log.Id, DateTime.newInstance(2018,01,01));
        }
        System.assertequals(logNumForEach*2, [SELECT Id FROM Application_Log__c].size());
        Test.startTest();
        String jobId = System.schedule('Purge Integration Logs', '0 25 5 15 * ?', new PurgeIntegrationLogSchedule());
        Test.stopTest();
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ct.size(), 'new job should be scheduled');
    }
}