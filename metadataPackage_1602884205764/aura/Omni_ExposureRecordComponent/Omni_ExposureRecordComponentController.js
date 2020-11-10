({
    /**
    * @description Stores Id of Exposure selected
    * @author      Luis Merinero
    * @date        05/12/2019                     
    */
    select : function(component, event, helper) {
        var selectEvent = component.getEvent("exposureSelectedEvent");
        var selected = component.get("v.selected");
        if(selected){
            selectEvent.setParams({ "sExposureId": null, "exposureCase": null, "exposureType": null});    
        }else{
            var exposureId = component.get("v.exposureId");
            var exposureType = component.get("v.exposureType");
            var exposure = component.get("v.exposure");
            selectEvent.setParams({ "sExposureId": exposureId, "exposureCase": exposure, "exposureType": exposureType});
        }
        selectEvent.fire();
    }
})