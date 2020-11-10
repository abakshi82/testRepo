trigger AgentWorkTrigger on AgentWork (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.execute(new Omni_AgentWorkTriggerHandler(), Trigger.operationType);
}