/**
* @description Handle all trigger actions from ContentVersionTrigger
* @author      Kejia Hu
* @date        01/08/2019                     
*/
public with sharing class Omni_ContentVersionTriggerHandler implements TriggerHandlerBase {

    public static FINAL String SOBJECT_NAME = 'ContentVersion';

    public String getObjectAPIName() {
        return SOBJECT_NAME;
    }
  
    public void handleBeforeInsert(List<SObject> listNew) {
        if(UserInfo.getUserType() == 'Standard'){
       		this.validateFileUploadsPermissions(listNew);
        }
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for Before Update logic
        return;
    }
    
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        //Placeholder for Before Delete logic
        return;
    }

    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        //Placeholder for After Insert logic
        return;
    }

    public void handleAfterUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for After Update logic
        return;
    }
    
    public void handleAfterDelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Delete logic
        return;
    }
    
    public void handleAfterUndelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Undelete logic
        return;
    }

    /**
    * @description Block uploading files
    * @author      Damian Kazior
    * @date        23/08/2019                     
    */
    private void validateFileUploadsPermissions(List<User> newUsers){ 
        if(!FeatureManagement.checkPermission('Can_Upload_Files')){
            this.throwErrorOnFileUpload(newUsers);
        }
    }
 
    private void throwErrorOnFileUpload(List<SObject> files){ 
        for(SObject file : files){
            file.addError(Label.Omni_FileUpload_ErrorMessage);
        }
    }
}