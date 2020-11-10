({
    /**
    * @Description: Leveraging lightning data model, fetch new Template Request instance
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */  
    iniatilizeNewRecord : function(component) {
        component.find("forceRecord").getNewRecord(
            "Template_Request__c",
            null,
            false,
            $A.getCallback(function() {
                var rec = component.get("v.propertyRecord");
                var error = component.get("v.recordError");
                if (error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
            })
        );
    },

    /**
    * @Description: Since Email template cannot be a lookup to an object, we store template ID on request object and let user select 
    *               template from picklist. Fetch all templates into a picklist
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    fetchTemplateOptions : function(component) {
        var action = component.get("c.getEmailTemplates"); 
        action.setCallback(this, function(response) {
            var values = [];    
            var picklistMap = response.getReturnValue();
            for(var key in picklistMap){
                values.push({label:picklistMap[key], value:key});
            }
            component.set("v.templateOptions", values);
            //set first template in list as a default
            component.find("templateId").set("v.value", values[0].value);
        })
        $A.enqueueAction(action); 
    },
    
    /**
    * @Description: Find template name in a list by template Id selected by the user
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    getTemplateNameById : function(component, templateId) {
        var templateOptions = component.get("v.templateOptions");
        var templateName;
        for(var templateOptionIndex in templateOptions){
            if(templateOptions[templateOptionIndex].value == templateId){
                templateName = templateOptions[templateOptionIndex].label;
            }
        }
        return templateName;
    },
    
    /**
    * @Description: Pass request object from cmp and create new template request for edit (leverage lightning data service) or create
    *               new template in clone folder with prepopulated parameters
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    createNewTemplateRequest : function(component, helper) {
        if(component.get("v.templateRecord.Is_New_Template__c")){
            helper.createNewEmailTemplateAndNewRequest(component, helper);
        }else{
            helper.createNewRequestForExistingTemplate(component, helper);
        }
    },

    /**
    * @Description: Process template request for existing email template.
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
   createNewRequestForExistingTemplate : function(component, helper) {
        var tempRec = component.find("forceRecord"); 
        tempRec.saveRecord($A.getCallback(function(result) {
            var resultsToast = $A.get("e.force:showToast");
            if (result.state === "SUCCESS") {
                resultsToast.setParams({
                    "title": $A.get("$Label.c.Omni_ActionOverride_NewTemplateRequest_Success"),
                    "message": $A.get("$Label.c.Omni_ActionOverride_NewTemplateRequest_RecordCreatedSucessfully")
                });
                resultsToast.fire(); 
                var recId = result.recordId;
                helper.navigateTo(recId); 
            } else if (result.state === "ERROR") {
                console.log('Error: ' + JSON.stringify(result.error));
                resultsToast.setParams({
                    "title": $A.get("$Label.c.Omni_ActionOverride_NewTemplateRequest_Error"),
                    "message": $A.get("$Label.c.Omni_ActionOverride_NewTemplateRequest_ErrorMessage	") + JSON.stringify(result.error)
                });
                resultsToast.fire(); 
            } else {
                console.log('Unknown problem, state: ' + result.state + ', error: ' + JSON.stringify(result.error));
            }
        }));
    },

    /**
    * @Description: Create new email template and allow for modifications
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    createNewEmailTemplateAndNewRequest : function(component, helper) {
        
        var action = component.get("c.createNewEmailTemplate");
        action.setParams({
            templateRequest: component.get("v.templateRecord")
        });
        action.setCallback(this, saveCallback); 
        $A.enqueueAction(action);
 
        function saveCallback(response) { 
            var auraResponse = response.getReturnValue();
            var state = response.getState();
            var error ="";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
               if(auraResponse.success == true){
                    component.set("v.templateRecord.Email_Template_Id__c", auraResponse.data.Id);
                    helper.createNewRequestForExistingTemplate(component, helper);
                }else{
                    error = auraResponse.message;
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.Omni_ActionOverride_NewTemplateRequest_Error"),
                        "message": $A.get("$Label.c.Omni_ActionOverride_NewTemplateRequest_ErrorMessage	") + error
                    });
                    resultsToast.fire(); 
                }
            } else {
                error = response.getError;
            }
        }
    },

    /**
    * @Description: Navigate to sObject record (recId)
    * @Author:      Damian Kazior, PwC
    * @Date:        25/06/2019
    */
    navigateTo: function(recId) { 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },   

     /**
    * @Description: Validate input before saving
    * @Author:      Damian Kazior, PwC
    * @Date:        06/07/2019
    */
    validateInput: function(component) { 
        var isNewTemplate = component.get("v.isCreateNewTemplate");
        if(isNewTemplate){
            var newTemplateName = component.find("newTemplateNameInput").get("v.value");
            var patternValidity = component.find("newTemplateNameInput").get("v.validity");
            if(!newTemplateName || !patternValidity.valid){
               return false;
            }else{
               return true;
            }
        }
        return true;
    }     
})