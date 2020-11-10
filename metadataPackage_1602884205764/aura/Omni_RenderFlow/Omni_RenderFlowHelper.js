({
    /**
     * @description Check if user provided at least one email. If so, enable 'next' button
     * @author      Damian Kazior   
     * @date        01/06/2020                     
     */
    validateRecipientEmails: function(component) {
        var appEvent = $A.get("e.c:Omni_Adhoc_ChangeNavigationStatus");
        if (component.get("v.allRolesSelected").length > 0) {
            appEvent.setParams({ "NextButtonActive": true });
        } else {
            appEvent.setParams({ "NextButtonActive": false });
        }
        console.log('fired:');
        appEvent.fire();
    },

    populateRecipientRole: function(component, allRolesSelected, roleCase) {
        allRolesSelected = [];
        allRolesSelected.push(roleCase);
        console.log('allRolesSelected:' + allRolesSelected);
        console.log('allRolesSelected:' + allRolesSelected[0].Id);
        return allRolesSelected;
    },

    populateRecipientRoleForCC: function(component, allRolesSelected, roleCase) {
        var exists = false;

        allRolesSelected.forEach(function(item, index, object) {
            //if exists in the array, remove
            if (roleCase.Id == item.Id) {
                exists = true;
                allRolesSelected.splice(index, 1);
            }

        });
        //if doesn't exist, add
        if (!exists) {
            allRolesSelected.push(roleCase);
        }
        return allRolesSelected;
    },


    extractIdFromRoles: function(allRolesSelected) {
        var allRoleIdsSelected = [];
        allRolesSelected.forEach(function(item, index, object) {
            allRoleIdsSelected.push(item.Id);
        });
        return allRoleIdsSelected;
    },
    extractEmailsFromRoles: function(allRolesSelected) {
        var allEmailsSelected = [];
        allRolesSelected.forEach(function(item, index, object) {
            allEmailsSelected.push(item.Email_Address_for_Role__c);
        });
        return allEmailsSelected;
    },

    /**
     * @description Component stores all roles and manual emails selected. package this data and
     *              and send to the container that saves these roles in the flow
     * @author      Damian Kazior   
     * @date        01/06/2020                     
     */
    passChosenRolesToFlow: function(component, stage, language, exposure, claimNumber) {
        if (component.get("v.allRolesSelected").length > 0) {
            var rolesEvent = $A.get("e.c:Omni_SelectedRolesEvent");
            if (stage == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
                rolesEvent.setParams({
                    "stage": stage,
                    "sRoleIds": component.get("v.allRoleIdsSelected"),
                    "sEmails": component.get("v.allEmailsSelected"),
                    "sLanguage": language,
                    "roleCases": component.get("v.allRolesSelected"),
                    "sExposure": exposure,
                    "sClaimNumber": claimNumber
                });

            } else {
                rolesEvent.setParams({
                    "stage": stage,
                    "sRoleIds": component.get("v.allCCRoleIdsSelected"),
                    "sEmails": component.get("v.allCCEmailsSelected"),
                    "sLanguage": language,
                    "roleCases": component.get("v.allCCRolesSelected"),
                    "sExposure": exposure,
                    "sClaimNumber": claimNumber
                });
            }
            rolesEvent.fire();
        }
    },

    passChosenManualEmailsToFlow: function(stage, emails) {
        if (emails.length > 0) {
            var emailsEvent = $A.get("e.c:Omni_Adhoc_AllManualEmailsEvent");
            if (stage == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
                emailsEvent.setParams({
                    "flowStage": stage,
                    "RoleEmails": emails
                });
            } else {
                emailsEvent.setParams({
                    "flowStage": stage,
                    "CCEmails": emails
                });
            }
            emailsEvent.fire();
        }
    },



})