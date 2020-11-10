({
    /**
     * @Description: Verify cases associated to the session
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    doInit: function(component, event, helper) {
        var sessionId = component.get("v.recordId");
        //helper.verifyAssociatedCase(component, event, sessionId);
    },

    /**
     * @Description: Handle save action in the footer
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    saveRecord: function(component, event, helper) {

        var selectedCase = component.get("v.selectedRecord");
        //if no case selected
        if (Object.keys(selectedCase).length == 0) {
            component.set("v.hasMissingClaimError", true);
        } else {
            component.set("v.hasMissingClaimError", false);
            helper.updateSessionWithCase(component, selectedCase.CaseId);
        }
    }
})