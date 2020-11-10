/**
* @Description entity list for email processing
* @Author      Kejia Hu
* @Date        28/01/2020                     
*/
public with sharing class Omni_EmailProcessingList {

    public Map<String, Omni_EmailProcessingEntity> emailEntityByDEAKey;

    public Omni_EmailProcessingList(List<EmailMessage> emails, Map<String, Case> relatedCaseById) {
        Map<String, Omni_EmailProcessingEntity> emailEntityByDEAKey = new Map<String, Omni_EmailProcessingEntity>();
        for (EmailMessage email : emails) {
            String deaKey = EmailMessageTriggerHandlerHelper.getDEAValFromEmailHeaders(email).toUpperCase();
            Omni_EmailProcessingEntity emailEntity = (emailEntityByDEAKey.containsKey(deaKey)) 
                                                        ? emailEntityByDEAKey.get(deaKey)
                                                        : new Omni_EmailProcessingEntity(deaKey);
            emailEntity.emailByCaseId.put(email.ParentId, email);
            emailEntity.mergeCases.add(relatedCaseById.get(email.ParentId));
            emailEntityByDEAKey.put(deaKey, emailEntity);
        }
        this.emailEntityByDEAKey = emailEntityByDEAKey;
    }

    /**
    * @Description merge cases to master case and create feed item if master is claim
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    public void mergeCases() {
        List<Omni_Feed> feeds = new List<Omni_Feed>(); 
        for (Omni_EmailProcessingEntity emailEntity : emailEntityByDEAKey.values()) {
            List<Omni_Feed> feedsPerEntity = emailEntity.mergeCases();
            if (!feedsPerEntity.isEmpty()) {
                feeds.addAll(feedsPerEntity);
            }
        }
        if (!feeds.isEmpty()) {
            Omni_FeedHandler.persistFeedItems(feeds);
        }
        Omni_TaskGenerator.createTaskForMatchedDEAEmail(emailEntityByDEAKey.values());
    }

    /**
    * @Description set master case for entities
    * @Author      Kejia Hu
    * @Date        28/01/2020                     
    */
    public void populateMasterCases() {
        Map<String, Case> masterCaseByDEAKey = Omni_CaseSelector.getMasterCasesFromDEAAddresses(
                                                    this.emailEntityByDEAKey.keySet());
        if(!masterCaseByDEAKey.isEmpty()) {
            for (String aKey : this.emailEntityByDEAKey.keySet()) {
                this.emailEntityByDEAKey.get(aKey).masterCase = masterCaseByDEAKey.get(aKey);
            }
        }
    }
}