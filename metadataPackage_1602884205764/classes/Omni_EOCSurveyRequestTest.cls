/**
* @description Test class for Omni_EOCSurveyRequest
* @author      Luis Merinero
* @date        09/03/2020                     
*/
@isTest
public class Omni_EOCSurveyRequestTest {
	
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
    static void createAutoPropertySurvey(){
        Map<String,Omni_SurveyRequest> mapCaseConfig = new Map<String,Omni_SurveyRequest>();
        Case claim = [SELECT id, ClaimId__c, Policy_Issuing_Group__c FROM Case Where RecordType.Name  = 'Claim'];
        PolicyIssuingGroup__c issuingGroup = new PolicyIssuingGroup__c(TypeCode__c = 'intact');
        insert issuingGroup;
        claim.TotalLoss__c = 'PAR';
        claim.ClaimId__c = '123Claim';
        claim.Policy_Issuing_Group__c = issuingGroup.id;
        update claim;
        
        Case exposure = [SELECT id, ClaimId__c, RecordType.Name, ExposureId__c FROM Case Where RecordType.DeveloperName  = 'OtherExposure'];
        SurveyConfig__mdt autoConfig = [SELECT id, SurveyIndicatorAPIName__c, SendSurveyOnce__c, Type__c, Active__c FROM SurveyConfig__mdt WHERE SurveyIndicatorAPIName__c = 'SendAutoPropertySurvey__c'];
        Map<String, SurveyConfig__mdt> configMap = new Map<String, SurveyConfig__mdt>();
        configMap.put('SendAutoPropertySurvey__c',autoConfig);
        
        Omni_SurveyConfig request = new Omni_SurveyConfig(claim, null, null);
        request.surveyConfigByKey = configMap;
        Omni_SurveyRequest sRequest = new Omni_SurveyRequest(request);
        Map<String, Omni_SurveyRequest> surveyRequest = new Map<String, Omni_SurveyRequest>();
        surveyRequest.put(claim.ClaimId__c + '-Claim', sRequest);
        
        Test.startTest();
        System.enqueueJob(new Omni_EOCSurveyRequest(surveyRequest));
        Test.stopTest();
    }
    
	@isTest
    static void createBenefitsSurvey(){
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
        
        Test.startTest();
        System.enqueueJob(new Omni_EOCSurveyRequest(surveyRequest));
        Test.stopTest();
    }

    @isTest
    static void createAutoPropertySurveySync(){
        Map<String,Omni_SurveyRequest> mapCaseConfig = new Map<String,Omni_SurveyRequest>();
        Case claim = [SELECT id, ClaimId__c, Policy_Issuing_Group__c FROM Case Where RecordType.Name  = 'Claim'];
        PolicyIssuingGroup__c issuingGroup = new PolicyIssuingGroup__c(TypeCode__c = 'intact');
        insert issuingGroup;
        claim.TotalLoss__c = 'PAR';
        claim.ClaimId__c = '123Claim';
        claim.Policy_Issuing_Group__c = issuingGroup.id;
        update claim;
        
        Case exposure = [SELECT id, ClaimId__c, RecordType.Name, ExposureId__c FROM Case Where RecordType.DeveloperName  = 'OtherExposure'];
        SurveyConfig__mdt autoConfig = [SELECT id, SurveyIndicatorAPIName__c, SendSurveyOnce__c, Type__c, Active__c FROM SurveyConfig__mdt WHERE SurveyIndicatorAPIName__c = 'SendAutoPropertySurvey__c'];
        Map<String, SurveyConfig__mdt> configMap = new Map<String, SurveyConfig__mdt>();
        configMap.put('SendAutoPropertySurvey__c',autoConfig);
        
        Omni_SurveyConfig request = new Omni_SurveyConfig(claim, null, null);
        request.surveyConfigByKey = configMap;
        Omni_SurveyRequest sRequest = new Omni_SurveyRequest(request);
        Map<String, Omni_SurveyRequest> surveyRequest = new Map<String, Omni_SurveyRequest>();
        surveyRequest.put(claim.ClaimId__c + '-Claim', sRequest);
        
        Test.startTest();
        Omni_EOCSurveyServiceSync surveySerivce = new Omni_EOCSurveyServiceSync(surveyRequest);
        surveySerivce.createAndSendSurveys();
        Test.stopTest();
    }
    
	@isTest
    static void createBenefitsSurveySync(){
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
        
        Test.startTest();
        Omni_EOCSurveyServiceSync surveySerivce = new Omni_EOCSurveyServiceSync(surveyRequest);
        surveySerivce.createAndSendSurveys();
        Test.stopTest();
    }

    @isTest
    static void coverMethods() { 
        Map<String,Omni_SurveyRequest> mapCaseConfig = new Map<String,Omni_SurveyRequest>();
        Case claim = [SELECT id, ClaimId__c, Policy_Issuing_Group__c FROM Case Where RecordType.Name  = 'Claim'];
		PolicyIssuingGroup__c issuingGroup = new PolicyIssuingGroup__c(TypeCode__c = 'intact');
        insert issuingGroup;
        claim.TotalLoss__c = 'PAR';
        claim.ClaimId__c = '123Claim';
        claim.Policy_Issuing_Group__c = issuingGroup.id;
        update claim;
        
        Case exposure = [SELECT id, ClaimId__c, RecordType.Name, ExposureId__c, ExposureType__c FROM Case Where RecordType.DeveloperName  = 'OtherExposure'];
        exposure.RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS;
        exposure.ExposureId__c = '1234Exp';
        update exposure;

        Case role = [SELECT Id, RoleId__c, PIG_EN__c, PIG_Logo_EN__c, ClaimNumber__c, Adjustor_Name__c, Broker_Name__c, Claim_LOB__c, PIG_Name_EN__c, 
                        Party_Name__c, Party_Address_Line__c, Party_City__c, Party_Province__c, Party_Postal_Code__c, LiabilityConfirmed__c, 
                        ProvinceOfIssuanceId__c, PIG_FR__c, PIG_Logo_FR__c, PIG_Name_FR__c, ClaimForRole__c, ExposureForRole__c, PartyContact__c, 
                        PartyContact__r.FirstName, PartyContact__r.LastName, PartyContact__r.Email, PartyAccount__c, RoleNature__c, SurveyLink__c,
                        ExposureForRole__r.ExposureType__c
                     FROM Case 
                     WHERE ExposureForRole__c  = :exposure.Id];
        role.RoleId__c = '12345';
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
        List<Omni_EOCSurveyRequest.MessageRequest> msgRequests = new List<Omni_EOCSurveyRequest.MessageRequest>{ 
                                                                        new Omni_EOCSurveyRequest.MessageRequest(
                                                                            EmailMessageTriggerHandlerHelper.SURVEY_TEMPLATS[0].Id,
                                                                            role,
                                                                            log.Id,
                                                                            null)
                                                                };
        Map<String, Omni_EOCSurveyRequest.MessageRequest> msgRequestByRoleId = new Map<String, Omni_EOCSurveyRequest.MessageRequest>{
                                                                                        role.RoleId__c => msgRequests[0]
                                                                                        };
        Test.startTest();
        Omni_EOCSurveyRequest req = new Omni_EOCSurveyRequest(surveyRequest);
        Map<String, Account> accountById = req.createAccounts(msgRequests);
        Map<String, Contact> contactById = req.createContacts(msgRequests, accountById);
        Map<String, SurveyBuilder__c> surveyBuildersByRoleId = req.createSurveyBuilders(
                                                                   msgRequests, 
                                                                   accountById,
                                                                   contactById);
        req.createTextFeeds(msgRequests, new List<Case>{exposure});
        req.createEmailMessages(msgRequestByRoleId, surveyBuildersByRoleId);
        req.updateRolesInRequests(msgRequestByRoleId);
        Test.stopTest();
    }

     @isTest
    static void coverMethodsSync() { 
        Map<String,Omni_SurveyRequest> mapCaseConfig = new Map<String,Omni_SurveyRequest>();
        Case claim = [SELECT id, ClaimId__c, Policy_Issuing_Group__c FROM Case Where RecordType.Name  = 'Claim'];
		PolicyIssuingGroup__c issuingGroup = new PolicyIssuingGroup__c(TypeCode__c = 'intact');
        insert issuingGroup;
        claim.TotalLoss__c = 'PAR';
        claim.ClaimId__c = '123Claim';
        claim.Policy_Issuing_Group__c = issuingGroup.id;
        update claim;
        
        Case exposure = [SELECT id, ClaimId__c, RecordType.Name, ExposureId__c, ExposureType__c FROM Case Where RecordType.DeveloperName  = 'OtherExposure'];
        exposure.RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS;
        exposure.ExposureId__c = '1234Exp';
        update exposure;

        Case role = [SELECT Id, RoleId__c, PIG_EN__c, PIG_Logo_EN__c, ClaimNumber__c, Adjustor_Name__c, Broker_Name__c, Claim_LOB__c, PIG_Name_EN__c, 
                        Party_Name__c, Party_Address_Line__c, Party_City__c, Party_Province__c, Party_Postal_Code__c, LiabilityConfirmed__c, 
                        ProvinceOfIssuanceId__c, PIG_FR__c, PIG_Logo_FR__c, PIG_Name_FR__c, ClaimForRole__c, ExposureForRole__c, PartyContact__c, 
                        PartyContact__r.FirstName, PartyContact__r.LastName, PartyContact__r.Email, PartyAccount__c, RoleNature__c, SurveyLink__c, 
                        ExposureForRole__r.ExposureType__c
                     FROM Case 
                     WHERE ExposureForRole__c  = :exposure.Id];
        role.RoleId__c = '12345';
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
        List<Omni_EOCSurveyServiceSync.MessageRequest> msgRequests = new List<Omni_EOCSurveyServiceSync.MessageRequest>{ 
                                                                        new Omni_EOCSurveyServiceSync.MessageRequest(
                                                                            EmailMessageTriggerHandlerHelper.SURVEY_TEMPLATS[0].Id,
                                                                            role,
                                                                            log.Id,
                                                                            null)
                                                                };
        Map<String, Omni_EOCSurveyServiceSync.MessageRequest> msgRequestByRoleId = new Map<String, Omni_EOCSurveyServiceSync.MessageRequest>{
                                                                                        role.RoleId__c => msgRequests[0]
                                                                                        };
        Test.startTest();
        Omni_EOCSurveyServiceSync req = new Omni_EOCSurveyServiceSync(surveyRequest);
        Map<String, Account> accountById = req.createAccounts(msgRequests);
        Map<String, Contact> contactById = req.createContacts(msgRequests, accountById);
        Map<String, SurveyBuilder__c> surveyBuildersByRoleId = req.createSurveyBuilders(
                                                                   msgRequests, 
                                                                   accountById,
                                                                   contactById);
        req.createTextFeeds(msgRequests, new List<Case>{exposure});
        req.createEmailMessages(msgRequestByRoleId, surveyBuildersByRoleId);
        req.updateRolesInRequests(msgRequestByRoleId);
        Test.stopTest();
    }
}