/**
   * @Description: Controller for Aura components creating and modifying Email Requests
   * @Author:      Damian Kazior, PwC
   * @Date:        25/06/2019
*/
public with sharing class Omni_Aura_TemplateRequestController { 

    /**
    * @Description: Fetch all email templates from folder accessible by template manager. Store templates in cache for better performance
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getEmailTemplates() {

        Map<String, String> pickListValuesMap = new Map<String, String>();
        Template_Management_Config__mdt templateConfiguration = Utility.getTemplateManagementConfigurations();
        List<EmailTemplate> templates = Omni_EmailTemplateSelector.getAllEmailTemplatesByFolderName(templateConfiguration.Cloned_Emails_Folder_Name__c);
       
        for(EmailTemplate template : templates){
            pickListValuesMap.put(template.Id, template.Name); 
        }     
        return pickListValuesMap;
    }

    /**
    * @Description: When user requests to create new email template, create that template in accessible folder and persist template request
                    with appropiate temlate
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    @AuraEnabled
    public static Omni_AuraResponse createNewEmailTemplate(Template_Request__c templateRequest) {
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        EmailTemplate newTemplate;

        try{
            Template_Management_Config__mdt templateConfiguration = Utility.getTemplateManagementConfigurations();
            BrandTemplate letterHead                              = Omni_BrandTemplateSelector.getBrandTemplatesByName(templateConfiguration.Letterhead_name__c);
            Folder folder                                         = Omni_FolderSelector.getFolderByName(templateConfiguration.Cloned_Emails_Folder_Name__c);
            
            newTemplate = new EmailTemplate(
                BrandTemplateId = letterHead.Id,
                DeveloperName   = templateRequest.Email_Template_Name__c,
                FolderId        = folder.id,
                Name            = templateRequest.Email_Template_Name__c, 
                TemplateStyle   = templateConfiguration.Template_Style__c,
                TemplateType    = templateConfiguration.Template_Type__c
            );
            insert newTemplate;
            auraResponse.data = newTemplate;
        }catch(Exception e){
            ApplicationLogHandler.addExceptionLog('Omni_Aura_TemplateRequestController', e, null);
            auraResponse.success = false;
            auraResponse.message = Label.Omni_ActionOverride_NewTemplateRequest_TemplateCannotBeCreated;
        }
        return auraResponse;
    }
}