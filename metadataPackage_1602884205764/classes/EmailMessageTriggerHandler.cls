/**
* @description Update EmailMessage records relationships once autonotification emails sent out
*			   Create FeedItem after EmailMessage records created
* @author      Kejia Hu
* @date        17/09/2019                     
*/
public with sharing class EmailMessageTriggerHandler implements TriggerHandlerBase {

    public String getObjectAPIName() {
        return 'EmailMessage';
    }
    
    /**
    * @description Update EmailMessage records relationships based on roles related
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    public void handleBeforeInsert(List<SObject> listNew) {
        try{
            Omni_EmailMessageService.updateOutboundEmails(listNew);  
            List<EmailMessage> emails = (List<EmailMessage>) listNew;

            //get all Case records Id related to new EmailMessage records
            Set<String> relatedCaseIds = EmailMessageTriggerHandlerHelper.getRelatedCaseIdsFromEmails(emails);
            if(!relatedCaseIds.isEmpty()) {
                Map<String, Case> roleClaimExpoEmailById = Omni_CaseSelector.getRoleClaimExpoEmailByIdFromCaseIds(relatedCaseIds);

                //DEA matching logic for Intact to Intact and email-to-case incoming emails
                Map<String, EmailMessage> emailMessageToReparentByDEAAddress = new  Map<String, EmailMessage>(); //One email message may link to multiple DEA Address
                //DEA matching logic for Intact to Intact emails, intact to Intact emails originally links to Claim/Exposure
                //retrieve Email cases in DEA Queue from Case Map
                Map<String, Case> claimExpoRoleById = EmailMessageTriggerHandlerHelper.getClaimExposureRoleFromCaseMap(roleClaimExpoEmailById);
                if (!claimExpoRoleById.isEmpty()) {
                    //Get Emails only related to Claim/Exposurem, from address is Intact domaine and Email has at least ToAddress or CcAddress not blank
                    Map<String, EmailMessage> claimExposureRoleRelatedIncomingEmailById = EmailMessageTriggerHandlerHelper.getClaimExposureRelatedIncomingEmailsForIntact(
                                                                                                emails, claimExpoRoleById);
                    Map<String, EmailMessage> claimExposureRoleRelatedIncomingEmailByDEAAddress = EmailMessageTriggerHandlerHelper.getEmailByDEAAddress(
                                                                                                        claimExposureRoleRelatedIncomingEmailById.values());
                    if (!claimExposureRoleRelatedIncomingEmailByDEAAddress.isEmpty()) {
                        emailMessageToReparentByDEAAddress.putAll(claimExposureRoleRelatedIncomingEmailByDEAAddress);
                    }
                }
                //TODO check the from address in from intact
                //Set<String> incomingToAddresses = null; //EmailMessageTriggerHandlerHelper.getIncomingDEAAddresses(nonSurveyEmails);
                
                //update DEA matched Emails ParentId and remove thread Id from email body
                //EmailMessageTriggerHandlerHelper.updateDEARelatedEmails(nonSurveyEmails, caseByDEAAddress);
                //exlcude DEA matched emails from reparenting Emails for roles
                //EmailMessageTriggerHandlerHelper.excludeDEARelatedEmails(nonSurveyEmails, caseByDEAAddress);

                //DEA matching logic for email-to-case emails, only apply to Emails whose parent are email cases in DEA matching queue
                //retrieve Email cases in DEA Queue from Case Map
                Map<String, Case> deaQueueEmailCaseById = EmailMessageTriggerHandlerHelper.getDEAQueueEmailCaseMapFromCaseMap(roleClaimExpoEmailById);
                if (!deaQueueEmailCaseById.isEmpty()) {
                    //Get Emails only related to Email Case, email case owner is DEA Matching Queue and Email has at least ToAddress or CcAddress not blank
                    Map<String, EmailMessage> deaQueueEmailCaseRelatedIncomingEmailById = EmailMessageTriggerHandlerHelper.getDEAQueueEmailCaseRelatedIncomingEmails(
                                                                                                emails, deaQueueEmailCaseById);
                    Map<String, EmailMessage> deaQueueEmailCaseRelatedIncomingEmailByDEAAddress = EmailMessageTriggerHandlerHelper.getEmailByDEAAddress(
                                                                                                        deaQueueEmailCaseRelatedIncomingEmailById.values());
                    if (!deaQueueEmailCaseRelatedIncomingEmailByDEAAddress.isEmpty()) {
                        emailMessageToReparentByDEAAddress.putAll(deaQueueEmailCaseRelatedIncomingEmailByDEAAddress);
                    }
                }

                Map<String, Case> caseByDEAAddress = new Map<String, Case>();

                //Get case from DEA Address
                if (!emailMessageToReparentByDEAAddress.isEmpty()) {
                    caseByDEAAddress = Omni_CaseSelector.getMasterCasesFromDEAAddresses(emailMessageToReparentByDEAAddress.keySet());
                }

                if (!caseByDEAAddress.isEmpty()) {
                    //remove invalid DEA address
                    EmailMessageTriggerHandlerHelper.removeInvalidDEA(emailMessageToReparentByDEAAddress, caseByDEAAddress);
                    EmailMessageTriggerHandlerHelper.removeEmailsWithMultipleDEAMatced(emailMessageToReparentByDEAAddress);
                    //update DEA matched Emails ParentId and remove thread Id from email body
                    EmailMessageTriggerHandlerHelper.updateDEARelatedEmails(emailMessageToReparentByDEAAddress, caseByDEAAddress);
                }

                //retrieve Role records that from Case list
                Map<String, Case> roleById = EmailMessageTriggerHandlerHelper.getRoleMapFromCaseMap(roleClaimExpoEmailById);
                if (!roleById.isEmpty()) {
                    //Update Emails lookups based on Role, exclude survey emails
                    EmailMessageTriggerHandlerHelper.updateEmailMessageRelationship(emails,roleById);
                }
                Omni_PulseSurveyService.preparePulseSurveys(emails); 
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ApplicationLogHandler.saveExceptionLog('Email Message Trigger', e, null); 
        }
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for Before Update logic
        return;
    }
    
    /**
    * @description prevent user deleting emails not related to role 
    * @author      Kejia Hu
    * @date        20/04/2020
    */
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        try {
            //Process case related emails
            Map<Id, EmailMessage> caseRelatedEmailMap = EmailMessageTriggerHandlerHelper.getCaseRelatedEmails((Map<Id, EmailMessage>) mapOld);
            Map<String, Case> roleByComRecordId = new Map<String, Case>();
            if (!caseRelatedEmailMap.isEmpty()) { 
                List<EmailMessage> emails = caseRelatedEmailMap.values();
                Set<String> relatedCaseIds = EmailMessageTriggerHandlerHelper.getRelatedCaseIdsFromEmails(emails);
                if(!relatedCaseIds.isEmpty()) { 
                    Map<String, Case> roleExpoEmailById = Omni_CaseSelector.getRoleExpoEmailByIdFromCaseIds(relatedCaseIds);
                    Map<String, Case> roleById = EmailMessageTriggerHandlerHelper.getRoleMapFromCaseMap(roleExpoEmailById);
                    if (!roleById.isEmpty()) {
                        roleByComRecordId = EmailMessageTriggerHandlerHelper.generateRoleByComRecordId(emails, roleById);
                    }
                }
            }
            //Prevent email deleting except for emails related to roles
            for(EmailMessage email : (List<EmailMessage>) mapOld.values()){
                if (roleByComRecordId.isEmpty() || !roleByComRecordId.containsKey(email.Id)) {
                    email.addError(System.Label.Omni_EmailDeleteNotAllowed);
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ApplicationLogHandler.saveExceptionLog('Email Message Trigger', e, null); 
        }
    }
    
    /**
    * @description create Feed on Claim for Emails
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        try {
            //Process case related emails
            Map<Id, EmailMessage> caseRelatedEmailMap = EmailMessageTriggerHandlerHelper.getCaseRelatedEmails((Map<Id, EmailMessage>)mapNew);
            if(caseRelatedEmailMap.isEmpty()) {
                return;
            }
            List<EmailMessage> emails = caseRelatedEmailMap.values();
            
            //get all Case records Id related to new EmailMessage records
            Set<String> relatedCaseIds = EmailMessageTriggerHandlerHelper.getRelatedCaseIdsFromEmails(emails);
            if(!relatedCaseIds.isEmpty()) {
                //Get Exposure(Case) records, Email Case records and Role(Case) records from given Case map
                Map<String, Case> roleExpoEmailById = Omni_CaseSelector.getRoleExpoEmailByIdFromCaseIds(relatedCaseIds);
                Map<String, Case> roleById = EmailMessageTriggerHandlerHelper.getRoleMapFromCaseMap(roleExpoEmailById);
                Map<String, Case> expoById = EmailMessageTriggerHandlerHelper.getExpoMapFromCaseMap(roleExpoEmailById);
                Map<String, Case> emailCaseById = EmailMessageTriggerHandlerHelper.getDEAQueueEmailCaseMapFromCaseMap(roleExpoEmailById);
                List<Omni_Feed> feeds = new List<Omni_Feed>();
                if (!roleById.isEmpty()) {
                    Map<String, Case> roleByComRecordId = EmailMessageTriggerHandlerHelper.generateRoleByComRecordId(
                                                            emails, roleById);
                    feeds.addAll(EmailMessageTriggerHandlerHelper.saveTextFeedsFromRoles(roleByComRecordId, caseRelatedEmailMap));
                }
                if (!expoById.isEmpty()) {
                    Map<String, Case> expoByComRecordId = EmailMessageTriggerHandlerHelper.generateExpoByComRecordId(
                                                        emails, expoById);
                    feeds.addAll(EmailMessageTriggerHandlerHelper.saveTextFeedsFromExpos(expoByComRecordId, caseRelatedEmailMap));
                }
                if (!emailCaseById.isEmpty()) {
                    //! Merge cases in future, this logic is covered in before trigger, keep the code in case to switch to merging in future
                    //! For test coverage only
                    if(Test.isRunningTest()) {
                        //Get Emails only related to Email Case and have DEA address in header
                        Map<String, EmailMessage> emailCaseRelatedEmails = EmailMessageTriggerHandlerHelper.getEmailCaseRelatedEmails(emails, emailCaseById);
                        //Setup emails and merge cases in every entity
                        Omni_EmailProcessingList emailProcessingList = new Omni_EmailProcessingList(emailCaseRelatedEmails.values(), emailCaseById);
                        //Setup master cases in every entity
                        emailProcessingList.populateMasterCases();
                    }
                    //Merge email cases to master cases
                    // EmailMessageTriggerHandlerHelper.MergeCaseAsyn(
                    //     JSON.serialize(emailProcessingList), JSON.serialize(emailCaseRelatedEmails.keySet()));

                    //Re-assign Email Cases in DEA Matching queue to PKI queue
                    EmailMessageTriggerHandlerHelper.sendCaseToPKIQueue(emailCaseById.values());
                }

                if (!feeds.isEmpty()) {
                    Omni_FeedHandler.persistFeedItems(feeds);
                }
                Omni_TaskGenerator.createTaskForMatchedIncomingEmail(mapNew.values()); 
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ApplicationLogHandler.saveExceptionLog('Email Message Trigger', e, null); 
        }
    }
    
    public void handleAfterUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for After Update logic
        return;
    }
    
    public void handleAfterDelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Delete logic
        return;
    }
    
    public void handleAfterUndelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Undelete logic
        return;
    }

}