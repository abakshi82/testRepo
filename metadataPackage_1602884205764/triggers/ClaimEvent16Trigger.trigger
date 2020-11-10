trigger ClaimEvent16Trigger on ClaimEvent_16__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}