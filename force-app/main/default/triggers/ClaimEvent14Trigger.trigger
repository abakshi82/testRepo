trigger ClaimEvent14Trigger on ClaimEvent_14__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}