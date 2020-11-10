({
    /**
    * @description Shows modal and constructs lightning component containing the flow
    * @author      Luis Merinero
    * @date        20/12/2019                     
    */
    openSubtab : function(component,event,helper){          
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
})