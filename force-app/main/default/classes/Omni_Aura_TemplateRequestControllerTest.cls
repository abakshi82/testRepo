/**
   * @Description: Test class for mni_Aura_TemplateRequestController
   * @Author:      Damian Kazior, PwC
   * @Date:        05/07/2019
*/
@isTest
public with sharing class Omni_Aura_TemplateRequestControllerTest {

    @TestSetup
    static void setupData(){
        Template_Management_Config__mdt templateConfiguration = Utility.getTemplateManagementConfigurations();
        TestDataFactory.generateEmailTemplates(TestDataFactory.TEST_SIZE_SMALL, templateConfiguration.Cloned_Emails_Folder_Name__c, true); 
    }  

    @isTest
    private static void getEmailTemplatesTest() {
        Map<String, String> pickListValuesMap = Omni_Aura_TemplateRequestController.getEmailTemplates();   
        System.assert(pickListValuesMap.size() >= TestDataFactory.TEST_SIZE_SMALL, 'There should be at least TEST_SIZE_SMALL templates in the dropdown for specific folder');
    }

    @isTest
    private static void createNewEmailTemplateSuccess() {
        Map<String, String> pickListValuesMap = Omni_Aura_TemplateRequestController.getEmailTemplates();
        Template_Request__c templateRequest = new Template_Request__c(
            Email_Template_Name__c = TestDataFactory.generateRandomString(5),
            Is_New_Template__c     = true,
            Name                   = TestDataFactory.generateRandomString(5)    
        ); 
        Omni_AuraResponse auraResponse = Omni_Aura_TemplateRequestController.createNewEmailTemplate(templateRequest);
        System.assertEquals(true, auraResponse.success, 'Email template cannot be created. Verify that all data required for template (outlined in configuration custom metadata) is present in the org');
        System.assertNotEquals(null, auraResponse.data.Id, 'Email template should have been created and persisted');
    }

    @isTest
    private static void createNewEmailTemplateFail() {
        Template_Request__c templateRequest = new Template_Request__c(); 
        Omni_AuraResponse auraResponse = Omni_Aura_TemplateRequestController.createNewEmailTemplate(templateRequest);
        System.assertEquals(false, auraResponse.success, 'Failure should be returned');
        System.assertNotEquals(null, auraResponse.message, 'Error message should be returned');
    }
}