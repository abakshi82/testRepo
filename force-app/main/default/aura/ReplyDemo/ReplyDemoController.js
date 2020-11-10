({
    doInit: function(component, event, helper) {


        var emailMessageId = component.get("v.recordId");

        var action = component.get("c.getemailMessageDetails");
        action.setParams({
            messageId: emailMessageId
        });

        action.setCallback(this, function(response) {
            var returnValue = response.getReturnValue();

            if (returnValue.data.Parent.RecordType.DeveloperName == 'Claim') {
                component.set("v.claimNumber", returnValue.data.Parent.ClaimNumber__c);
                component.set("v.claimId", returnValue.data.Parent.Id);
            } else if (returnValue.data.Parent.RecordType.DeveloperName == 'Benefits' || returnValue.data.Parent.RecordType.DeveloperName == 'BodilyInjury') {
                component.set("v.claimNumber", returnValue.data.Parent.ClaimForExposure__r.ClaimNumber__c);
                component.set("v.claimId", returnValue.data.Parent.ClaimForExposure__r.Id);
                component.set("v.exposure", returnValue.data.Parent);
            } else if (returnValue.data.Parent.RecordType.DeveloperName == 'OtherExposure') {
                component.set("v.claimNumber", returnValue.data.Parent.ClaimForExposure__r.ClaimNumber__c);
                component.set("v.claimId", returnValue.data.Parent.ClaimForExposure__r.Id);
                component.set("v.exposure", returnValue.data.Parent);
            } else {
                throw new Error("Your email message is not associated with valid record type");
            }

            component.set("v.FromAddress", returnValue.data.FromAddress);
            component.set("v.email", returnValue.data);
            component.set("v.HtmlBody",returnValue.data.HtmlBody);
            helper.openTab(component);
        })
        $A.enqueueAction(action);

    },



})