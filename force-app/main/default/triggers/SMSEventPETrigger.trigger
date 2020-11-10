trigger SMSEventPETrigger on SMS_Event__e (after insert) {
	TriggerDispatcher.execute(new Omni_SMSEventPETriggerHandler(), Trigger.operationType);
}