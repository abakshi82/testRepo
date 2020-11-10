trigger ClaimEvent18Trigger on ClaimEvent_18__e (after insert) {
	TriggerDispatcher.execute(new Omni_ClaimEventTriggerHandler(), Trigger.operationType);
}