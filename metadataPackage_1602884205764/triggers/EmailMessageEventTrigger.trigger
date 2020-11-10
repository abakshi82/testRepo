/**
* @description Event to send email messages in bulk
* @author      Kejia Hu
* @date        04/11/2019                     
*/
trigger EmailMessageEventTrigger on EmailMessage__e (after insert) {

    TriggerDispatcher.execute(new EmailMessageEventTriggerHandler(), Trigger.operationType);
}