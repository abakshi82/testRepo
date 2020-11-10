trigger ClaimEvent9Trigger on ClaimEvent_9__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}