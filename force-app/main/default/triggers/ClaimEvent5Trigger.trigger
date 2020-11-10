trigger ClaimEvent5Trigger on ClaimEvent_5__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}