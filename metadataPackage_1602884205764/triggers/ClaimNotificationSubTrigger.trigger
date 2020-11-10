/**
* @description trigger logic for Platform Event Claim_Notification_Sub__e
* @author      Kejia Hu
* @date        24/10/2019                     
*/
trigger ClaimNotificationSubTrigger on Claim_Notification_Sub__e (after insert) {

    TriggerDispatcher.execute(new Omni_ClaimNotificationSubTriggerHandler(), Trigger.operationType);

}