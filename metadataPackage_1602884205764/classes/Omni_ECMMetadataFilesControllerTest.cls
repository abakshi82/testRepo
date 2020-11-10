/**
* @Description: Test class for Omni_ECMMetadataFilesController
* @Author:      Luis Merinero
* @Date:        08/04/2020
*/
@isTest
public class Omni_ECMMetadataFilesControllerTest {

	@isTest
    static void publishECMProcessed(){
        Case testCase = new Case();
        insert testCase;
        Meta_Junction__c metaJunction = new Meta_Junction__c();
        insert metaJunction;
        List<EmailMessage> messages = TestDataFactory.createEmailMessages(1, testCase, false);
        insert messages;
        File_Metadata__c fMetadata = TestDataFactory_ECM.createFileMetadata('testRef');
        fMetadata.Meta_Junction__c = metaJunction.Id;
        Update fMetadata;
        insert new ECM_Metadata__c(File_Metadata__c = fMetadata.Id);
        
        Test.startTest();
        Omni_ECMMetadataFilesController.getECMMetadataByEmailMessage(messages[0].id);
		messages[0].Meta_Junction__c = metaJunction.Id;
        update messages;
		List<ECM_Metadata__c> ecmList = Omni_ECMMetadataFilesController.getECMMetadataByEmailMessage(messages[0].id);
        Test.stopTest();
        
        System.assertEquals(ecmList.size(), 3);
    }
}