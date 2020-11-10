@isTest
private class Omni_ClaimEventDispatcherTriggerTest {

    @isTest
    static void publishClaimEvent1(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent2(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '6', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent3(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '11', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent4(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '16', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent5(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
       Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '21', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent6(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '26', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent7(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '31', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent8(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '36', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

     @isTest
    static void publishClaimEvent9(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '41', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent10(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '46', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent11(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '51', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent12(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '56', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent13(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '61', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent14(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '66', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent15(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '71', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent16(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '76', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent17(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '81', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent18(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '86', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent19(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '91', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void publishClaimEvent20(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '96', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH));
        Test.stopTest();   
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void coverMethods() {
        Test.startTest();
        Omni_ClaimEventDispatcherTriggerHandler handler = new Omni_ClaimEventDispatcherTriggerHandler();
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('ClaimEvent_Dispatcher__e', handler.getObjectAPIName(),'Object name should be ClaimEvent_Dispatcher__e');
    }
}