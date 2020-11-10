({
    /**
     * @description Checks if newly selected role already exists. If so, removes it from the array
     * @author      Damian Kazior   
     * @date        01/06/2020                     
     */
    populateRecipientRole: function(component, allRoleIdsSelected, roleCase) {
        var exists = false;
        allRoleIdsSelected.forEach(function(item, index, object) {

            if (roleCase.Id == item.Id) {
                exists = true;
                allRolesSelected.splice(index, 1);
            }
        });
        if (!exists) {
            allRolesSelected.push(roleCase);
        }
        return allRolesSelected;
    },
})