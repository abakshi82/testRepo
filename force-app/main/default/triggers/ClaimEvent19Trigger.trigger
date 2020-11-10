trigger ClaimEvent19Trigger on ClaimEvent_19__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}