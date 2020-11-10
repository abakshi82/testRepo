/**
* @Description: Controller Helper for Omni_CloseWorkMergeCaseButton lightning component
* @Author:      Kejia Hu
* @Date:        21/01/2020
*/
public without sharing class Omni_MergeCase_AuraHelper {

    /**
    * @description merge Case records from Case records Ids and create feed iteams for Exposure
    * @author      Kejia Hu
    * @date        23/01/2020                     
    */
    public static Map<Id, Case> mergeCases(String mergeCaseId, String masterCaseId) {
        Map<Id, Case> caseById = Omni_CaseSelector.getCaseByIdForMerge(new List<String>{mergeCaseId, masterCaseId});
        Case masterCase = caseById.get(masterCaseId);
        Case mergeCase = caseById.get(mergeCaseId);
        merge masterCase mergeCase;
        return new Map<Id, Case>{masterCase.Id => masterCase};
    }

    /**
    * @description save FeedItems for an exposure
    * @author      Kejia Hu
    * @date        23/01/2020                     
    */
    public static List<Omni_Feed> generateFeedsFromEmailExpoForClaim(Case exposure, List<EmailMessage> emails) {
        List<Omni_Feed> feeds = new List<Omni_Feed>();
        for (EmailMessage email : emails) {
            Omni_Feed feedEmail = new Omni_Feed();
            feedEmail.channel = Omni_ClaimEventConstant.COMM_CHANNEL_EMAIL;
            feedEmail.Exposure = Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID.get(exposure.ExposureType__c).Name;
            feedEmail.parentId = exposure.ClaimForExposure__c;
            feedEmail.recordId = email.Id;
            feedEmail.createdDate = email.CreatedDate;
            feeds.add(feedEmail);
        }
        return feeds;
    }

}