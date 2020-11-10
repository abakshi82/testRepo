/**
* @description OM-98 trigger logic for Platform Event Claim_Notification__e
* @author      Kejia Hu
* @date        01/08/2019                     
*/
trigger ClaimNotificationPETrigger on Claim_Notification__e (after insert) {
    
	TriggerDispatcher.execute(new Omni_ClaimNotificationPETriggerHandler(), Trigger.operationType);
}