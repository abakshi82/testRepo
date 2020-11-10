({
    doInit: function(component, event, helper) {
        var taskId = component.get("v.recordId");
        var action = component.get("c.changeOwner");
        action.setParams({
            taskId: taskId
        });
        action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    if (returnValue.success == true) {
                        $A.get('e.force:refreshView').fire();
                    }
                } else {
                    var rec = response.getReturnValue();
                }
                $A.get("e.force:closeQuickAction").fire();
            }

        );
        $A.enqueueAction(action);
    }
})