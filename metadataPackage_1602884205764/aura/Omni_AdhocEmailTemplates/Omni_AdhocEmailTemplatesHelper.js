({
    /**
     * @description Filters Email Templates by keyword
     * @author      Luis Merinero
     * @date        20/12/2019                     
     */
    filterRecords: function(component) {
        var data = component.get("v.data");
        var allData = component.get("v.templates");
        var searchKey = component.get("v.filter");
        if (data != undefined || data.length > 0) {
            var filtereddata = allData.filter(word => (!searchKey) || word.label.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
        }
        component.set("v.data", filtereddata);
        if (searchKey == '') {
            component.set("v.data", component.get("v.templates"));
        }
    },

    /**
     * @description Load List of Email Template Folders
     * @author      Luis Merinero
     * @date        02/01/2020                     
     */
    loadFolders: function(component) {
        var action = component.get("c.getFolderList");
        action.setParams({ objectType: "Email" });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let resp = response.getReturnValue();
                let folders = [];
                var language = component.get("v.preferredLanguage");

                resp.forEach(function(key) {
                    if (language == 'F') {
                        if (key.Name.substring(key.Name.length - 2) != 'EN') {
                            folders.push({ "label": key.Name, "value": key.Name });
                        }
                    } else {
                        if (key.Name.substring(key.Name.length - 2) != 'FR') {
                            folders.push({ "label": key.Name, "value": key.Name });
                        }
                    }
                });
                component.set("v.foldersList", folders);
            }
        })
        $A.enqueueAction(action);
    },


    /**
     * @description Query Email Templates by Folder Name and Language
     * @author      Luis Merinero
     * @date        02/01/2020                     
     */
    queryEmailTemplates: function(component) {
        var folderSelected = component.get("v.folderSelected");
        var language = component.get("v.preferredLanguage") == "F" ? "FR_%" : "EN_%";
        var action = component.get("c.getEmailTemplatesList");
        action.setParams({ "folderName": folderSelected, "language": language });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let resp = response.getReturnValue();
                let lables = [];
                resp.forEach(function(key) {
                    lables.push({ "label": key.Name, "value": key.Id });
                });
                component.set("v.filter", "");
                component.set("v.templates", lables);
                component.set("v.data", lables);
                this.setDefaultTemplate(component);
            }
        })
        $A.enqueueAction(action);
    },

    /**
     * @description Set blank template to be a default. When user does not select any template, blank will be preselected
     * @author      Damian Kazior
     * @date        02/01/2020                     
     */
    setDefaultTemplate: function(component) {
        var action = component.get("c.isABBIMember");
        var templates = component.get("v.data");
        var language = component.get("v.preferredLanguage") == "F" ? "FR_" : "EN_";

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let isABorBIGroupMember = response.getReturnValue();
                if (!isABorBIGroupMember) {
                    templates.forEach(function(key) {
                        if (key.label == language + 'Blank_Template_Pulse_Survey') {
                            component.set("v.templateId", key.value);
                        }
                    });
                }
            }
        })
        $A.enqueueAction(action);
    }
})