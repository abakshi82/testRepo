/**
* @description handle email, SMS, Fax, Print communications for events
* @author      Kejia Hu
* @date        23/10/2019                     
*/
public class Omni_CommunicationDispatcher {
	static final string EMAIL = 'EMAIL';
    static final string SMS = 'SMS';
    static final string FAX = 'FAX';
    static final string PRINT = 'PRINT';
    
    // method to send and select the communication channel
    public static void send(string commType, 
                            Map<RoleWithLog, List<String>> toSendDataWithLog, 
                            Map<String, Id> emailTemplateIdWithName, 
                            Map<String, Account> accountIdToAccountInfo,
                            Map<Case, Set<Communication_Configuration__c>> toSendSMSCaseWithConfig,
                            String integrationLogId,
                            Map<Case, Set<Communication_Configuration__c>> toSendFaxPrint,
                            Map<RoleWithLog, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplate,
                            Map<RoleWithLog, Set<Communication_Configuration__c>> toSendPrintWithLog,
                            Map<RoleWithLog, Set<Communication_Configuration__c>> toSendFaxWithLog
                           )
    {
        if (toSendDataWithLog != null)
        {
            //Sending emails in queueable job through an email event bus
            //sendEmail(toSendDataWithLog, emailTemplateIdWithName);

            //Sending real time emails
            sendEmailSync(toSendDataWithLog, emailTemplateIdWithName);
        }
        
        if (commType == SMS)
        {
            sendSMS(null, accountIdToAccountInfo,toSendSMSCaseWithConfig,integrationLogId,toSendRoleWithListOfCommWithTemplate);
        }
        
        if (commType == FAX)
        {
            sendFax(toSendFaxWithLog);
        }

        if (commType == PRINT)
        {
            sendPrint(toSendPrintWithLog);
        }
        
    }
    
    //Method to send emails messages to an email event bus for sending
    // public static void sendEmail(Map<RoleWithLog, List<String>> toSendEmail, 
    //                              Map<String, Id> emailTemplateIdWithName)
    // {
    //     //Get DEA Address by Case Id map from Roles
    //     Map<String, String> deaAddressByCaseId = getDEAByCaseId(getIds(toSendEmail.keySet()));

    //     List<Message> messagesToSend = new List<Message>();
    //     //Email Message Event: for Sending email message
    //     List<EmailMessage__e> emailMessageEvents = new List<EmailMessage__e>();
    //     for(RoleWithLog roleWithLog : toSendEmail.keySet()){
    //         Case role = roleWithLog.role;
    //         String templateId;
    //         for(String currentTemplate : toSendEmail.get(roleWithLog)) {
    //             if (emailTemplateIdWithName.get(currentTemplate) != null) {
    //                 templateId = emailTemplateIdWithName.get(currentTemplate);
    //             }
    //             if (templateId != null){
    //                 EmailMessage__e emailEvent = new EmailMessage__e();
    //                 emailEvent.LogId__c = roleWithLog.log.Id;
    //                 emailEvent.TargetObjectId__c = role.PartyContact__c;
    //                 emailEvent.TemplateId__c = templateId;
    //                 emailEvent.ReplyTo__c = deaAddressByCaseId.get(role.Id);
    //                 emailEvent.WhatId__c = role.id;
    //                 emailEvent.TransactionId__c = roleWithLog.log.Transaction_Id__c;
    //                 emailMessageEvents.add(emailEvent);
    //             }

    //         }
    //     }
    //     //Publish Email Message Events:
    //     if (!emailMessageEvents.isEmpty()) {
    //         Eventbus.publish(emailMessageEvents);
    //     }
    // }

    /**
    * @description Method to send real time emails
    * @author      Kejia Hu
    * @date        19/12/2019                     
    */
    public static void sendEmailSync(Map<RoleWithLog, List<String>> toSendEmail, 
                                 Map<String, Id> emailTemplateIdWithName)
    {
        //Get DEA Address by Case Id map from Roles
        Map<String, String> deaAddressByCaseId = getDEAByCaseId(getIds(toSendEmail.keySet()));

        List<Message> messagesToSend = new List<Message>();
        //Email Message Event: for Sending email message
        List<EmailMessage__e> emailMessageEvents = new List<EmailMessage__e>();
        for(RoleWithLog roleWithLog : toSendEmail.keySet()){
            Case role = roleWithLog.role;
            String templateId;
            for(String currentTemplate : toSendEmail.get(roleWithLog)) {
                if (emailTemplateIdWithName.get(currentTemplate) != null) {
                    templateId = emailTemplateIdWithName.get(currentTemplate);
                }
                if (templateId != null){
                    Message msg = new Message();
                    msg.logId = roleWithLog.log.Id;
                    msg.targetObjectId = role.PartyContact__c;
                    msg.templateId = templateId;
                    msg.replyTo = deaAddressByCaseId.get(role.Id);
                    msg.whatId = role.id;
                    msg.transactionId = roleWithLog.log.Transaction_Id__c;
                    msg.fromAddress = Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('NotificationFromAddress');
                    messagesToSend.add(msg);
                }
            }
        }
        //Send Email Messages:
        if (!messagesToSend.isEmpty()) {
            sendEmailMessagesBulkSync(messagesToSend);
        }
    }

    // place holder to send sms 
    public static void sendSMS(Map<Case, List<String>> toSendSMS, Map<String, Account> accountIdToAccountInfo,
                               Map<Case, Set<Communication_Configuration__c>> toSendSMSCaseWithConfig, String integrationLogId,
                               Map<RoleWithLog, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplate){
                             
                                   // Call SMS Methods
                                   Omni_SMSService smsService  = new Omni_SMSService();
                                    smsService.sendSMS(accountIdToAccountInfo, toSendRoleWithListOfCommWithTemplate);
                               }
    
    //placeholder to send Fax
    public static void sendFax(Map<RoleWithLog, Set<Communication_Configuration__c>> commConfigSetByRole){
        Omni_FaxService faxSerivce = new Omni_FaxService(commConfigSetByRole);
        faxSerivce.handleFax();
    }
    
    //placeholder to send Fax
    public static void sendPrint(Map<RoleWithLog, Set<Communication_Configuration__c>> commConfigSetByRole){
        Omni_PrintService printSerivce = new Omni_PrintService(commConfigSetByRole);
        printSerivce.handlePrint();
    }

    /**
    * @description send multiple email messages by chunck of 10 maximun
    *              ! This method can handle maximum 100 emails, in case of more emails, need to build new logc to send additional ones
    *              ! a different transaction
    * @author      Kejia Hu
    * @date        19/12/2019                     
    */
    public static void sendEmailMessagesBulkSync(List<Omni_CommunicationDispatcher.Message> messagesToProcess) {
        List<Omni_CommunicationDispatcher.Message> messagesToSend = new List<Omni_CommunicationDispatcher.Message>();
        for (Integer i=0; i<messagesToProcess.size(); i++) {
            messagesToSend.add(messagesToProcess[0]);
            messagesToProcess.remove(0);
            if (i==Omni_ClaimEventConstant.NUM_EMAILS_TO_SEND_ASYN-1) {
                break;
            }
        }
        //Bulk email sending
        Omni_EmailServiceSync emailService =  new Omni_EmailServiceSync(messagesToSend, false, false);
        emailService.sendEmails();
        if (!messagesToProcess.isEmpty()) {
            sendEmailMessagesBulkSync(messagesToProcess);
        }
    }

    /**
    * @Description: get caseId from given map
    * @Author:      Kejia Hu
    * @Date:        04/10/2019
    */
    private static List<String> getIds(Set<RoleWithLog> cases) {
        List<String> ids = new List<String>();
        for (RoleWithLog c : cases) {
            ids.add(c.role.Id);
        }
        return ids;
    }

    /**
    * @Description: get DEA Addresses from Case Ids
    * @Author:      Kejia Hu
    * @Date:        04/10/2019
    */
    private static Map<String, String> getDEAByCaseId(List<String> caseIds) {
        Map<String, String> addressByCaseId = new Map<String, String>();
        List<Case> cases = Omni_CaseSelector.getCaseById(caseIds).values();
        if (!cases.isEmpty()) {
            for (Case c : cases) {
                addressByCaseId.put(c.Id, c.DEAForRole__c);
            }
        }
        return addressByCaseId;
    }

    public class Message {
        public String logId;
        public String targetObjectId;
        public String templateId;
        public String whatId;
        public String replyTo;
        public String transactionId;
        public String fromAddress;
    }

    public class RoleWithLog {
        public Application_Log__c log;
        public Case role;

        public RoleWithLog(Application_Log__c log, Case role) {
            this.log = log;
            this.role = role;
        }
    }
}