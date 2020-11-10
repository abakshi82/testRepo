trigger ClaimEvent12Trigger on ClaimEvent_12__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}