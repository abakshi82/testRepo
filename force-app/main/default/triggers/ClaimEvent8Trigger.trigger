trigger ClaimEvent8Trigger on ClaimEvent_8__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}