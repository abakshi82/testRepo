({
    /**
     * @description Loads list of Roles related to Claim
     * @author      Luis Merinero
     * @date        05/12/2019                     
     */
    doInit: function(component, event, helper) {
        //if users goes back to correct data, populate previous selection
        if (component.get("v.flowStage") == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
            if (component.get("v.allRolesSelected").length > 0) {
                component.set("v.roleSelectedId", component.get("v.allRolesSelected")[0]);
            }
        }

        var rid = component.get("v.claimId");
        var action = component.get("c.getRoles");
        action.setParams({ claimId: rid });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.allRoles", response.getReturnValue());
                component.set("v.data", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Invokes filter method from helper
     * @author      Luis Merinero
     * @date        20/12/2019                     
     */
    doFilter: function(component, event, helper) {
        helper.FilterRecords(component);
    },

    onRoleSelected: function(component, event, helper) {
        component.set("v.roleSelectedId", event.getParam("selectedRole").Id);
        if (component.get("v.flowStage") == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
            component.set("v.preferredLanguage", event.getParam("selectedRole").Language_Preference__c);
        }

        helper.passSelectionToEmailSummary(component, event.getParam("selectedRole"));
    },



})