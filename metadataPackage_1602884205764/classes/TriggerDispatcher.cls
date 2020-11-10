/**
* @description dispatch logic for trigger
* @author      Kejia Hu
* @date        03/07/2019                     
*/
public class TriggerDispatcher {
    
    public static void execute(TriggerHandlerBase triggerhandler, System.TriggerOperation triggerOperation){
        
        Boolean isTriggerEnabled;
        String objName = triggerhandler.getObjectAPIName();
        Map<String, Boolean> triggerSwitchByObj = Utility.TRIGGER_SWTICH_BY_OBJ_NAME;
        if(triggerSwitchByObj.isEmpty() || !triggerSwitchByObj.containsKey(objName)) {
            isTriggerEnabled = true;
        } else {
            isTriggerEnabled = triggerSwitchByObj.get(objName);
        }
        
        if(!isTriggerEnabled) {
            return;
        }

        switch on triggerOperation {
            when BEFORE_INSERT {
                triggerhandler.handleBeforeInsert(Trigger.new);
            } when BEFORE_UPDATE {
                triggerhandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            } when BEFORE_DELETE {
                triggerhandler.handleBeforeDelete(Trigger.oldMap);
            } when AFTER_INSERT {
                triggerhandler.handleAfterInsert(Trigger.newMap);
            } when AFTER_UPDATE {
                triggerhandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
            } when AFTER_DELETE {
                triggerhandler.handleAfterDelete(Trigger.oldMap);
            } when AFTER_UNDELETE {
                triggerhandler.handleAfterUndelete(Trigger.oldMap);
            }
        }  
    }    
}