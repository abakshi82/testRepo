/**
* @Description contains data related to one Email Processing 
* @Author      Kejia Hu
* @Date        28/01/2020                     
*/
public with sharing class Omni_EmailProcessingEntity {

    public String deaKey;
    public Case masterCase;
    public Set<Case> mergeCases;
    public Map<String, EmailMessage> emailByCaseId;

    public Omni_EmailProcessingEntity(String deaKey) {
        this.deaKey = deaKey;
        if (null == mergeCases) {
            this.mergeCases = new Set<Case>();
        }
        if (null == emailByCaseId) {
            this.emailByCaseId = new Map<String, EmailMessage>();
        }
    }

    /**
    * @Description merge cases to master cases
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    public List<Omni_Feed> mergeCases() {
        List<Omni_Feed> feeds = new List<Omni_Feed>();
        if (null != masterCase) {
            Set<Id> ids = getIds(mergeCases);
            ids.add(masterCase.Id);
            Map<String, Case> caseById = Omni_CaseSelector.getMinCaseInfo(ids);
            if (null != masterCase && !mergeCases.isEmpty()) {
                for (Case mergeCase : mergeCases) {
                    masterCase = caseById.get(masterCase.Id); 
                    mergeCase =  caseById.get(mergeCase.Id); 
                    merge masterCase mergeCase;
                    Omni_Feed feedEmail = generateFeed(mergeCase);
                    if (null != feedEmail) {
                        feeds.add(feedEmail);
                    }
                }
            }
        }
        return feeds;
    }

    /**
    * @Description generate feed from a case
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    public Omni_Feed generateFeed(Case mergeCase) {
        Omni_Feed feedEmail;
        //Create feed item is master case is an exposure
        if (masterCase.recordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BI
                || masterCase.recordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS) { 
            feedEmail = new Omni_Feed();
            feedEmail.channel = Omni_ClaimEventConstant.COMM_CHANNEL_EMAIL;
            feedEmail.Exposure = Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID.get(masterCase.ExposureType__c).Name;
            feedEmail.parentId = masterCase.ClaimForExposure__c;
            feedEmail.recordId = emailByCaseId.get(mergeCase.Id).Id;
            feedEmail.createdDate = emailByCaseId.get(mergeCase.Id).CreatedDate;
        }
        return feedEmail;
    }

    /**
    * @Description get Ids from Cases
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    private Set<Id> getIds(Set<Case> cases) {
        Set<Id> ids = new Set<Id>();
        for(Case c : cases) {
            ids.add(c.Id);
        }
        return ids;
    }
}