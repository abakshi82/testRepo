trigger ClaimEventDispatcherTrigger on ClaimEvent_Dispatcher__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventDispatcherTriggerHandler(), Trigger.operationType);
}