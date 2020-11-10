({
	/**
    * @description Shows modal and constructs lightning component containing the flow
    * @author      Luis Merinero
    * @date        20/12/2019                     
    */
    openSubtab : function(component,event,helper){

        if($A.util.isEmpty(component.get("v.flowName")))
        {
            helper.showToast(component,'error','ERROR','No Flow Name Defined', 'dismiss');
        }
        else
        {            
            var recordId = component.get("v.recordId");
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__Omni_RenderFlow"
                    },
                    "state": {
                        "uid": "1",
						"c__claimId": component.get("v.recordId"),
					}
                }
                
            	}).then(function(subtabId) {
					workspaceAPI.setTabLabel({
                		tabId: subtabId,
                		label: "Compose +"
            		});
            	}).catch(function(error) {
                	console.log(error);
            	});
        	});
        }

    },
    
	/**
    * @description Displays "Toast" message
    * @author      Luis Merinero
    * @date        20/12/2019                     
    */
    showToast : function(component,type,title,message, mode){
        
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type,
            "mode" : mode,
            "duration" : 8000
            
        });
        toastEvent.fire();        
    }
})