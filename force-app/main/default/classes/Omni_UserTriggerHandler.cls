public without sharing class Omni_UserTriggerHandler implements TriggerHandlerBase {

    public static FINAL String SOBJECT_NAME = 'User';

    public String getObjectAPIName() {
        return SOBJECT_NAME;
    }

    public void handleBeforeInsert(List<SObject> listNew) { 
        //Placeholder for Before Insert logic
        return;
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        this.validateUserUpdatesPermissions(mapNew.values(), mapOld.values());
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
    * @description Block users from updating user records except language
    * @author      Damian Kazior
    * @date        23/08/2019                     
    */
    private void validateUserUpdatesPermissions(List<User> newUsers, List<User> oldUsers){

        if(!FeatureManagement.checkPermission('Can_Modify_User_Records')){
            Map<String, Schema.SObjectField> userFieldsMap = Schema.describeSObjects(new String[]{'User'})[0].fields.getMap();
            Set<User> usersInvalidUpdate = new Set<User>();
            for(Integer k=0; k<newUsers.size(); k++){
                for(Schema.SObjectField userFieldName : userFieldsMap.values()){
                    if(userFieldName.getDescribe().getName() !='LastPasswordChangeDate'){
                    //detect any change other than language
                    if(userFieldName.getDescribe().getName() != 'LanguageLocaleKey' &&
                        userFieldName.getDescribe().getName() != 'Language_Picker__c' &&
                        userFieldName.getDescribe().getName() != 'Title_1__c' &&
						userFieldName.getDescribe().getName() != 'Title_1_FR__c' &&
						userFieldName.getDescribe().getName() != 'Title_2__c' &&
						userFieldName.getDescribe().getName() != 'Title_2_FR__c' &&
						userFieldName.getDescribe().getName() != 'Share_Tasks_With__c' &&
						userFieldName.getDescribe().getName() != 'Delegated_User__c' &&
						userFieldName.getDescribe().getName() != 'AboutMe' &&
                        userFieldName.getDescribe().getName() != 'City' &&
                        userFieldName.getDescribe().getName() != 'Country' &&
                        userFieldName.getDescribe().getName() != 'Extension' &&
                        userFieldName.getDescribe().getName() != 'Fax' &&
                        userFieldName.getDescribe().getName() != 'Phone' &&
                        userFieldName.getDescribe().getName() != 'PostalCode' &&
                        userFieldName.getDescribe().getName() != 'State' &&
                        userFieldName.getDescribe().getName() != 'Street' &&
                        newUsers[k].get(userFieldName) != oldUsers[k].get(userFieldName)){
                        usersInvalidUpdate.add(newUsers[k]);
                        break;
                    } 
                    }     
                }
            }
            this.throwErrorOnUserUpdate(usersInvalidUpdate);
        }
    }

    /**
    * @description throw error once inappropiate user tries to edit user record
    * @author      Damian Kazior
    * @date        23/08/2019                     
    */
    private void throwErrorOnUserUpdate(Set<User> users){
        for(SObject user : users){
            user.addError(Label.Omni_UserUpdate_ErrorMessage); 
        }
    }
}