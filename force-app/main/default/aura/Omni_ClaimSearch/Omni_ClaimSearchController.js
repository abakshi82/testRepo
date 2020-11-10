({
    /**
     * @Description: Handle focus event and display a list of suggestions
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    onfocus: function(component, event, helper) {
        //Placeholder. Update for actions on focus 
    },

    /**
     * @Description: Handle blur event and hide list of suggestions
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020 
     */
    onblur: function(component, event, helper) {
        component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },

    /**
     * @Description: Handle key press and present partial search suggestions. If there is more than one 
     *               character provided, display the lsit. Otherwise hide it
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    keyPressController: function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        //do not show suggestions for less than 5 digits
        if (getInputkeyWord.length > 4) {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        } else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    /**
     * @Description: Clear record selection
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    clear: function(component, event, heplper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord", null);
        component.set("v.listOfSearchRecords", null);
        component.set("v.selectedRecord", {});
    },

    /**
     * @Description: Handle user clicking on one of the records inthe sugestion list
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    handleComponentEvent: function(component, event, helper) {

        var selectedCase = event.getParam("recordByEvent");
        component.set("v.selectedRecord", selectedCase);

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
    }
})