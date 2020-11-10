({
	/**
    * @description Filters list based on keyword
    * @author      Luis Merinero
    * @date        20/12/2019                     
    */
    fireRetrievedEvent: function(documentId, fileName, component, event) { 
        var retrievedEvent = component.getEvent("fileRetrievedEvent");
        if(documentId){
        	retrievedEvent.setParams({ "sDocumentId": documentId, "sContentDocumentName": fileName});
        	retrievedEvent.fire();
        }else{
            //Display Error message
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Unable to retrieve your File. Please contact your administrator."
            });
            toastEvent.fire();
			event.getSource().set("v.disabled", false);
        }
    },
    
	/**
     * @description Filters Files by keyword
     * @author      Luis Merinero
     * @date        12/02/2020                    
     */
    filterRecords: function(component) {
        var data = component.get("v.data");
        var allData = component.get("v.filesList");
        var searchKey = component.get("v.filter");
        if (data != undefined || data.length > 0) {
            var filtereddata = allData.filter(word => (!searchKey) || word.documentTitle.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
        }
        component.set("v.data", filtereddata);
        if (searchKey == '') {
            component.set("v.data", component.get("v.filesList"));
        }
    },
})