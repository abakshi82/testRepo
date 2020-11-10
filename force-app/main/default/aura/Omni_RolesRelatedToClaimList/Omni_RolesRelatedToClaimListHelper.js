({
    /**
     * @description Filters list based on keyword
     * @author      Luis Merinero
     * @date        20/12/2019                     
     */
    FilterRecords: function(component) {

        var data = component.get("v.data");
        var allData = component.get("v.allRoles");

        var searchKey = component.get("v.filter");
        if (data != undefined && data.length > 0) {
            console.log('allData::' + allData);
            var filtereddata = allData.filter(word => (!searchKey) || word.Nature_of_Role__c.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.PartyAccount__r.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.Email_Address_for_Role__c.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
            component.set("v.data", filtereddata);
            console.log('filtereddata::' + filtereddata);
        }

        if (searchKey == '') {
            component.set("v.data", component.get("v.allRoles"));
        }
    },

    passSelectionToEmailSummary: function(component, role) {
        var roleId = role.Id;
        console.log('roleId' + roleId);

        //var role = component.get("v.roleSelected");
        var stage = component.get("v.flowStage");
        var emailRecipient = role.Email_Address_for_Role__c;
        var exposureForRole = role.ExposureForRole__c;
        console.log('exposureForRole' + exposureForRole);
        var preferredLanguage = role.Language_Preference__c;
        var claimNumber = role.ClaimForRole__r.ClaimNumber__c;
        var selectEvent = component.getEvent("roleEventFired");
        selectEvent.setParams({
            "stage": stage,
            "sRoleId": roleId,
            "sEmail": emailRecipient,
            "sLanguage": preferredLanguage,
            "roleCase": role,
            "sExposure": exposureForRole,
            "sClaimNumber": claimNumber
        });
        selectEvent.fire();
        console.log('SENT');
    }
})