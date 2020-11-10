({
    /**
     * @description Stores Id of Role selected
     * @author      Luis Merinero
     * @date        05/12/2019                     
     */
    select: function(component, event, helper) {

        var role = component.get("v.role");


        var stage = component.get("v.flowStage");
        var roleEvent = $A.get("e.c:Omni_Adhoc_IndividualRoleSelectedEvent");
        console.log('stage' + stage);
        console.log('roleEvent' + roleEvent);
        roleEvent.setParams({
            "stage": stage,
            "selectedRole": role
        });
        console.log('FIRE');
        roleEvent.fire();
        console.log('FIRED');
        helper.changeUIOnSelect(component, event, helper);
    }

})