({
    /**
     * @description Helper - Adds ContentDocumentId to list of attachments and updates Summary Component
     * @author      Luis Merinero
     * @date        17/01/2020                    
     */
    addDocumentId: function(component, documentId, documentName) {
        var selectedIdsString = component.get("v.selectedIds");
        var fileNames = component.get("v.fileNames");
        fileNames.push(documentName);
        if (selectedIdsString == null) {
            selectedIdsString = documentId;
        } else {
            selectedIdsString += "," + documentId;
        }
        component.set("v.selectedIds", selectedIdsString);
        component.set("v.fileNames", fileNames);

        var selectEvent = component.getEvent("filesSelectedEvent");
        selectEvent.setParams({ "fileNames": fileNames });
        selectEvent.fire();
    },

    /**
     * @description Creates Shadow Role if Exposure is selected
     * @author      Luis Merinero
     * @date        06/01/2020                  
     */
    createShadowRole: function(component, helper, roleId, exposureId) {
        var action = component.get("c.getShadowRoleId");
        action.setParams({ roleId: roleId, exposureId: exposureId });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.redirectToRole(component, result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Redirects the user to the Role (Case) tab, opens the email composer and pre-populates the To, CC, Email Template and Attachments
     * @author      Luis Merinero
     * @date        06/01/2020                  
     */
    redirectToRole: function(component, parentId) {
        var workspaceAPI = component.find("workspace");
        var focusedTabId;
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            focusedTabId = response.tabId;
        });
        workspaceAPI.openTab({
            url: '#/sObject/' + parentId + '/view',
            focus: true
        });

        var actionAPI = component.find("quickActionAPI");

        var toEmails = component.get("v.allEmailsSelected");
        var toManualEmails = component.get("v.allManualEmailsSelected");
        var ccEmail = component.get("v.allCCEmailsSelected");
        var ccManualEmail = component.get("v.allManualCCEmailsSelected");
        var fileIds = component.get("v.selectedIds");
        var templateId = component.get("v.templateId");
        var fields = { ToAddress: { value: toEmails.concat(toManualEmails) }, EmailTemplate: { value: templateId }, CcAddress: { value: ccEmail.concat(ccManualEmail) }, ContentDocumentIds: { value: fileIds } };
        var args = { actionName: "Case.SendEmail", targetFields: fields, entityName: "Case" };
        actionAPI.setActionFieldValues(args);
        workspaceAPI.closeTab({ tabId: focusedTabId });
    }
})