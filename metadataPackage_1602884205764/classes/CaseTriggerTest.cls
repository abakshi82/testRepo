@isTest
private class CaseTriggerTest {

    @isTest
    static void coverClaimIdUpdate() {
        Case role = TestDataFactory.createClaimRole();
        Test.startTest();
        role.ClaimId__c = '12345';
        update role;
        Test.stopTest();
        List<Case> roles = [SELECT Id, ClaimId__c FROM Case WHERE 
                                RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimNotificationConstant.EXPOSURE_ROLE_RECORD_TYPE_NAME).getRecordTypeId() 
                                OR 
                                RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimNotificationConstant.CLAIM_ROLE_RECORD_TYPE_NAME).getRecordTypeId()];    
        System.assertEquals(1, roles.size(),'One role should be created');
    }

    @isTest
    static void coverMethods() {
        Test.startTest();
        CaseTriggerHandler handler = new CaseTriggerHandler();
        handler.handleBeforeDelete(null);
        handler.handleBeforeInsert(null);
        handler.handleAfterInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('Case', handler.getObjectAPIName(),'Object name should be Case');
    }
}