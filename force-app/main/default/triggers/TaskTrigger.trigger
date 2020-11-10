trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    System.debug('***TaskTrigger Queries - Before:' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
    TriggerDispatcher.execute(new Omni_TaskTriggerHandler(), Trigger.operationType); 
    System.debug('***TaskTrigger Queries - After:' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
}