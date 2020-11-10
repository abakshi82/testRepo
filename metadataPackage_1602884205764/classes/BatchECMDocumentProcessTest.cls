/**
* @description Test class for BatchECMDocumentProcess
* @author      Luis Merinero
* @date        1/03/2020                     
*/
@isTest
public class BatchECMDocumentProcessTest {

	@testSetup
    private static void testSetupData(){
        TestDataFactory.createExposureStatus();
        TestDataFactory.createContactTypeRole();
        TestDataFactory.createPolicyIssuingGroup();
        Case exposure = TestDataFactory.createOtherExposures(1)[0]; 
    }
    
	@isTest
    static void createSuccessIngest(){
		TestDataFactory.createECMConfiguration();
        Test.setMock(HttpCalloutMock.class, TestDataFactory.createServiceMock(200, '{"trackingNumber":"08f7af14-825f-43e9-814a-6ce788dd02e1","documents":[{"referenceNumber":"0684c0000000jZxAAI","documentProcessingResult":"PASSED","documentProcessingStatus":"PASSED_PUBLISH_TO_SF_INDIVIDUAL_DOCUMENT_TOPIC","messageId":"12345"}]}'));

		Case claim = [SELECT id, ClaimId__c, Policy_Issuing_Group__c FROM Case Where RecordType.Name = 'Claim'];
        TestDataFactory.SaveFileMetadata(claim);
        Test.startTest();
        Omni_BatchECMDocumentProcessSchedule schedulableClass = new Omni_BatchECMDocumentProcessSchedule();
		schedulableClass.execute(null);
        Test.stopTest();
        
        List<Application_log__c> logs = [SELECT id FROM Application_log__c];
        System.assertEquals(1, logs.size());
    }
    
    @isTest
	static void createFailedIngest(){
		TestDataFactory.createECMConfiguration();
        Test.setMock(HttpCalloutMock.class, TestDataFactory.createServiceMock(200, '{"trackingNumber":"08f7af14-825f-43e9-814a-6ce788dd02e1","documents":[{"referenceNumber":"0684c0000000jZxAAI","documentProcessingResult":"FAILED","documentProcessingStatus":"FAILED_TEST","messageId":"12345"}]}'));

		Case claim = [SELECT id, ClaimId__c, Policy_Issuing_Group__c, Owner.Name FROM Case Where RecordType.Name = 'Claim'];
        TestDataFactory.SaveFileMetadata(claim);
        Test.startTest();
        Omni_BatchECMDocumentProcessSchedule schedulableClass = new Omni_BatchECMDocumentProcessSchedule();
		schedulableClass.execute(null);
        Test.stopTest();
        
		List<File_Metadata__c> fileMeta = [SELECT id, Handler_ECM_Failure__c FROM File_Metadata__c];
        System.assertEquals(true, fileMeta[0].Handler_ECM_Failure__c);
    }

    @isTest
	static void testSchedulerBatchECMDocumentProcess(){
		Test.startTest();
        String jobId = System.schedule('BatchECMDocumentProcess', '0 1 * * * ?', new Omni_BatchECMDocumentProcessSchedule());
        Test.stopTest();
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ct.size(), 'new job should be scheduled');
    }
}