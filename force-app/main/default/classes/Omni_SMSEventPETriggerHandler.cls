/**
* @description OM-1259 logic once Platform Event Claim_Notification__e trigger fires
* @author      Damian azior
* @date        04/11/2019                     
*/
public with sharing class Omni_SMSEventPETriggerHandler implements TriggerHandlerBase {

    public String getObjectAPIName() {
        return Omni_SMSConstant.EVENT_NAME;
    }
    
    public void handleBeforeInsert(List<SObject> listNew) {
        //Placeholder for Before Insert logic
        return;
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for Before Update logic
        return;
    }
    
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        //Placeholder for Before Delete logic
        return;
    }
    
    /**
    * @description After PE publishes, save data into salesforce and send notification
    * @author      Damian Kazior
    * @date        01/08/2019                     
    */ 
    public void handleAfterInsert(Map<Id, SObject> mapNew) {
 
        ApplicationLogHandler.clear();
        //events in current scope, populate scope based on the batch size
        List<Id> messagesInScope = new List<Id>();
        Integer counter = 0;
        SMS_Event__e resumeCheckPointEvent;
        try{
            for (SMS_Event__e event : (List<SMS_Event__e>) mapNew.values()){
                counter ++;
                //when reached the desired event batch size, quit loop and set resume point
                if (counter > Omni_SMSConstant.MAX_NUMBER_EVENTS_PER_PAYLOAD) {
                    break;
                } else {
                    resumeCheckPointEvent = event;
                    // Set Replay ID after which to resume event processing in new trigger execution.
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEvent.ReplayId);
                }
                messagesInScope.add(event.Live_Message_Id__c);
            }
            if (!messagesInScope.isEmpty()) {

                List<LiveMessage__c> liveMessages = Omni_LiveMessageSelector.getLiveMessagesByIds(messagesInScope);
                Omni_SMSService smsService = new Omni_SMSService();
                List<Omni_SMSService.SMSDataWrapper> dataWrappers = new List<Omni_SMSService.SMSDataWrapper>();
                for(LiveMessage__c liveMessage : liveMessages){
                    dataWrappers.add(Omni_SMSUtilities.createSMSDataWrapperFromLivemessage(liveMessage)); 
                }
                smsService.smsDataWrappers = dataWrappers;
                smsService.sendSMSMessages(); 
            }

        } catch(Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            Application_Log__c exceptionLog = ApplicationLogHandler.saveExceptionLog('SMS Message Event Bulk Exceptions' , e , null);
        } finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    	return;
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