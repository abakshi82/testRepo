({
	/**
    * @description Creates Shadow Role is Exposure is selected
    * @author      Luis Merinero
    * @date        06/01/2020                  
    */
	createShadowRole : function(component, helper, roleId, exposureId) {
		var action = component.get("c.getShadowRoleId");
        action.setParams({roleId : roleId, exposureId : exposureId});
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
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
    redirectToRole : function(component, parentId) {
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
        var rid = component.get("v.recordId");
        var toEmail = component.get("v.toEmail");
        var ccEmail = component.get("v.ccEmails");
        var fileIds = component.get("v.fileIds");
        var templateId = component.get("v.templateId");
        var fields = { ToAddress: {value: toEmail}, EmailTemplate: {value: templateId}, CcAddress: {value: ccEmail}, ContentDocumentIds: {value: fileIds}};
        var args = {actionName: "Case.SendEmail", targetFields: fields, entityName : "Case"};
        actionAPI.setActionFieldValues(args);
        workspaceAPI.closeTab({tabId: focusedTabId});
    }
})