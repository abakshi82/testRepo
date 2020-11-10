trigger ClaimEvent7Trigger on ClaimEvent_7__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}