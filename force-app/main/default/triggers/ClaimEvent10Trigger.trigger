trigger ClaimEvent10Trigger on ClaimEvent_10__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}