({
	mergeCases : function(component, event, mergeCaseId, masterCaseId) {
		var action = component.get("c.mergeCaseToMaster");
		action.setParams({
			"mergeCaseId" : mergeCaseId,
			"masterCaseId" : masterCaseId
		});

		action.setCallback(this, processCallBack);
		$A.enqueueAction(action);

		function processCallBack(response) {
			var returnId = response.getReturnValue();
			var state = response.getState();
			if (state === "SUCCESS") {
				if (returnId) {
					this.showSuccessToast(component, event);
					this.hideSpinnerWhileMerging(component, event);
					//Close Email Case tab and open the master claim or exposure record after merge
					var workspaceAPI = component.find("workspace");
					workspaceAPI.getFocusedTabInfo().then(function(response) {
						var focusedTabId = response.tabId;
						workspaceAPI.openTab({
							recordId: masterCaseId,
							focus: true,
							overrideNavRules: true
						}).then(
							function(newTabId) {
								workspaceAPI.closeTab({ tabId: focusedTabId }).then(
									function(success) {
										if (success) {
											workspaceAPI.focusTab(newTabId);
										}
									});
						}).catch(function(error) {
							console.log(error);
						});
					});
				} else {
					console.error('Controller method failed!');
					this.showErrorToast(component, event, $A.get("{!$Label.c.Omni_CaseMerge_Msg_MergeGoWrong}"));
					this.hideSpinnerWhileMerging(component, event);
					
				}
			}
			else if (state === "ERROR") {
				let errors = response.getError();
				let message = $A.get("{!$Label.c.Omni_CaseMerge_Msg_UnknowError}"); 
				if (errors && Array.isArray(errors) && errors.length > 0) {
					message = errors[0].message;
				}
				console.error(message);
				this.showErrorToast(component, event, message);
				this.hideSpinnerWhileMerging(component, event);
			}
		}
	},

    showSuccessToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": $A.get("{!$Label.c.Omni_CaseMerge_ToastTitle_Success}"),
			"message": $A.get("{!$Label.c.Omni_CaseMerge_Msg_MergeSuccess}"),
			"type": "success"
        });
        toastEvent.fire();
	},
	
	showErrorToast : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": $A.get("{!$Label.c.Omni_CaseMerge_ToastTitle_MergeFailed}"),
			"message": message,
			"type": "error"
        });
        toastEvent.fire();
	},
	
	showSpinnerWhileMerging: function (component, event) {
        var spinner = component.find("spinnerWhileMerging");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinnerWhileMerging: function (component, event) {
        var spinner = component.find("spinnerWhileMerging");
        $A.util.addClass(spinner, "slds-hide");
    }
})