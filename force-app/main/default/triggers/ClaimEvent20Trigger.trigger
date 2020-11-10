trigger ClaimEvent20Trigger on ClaimEvent_20__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}