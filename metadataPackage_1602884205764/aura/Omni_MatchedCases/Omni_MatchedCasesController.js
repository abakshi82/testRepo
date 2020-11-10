({
    /**
     * @Description: Verify cases associated to the session
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    doInit: function(component, event, helper) {
        var sessionId = component.get("v.sessionId");
        console.log('sessionId:' + sessionId);
        helper.getCasesByPhoneNumber(component, sessionId);
    },

    /**
     * @Description: Handle user clicking on one of the records inthe sugestion list
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    handleComponentEvent: function(component, event, helper) {

        var selectedCase = event.getParam("recordByEvent");
        component.set("v.selectedRecord", selectedCase);

        // var forclose = component.find("lookup-pill");
        // $A.util.addClass(forclose, 'slds-show');
        // $A.util.removeClass(forclose, 'slds-hide');

        // var forclose = component.find("searchRes");
        // $A.util.addClass(forclose, 'slds-is-close');
        // $A.util.removeClass(forclose, 'slds-is-open');

        // var lookUpTarget = component.find("lookupField");
        // $A.util.addClass(lookUpTarget, 'slds-hide');
        // $A.util.removeClass(lookUpTarget, 'slds-show');
    }


})