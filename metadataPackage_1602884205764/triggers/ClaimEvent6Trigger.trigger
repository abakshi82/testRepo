trigger ClaimEvent6Trigger on ClaimEvent_6__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}