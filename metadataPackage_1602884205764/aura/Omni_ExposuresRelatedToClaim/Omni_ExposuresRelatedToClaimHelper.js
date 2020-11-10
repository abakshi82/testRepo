({
	/**
    * @description Filters list based on keyword
    * @author      Luis Merinero
    * @date        30/12/2019                     
    */
    FilterRecords: function(component) { 
        var data = component.get("v.data");
        var allData = component.get("v.allExposures");
        var searchKey = component.get("v.filter"); 
        if(data!=undefined || data.length>0){
            var filtereddata = allData.filter(word => (!searchKey) || word.CaseNumber.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.ExposureType__r.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);  
            console.log('** '+filtereddata);  
        }  
        component.set("v.data", filtereddata);  
        if(searchKey==''){  
            component.set("v.data",component.get("v.allExposures"));  
        }  
    } 
})