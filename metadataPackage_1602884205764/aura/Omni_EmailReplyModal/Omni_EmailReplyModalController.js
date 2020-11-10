({
    /**
     * @Description: Verify cases associated to the session
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    doInit: function(component, event, helper) {

        helper.getClaimInformation(component);
        helper.getUserInfo(component);
    },

    handleUploadFinished: function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var contentDocumentId = uploadedFiles[0].documentId;
        var contentDocumentName = uploadedFiles[0].name;
        helper.addDocumentId(component, contentDocumentId, contentDocumentName);

        //Display Success message
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The file has been uploaded succesfully.",
            "type": "success"
        });
        toastEvent.fire();
    },

    addRetrievedFile: function(component, event, helper) {
        var contentDocumentId = event.getParam("sDocumentId");
        var contentDocumentName = event.getParam("sContentDocumentName");
        helper.addDocumentId(component, contentDocumentId, contentDocumentName);
    },

    /**
     * @description Redirects the user to the Role (Case) tab, opens the email composer and pre-populates the To, CC, Email Template and Attachments
     * @author      Luis Merinero
     * @date        06/01/2020                  
     */
    openTab: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var parentId = component.get("v.claimId");
        var exposure = component.get("v.exposure");
        var emailMessageId = component.get("v.recordId");
        var isReplyAll = component.get("v.replyAll");
        var ToAddress = component.get("v.ToAddress");
        var CcAddress = component.get("v.CcAddress");

        if (!isReplyAll) {
            CcAddress = {};
        }

        if (exposure) {
            parentId = exposure.Id;
        }

        var focusedTabId;
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            focusedTabId = response.tabId;
        });
        workspaceAPI.openTab({
            url: '#/sObject/' + parentId + '/view',
            focus: true
        });
		
   
        var actionAPI = component.find("quickActionAPI");
        var fileIds = component.get("v.selectedIds");

     var oldBody = component.get("v.email").HtmlBody;
   var htmlBody = helper.buildReplyHtmlString(component) + oldBody;
 
        
        var fields = {
            ToAddress: { value: ToAddress },
            CcAddress: { value: CcAddress },
            ContentDocumentIds: { value: fileIds },
            HtmlBody: { value:   htmlBody },
            Subject: { value: 'RE: ' + component.get("v.email").Subject },
            ReplyToEmailMessageId: { value: emailMessageId },
        };
        console.log('ToAddress::' + ToAddress);
        var args = { actionName: "Case.SendEmail", targetFields: fields, entityName: "Case" };
        actionAPI.setActionFieldValues(args);
        workspaceAPI.closeTab({ tabId: focusedTabId });
    }


})