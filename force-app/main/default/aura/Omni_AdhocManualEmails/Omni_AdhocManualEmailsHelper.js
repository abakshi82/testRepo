({
    passEmailsToParent: function(component) {
        var emailsString = component.get("v.emails");
        if (emailsString) {
            var emails = emailsString.split(",");
            var selectEvent = component.getEvent("ManualEmailsEvent");

            var flowStage = component.get("v.flowStage")
            if (flowStage == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
                console.log('recipient:');
                selectEvent.setParams({
                    "RoleEmails": emails,
                    "flowStage": $A.get("$Label.c.Omni_Adhoc_Recipient")
                });
            } else {
                console.log('cc:');
                selectEvent.setParams({
                    "CCEmails": emails,
                    "flowStage": $A.get("$Label.c.Omni_Adhoc_CCRecipients")
                });
            }
            selectEvent.fire();
        }
    }
})