trigger ClaimEvent11Trigger on ClaimEvent_11__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}