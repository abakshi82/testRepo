({
	/**
    * @description Displays List of Exposures related to Claim
    * @author      Luis Merinero
    * @date        05/12/2019                     
    */
    doInit : function(component, event, helper) {
		var	rid = component.get("v.claimId");
        var action = component.get("c.getExposures");
        action.setParams({claimId : rid});
        action.setCallback(this, function(response){
            var name = response.getState();
            if (name === "SUCCESS") {
                component.set("v.allExposures", response.getReturnValue());
                component.set("v.data", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
		//Set stage to Exposure
        var selectEvent = component.getEvent("flowStageEvent");
        selectEvent.setParams({"currentStage": $A.get("$Label.c.Omni_Adhoc_Exposure")});
        selectEvent.fire();
    },
    
	/**
    * @description Stores Id of Exposure selected
    * @author      Luis Merinero
    * @date        05/12/2019                     
    */
    populateSelectedExposure: function(component, event, helper) {
        var selected = event.getParam("sExposureId");
        component.set("v.exposureSelected",selected);
        var selectedType = event.getParam("exposureType");
        component.set("v.exposureSelectedType",selectedType);
    },
    
	/**
    * @description Invokes filter method from helper
    * @author      Luis Merinero
    * @date        30/12/2019                     
    */
    doFilter: function(component, event, helper) {
        helper.FilterRecords(component);  
    } 
 })