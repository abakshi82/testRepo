({
    /**
     * @Description: Initialize component
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    doInit: function(component, event, helper) {
        //if (_GLOBAL.getRole()) {
        //    helper.checkExisiting(component, event, helper);
        //}
    },

    persistGetParams: function(component, event, helper) {

        if (!helper.getIsSitePreview(window.location.hostname)) {
            if (_GLOBAL.getClaimId()) {
                helper.storeParams(component, event, helper);
                helper.setTransaltedContent(component, event, helper);
                helper.validateAndCreateSurveyResult(component, event, helper);
            } else {
                helper.fetchUrlParams(component, event, helper);
            }
        }
    },



    /**
     * @Description: Handle save action in the footer
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    addComment: function(component, event, helper) {
        helper.updateSurvey(component, event, helper);
    }

})