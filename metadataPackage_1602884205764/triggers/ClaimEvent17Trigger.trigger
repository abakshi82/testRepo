trigger ClaimEvent17Trigger on ClaimEvent_17__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}