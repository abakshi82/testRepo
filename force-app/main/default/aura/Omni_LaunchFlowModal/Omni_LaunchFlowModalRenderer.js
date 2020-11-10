({

    afterRender : function(component, helper) {
        this.superAfterRender();
        var autoLaunchFlow = component.get("v.autoLaunchFlow");
        if(autoLaunchFlow)
        {
            helper.showModal(component,event,helper);
        }
    }

})