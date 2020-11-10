trigger ClaimEvent13Trigger on ClaimEvent_13__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}