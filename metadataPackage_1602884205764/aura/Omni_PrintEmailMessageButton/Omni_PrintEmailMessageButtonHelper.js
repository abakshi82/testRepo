({
    navigateToPDF: function(component, event) {
        var urlEvent = $A.get("e.force:navigateToURL"); 
        var vfUrl = "/apex/OMNI_ViewPrintLetterAsPDF?emailId="+ component.get("v.recordId")
        urlEvent.setParams({ 
            "url": vfUrl
        }); 
        urlEvent.fire();
    }
})