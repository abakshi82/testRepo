public with sharing class Omni_PulseSurveyResultTriggerHandler implements TriggerHandlerBase {

    public static FINAL String SOBJECT_NAME = 'Pulse_Survey_Result__c';

    public String getObjectAPIName() { 
        return SOBJECT_NAME;
    }

    public void handleBeforeInsert(List<SObject> listNew) { 
        //Placeholder for Before Insert logic
        return;
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for Before Insert logic
        return;
    }
    
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        //Placeholder for Before Delete logic
        return;
    }

    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        //Create task for adjustor
        Omni_TaskGenerator.createTaskForPulseSurveyResult(mapNew.values());
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

    private void validateUserUpdatesPermissions(List<User> newUsers, List<User> oldUsers){
        //Placeholder for Before Insert logic
        return;
    }

    private void throwErrorOnUserUpdate(Set<User> users){
        //Placeholder for Before Insert logic
        return;
    }
}