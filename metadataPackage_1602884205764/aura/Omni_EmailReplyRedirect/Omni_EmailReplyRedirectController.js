({
    doInit: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:Omni_EmailReplyModal",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                replyAll: false
            }
        });
        evt.fire();


    },
})