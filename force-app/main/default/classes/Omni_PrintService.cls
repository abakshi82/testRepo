/**
 * @Description: handle print service logic, current print service is done by CC
 * 				 salesforce only create feeditems per print once receive from payload
 * @author:      Kejia Hu
 * @Date:        22-09-2019
 */
public with sharing class Omni_PrintService {
    
    private Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> commConfigByRole;
    
    public Omni_PrintService(Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> commConfigByRole) {
        this.commConfigByRole = commConfigByRole;
    }
	
    /**
     * @Description: convert input into FeedItem records for print and persist 
     * @author:      Kejia Hu
     * @Date:        22-09-2019
     */
    public void handlePrint() {
        List<Omni_Feed> feeds = Omni_FaxPrintServiceHelper.convertToFeeds(commConfigByRole, Omni_ClaimNotificationConstant.COMM_CHANNEL_PRINT);
        if (!feeds.isEmpty()) {
            Omni_FeedHandler.persistFeedItems(feeds);
        }
        for (Omni_CommunicationDispatcher.RoleWithLog roleWithLog : commConfigByRole.keySet()) {
            ApplicationLogHandler.addLogWithTransId(
                Omni_ClaimNotificationConstant.APP_NAME_PRINT_LOG, null, roleWithLog.log.Id, roleWithLog.log.Transaction_Id__c);
        }
    }
}