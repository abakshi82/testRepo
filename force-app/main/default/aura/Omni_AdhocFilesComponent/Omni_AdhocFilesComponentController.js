({
    /**
     * @description Obtains List of Files from Salesforce that starts with the claim number (Will be replaced by EcM Integration)
     * @author      Luis Merinero
     * @date        03/01/2020                    
     */
    doInit: function(component, event, helper) {
        var action = component.get("c.getUserId");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.userId", result.getReturnValue());
            }
        });
        $A.enqueueAction(action);

        //Set stage to Files
        var selectEvent = component.getEvent("flowStageEvent");
        selectEvent.setParams({ "currentStage": $A.get("$Label.c.Omni_Adhoc_Files") });
        selectEvent.fire();

        //Redirect part
        var templateId = component.get("v.templateId");
        if (templateId == null) {
            var action = component.get("c.getBlankTemplate");
            action.setCallback(this, function(result) {
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.templateId", result.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    },

    /**
     * @description Handles Files retrieved from User's Computer
     * @author      Luis Merinero
     * @date        03/01/2020                     
     */
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
     * @description Redirect to Role and open Email Composer
     * @author      Luis Merinero
     * @date        22/11/2019                     
     */
    openTab: function(component, event, helper) {
        //TODO which role to select?
        var roleId = component.get("v.allRolesSelected")[0];
        console.log('roleId:' + roleId);
        var exposureId = component.get("v.exposureId");
        var exposureForRole = component.get("v.exposureForRole");
        if (exposureId && exposureForRole != exposureId) {
            helper.createShadowRole(component, helper, roleId, exposureId);
        } else {
            helper.redirectToRole(component, roleId);
        }
    },

    /**
     * @description Manage Flow Navigation Buttons and Update Communication Summary
     * @author      Luis Merinero
     * @date        23/12/2019                     
     */
    onButtonPressed: function(component, event, helper) {
        var actionClicked = event.getSource().getLocalId();
        var navigate = component.get('v.navigateFlow');
        navigate(actionClicked);
    }
})