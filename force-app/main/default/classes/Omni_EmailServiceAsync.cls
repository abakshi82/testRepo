/**
* @description OM-1259 Queueable job for sending emails and handle retry and log exception
* @author      Kejia Hu
* @date        31/10/2019                     
*/
public class Omni_EmailServiceAsync implements Queueable {

    String msgString;
    Boolean isARetryForException;
    Boolean isARetryForErrors;

    public static final String ORG_WIDE_ADDRESS_ID = getOrgWideEmailAddressId();

    public Omni_EmailServiceAsync(String msgString, Boolean isARetryForException, Boolean isARetryForErrors) {
        this.msgString = msgString;
        this.isARetryForException = isARetryForException;
        this.isARetryForErrors = isARetryForErrors;
    }
    
    public void execute(QueueableContext context) {
        ApplicationLogHandler.clear();
        List<Application_Log__c> eventLogs = new List<Application_Log__c>();
        List<Messaging.SingleEmailMessage> messagesToSend = new List<Messaging.SingleEmailMessage>();
        List<Omni_CommunicationDispatcher.Message> msgs = new List<Omni_CommunicationDispatcher.Message>();
        try {
            msgs = (List<Omni_CommunicationDispatcher.Message>) JSON.deserialize(msgString, List<Omni_CommunicationDispatcher.Message>.class);
            for (Omni_CommunicationDispatcher.Message msg : msgs) {
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                m.setTargetObjectId(msg.targetObjectId);
                m.setTemplateId(msg.templateId);
                m.setWhatId(msg.whatId);
                m.setReplyTo(msg.replyTo);
                if (null != ORG_WIDE_ADDRESS_ID) {
                    m.setOrgWideEmailAddressId(ORG_WIDE_ADDRESS_ID);
                }
                messagesToSend.add(m);
                Application_Log__c eventLog  = new Application_Log__c();
                eventLog.RecordTypeId        = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
                eventLog.Application_Name__c = (isARetryForException || isARetryForErrors) 
                                                ? Omni_ClaimNotificationConstant.APP_NAME_EMAIL_ASYN_LOG_RETRY
                                                : Omni_ClaimNotificationConstant.APP_NAME_EMAIL_ASYN_LOG;
                eventLog.Category__c         = Omni_SMSConstant.SMS_EVENT_CATEGROY_INTEGRATION;
                eventLog.Application_Log__c = msg.logId;
                eventLog.Transaction_Id__c = msg.transactionId;
                eventLog.Description__c  = 'Email Template Id: ' + msg.templateId + '; Target Contact Id: ' + msg.targetObjectId + 
                                            '; Related To Record Id: ' + msg.whatId;
                eventLogs.add(eventLog);
            }
            insert eventLogs;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messagesToSend, false);
            //Log errors in sendResult and link it to the first Email log
            List<Integer> indexListForErrorRetry = hanldeSendResults(results, eventLogs[0].Id, isARetryForErrors);
            //Retry errored messages
            if (!isARetryForErrors && !indexListForErrorRetry.isEmpty()) {
                isARetryForErrors = true;
                //Build msgStringForErrorRetry from errorred message
                String msgStringForErrorRetry = JSON.serialize(pickErrorredMessages(indexListForErrorRetry, msgs));
                System.enqueueJob(new Omni_EmailServiceAsync(msgStringForErrorRetry, isARetryForException, isARetryForErrors));
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            if(isARetryForException) {
                //Exception occured again in Exception retry, log exception as an Email Asynchronous Exception Log
                ApplicationLogHandler.addExceptionLog('Email Asynchronous Exception Log', e, eventLogs[0].Id);
            } else {
                ApplicationLogHandler.addExceptionLog('Email Asynchronous Retried Log', e, eventLogs[0].Id);
                //Resend the entire message list to the queuable job when exception occured first time
                isARetryForException = true;
                System.enqueueJob(new Omni_EmailServiceAsync(msgString, isARetryForException, isARetryForErrors));
            }
        } finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    }

    /**
    * @Description: check send result, log errors and build index for retry in errors occurs first time
    * @Author:      Kejia Hu
    * @Date:        04/10/2019
    */
    private static List<Integer> hanldeSendResults(List<Messaging.SendEmailResult> mailResults, String parentId, Boolean isARetryForErrors) {
        List<Integer> indexListForErrorRetry = new List<Integer>();
        for (Integer i=0; i<mailResults.size(); i++) {
            String errors = '';
            Messaging.SendEmailResult result = mailResults[i];
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError err : result.getErrors()) {
                    errors +=  'Error: ' + err.getMessage() + ', TargetObjectId: ' + err.getTargetObjectId() + '\n';
                }
                if(isARetryForErrors) {
                    ApplicationLogHandler.addExceptionLog('Email SendEmailError Log', new SendMessageException(errors), parentId);
                } else {
                    ApplicationLogHandler.addExceptionLog('Email SendEmailError Retried Log', new SendMessageException(errors), parentId);
                    indexListForErrorRetry.add(i);
                }
            }
        }
        return indexListForErrorRetry;
    }

    /**
    * @Description: get errored messages
    * @Author:      Kejia Hu
    * @Date:        13/11/2019
    */
    public static List<Omni_CommunicationDispatcher.Message> pickErrorredMessages(List<Integer> indexListForErrorRetry, 
                                                                                   List<Omni_CommunicationDispatcher.Message> allMessages) {
        List<Omni_CommunicationDispatcher.Message> messagesToRetry = new List<Omni_CommunicationDispatcher.Message>();
        for (Integer i : indexListForErrorRetry) {
            messagesToRetry.add(allMessages[i]);
        }
        return messagesToRetry;                                                                        
    }

    /**
    * @Description: get OrgWideEmailAddress from claim notification config metadata
    * @Author:      Kejia Hu
    * @Date:        25/09/2019
    */
    private static String getOrgWideEmailAddressId() {
        String fromAddress = Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('NotificationFromAddress');
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :fromAddress];
        return (owea.size()>0)  ? owea.get(0).Id : null;
    }

    /**
    * @Description: custom exception for webtext issues
    * @author:      Kejia Hu
    * @Date:        07/10/2019
    */
    public class SendMessageException extends Exception {}
}