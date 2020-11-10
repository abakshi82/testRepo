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
    },

    setTabName: function(component) {
        var workspaceAPI = component.find("workspace");
        var isReplyAll = component.get("v.replyAll");
        var label = '';
        if (isReplyAll) {
            label = $A.get("$Label.c.Omni_ReplyAllPlus");
        } else {
            label = $A.get("$Label.c.Omni_ReplyPlus");
        }
        console.log('label::' + label);
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: label
            });
        })
    },

    getClaimInformation: function(component) {
        var emailMessageId = component.get("v.recordId");
        var isReplyAll = component.get("v.replyAll");

        var action = component.get("c.getemailMessageDetails");
        action.setParams({
            messageId: emailMessageId
        });

        action.setCallback(this, function(response) {
            var returnValue = response.getReturnValue();
            console.log('claim::' + JSON.stringify(returnValue));
            if (returnValue.data.Parent.RecordType.DeveloperName == 'Claim') {
                component.set("v.claimNumber", returnValue.data.Parent.ClaimNumber__c);
                component.set("v.claimId", returnValue.data.Parent.Id);
            } else if (returnValue.data.Parent.RecordType.DeveloperName == 'Benefits' || returnValue.data.Parent.RecordType.DeveloperName == 'BodilyInjury') {
                component.set("v.claimNumber", returnValue.data.Parent.ClaimForExposure__r.ClaimNumber__c);
                component.set("v.claimId", returnValue.data.Parent.ClaimForExposure__r.Id);
                component.set("v.exposure", returnValue.data.Parent);
                component.set("v.exposureType", returnValue.data.Parent.RecordType.DeveloperName);
            } else if (returnValue.data.Parent.RecordType.DeveloperName == 'OtherExposure') {
                component.set("v.claimNumber", returnValue.data.Parent.ClaimForExposure__r.ClaimNumber__c);
                component.set("v.claimId", returnValue.data.Parent.ClaimForExposure__r.Id);
                component.set("v.exposure", returnValue.data.Parent);
                component.set("v.exposureType", returnValue.data.Parent.RecordType.DeveloperName);
            } else {
                component.set("v.invalidCase", true);
                throw new Error("Your email message is not associated with valid record type");
            }
            if (returnValue.data.Incoming) {
                component.set("v.isIncoming", true);
                component.set("v.ToAddress", returnValue.data.FromAddress);
                if (isReplyAll) {
                    var ccAddress = returnValue.data.CcAddress;
                    if (ccAddress) {
                        component.set("v.CcAddress", ccAddress.split(";").concat(returnValue.data.ToAddress.split(";")));
                    } else {
                        component.set("v.CcAddress", returnValue.data.ToAddress.split(";"));
                    }
                }
            } else {
                component.set("v.isIncoming", false);
                component.set("v.ToAddress", returnValue.data.ToAddress.split(";"));
                if (isReplyAll && returnValue.data.CcAddress) {
                    component.set("v.CcAddress", returnValue.data.CcAddress.split(";"));
                }
            }
            component.set("v.FromAddress", returnValue.data.FromAddress);
		 component.set("v.email", returnValue.data.Email);
    
        })
        $A.enqueueAction(action);
    },

    getUserInfo: function(component) {
        var userIdAction = component.get("c.getUserId");
        userIdAction.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.userId", result.getReturnValue());
            }
            this.setTabName(component);
        });
        $A.enqueueAction(userIdAction);
    },

    buildReplyHtmlString: function(component) {
        var fromName = component.get("v.email").FromName;
        if (!fromName) {
            fromName = '';
        }
        return '<br clear="none"/> ' +
            '<br clear="none" />' +
            '<br clear="none" />' +
            '--------------- ' + $A.get("$Label.c.Omni_EmailReply_OriginalMessage") + ' ---------------<br clear="none" />' +
            '<b>' + $A.get("$Label.c.Omni_EmailReply_From") + ':</b>' + fromName + ' [' + component.get("v.email").FromAddress + ']<br/>' +
            '<b>' + $A.get("$Label.c.Omni_EmailReply_Sent") + ':</b> ' + $A.localizationService.formatDate(component.get("v.email").MessageDate, "dd/MM/yyyy hh:mm a") + '<br/>' +
            '<b>' + $A.get("$Label.c.Omni_EmailReply_To") + ':</b> ' + component.get("v.email").ToAddress + '<br/>' +
            '<b>' + $A.get("$Label.c.Omni_EmailReply_Subject") + ':</b> ' + component.get("v.email").Subject + '<br/>' +
       '<br clear="none" />';

    },


})