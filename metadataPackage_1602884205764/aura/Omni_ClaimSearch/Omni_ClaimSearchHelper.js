({
    /**
     * @Description: Search cases based on provided keywords
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    searchHelper: function(component, event, getInputkeyWord) {

        var action = component.get("c.fetchLookUpValues");

        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName': 'Case'
        });

        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue().dataList;
                if (storeResponse.length == 0) {
                    component.set("v.Message", $A.get("$Label.c.Omni_ClaimSearch_NoResultsFound"));
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
})