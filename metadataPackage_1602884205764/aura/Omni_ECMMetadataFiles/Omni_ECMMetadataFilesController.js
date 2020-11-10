({
    /**
    * @description Retrieve ECM Metadata Records related to Email Message
    * @author      Luis Merinero
    * @date        03/02/2020                   
    */
    doInit : function(component, event, helper) {
        var colName = $A.get("$Label.c.Omni_ECMMetadataColumnName");
        var colType = $A.get("$Label.c.Omni_ECMMetadataColumnType");
        var colSize = $A.get("$Label.c.Omni_ECMMetadataColumnSize");
        var colLink = $A.get("$Label.c.Omni_ECMMetadataColumnLink");
		component.set('v.columns', [
            {label: colName, fieldName: 'ECM__c', type: 'text'},
            {label: colType, fieldName: 'ECM_File_Mime_Type__c', type: 'text'},
            {label: colSize, fieldName: 'ECM_File_Size__c', type: 'text'},
            {label: colLink, fieldName: 'eCM_File_URL__c', type: 'url', typeAttributes: { target: '_self', label: 'Go to eCM'}},
        ]);
        var emailMessageId = component.get("v.recordId");
        var action = component.get("c.getECMMetadataByEmailMessage");
        action.setParams({emailMessageId : emailMessageId});
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.filesList",result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})