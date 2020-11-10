({
    /**
    * @Description: initialize component with data
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */  
    doInit  : function(component, event, helper) {
        helper.iniatilizeNewRecord(component);
        helper.fetchTemplateOptions(component);
    },

    /**
    * @Description: Handle selecting new template checkbox
    * @Author:      Damian Kazior, PwC
    * @Date:        05/07/2019
    */  
    handleCheckbox  : function(component, event, helper) {
        var templatePicklist  = component.find('templateId');
        if(templatePicklist.get('v.disabled')){
            templatePicklist.set('v.disabled',false);
            component.set("v.isCreateNewTemplate", false);
        }else{
            templatePicklist.set('v.disabled',true);
            component.set("v.isCreateNewTemplate", true);
        }
    },

    /**
    * @Description: Handle 'create' action
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */  
    saveRecord  : function(component, event, helper) {
        var isComponentValid = helper.validateInput(component);
        if(isComponentValid){
            var propTemplateId      = component.find("templateId").get("v.value");
            var isCreateNewTemplate = component.find('isCreateNew').get("v.value");
            component.set("v.templateRecord.Name", "new request"); //TODO what do we want the name to be?
            var templateName = '';
            if(isCreateNewTemplate){
                templateName = component.find('newTemplateNameInput').get("v.value");
            }else{
                templateName = helper.getTemplateNameById(component, propTemplateId);
                component.set("v.templateRecord.Email_Template_Id__c", propTemplateId);
            }
            component.set("v.templateRecord.Email_Template_Name__c", templateName);
            component.set("v.templateRecord.Is_New_Template__c", isCreateNewTemplate);
            helper.createNewTemplateRequest(component, helper); 
        }
    },

    /**
    * @Description: Handle 'cancel' action
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    cancelDialog : function(component, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Template_Request__c"
        });
        homeEvt.fire();
    }

})