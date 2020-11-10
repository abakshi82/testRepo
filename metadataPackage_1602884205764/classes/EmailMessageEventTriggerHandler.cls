/**
* @description logic once Platform Event EmailMessage__e trigger fires
* @author      Kejia Hu
* @date        04/11/2019                     
*/
public with sharing class EmailMessageEventTriggerHandler implements TriggerHandlerBase {
    public String getObjectAPIName() {
        return Omni_ClaimNotificationConstant.EMAIL_EVENT_NAME;
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
    
    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        ApplicationLogHandler.clear();
        //events in current scope, populate scope based on the batch size
        List<EmailMessage__e> eventsInScope = new List<EmailMessage__e>();
        Integer counter = 0;
        EmailMessage__e resumeCheckPointEvent;
        try{
            for (EmailMessage__e event : (List<EmailMessage__e>) mapNew.values()){
                counter ++;
                //when reached the desired event batch size, quit loop and set resume point
                if (counter > Omni_ClaimNotificationConstant.EMAIL_EVENT_BATCH_SIZE) {
                    break;
                } else {
                    resumeCheckPointEvent = event;
                    // Set Replay ID after which to resume event processing in new trigger execution.
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEvent.ReplayId);
                }
                eventsInScope.add(event);
            }
            //Send emails scope size is 50
            List<Omni_CommunicationDispatcher.Message> messagesToSend = 
                                    EmailMessageEventTriggerHandlerHelper.generateCommMessagesFromEvents(eventsInScope);
            EmailMessageEventTriggerHandlerHelper.sendEmailMessagesBulkAsyn(messagesToSend);
        } catch(Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            Application_Log__c exceptionLog = ApplicationLogHandler.addExceptionLog('Email Message Event Bulk Exceptions', e , eventsInScope[0].LogId__c);
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