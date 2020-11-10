@isTest
private class BatchDeleteECMProcessedDocsTest {

    @isTest
    static void testDeleteBatch() {
        ContentVersion cv = TestDataFactory_ECM.createContentVersion();
        File_Metadata__c filemetadata = TestDataFactory_ECM.createFileMetadata(cv.Id);
        System.assert([SELECT Id FROM File_Metadata__c WHERE File_Deleted__c = false].size() > 0);
        System.assert([SELECT Id FROM ContentVersion].size() > 0);
        Test.startTest();
		Omni_ECMFilesDeleteSchedule schedulableClass = new Omni_ECMFilesDeleteSchedule();
		schedulableClass.execute(null);
        Test.stopTest();
        System.assertEquals(true,[SELECT Id, File_Deleted__c FROM File_Metadata__c][0].File_Deleted__c, 'File Metadata should be updated as deleted');
        System.assertEquals(0, [SELECT Id FROM ContentVersion].size(),'ContentVersion should be deleted');
    } 
}