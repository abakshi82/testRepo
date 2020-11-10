/**
* @description Test class for Omni_ECMRetrieveClass
* @author      Luis Merinero
* @date        05/03/2020                    
*/ 
@isTest
public class Omni_ECMRetrieveClassTest {

    @testSetup
    static void setup(){
        TestDataFactory.createECMConfiguration();
        insert new ContentVersion(VersionData = Blob.valueOf('ABCFileData'), Title = 'Test File', PathOnClient = 'Test File.jpg');
    }
    
    @isTest
    static void testECMRetrieveSuccess(){
        ContentVersion version = [SELECT id FROM ContentVersion LIMIT 1];
        Test.setMock(HttpCalloutMock.class, TestDataFactory.createServiceMock(200, '{"ecmDiscriminator": "CLM", "mimeType": "PDF", "slfid": "' + version.Id + '","trackingNumber": "123456ABC"}'));
        Test.startTest();
        Omni_AdhocFlowController.ECMRetrieveDocumentUrl('12345', 'http://cmpurl.com');
        Test.stopTest();
        File_Metadata__c fm = [SELECT id, Sent_to_Handler__c FROM File_Metadata__c LIMIT 1];
        System.assert(fm.Sent_to_Handler__c);
    }
    
	@isTest
    static void testECMRetrieveError(){
        Test.setMock(HttpCalloutMock.class, TestDataFactory.createServiceMock(200, '{"ecmDiscriminator": "CLM", "mimeType": "PDF", "slfid": "1234567","trackingNumber": "123456ABC"}'));
        Test.startTest();
        Omni_AdhocFlowController.ECMRetrieveDocumentUrl('12345', 'http://cmpurl.com');
        Test.stopTest();
        Application_Log__c[] logs = [SELECT id FROM Application_Log__c WHERE Application_Name__c = 'ECM Retrieve Request Exception'];
    	System.assertEquals(1, logs.size());
    }
}