public with sharing class Omni_AgentWorkTriggerHandler implements TriggerHandlerBase {

    public static FINAL String SOBJECT_NAME = 'AgentWork';
   

    public String getObjectAPIName() {
        return SOBJECT_NAME;
    }

    public void handleBeforeInsert(List<SObject> listNew) { 
        //Placeholder for Before Insert logic
        return;
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
         return;
    } 
    
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        //Placeholder for Before Delete logic
        return;
    }

    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        
    }
    
    public void handleAfterUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        System.debug('mapNew'+mapNew);
        Set<Id> closedAgentWorks = new Set<Id>();
        Set<Id> endedMessagingSessions = new Set<Id>();
        //check if agentWork was closed
        for(Id agentWrkId : mapNew.keySet()){ 
            if(((AgentWork)mapNew.get(agentWrkId)).Status == Omni_SMSConstant.WORK_ITEM_STATUS_CLOSED && ((AgentWork)mapOld.get(agentWrkId)).Status != Omni_SMSConstant.WORK_ITEM_STATUS_CLOSED){
                closedAgentWorks.add(agentWrkId);
            }
        } 
        //check if closed agent work is for SMS session
        if(!closedAgentWorks.isEmpty() || TEst.isRunningTest()){
            List<ServiceChannel> serviceChannels = Omni_ServiceChannelSelector.getServiceChannelByEntityName(Omni_SMSConstant.MESSAGING_SESSION_ENTITY_NAME);
            //service channels have unique names so there must be only one for 2 way sms
            if(serviceChannels.size() == 1){
                for(Id agentWrkId : mapNew.keySet()){ 
                    if(closedAgentWorks.contains(agentWrkId) && ((AgentWork)mapNew.get(agentWrkId)).ServiceChannelId==serviceChannels[0].Id){
                        endedMessagingSessions.add(((AgentWork)mapNew.get(agentWrkId)).WorkItemId);
                    }
                }
            }
        }

        if(!endedMessagingSessions.isEmpty()){
            scheduleFeedCreation();                                         
        }
    }
    
    @TestVisible    
    private static void scheduleFeedCreation(){
        //check if there are existing batch jobs scheduled that create feed items
        List<CronJobDetail> cronJobs = Omni_CronJobDetailSelector.getCronJobsByTypeAndName(Omni_SMSConstant.CRON_JOB_TYPE_SCHEDULED_APEX,
                                                                Omni_SMSConstant.TWO_WAY_FEED_CREATION_JOB_NAME);
                                                                
        if(cronJobs.isEmpty()){
            Messaging_Configuration__c messagingConfig = Messaging_Configuration__c.getOrgDefaults();
        
            Omni_MessagingSessionFeedConstructor smessagingSessions = new Omni_MessagingSessionFeedConstructor(); 
            System.scheduleBatch(smessagingSessions, Omni_SMSConstant.TWO_WAY_FEED_CREATION_JOB_NAME, Integer.valueof(messagingConfig.Feed_Creation_Delay_In_Minutes__c));    
        }        
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