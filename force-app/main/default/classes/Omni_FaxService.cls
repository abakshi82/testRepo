/**
 * @Description: handle fax service logic, current fax service is done by CC
 * 				 salesforce only create feeditems per fax
 * @author:      Kejia Hu
 * @Date:        22-09-2019
 */
public with sharing class Omni_FaxService {
    
    private Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> commConfigByRole;
    
    public Omni_FaxService(Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> commConfigByRole) {
        this.commConfigByRole = commConfigByRole;
    }
    
    /**
     * @Description: convert input into FeedItem records for fax and persist 
     * @author:      Kejia Hu
     * @Date:        22-09-2019
     */
    public void handleFax() {
        List<Omni_Feed> feeds = Omni_FaxPrintServiceHelper.convertToFeeds(commConfigByRole, Omni_ClaimNotificationConstant.COMM_CHANNEL_FAX);
        if (!feeds.isEmpty()) {
            Omni_FeedHandler.persistFeedItems(feeds);
        }
        for (Omni_CommunicationDispatcher.RoleWithLog roleWithLog : commConfigByRole.keySet()) {
            ApplicationLogHandler.addLogWithTransId(
                Omni_ClaimNotificationConstant.APP_NAME_PRINT_LOG, null, roleWithLog.log.Id, roleWithLog.log.Transaction_Id__c);
        }
    }
}