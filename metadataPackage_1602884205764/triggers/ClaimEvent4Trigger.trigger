trigger ClaimEvent4Trigger on ClaimEvent_4__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}