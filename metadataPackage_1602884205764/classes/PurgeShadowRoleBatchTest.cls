@isTest
private class PurgeShadowRoleBatchTest {

    @isTest
    static void runPurgeAllShadowRolesBatch(){
        Integer numToInsert = 20;
        List<Case> roles = TestDataFactory.createShadowRoles(numToInsert);
        for(Case c : roles){
            Test.setCreatedDate(c.Id, DateTime.newInstance(2018,01,01));
        }
        System.assertequals(numToInsert, [SELECT Id FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId()].size(), 'Shadow roles should be created');
        Test.startTest();
        Database.executeBatch(new PurgeShadowRoleBatch(null), 2000);
        Test.stopTest();
        System.assertequals(0, [SELECT Id FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId()].size(), 'Shadow roles should be removed');
    }

    @isTest
    static void runPurgeTodayShadowRolesBatch(){
        Integer numToInsert = 20;
        List<Case> roles = TestDataFactory.createShadowRoles(numToInsert);
        System.assertequals(numToInsert, [SELECT Id FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId()].size(), 'Shadow roles should be created');
        Test.startTest();
        Database.executeBatch(new PurgeShadowRoleBatch(0), 2000);
        Test.stopTest();
        System.assertequals(numToInsert, [SELECT Id FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId()].size(), 'Today Shadow roles should not be removed');
    }

    @isTest
    static void runPurgelastYearShadowRolesBatch(){
        Integer numToInsert = 20;
        List<Case> roles = TestDataFactory.createShadowRoles(numToInsert);
        for(Case c : roles){
            Test.setCreatedDate(c.Id, DateTime.newInstance(2018,01,01));
        }
        System.assertequals(numToInsert, [SELECT Id FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId()].size(), 'Shadow roles should be created');
        Test.startTest();
        Database.executeBatch(new PurgeShadowRoleBatch(30), 2000);
        Test.stopTest();
        System.assertequals(0, [SELECT Id FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId()].size(), 'last year Shadow roles should not be removed');
    }
}