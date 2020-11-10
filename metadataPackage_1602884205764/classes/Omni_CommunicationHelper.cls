/**
* @description OM-925 Helper class to manage the communications for events
* @author      Vikas Sharma
* @date        09/05/2019                     
*/
public with sharing class Omni_CommunicationHelper {
    //Replaced by Communication Dispacher

    // static final string EMAIL = 'EMAIL';
    // static final string SMS = 'SMS';
    // static final string FAX = 'FAX';
    // static final string PRINT = 'PRINT';
    // static String logParentId;
    
    // // method to send and select the communication channel
    
    // public static void send(string commType, 
    //                         Map<Case,List<String>> toSendData, 
    //                         Map<String, Id> emailTemplateIdWithName, 
    //                         Map<String, Account> accountIdToAccountInfo,
    //                         Map<Case, Set<Communication_Configuration__c>> toSendSMSCaseWithConfig,
    //                         String integrationLogId,
    //                         Map<Case, Set<Communication_Configuration__c>> toSendFaxPrint,
    //                         Map<Case, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplate,
    //                         Map<Case, Set<Communication_Configuration__c>> toSendPrint,
    //                         Map<Case, Set<Communication_Configuration__c>> toSendFax
    //                        )
    // {
    //     logParentId = integrationLogId;
    //     if (toSendData != null)
    //     {
    //         sendEmail(toSendData, emailTemplateIdWithName);
    //     }
        
    //     if (commType == SMS)
    //     {
    //         sendSMS(toSendData, accountIdToAccountInfo,toSendSMSCaseWithConfig,integrationLogId,toSendRoleWithListOfCommWithTemplate);
    //     }
        
    //     if (commType == FAX)
    //     {
    //         sendFax(toSendFax);
    //     }

    //     if (commType == PRINT)
    //     {
    //         sendPrint(toSendPrint);
    //     }
        
    // }
    
    // //Method to send emails
    // public static void sendEmail(Map<Case, List<String>> toSendEmail, 
    //                              Map<String, Id> emailTemplateIdWithName)
    // {
    //     //Get DEA Address by Case Id map from Roles
    //     Map<String, String> deaAddressByCaseId = getDEAByCaseId(getIds(toSendEmail.keySet()));

    //     List<Message> messagesToSend = new List<Message>();
    //     for(Case cs : toSendEmail.keySet()){
    //         String templateId;
    //         for(String currentTemplate : toSendEmail.get(cs)) {
    //             if (emailTemplateIdWithName.get(currentTemplate) != null) {
    //                 templateId = emailTemplateIdWithName.get(currentTemplate);
    //             }
                
    //             if (templateId != null){
    //                 Message m = new Message();
    //                 m.targetObjectId = cs.PartyContact__c;
    //                 m.templateId = templateId;
    //                 m.whatId = cs.id;
    //                 m.replyTo = deaAddressByCaseId.get(cs.Id);
    //                 messagesToSend.add(m);
    //             }
    //         }
    //     }
    //     //Send messages in future
    //     sendEmailMessagesAsync(messagesToSend, logParentId);
    // }
    // // place holder to send sms 
    // public static void sendSMS(Map<Case, List<String>> toSendSMS, Map<String, Account> accountIdToAccountInfo,
    //                            Map<Case, Set<Communication_Configuration__c>> toSendSMSCaseWithConfig, String integrationLogId,
    //                            Map<Case, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplate){
                                   
    //                                // Call SMS Methods
    //                                //Omni_SMSService smsService  = new Omni_SMSService();
    //                               // smsService.sendSMS(accountIdToAccountInfo, integrationLogId, 
    //                                //                   toSendRoleWithListOfCommWithTemplate);
    //                            }
    
    // //placeholder to send Fax
    // public static void sendFax(Map<Case, Set<Communication_Configuration__c>> commConfigSetByRole){
    //     // Omni_FaxService faxSerivce = new Omni_FaxService(commConfigSetByRole);
    //     // faxSerivce.handleFax();
    // }
    
    // //placeholder to send Fax
    // public static void sendPrint(Map<Case, Set<Communication_Configuration__c>> commConfigSetByRole){
    //     // Omni_PrintService printSerivce = new Omni_PrintService(commConfigSetByRole);
    //     // printSerivce.handlePrint();
    // }

    // /**
    // * @Description: send email in future until hit the limit
    // * @Author:      Kejia Hu
    // * @Date:        04/10/2019
    // */
    // private static void sendEmailMessagesAsync(List<Message> messages, String parentId) {
    //     try {
    //         for (Message message : messages) {
    //             if (Limits.getAsyncCalls() < Limits.getLimitAsyncCalls()) {
    //                 sendEmailAsyn(JSON.serialize(message), parentId);
    //             } else {
    //                 break;
    //             }
    //         }
    //     } catch (Exception e){
    //         ApplicationLogHandler.addExceptionLog('Email Error Log', null , parentId);
    //     }
    // }

    // /**
    // * @Description: get OrgWideEmailAddress from claim notification config metadata
    // * @Author:      Kejia Hu
    // * @Date:        04/10/2019
    // */
    // private static void hanldeSendResults(List<Messaging.SendEmailResult> mailResults, String parentId) {
    //     for (Messaging.SendEmailResult result : mailResults) {
    //         String errors = '';
    //             Application_Log__c eventLog  = new Application_Log__c();
    //             eventLog.RecordTypeId        = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
    //             eventLog.Application_Name__c = 'Email Log';
    //             eventLog.Category__c         = Omni_SMSConstant.SMS_EVENT_CATEGROY_INTEGRATION;
    //             eventLog.Application_Log__c = parentId;
    //             insert eventLog;
    //         if (!result.isSuccess()) {
    //             for (Messaging.SendEmailError err : result.getErrors()) {
    //                 errors +=  'Error: ' + err.getMessage() + ', TargetObjectId: ' + err.getTargetObjectId() + '\n';
    //             }
    //             ApplicationLogHandler.addExceptionLog('Email Error Log', new SendMessageException(errors), eventLog.Id);
    //         }
    //     }
    //     ApplicationLogHandler.persistApplicationLogs();
    // }
    
    // /**
    // * @Description: get OrgWideEmailAddress from claim notification config metadata
    // * @Author:      Kejia Hu
    // * @Date:        25/09/2019
    // */
    // private static String getOrgWideEmailAddressId() {
    //     String fromAddress = Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('NotificationFromAddress');
    //     OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :fromAddress];
    //     return (owea.size()>0)  ? owea.get(0).Id : null;
    // }

    // /**
    // * @Description: get caseId from given map
    // * @Author:      Kejia Hu
    // * @Date:        04/10/2019
    // */
    // private static List<String> getIds(Set<Case> cases) {
    //     List<String> ids = new List<String>();
    //     for (Case c : cases) {
    //         ids.add(c.Id);
    //     }
    //     return ids;
    // }

    // /**
    // * @Description: get DEA Addresses from Case Ids
    // * @Author:      Kejia Hu
    // * @Date:        04/10/2019
    // */
    // private static Map<String, String> getDEAByCaseId(List<String> caseIds) {
    //     Map<String, String> addressByCaseId = new Map<String, String>();
    //     List<Case> cases = Omni_CaseSelector.getCaseById(caseIds).values();
    //     if (!cases.isEmpty()) {
    //         for (Case c : cases) {
    //             addressByCaseId.put(c.Id, c.DEAForRole__c);
    //         }
    //     }
    //     return addressByCaseId;
    // }

    // /**
    // * @Description: custom exception for webtext issues
    // * @author:      Kejia Hu
    // * @Date:        07/10/2019
    // */
    // public class SendMessageException extends Exception {
    // }

    // /**
    // * @Description: send one email message in future
    // * @author:      Kejia Hu
    // * @Date:        07/10/2019
    // */
    // @future
    // public static void sendEmailAsyn(String msgString, String parentId) {
    //     try {
    //         Message msg = (Message) JSON.deserialize(msgString, Message.class);
    //         Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
    //         m.setTargetObjectId(msg.targetObjectId);
    //         m.setTemplateId(msg.templateId);
    //         m.setWhatId(msg.whatId);
    //         m.setReplyTo(msg.replyTo);
    //         String orgWideEmailAddressId = getOrgWideEmailAddressId();
    //         if (null != orgWideEmailAddressId) {
    //             m.setOrgWideEmailAddressId(orgWideEmailAddressId);
    //         }
    //         Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{m});
    //         hanldeSendResults(results, parentId);
    //     } catch (Exception e) {
    //         System.debug(e.getMessage() + ' ' + e.getStackTraceString());
    //         ApplicationLogHandler.addExceptionLog('Email Error Log', e, parentId);
    //     } finally {
    //         ApplicationLogHandler.persistApplicationLogs();
    //     }
    // }

    // private class Message {
    //     String targetObjectId;
    //     String templateId;
    //     String whatId;
    //     String replyTo;
    // }

    // public class RoleWithLog {
    //     public Application_Log__c log;
    //     public Case role;

    //     public RoleWithLog(Application_Log__c log, Case role) {
    //         this.log = log;
    //         this.role = role;
    //     }
    // }
}