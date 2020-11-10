/**
* @description sending emails and handle retry and log exception
*              retry once if exception occurred
*              retry only once if email sending have errors
* @author      Kejia Hu
* @date        19/12/2019                     
*/
public class Omni_EmailServiceSync {

    List<Omni_CommunicationDispatcher.Message> messages;
    Boolean isARetryForException;
    Boolean isARetryForErrors;

    public Omni_EmailServiceSync(List<Omni_CommunicationDispatcher.Message> messages, Boolean isARetryForException, Boolean isARetryForErrors) {
        this.messages = messages;
        this.isARetryForException = isARetryForException;
        this.isARetryForErrors = isARetryForErrors;
    }

    /**
    * @Description: parser input messages, build message to send and handle exception and sending errors
    * @Author:      Kejia Hu
    * @Date:        19/12/2019
    */
    public void sendEmails() {
        List<Application_Log__c> eventLogs = new List<Application_Log__c>();
        List<Messaging.SingleEmailMessage> messagesToSend = new List<Messaging.SingleEmailMessage>();
        //Set contact for test purpose, all emails will go to this contact once config active
        String testContactId = getTestContactId('AutomaticNotificationEmail');
        try {
            for (Omni_CommunicationDispatcher.Message msg : messages) {
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                if (String.isBlank(testContactId)) {
                    m.setTargetObjectId(msg.targetObjectId);
                } else {
                    m.setTargetObjectId(testContactId);
                }
                m.setTemplateId(msg.templateId);
                m.setWhatId(msg.whatId);
                m.setReplyTo(msg.replyTo);
                if (Omni_ClaimEventDAOHelper.orgWideEmailAddressByEmail.containsKey(msg.fromAddress)) {
                    m.setOrgWideEmailAddressId(Omni_ClaimEventDAOHelper.orgWideEmailAddressByEmail.get(msg.fromAddress).Id);
                }
                messagesToSend.add(m);
                Application_Log__c eventLog  = new Application_Log__c();
                eventLog.RecordTypeId        = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
                eventLog.Application_Name__c = (isARetryForException || isARetryForErrors) 
                                                ? 'Email Retry Log'
                                                : 'Email Log';
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
                List<Omni_CommunicationDispatcher.Message> msgsForErrorRetry = pickErrorredMessages(indexListForErrorRetry, messages);
                Omni_EmailServiceSync emailServiceSync =  new Omni_EmailServiceSync(msgsForErrorRetry, isARetryForException, isARetryForErrors);
                emailServiceSync.sendEmails();
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            if(isARetryForException) {
                //Exception occured again in Exception retry, log exception as an Email Asynchronous Exception Log
                ApplicationLogHandler.addExceptionLog('Email Exception', e, eventLogs[0].Id);
            } else {
                ApplicationLogHandler.addExceptionLog('Email Exception Retried', e, eventLogs[0].Id);
                //Resend the entire message list to the queuable job when exception occured first time
                isARetryForException = true;
                Omni_EmailServiceSync emailServiceSync =  new Omni_EmailServiceSync(messages, isARetryForException, isARetryForErrors);
                emailServiceSync.sendEmails();
            }
        } finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    }

    /**
    * @Description: get contact Id for communication test
    * @Author:      Kejia Hu
    * @Date:        28/02/2020
    */
    public static String getTestContactId(String configName){
        String contactId = '';
        if (Utility.COMM_TEST_CHANNEL_BY_NAME.containsKey(configName) 
            && true == Utility.COMM_TEST_CHANNEL_BY_NAME.get(configName).Active__c) {
                contactId = Utility.COMM_TEST_CHANNEL_BY_NAME.get(configName).ContactId__c;
        }
        return contactId;
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
                    ApplicationLogHandler.addExceptionLog('Email Sending Error', new SendMessageException(errors), parentId);
                } else {
                    ApplicationLogHandler.addExceptionLog('Email Sending Error Retried', new SendMessageException(errors), parentId);
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
    * @Description: custom exception for webtext issues
    * @author:      Kejia Hu
    * @Date:        07/10/2019
    */
    public class SendMessageException extends Exception {}

}