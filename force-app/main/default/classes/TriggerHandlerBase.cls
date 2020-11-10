/**
* @description interface for trigger handler
* @author      Kejia Hu
* @date        03/07/2019                     
*/
public interface TriggerHandlerBase {
    
    String getObjectAPIName();
        
    void handleBeforeInsert(List<SObject> newList);
    
    void handleBeforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
    
    void handleBeforeDelete(Map<Id, SObject> oldMap);
    
    void handleAfterInsert(Map<Id, SObject> newMap);
    
    void handleAfterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
    
    void handleAfterDelete(Map<Id, SObject> oldMap);
    
    void handleAfterUndelete(Map<Id, SObject> oldMap);

}