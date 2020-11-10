/**
* @Description: Controller for Omni_CloseWorkMergeCaseButton lightning component
* @Author:      Kejia Hu
* @Date:        21/01/2020
*/
public without sharing class Omni_MergeCase_AuraController {

    @AuraEnabled
    public static String mergeCaseToMaster(String mergeCaseId, String masterCaseId) {
        try {
            //! Delete AgentWorks that related to cases
            List<Agentwork> agentworks = [select Id, Status from Agentwork Where WorkItemId = :mergeCaseId OR WorkItemId = :masterCaseId];
            if (!agentworks.isEmpty()) {
                delete agentworks;
            }
            Map<Id, SObject> emailMap = new Map<Id, SObject>([SELECT Id, CreatedDate, HasAttachment, Subject FROM EmailMessage WHERE ParentId = :mergeCaseId]);
            List<EmailMessage> emails = (List<EmailMessage>) emailMap.values();
            //Merge cases 
            Map<Id, Case> masterCaseById = Omni_MergeCase_AuraHelper.mergeCases(mergeCaseId, masterCaseId);
            Case masterCase = masterCaseById.get(masterCaseId);
            Omni_TaskGenerator.createTaskForMatchedDEAEmail(masterCase, emails);
            //Create feed item is master case is an exposure
            if (masterCase.recordTypeId==Omni_ClaimEventConstant.RECORD_TYPE_ID_BI
                    || masterCase.recordTypeId==Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS
                    || masterCase.recordTypeId==Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE) { 
                if (!emails.isEmpty()) {
                    List<Omni_Feed> feeds = Omni_MergeCase_AuraHelper.generateFeedsFromEmailExpoForClaim(masterCase, emails);
                    Omni_FeedHandler.persistFeedItems(feeds);
                }
            }
            //Invoke ECM process for files and attachments
            EmailMessageTriggerHandlerHelper.excludeNoAttachmentEmails(emails);
            if (!emails.isEmpty()) {
                ECMDocumentsLinkTriggerHandler.manualTriggerHandler(emails);
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ApplicationLogHandler.saveExceptionLog('Email Case Manual Merge', e, null);
            //Return null when error occurs
            masterCaseId = null;
        }
        return masterCaseId;
    }
}