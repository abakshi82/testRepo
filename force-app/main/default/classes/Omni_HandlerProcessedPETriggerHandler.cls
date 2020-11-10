/**
* @description OM-98 logic once Platform Event Handler Processed trigger fires
* @author      Vikas Sharma
* @date        20/01/2020                     
*/
public with sharing  class Omni_HandlerProcessedPETriggerHandler  implements TriggerHandlerBase {
    public String getObjectAPIName() {
        return 'Handler_Processed__e';
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
    * @description After PE publishes, process the platform events
    * @author      Kejia Hu
    * @date        01/08/2019                     
    */
    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        
        Map<String, Handler_Processed__e> eventsToProcess = new Map<String, Handler_Processed__e>();
        Integer counter = 0;
        Handler_Processed__e resumeCheckPointEvent;

		try {
            for (SObject oneObj : mapNew.values()) {
                counter ++;
                Handler_Processed__e event = (Handler_Processed__e) oneObj;

                if (counter > Integer.valueOf(
                        Omni_ECMProcessedPETriggerHandlerHelper.ECM_CONFIG_BY_NAME.get('BatchSize_HandlerProcesse'))) {
                    break;
                } else {
                    resumeCheckPointEvent = event;
                    // Set Replay ID after which to resume event processing in new trigger execution.
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEvent.ReplayId);
                }
                eventsToProcess.put(event.TrackingId__c, Event);
            }

            if (!eventsToProcess.isEmpty()) { 
                HandlerProcessedTriggerHandlerHelper.updateTheFlagForFileMetadata(eventsToProcess);
            }
            
        } catch(Exception e) {
            System.debug('Exception Occured in Omni_HandlerProcsessedPETriggerHandler' + e);  
            Application_Log__c exceptionLog = ApplicationLogHandler.saveExceptionLog('ECM Create Handler Exceptions'
                                                   , e
                                                   , '');
        }
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

    public class ClaimNotificationHandlerException extends Exception {} 

}