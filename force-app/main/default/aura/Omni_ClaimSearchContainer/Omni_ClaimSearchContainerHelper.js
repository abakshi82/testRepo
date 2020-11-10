({
    /**
     * @Description: Update session record with claim or exposure selected
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    updateSessionWithCase: function(component, selectedCase) {
        var sessionRecordId = component.get("v.recordId");
        var action = component.get("c.updateSession");

        action.setParams({
            'sessionId': sessionRecordId,
            'claimId': selectedCase
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            if (state === "SUCCESS") { //general webservice success
                if (storeResponse.success) { //aura response
                    component.set("v.selectedClaim", component.get("v.selectedRecord.Name"));
                } else {
                    component.set("v.selectedClaim", 'ERROR - contact administrator');
                }
            }

            let errors = response.getError();
            if (errors && Array.isArray(errors) && errors.length > 0) {
                var message = errors[0].message;
                //TODO display error message to the user?
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @Description: If session does not have a case associated to it, display a modal 
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    getAssociatedClaim: function(component, event, sessionId) {
        var action = component.get("c.fetchCaseForSession");

        action.setParams({
            'sessionId': sessionId
        });

        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            var storeResponse = response.getReturnValue();

            if (state === "SUCCESS") {
                if (storeResponse.success) {
                    if (storeResponse.dataList[0]) {
                        component.set("v.selectedClaim", storeResponse.dataList[0].Name);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
})