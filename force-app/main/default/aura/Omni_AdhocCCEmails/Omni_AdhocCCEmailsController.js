({
    /**
     * @description Updates Flow Path
     * @author      Luis Merinero
     * @date        23/12/2019                     
     */
    doInit: function(component, event, helper) {
        //Set stage to CC Emails
        var selectEvent = component.getEvent("flowStageEvent");
        selectEvent.setParams({ "currentStage": $A.get("$Label.c.Omni_Adhoc_CCdRecipients") });
        selectEvent.fire();
    },

    /**
     * @description Update *valid* attribute
     * @author      Luis Merinero
     * @date        23/12/2019                     
     */
    validationMessage: function(component, event, helper) {
        var validation = component.find('ccEmailForm').checkValidity();
        component.set("v.valid", !validation);
    },

    /**
     * @description Manage Flow Navigation Buttons and Update Communication Summary
     * @author      Luis Merinero
     * @date        23/12/2019                     
     */
    onButtonPressed: function(component, event, helper) {
        var CCEmailsString = component.get("v.CCEmails");
        if (CCEmailsString) {
            var CCEmails = CCEmailsString.split(",");
            var selectEvent = component.getEvent("CCEmailsEvent");
            selectEvent.setParams({ "CCEmails": CCEmails });
            selectEvent.fire();
        }
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
    }
})