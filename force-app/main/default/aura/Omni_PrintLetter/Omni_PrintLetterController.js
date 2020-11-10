({
    generateLetter: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL"); 
        var vfUrl = "/apex/OMNI_PreviewEditPrintLetter?tempId="+ component.get("v.templateId") + "&caseId=" + component.get("v.roleRecord").Id
        urlEvent.setParams({ 
            "url": vfUrl
        }); 
        urlEvent.fire();
    }
})