({
    /**
     * @description Obtains List of Files from ECM related to the Claim and (if applicable) to the exposure
     * @author      Luis Merinero
     * @date        16/01/2020                   
     */
    searchECMFiles: function(component, event, helper) {
        var claimNumber = component.get("v.claimNumber");
        console.log("exposureType::" + component.get("v.exposureType"));
        var exposureType = component.get("v.exposureType");
        var includeArchive = component.get("v.includeArchive");
        var action = component.get("c.ECMSearch");
        action.setParams({ claimNumber: claimNumber, exposureType: exposureType, includeArchive: includeArchive });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultString = result.getReturnValue();
                if (resultString === 'null') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Unable to locate files related to this claim. Please contact your administrator."
                    });
                    toastEvent.fire();
                } else {
                    var files = JSON.parse(resultString);
                    component.set("v.filesList", files);
                    component.set("v.data", files);
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Retrieves ContentVersion Id and stores it to add into Email Composer
     * @author      Luis Merinero
     * @date        16/01/2020                     
     */
    retrieveECMFile: function(component, event, helper) {
        event.getSource().set("v.disabled", true);
        var file = event.getSource().get("v.value");
        var fileName = file.documentTitle;
        var action = component.get("c.ECMRetrieveDocumentUrl");
        action.setParams({ cmpid: file.CMPID, cmpUrl: file.CMPURL });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.fireRetrievedEvent(result.getReturnValue(), fileName, component, event);
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Show/Hide Spinner when aura controller is in process
     * @author      Luis Merinero
     * @date        15/01/2020                     
     */
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true);
    },

    hideSpinner: function(component, event, helper) {
        component.set("v.Spinner", false);
    },

    doFilter: function(component, event, helper) {
        helper.filterRecords(component);
    },

})