@istest
private class PurgeShadowRoleScheduleTest {

    @isTest
    static void runPurgeAllLogSchedule(){
        Integer numToInsert = 20;
        List<Case> roles = TestDataFactory.createShadowRoles(numToInsert);
        System.assertequals(numToInsert, [SELECT Id FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId()].size(), 'Shadow roles should be created');
        Test.startTest();
        String jobId = System.schedule('Purge Shadow roles', '0 1 * * * ?', new PurgeShadowRoleSchedule());
        Test.stopTest();
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ct.size(), 'new job should be scheduled');
    }

}