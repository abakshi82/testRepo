trigger ClaimEvent2Trigger on ClaimEvent_2__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}