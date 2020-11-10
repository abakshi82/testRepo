({
    /**
     * @Description: Handle click on New Template button 
     * @Author:      Damian Kazior, PwC
     * @Date:        02/02/2020
     */
    handleClickStart: function(component, event, helper) {
        var caseId = component.get("v.recordId");
        console.log(caseId);
        helper.getMessagingUser(component, caseId);
    },
})