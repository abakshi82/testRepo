@isTest
private class Omni_HandlerProcessedPETriggerTest {

    @isTest
    static void publishECMProcessedFailure(){
        File_Metadata__c fmetadataBefore = new File_Metadata__c(Reference_Id__c = '0684c0000000imlAAA', messageId__c = '06A4m0000000JRjEAB', Unique_Id__c = '06A4m0000000JRjEAB-0684c0000000imlAAA');
        insert fmetadataBefore;
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestEventDataFactory.createHandlerProcessedEventFailure(
                                                    'c16bb02d-a36c-484f-8dca-b3c91e7447ae', '0684c0000000imlAAA', '06A4m0000000JRjEAB'));
        Test.stopTest();
        System.assertEquals(true, [SELECT Id From Application_Log__c].size()>0, 'Log should be created!');
        File_Metadata__c fmetadataAfter = [SELECT Id, Document_Processing_Status__c From File_Metadata__c WHERE Id = :fmetadataBefore.Id];
        System.assertEquals(true,fmetadataAfter.Document_Processing_Status__c.contains('Retrying'), 'Metadata status need to updated for Retrying');
    }

    @isTest
    static void publishECMProcessedSuccess(){
        File_Metadata__c fmetadataBefore = new File_Metadata__c(Reference_Id__c = '0684c0000000imlAAA', messageId__c = '06A4m0000000JRjEAM', Unique_Id__c = '06A4m0000000JRjEAB-0684c0000000imlAAA');
        insert fmetadataBefore;
        System.assertEquals(0, [SELECT Id From Application_Log__c].size(), 'No log should exist!');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestEventDataFactory.createHandlerProcessedEventSuccess(
                                                    'c16bb02d-a36c-484f-8dca-b3c91e7447ae', '0684c0000000imlAAA', '06A4m0000000JRjEAM'));
        Test.stopTest();
        System.assertEquals(true, [SELECT Id From Application_Log__c].size()>0, 'Log should be created!');
    }

    @isTest
    static void coverMethods() {
        Test.startTest();
        Omni_HandlerProcessedPETriggerHandler handler = new Omni_HandlerProcessedPETriggerHandler();
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('Handler_Processed__e', handler.getObjectAPIName(),'Object name should be Handler_Processed__e');
    }

}