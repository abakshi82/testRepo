({
    getMessagingUser: function(component, caseId) {
        var action = component.get("c.verifyMessagingUser");
        action.setParams({ caseId: caseId });

        action.setCallback(this, function(response) {
            var returnValue = response.getReturnValue();
            console.log(returnValue);
            if (returnValue.success == true) {
                this.navigateTo(returnValue.data.Id);
            } else {
                console.log('err');
                this.showError(component, returnValue.message);
            }
        })
        $A.enqueueAction(action);
    },

    navigateTo: function(recId) {

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },

    showError: function(component, errorMessage) {
        let toastParams = {
            title: "Error",
            message: errorMessage,
            type: "error"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();

    },
})