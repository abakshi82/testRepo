trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.execute(new Omni_UserTriggerHandler(), Trigger.operationType);  
}