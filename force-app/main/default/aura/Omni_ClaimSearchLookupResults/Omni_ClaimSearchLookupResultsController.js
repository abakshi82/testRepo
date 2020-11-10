({
    /**
     * @Description: Handle record selection. Pass chosen record in the event to the parent search component
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    selectRecord: function(component, event, helper) {
        var getSelectRecord = component.get("v.oRecord");
        var compEvent = component.getEvent("oSelectedRecordEvent");
        compEvent.setParams({ "recordByEvent": getSelectRecord });
        compEvent.fire();

        var compEvent = component.getEvent("oneRecordEvent");
        compEvent.setParams({ "recordByEvent": getSelectRecord });
        compEvent.fire();


    },
})