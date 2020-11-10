@isTest
private class Omni_EOCSurveyRequestBatchTest {

    @testSetup
    private static void testSetupData(){
        TestDataFactory.createExposureStatus();
        TestDataFactory.createContactTypeRole();
        TestDataFactory.createPolicyIssuingGroup();
        Case exposure = TestDataFactory.createOtherExposures(1)[0];
        Case role = TestDataFactory.createExposureRole(exposure);
        insert role;    
    }
    
	@isTest
    static void runScheduleSurveyBatch(){
        Map<String,Omni_SurveyRequest> mapCaseConfig = new Map<String,Omni_SurveyRequest>();
        Case claim = [SELECT id, ClaimId__c, Policy_Issuing_Group__c FROM Case Where RecordType.Name  = 'Claim'];
		PolicyIssuingGroup__c issuingGroup = new PolicyIssuingGroup__c(TypeCode__c = 'intact');
        insert issuingGroup;
        claim.TotalLoss__c = 'PAR';
        claim.ClaimId__c = '123Claim';
        claim.Policy_Issuing_Group__c = issuingGroup.id;
        update claim;
        
        Case exposure = [SELECT id, ClaimId__c, RecordType.Name, ExposureId__c FROM Case Where RecordType.DeveloperName  = 'OtherExposure'];
        exposure.RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS;
        exposure.ExposureId__c = '1234Exp';
        update exposure;
        
        Application_Log__c log = new Application_Log__c();
        insert log;
        
        SurveyConfig__mdt benefitsConfig = [SELECT id, SurveyIndicatorAPIName__c, SendSurveyOnce__c, Type__c, Active__c FROM SurveyConfig__mdt WHERE SurveyIndicatorAPIName__c = 'SendAutoPropertySurvey__c'];
        Map<String, SurveyConfig__mdt> configMap = new Map<String, SurveyConfig__mdt>();
        configMap.put('SendAccidentBenefitsSurvey__c',benefitsConfig);
        
        Omni_SurveyConfig request = new Omni_SurveyConfig(claim, exposure, log.id);
        request.surveyConfigByKey = configMap;
        
        Omni_SurveyRequest sRequest = new Omni_SurveyRequest(request);
        Map<String, Omni_SurveyRequest> surveyRequest = new Map<String, Omni_SurveyRequest>();
        surveyRequest.put(exposure.ExposureId__c + '-Exposure', sRequest);

        String jobId = System.enqueueJob(new Omni_EOCSurveyRequest(surveyRequest));
        Omni_ClaimEventHelper.saveEOCRequests(surveyRequest, jobId);
        System.assertEquals(false, [SELECT Id FROM SurveyRequest__c WHERE JobId__c = :jobId].isEmpty(), 'survey requests should be created');
        
        Test.startTest();
        Omni_EOCSurveyRequestBatchSchedule schedulableClass = new Omni_EOCSurveyRequestBatchSchedule();
        schedulableClass.execute(null);
        Test.stopTest();
        System.assertEquals(true, [SELECT Id FROM SurveyRequest__c WHERE JobId__c = :jobId].isEmpty(), 'survey requests should be deleted after batch job');
    }

}