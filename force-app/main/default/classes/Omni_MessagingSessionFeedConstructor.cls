global class Omni_MessagingSessionFeedConstructor implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        //get all messaging session for which there feed was not created
        String query = 'SELECT Id FROM MessagingSession WHERE ID not In (SELECT Messaging_Session__c FROM LiveMessage__c WHERE RecordTypeId = \''+Omni_SMSConstant.LIVEMESSAGE_2WAY_RECORDTYPE_ID+'\') AND Status = \'Ended\' AND CaseId != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<MessagingSession> scope){
        Set<Id> sessionIds = new Set<Id>();
        for(MessagingSession msgSession : scope){
            sessionIds.add(msgSession.Id);
        }
        
        try{
            processMessagingSessions(sessionIds);
        }catch (Exception e) {
            System.debug(e);
            ApplicationLogHandler.saveExceptionLog(Omni_SMSConstant.TWO_WAY_SMS_APPLICATION_NAME, e , null); 
        }
    }
   
   public static void processMessagingSessions(Set<Id> endedMessagingSessions) {

        Set<Id> cases = new Set<Id>();
        Map<Id, MessagingSession> messagingSessionDetails = Omni_MessagingSessionSelector.getMessagingSessionsById(endedMessagingSessions);
        
        for(MessagingSession msgSession : messagingSessionDetails.values()){ 
            cases.add(msgSession.CaseId);
        } 
 
        Map<Id, Case> linkedCases = Omni_CaseSelector.getCasesByIds(cases);

        Map<Id, String> sessionIdToConversation = mapSessionToConversationBlock(endedMessagingSessions);

        System.debug('sessionIdToConversation::'+sessionIdToConversation);

        List<LiveMessage__c> liveMessages = new List<LiveMessage__c>();
        for(Id messagingSessionId : sessionIdToConversation.keySet()){
            Case claimExposure = linkedCases.get((messagingSessionDetails.get(messagingSessionId)).CaseId); 
            MessagingEndUser messagingUser = messagingSessionDetails.get(messagingSessionId).MessagingEndUser; 
            liveMessages.add(createLiveMessageRecord(messagingSessionId, claimExposure, messagingUser, sessionIdToConversation.get(messagingSessionId)));
        }
        System.debug('liveMessages::'+liveMessages);
        insert liveMessages;
        List<FeedItem> feeds = genereateAndInsertFeedItems(liveMessages);
        System.debug('feeds'+feeds);
    }

    public static LiveMessage__c createLiveMessageRecord(Id messagingSessionId, Case claimExposure, MessagingEndUser messagingUser, String messageBody){

        LiveMessage__c liveMessage = new LiveMessage__c();
        liveMessage.RecordTypeId = Omni_SMSConstant.LIVEMESSAGE_2WAY_RECORDTYPE_ID;

        if(claimExposure.RecordType.developerName == Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME){

            liveMessage.Claim_For_Role__c = claimExposure.Id; 
            liveMessage.Case__c           = claimExposure.Id;

        }else if(claimExposure.RecordType.developerName == Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS ||
                claimExposure.RecordType.developerName == Omni_ClaimEventConstant.EXPOSURE_TYPE_BODILY_INJURY  ||
                claimExposure.RecordType.developerName == Omni_ClaimEventConstant.EXPOSURE_TYPE_OTH_EXPOSURE){

            liveMessage.Exposure_For_Role__c = claimExposure.Id;
            liveMessage.Claim_For_Role__c    = claimExposure.ClaimForExposure__c;
            liveMessage.Case__c              = claimExposure.Id;
            liveMessage.Exposure_Type_Id__c  = claimExposure.ExposureType__c;
        }

        
        liveMessage.Messaging_Session__c    = messagingSessionId;
        liveMessage.Phone_Number__c         = messagingUser.MessagingPlatformKey;

        //person account has first name. Business account has Name only
        if(messagingUser.Account.FirstName == null){
            liveMessage.Recipient_Name__c = messagingUser.Account.Name;
        }else{
            liveMessage.Recipient_Name__c = messagingUser.Account.FirstName + ' ' +  messagingUser.Account.LastName;
        }
        liveMessage.Message_Text__c = messageBody;
        liveMessage.Status__c       = Omni_SMSConstant.SMS_STATUS_DELIVERED; 

        return liveMessage;
    }

    public static Map<Id, String> mapSessionToConversationBlock(Set<Id> endedMessagingSessions){

        List<ConversationEntry> conversationEntries = Omni_ConversationEntrySelector.getConversationEntriesBySessionIds(endedMessagingSessions);
        
        Map<Id, List<ConversationEntry>> sessionIdToConversationList = new Map<Id, List<ConversationEntry>>();
        for(ConversationEntry conversation : conversationEntries){
            if(!sessionIdToConversationList.containsKey(conversation.ConversationId)){
                sessionIdToConversationList.put(conversation.ConversationId, new List<ConversationEntry>());
            }
            sessionIdToConversationList.get(conversation.ConversationId).add(conversation);
        }

        Map<Id, String> sessionToConversation = new Map<Id, String>();
        for(Id sessionId : sessionIdToConversationList.keySet()){
            sessionToConversation.put(sessionId, createConversationBlock(sessionIdToConversationList.get(sessionId)));
        }
        return sessionToConversation;
    }

    private static String createConversationBlock(List<ConversationEntry> conversationEntries) {

        String conversation = '\n';
        for(ConversationEntry convEntry : conversationEntries){
            if(convEntry.ActorType == 'EndUser'){
                conversation += 'Customer' + ': ' + convEntry.Message + '\n';    
            }else{
                conversation += convEntry.ActorType + ': ' + convEntry.Message + '\n';
            }
        }
        return conversation;
    }

    public static List<FeedItem> genereateAndInsertFeedItems(List<LiveMessage__c> liveMessages) {

        Map<String, ExposureType__c> exposures = Omni_ClaimNotificationDAOHelper.EXPOSURE_TYPE_BY_ID;

        List<Omni_Feed> feeds = new List<Omni_Feed>();
        for(LiveMessage__c liveMessage : liveMessages){
            if(liveMessage.Exposure_For_Role__c == null){
                Omni_Feed roleFeed          = generateBaseFeed(liveMessage);
                roleFeed.bodyOfSMS          = liveMessage.Message_Text__c;
                roleFeed.recipientsName     = liveMessage.Recipient_Name__c;
                roleFeed.parentId           = liveMessage.Claim_For_Role__c; 
                feeds.add(roleFeed);
            }else{
                Omni_Feed exposureFeed      = generateBaseFeed(liveMessage);
                exposureFeed.bodyOfSMS      = liveMessage.Message_Text__c;
                exposureFeed.recipientsName = liveMessage.Recipient_Name__c;
                exposureFeed.parentId       = liveMessage.Exposure_For_Role__c;
                feeds.add(exposureFeed);   
        
                Omni_Feed claimFeed         = generateBaseFeed(liveMessage);
                claimFeed.exposure          = exposures.get(liveMessage.Exposure_Type_Id__c).Name;
                claimFeed.parentId          = liveMessage.Claim_For_Role__c;
                feeds.add(claimFeed);                 
            }    
        }
        return Omni_FeedHandler.persistFeedItems(feeds);
    }

    private static Omni_Feed generateBaseFeed(LiveMessage__c liveMessage){
         Omni_Feed omnifeed = new Omni_Feed();
         omnifeed.channel               = Omni_SMSConstant.SMS_COMMUNICATION_FEED_NAME;
         omnifeed.recipientsPhoneNumber = liveMessage.Phone_Number__c;
         //TODO
         //omnifeed.communicationName     = this.liveMessage.Communication_Configuration__r.SMS_Subject_EN__c + ' / ' + this.liveMessage.Communication_Configuration__r.SMS_Subject_FR__c;
         omnifeed.recordId              = liveMessage.Id;
         return omnifeed;
    }   

    global void finish(Database.BatchableContext BC){
        //TODO
    }
}