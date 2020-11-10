/**
* @description Test class for Omni_AdhocFlowControllerTest
* @author      Luis Merinero
* @date        23/12/2019                     
*/
@isTest
public class Omni_AdhocFlowControllerTest {

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
    static void validateRoleAndExposuresSelected(){
        Case claim = [SELECT id, RecordTypeId FROM Case Where RecordType.Name  = 'Claim'];
        Set<Id> idsSet = new Set<Id>{claim.Id};
        Set<String> stringsSet = new Set<String>{claim.Id};
        
        Test.startTest();
        List<Case> roles = Omni_AdhocFlowController.getRoles(claim.id);
		List<Case> exposures = Omni_AdhocFlowController.getExposures(claim.Id);
		Id userID = Omni_AdhocFlowController.getUserId();
        Boolean ABBIMember = Omni_AdhocFlowController.isABBIMember();
        Omni_AdhocFlowController.getShadowRoleId(roles[0].id, exposures[0].id);
        Omni_AdhocFlowController.getShadowRoleId(roles[0].id, exposures[0].id);
        Omni_CaseSelector.getRoleEmailCaseByIdFromCaseIds(stringsSet);
        Omni_CaseSelector.getCaseDetailsById(idsSet);
        Omni_CaseSelector.getClaimExpoDetailsById(idsSet);
        Test.stopTest();

        System.assertEquals(1, roles.size());
        System.assertEquals(1, exposures.size());
        System.assertEquals(UserInfo.getUserId(), userID);
    }

    @isTest
    static void validateEmailTemplates(){
        List<Folder> folders = Omni_AdhocFlowController.getFolderList('Email');
        insert new EmailTemplate(folderId = folders[0].id, Name = 'EN_Email', DeveloperName = 'EN_Email', TemplateType = 'text');
		List<EmailTemplate> templates = Omni_AdhocFlowController.getEmailTemplatesList(folders[0].Name, 'EN');
        String BlankTemplate = Omni_AdhocFlowController.getBlankTemplate();
    }
}