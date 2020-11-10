({
    /**
     * @description Retrieves List of Email Templates
     * @author      Luis Merinero
     * @date        05/12/2019                     
     */
    doInit: function(component, event, helper) {
        helper.loadFolders(component);
        helper.queryEmailTemplates(component);

        //Set stage to Email Template
        var selectEvent = component.getEvent("flowStageEvent");
        selectEvent.setParams({ "currentStage": $A.get("$Label.c.Omni_Adhoc_EmailTemplate") });
        selectEvent.fire();
    },

    /**
     * @description Stores Email Template Id when Template selected
     * @author      Luis Merinero
     * @date        05/12/2019                     
     */
    selectTemplate: function(component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.templateId", selectedOptionValue);

        //Event to update Summary
        var opts = component.get("v.data");
        var selOpts = opts.filter(opt => selectedOptionValue.indexOf(opt.value) > -1);
        var selectEvent = component.getEvent("templateSelectedEvent");
        selectEvent.setParams({ "templateName": selOpts[0].label });
        selectEvent.fire();
    },

    /**
     * @description Stores Email Template Id when Template selected
     * @author      Luis Merinero
     * @date        05/12/2019                     
     */
    updateTemplatesQuery: function(component, event, helper) {
        helper.loadFolders(component);
        helper.queryEmailTemplates(component);
    },

    /**
     * @description Filters Email Templates by keyword 
     * @author      Luis Merinero
     * @date        20/12/2019                     
     */
    doFilter: function(component, event, helper) {
        helper.filterRecords(component);
    },

    /**
     * @description Show/Hide Spinner when aura controller is in process
     * @author      Luis Merinero
     * @date        17/01/2020                     
     */
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true);
    },

    hideSpinner: function(component, event, helper) {
        component.set("v.Spinner", false);
    }
})