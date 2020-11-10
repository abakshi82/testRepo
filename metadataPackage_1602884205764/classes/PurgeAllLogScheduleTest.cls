@istest
private class PurgeAllLogScheduleTest {

    @isTest
    static void runPurgeAllLogSchedule(){
        Integer logNumForEach = 20;
        List<Application_Log__c> appLogs = TestDataFactory.createExceptionIntegrationAppLogs(logNumForEach);
        for(Application_Log__c log : appLogs){
            Test.setCreatedDate(log.Id, DateTime.newInstance(2018,01,01));
        }
        Test.startTest();
        String jobId = System.schedule('Purge Exception Logs', '0 1 * * * ?', new PurgeAllLogSchedule());
        Test.stopTest();
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ct.size(), 'new job should be scheduled');
    }

}