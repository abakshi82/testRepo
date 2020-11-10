({
    doInit: function(component, event, helper) {
        var state = component.get('v.flowStage');
        var selectEvent = component.getEvent("flowStageEvent");
        selectEvent.setParams({ "currentStage": state });

        if (state == $A.get("$Label.c.Omni_Adhoc_CCRecipients")) {
            component.set("v.nextButtonDisabled", false);
            component.set("v.previousButtonDisabled", false);
            selectEvent.setParams({ "currentStage": $A.get("$Label.c.Omni_Adhoc_CCdRecipients") });
        } else {
            component.set("v.previousButtonDisabled", true);
            if (component.get('v.allRolesSelected').length > 0) {
                component.set("v.nextButtonDisabled", false);
            } else {
                component.set("v.nextButtonDisabled", true);
            }

        }
        selectEvent.fire();

    },

    /**
     * @description Manage Flow Navigation Buttons and Update Communication Summary
     * @author      Luis Merinero
     * @date        23/12/2019                     
     */
    onNextButtonPressed: function(component, event, helper) {
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
    },

    onPreviousButtonPressed: function(component, event, helper) {
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
    },

    /**
     * @description Once at least one email was selected as a recipient, user is allowed to continue with the flow
     * @author      Damian Kazior   
     * @date        01/06/2020                     
     */
    changeNavigationButtons: function(component, event, helper) {
        var nextButtonActive = event.getParam("NextButtonActive");
        component.set("v.nextButtonDisabled", !nextButtonActive);
    },

    /**
     * @description Save Roles to flow variable
     * @author      Damian Kazior   
     * @date        01/06/2020                     
     */
    saveAllSelectedRoles: function(component, event, helper) {
        var stage = event.getParam("stage");
        if (stage == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
            component.set("v.allRolesSelected", event.getParam("sRoleIds"));
            var exposureForRole = event.getParam("sExposure");
            component.set("v.exposureForRole", exposureForRole);
            var claimNumber = event.getParam("sClaimNumber");
            component.set("v.claimNumber", claimNumber);
            component.set("v.allEmailsSelected", event.getParam("sEmails"));
        } else {
            component.set("v.allCCEmailsSelected", event.getParam("sEmails"));
        }
    },

    /**
     * @description Save manual emails to flow variable
     * @author      Damian Kazior   
     * @date        01/06/2020                     
     */
    saveAllManualEmails: function(component, event, helper) {
        var stage = event.getParam("flowStage");
        if (stage == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
            component.set("v.allManualEmailsSelected", event.getParam("RoleEmails"));
        } else {
            component.set("v.allManualCCEmailsSelected", event.getParam("CCEmails"));
        }
    },


})