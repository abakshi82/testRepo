({
    /**
     * @description Updates Flow Path
     * @author      Luis Merinero
     * @date        23/12/2019                     
     */
    doInit: function(component, event, helper) {
        var allEmails = component.get("v.emailsArray");
        if (allEmails.length != 0) {
            component.set("v.emails", allEmails.join(", "))
        }
    },

    /**
     * @description Update *valid* attribute
     * @author      Luis Merinero
     * @date        23/12/2019                     
     */
    validationMessage: function(component, event, helper) {
        var validation = component.find('ccEmailForm').checkValidity();
        component.set("v.valid", !validation);
        if (validation) {
            helper.passEmailsToParent(component);
        }

    },
})