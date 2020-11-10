@isTest
private class Omni_ECMProcessedPETriggerTest {

     @isTest
    static void publishECMProcessed(){
        System.assertEquals(0, [SELECT Id From ECM_Metadata__c].size(), 'No ECM Metadata should exist!');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestEventDataFactory.createECMProcessedEvent(
                                                    'c16bb02d-a36c-484f-8dca-b3c91e7447ae', '06A4m0000000JRjEAB', '0684c0000000imlAAA'));
        Test.stopTest();
        System.assertEquals(true, [SELECT Id From ECM_Metadata__c].size()>0, 'ECM Metadata should be created!');
    }

    @isTest
    static void coverMethods() {
        Test.startTest();
        Omni_ECMProcessedPETriggerHandler handler = new Omni_ECMProcessedPETriggerHandler();
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('ECM_Processed__e', handler.getObjectAPIName(),'Object name should be ECM_Processed__e');
    }
    
	@isTest
    static void eCMFilesController() {
		Database.SaveResult sr = EventBus.publish(TestEventDataFactory.createECMProcessedEvent(
                                                    'c16bb02d-a36c-484f-8dca-b3c91e7447ae', '06A4m0000000JRjEAB', '0684c0000000imlAAA'));
        Meta_junction__c[] meta = [SELECT id from Meta_junction__c];
        System.debug(meta);
        Test.startTest();

        Test.stopTest();
    }

}