({
     /**
     * @description Retrieves List of Email Templates
     * @author      Luis Merinero
     * @date        05/12/2019                     
     */
    doInit: function(component, event, helper) {
		var templateId = component.get("v.templateId");
        if(templateId == null){
            var action = component.get("c.getBlankTemplate");
            action.setCallback(this, function(result){
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
    				component.set("v.templateId", result.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    /**
    * @description Redirect to Role and open Email Composer
    * @author      Luis Merinero
    * @date        22/11/2019                     
    */
    openTab : function(component, event, helper) {
		var roleId = component.get("v.roleId");
		var exposureId = component.get("v.exposureId");
		var exposureForRole = component.get("v.exposureForRole");
        if(exposureId && exposureForRole != exposureId){
            helper.createShadowRole(component, helper, roleId, exposureId);
        }else{
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