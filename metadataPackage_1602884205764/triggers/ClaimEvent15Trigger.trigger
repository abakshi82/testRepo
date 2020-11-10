trigger ClaimEvent15Trigger on ClaimEvent_15__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}