/**
* @description helper class holds additional methods for trigger handler
* @author      Kejia Hu
* @date        04/11/2019                     
*/
public with sharing class EmailMessageEventTriggerHandlerHelper {
    
    /**
    * @description send multiple email messages asyn a time
    * @author      Kejia Hu
    * @date        04/11/2019                     
    */
    public static void sendEmailMessagesBulkAsyn(List<Omni_CommunicationDispatcher.Message> messagesToProcess) {
        List<Omni_CommunicationDispatcher.Message> messagesToSend = new List<Omni_CommunicationDispatcher.Message>();
        for (Integer i=0; i<messagesToProcess.size(); i++) {
            messagesToSend.add(messagesToProcess[0]);
            messagesToProcess.remove(0);
            if (i==Omni_ClaimNotificationConstant.NUM_EMAILS_TO_SEND_ASYN-1) {
                break;
            }
        }
        //Bulk email sending in queueable job
        System.enqueueJob(new Omni_EmailServiceAsync(JSON.serialize(messagesToSend), false, false));
        if (!messagesToProcess.isEmpty()) {
            sendEmailMessagesBulkAsyn(messagesToProcess);
        }
    }

    /**
    * @description generate Omni_CommunicationDispatcher.Message list from Email Message Event list, generate log per event
    * @author      Kejia Hu
    * @date        04/11/2019                     
    */
    public static List<Omni_CommunicationDispatcher.Message> generateCommMessagesFromEvents(List<EmailMessage__e> events) {
        List<Omni_CommunicationDispatcher.Message> messages = new List<Omni_CommunicationDispatcher.Message>();
        for (EmailMessage__e event : events) {
            Omni_CommunicationDispatcher.Message message = generateCommMessageFromEvent(event);
            messages.add(message);
        }
        return messages;
    }

    /**
    * @description generate Omni_CommunicationDispatcher.Message instance from one Email Message Event
    * @author      Kejia Hu
    * @date        04/11/2019                     
    */
    public static Omni_CommunicationDispatcher.Message generateCommMessageFromEvent(EmailMessage__e event) {
        Omni_CommunicationDispatcher.Message m = new Omni_CommunicationDispatcher.Message();
        m.targetObjectId = event.TargetObjectId__c;
        m.templateId = event.TemplateId__c;
        m.whatId = event.WhatId__c;
        m.replyTo = event.ReplyTo__c;
        m.transactionId = event.TransactionId__c;
        m.logId = event.LogId__c;
        return m;
    }
}