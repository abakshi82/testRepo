({
    openTab: function(component) {
    var workspaceAPI = component.find("workspace");
        var emailMessageId = component.get("v.recordId");
 var parentId = component.get("v.claimId");
        var exposure = component.get("v.exposure");
  var FromAddress = component.get("v.FromAddress");
        var CcAddress = component.get("v.CcAddress");
        var HtmlBody=component.get("v.HtmlBody");
console.log('****'+HtmlBody);
     if (exposure) {
            parentId = exposure.Id;
        }

        var focusedTabId;
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            focusedTabId = response.tabId;
        });
        workspaceAPI.openTab({
            url: '#/sObject/' + parentId + '/view',
            focus: true
        });

   var actionAPI = component.find("quickActionAPI");
 	console.log('ToAddress' + FromAddress);
      console.log('Email ID to Reply:' + emailMessageId);
        var fields = {
            //BccAddress: { value: '' },
              HtmlBody:{value:HtmlBody},
            ToAddress: { value: FromAddress },
            CcAddress: { value: CcAddress },
         ReplyToEmailMessageId: { value: '02s4c0000006WMxAAM' },
        };
        console.log('Email ID to Reply:' + emailMessageId);
        var args = { actionName: "Case.SendEmail", targetFields: fields, entityName: "Case" };
        actionAPI.setActionFieldValues(args);
        workspaceAPI.closeTab({ tabId: focusedTabId });
    }

})