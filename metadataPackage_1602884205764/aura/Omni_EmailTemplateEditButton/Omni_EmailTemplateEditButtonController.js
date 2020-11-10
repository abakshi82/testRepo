({
    /**
    * @Description: Handle click on Edit Template button
    * @Author:      Damian Kazior, PwC
    * @Date:        02/07/2019
    */
    handleClickEdit : function(component, event, helper) {
        var emailTemplateId = component.get("v.templateRequest.Email_Template_Id__c");
        helper.navigateToEmailSetup(emailTemplateId, false);
    },

    /**
    * @Description: Handle click on New Template button 
    * @Author:      Damian Kazior, PwC
    * @Date:        02/07/2019
    */
   handleClickNew : function(component, event, helper) {
        helper.navigateToEmailSetup(null, true);
    },
    
})