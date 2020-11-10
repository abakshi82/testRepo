trigger ClaimEventBackupTrigger on ClaimEvent_Backup__e (after insert) {
    TriggerDispatcher.execute(new Omni_ClaimEventBackupTriggerHandler(), Trigger.operationType);
}