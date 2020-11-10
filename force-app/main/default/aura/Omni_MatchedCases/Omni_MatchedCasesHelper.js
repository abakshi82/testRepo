({
    /**
     * @Description: 
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    getCasesByPhoneNumber: function(component, sId) {
        var action = component.get("c.fetchCasesForPhoneNumber");

        action.setParams({
            'sessionId': sId
        });

        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue().dataList;
                if (storeResponse.length == 0) {
                    //component.set("v.Message", $A.get("$Label.c.Omni_ClaimSearch_NoResultsFound"));
                } else {
                    //component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }

            let errors = response.getError();
            if (errors && Array.isArray(errors) && errors.length > 0) {
                var errorMessage = errors[0].message;
                //TODO display error message to the user? 
            }
        });
        $A.enqueueAction(action);
    },
})