/**
* @description Test class for Omni_ECMSearchClass
* @author      Luis Merinero
* @date        05/03/2020                     
*/ 
@isTest
public class Omni_ECMSearchClassTest {
    
    @isTest
    static void testECMSearchSuccess(){
        TestDataFactory.createECMConfiguration();
        Test.setMock(HttpCalloutMock.class, TestDataFactory.createServiceMock(200, '{"documents":[{"documentTitle": "Adhoc Communication.doc","mimeType": "JPG","Confidentiality": "private","fileSize": "25Mb","DocumentClass": "","ClaimNumber": "c2211","ClaimantName": "John Smith","PolicyNumber": "123","ClaimAdjusterID": "","InsuredName": "John","DateofLoss": "","DocumentStatus": "Assigned" ,"CMPID": "1","CommunicationType": "","ClaimSubType": "testClaimType","MessageID": "testMessageId","ReferenceNumber": "","trackingNumber": "randomlyGenerated"},{"documentTitle": "ECMTestTitle2.pdf","mimeType": "PDF","Confidentiality": "private","fileSize": "10Mb","DocumentClass": "","ClaimNumber": "c2211","ClaimantName": "Andrew Smith","PolicyNumber": "123","ClaimAdjusterID": "","InsuredName": "Andrew","DateofLoss": "","DocumentStatus": "Assigned" ,"CMPID": "2","CommunicationType": "","ClaimSubType": "testClaimType","MessageID": "testMessageId","ReferenceNumber": "","trackingNumber": "randomlyGenerated"}]}'));
        Test.startTest();
        Omni_AdhocFlowController.ECMSearch('12345', 'GENERAL', TRUE);
        Test.stopTest();
		Application_Log__c[] logs = [SELECT id FROM Application_Log__c WHERE Application_Name__c = 'ECM Search Request Exception'];
    	System.assertEquals(0, logs.size());    }
    
    @isTest
    static void testECMSearchError(){
        Test.setMock(HttpCalloutMock.class, TestDataFactory.createServiceMock(200, ''));
        Test.startTest();
        Omni_AdhocFlowController.ECMSearch('12345', 'GENERAL', TRUE);
        Test.stopTest();
		Application_Log__c[] logs = [SELECT id FROM Application_Log__c WHERE Application_Name__c = 'ECM Search Request Exception'];
    	System.assertEquals(1, logs.size());
    }
}