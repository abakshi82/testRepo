/**
 * @Description: helper class for FaxService and PrintService
 * @author:      Kejia Hu
 * @Date:        22-09-2019
 */
public with sharing class Omni_FaxPrintServiceHelper {
    
    public static Map<Id, Case> roleWithFormulaByCaseId;
    
    /**
     * @Description: convert and persist commConfigByRole map into List of Omni_Feed
     * @author:      Kejia Hu
     * @Date:        22-09-2019
     */
    public static List<Omni_Feed> convertToFeeds(Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> commConfigByRole, String channel) {
        roleWithFormulaByCaseId = Omni_CaseSelector.getCaseById(getIds(commConfigByRole.keySet()));
        List<Omni_Feed> omniFeedList = new List<Omni_Feed>();
        //convert to Omni_Feed List
        for (Omni_CommunicationDispatcher.RoleWithLog roleWithLog : commConfigByRole.keySet()) {
            Case role = roleWithLog.role;
            List<Omni_Feed> feedsToAdd = convertToFeeds(role, commConfigByRole.get(roleWithLog), channel);
            if (!feedsToAdd.isEmpty()) {
                omniFeedList.addAll(feedsToAdd);
            }
        }
        return omniFeedList;
    }

    /**
     * @Description: convert input into List of Omni_Feed
     * @author:      Kejia Hu
     * @Date:        23-09-2019
     */
    public static List<Omni_Feed> convertToFeeds(Case role, Set<Communication_Configuration__c> commConfigSet, String channel) {
        List<Omni_Feed> omniFeedList = new List<Omni_Feed>();
        for (Communication_Configuration__c config : commConfigSet) {
            if (channel == Omni_ClaimNotificationConstant.COMM_CHANNEL_FAX) {
                omniFeedList.addAll(creatOmniFeeds(role, channel, 
                                            config.Fax_Subject_EN__c + ' / ' + config.Fax_Subject_FR__c));
            } else if (channel == Omni_ClaimNotificationConstant.COMM_CHANNEL_PRINT) {
                omniFeedList.addAll(creatOmniFeeds(role, channel, 
                                            config.Print_Subject_EN__c + ' / ' + config.Print_Subject_FR__c));
            }
        }
        return omniFeedList;
    }

    /**
     * @Description: create Omni_Feed instance
     * @author:      Kejia Hu
     * @Date:        23-09-2019
     */
    public static List<Omni_Feed> creatOmniFeeds(Case role, String commType, String subject) {
        List<Omni_Feed> feeds = new List<Omni_Feed>();
        Case roleWithFormula = roleWithFormulaByCaseId.get(role.Id);
        String recipientFullName = '';
        if (null != roleWithFormula) {
            recipientFullName = (String.isBlank(roleWithFormula.Party_First_Name__c))
                                    ? ''
                                    : roleWithFormula.Party_First_Name__c + ' ';
            recipientFullName += roleWithFormula.Party_Last_Name__c;
        }
        if(role.ExposureForRole__c == null){
            Omni_Feed feedForClaim = new Omni_Feed();
            feedForClaim.channel = commType;
            feedForClaim.communicationName = subject;
            feedForClaim.recipients = recipientFullName;
            feedForClaim.Message = System.Label.Omni_FaxPrintFeedMessage;
            feedForClaim.parentId = role.ClaimForRole__c;
            feeds.add(feedForClaim);
        }else{
            Omni_Feed feedForExposure = new Omni_Feed();
            feedForExposure.channel = commType;
            feedForExposure.communicationName = subject;
            feedForExposure.parentId = role.ExposureForRole__c;
            feedForExposure.recipients = recipientFullName;
            feedForExposure.Message = System.Label.Omni_FaxPrintFeedMessage;
            feeds.add(feedForExposure); 

            Omni_Feed feedForClaim = new Omni_Feed();
            feedForClaim.channel = commType;
            feedForExposure.recipients = recipientFullName;
            feedForClaim.exposure = role.Exposure_Type_for_Role__c;
            feedForClaim.parentId = role.ClaimForRole__c;
            feeds.add(feedForClaim);     
        }
        return feeds;
    }

    /**
    * @Description: get caseId from given case Set
    * @Author:      Kejia Hu
    * @Date:        09/10/2019
    */
    private static List<String> getIds(Set<Omni_CommunicationDispatcher.RoleWithLog> cases) {
        List<String> ids = new List<String>();
        for (Omni_CommunicationDispatcher.RoleWithLog c : cases) {
            ids.add(c.role.Id);
        }
        return ids;
    }
}