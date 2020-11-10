trigger ClaimEvent3Trigger on ClaimEvent_3__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}