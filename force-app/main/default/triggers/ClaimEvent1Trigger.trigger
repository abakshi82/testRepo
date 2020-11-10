trigger ClaimEvent1Trigger on ClaimEvent_1__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}