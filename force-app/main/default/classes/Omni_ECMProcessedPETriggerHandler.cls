/**
* @description OM-98 logic once Platform Event ECM Processed trigger fires
* @author      Vikas Sharma
* @date        20/01/2020                     
*/
public with sharing  class Omni_ECMProcessedPETriggerHandler  implements TriggerHandlerBase {
    public String getObjectAPIName() {
        return 'ECM_Processed__e';
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
        List<Application_Log__c> integrationLogs = new List<Application_Log__c>();
        Map<String, ECM_Processed__e> eventsToProcess = new Map<String, ECM_Processed__e>();
        Integer counter = 0;
        ECM_Processed__e resumeCheckPointEvent;

        try {
            for (SObject oneObj : mapNew.values()) {
                Application_Log__c integrationLog;
                counter ++;
                ECM_Processed__e event = (ECM_Processed__e) oneObj;

                if (counter > Integer.valueOf(
                        Omni_ECMProcessedPETriggerHandlerHelper.ECM_CONFIG_BY_NAME.get('BatchSize_ECMProcessed'))) {
                    break;
                } else {
                    resumeCheckPointEvent = event;
                    // Set Replay ID after which to resume event processing in new trigger execution.
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEvent.ReplayId);
                    integrationLog = Omni_ClaimEventHelper.genereateIntegrationLog(JSON.serialize(event), event.TrackingId__c, 
                                                             Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'ECM Processed',
                                                             '', event.TrackingId__c);                    
                    integrationLogs.add(integrationLog);
                }
                eventsToProcess.put(event.TrackingId__c, Event);
            }
            //insert integrationLog;
            if (!integrationLogs.isEmpty()) {
                insert integrationLogs;
            }

            if (!eventsToProcess.isEmpty()) {
                Omni_ECMProcessedPETriggerHandlerHelper.updateTheFlagForFileMetadata(eventsToProcess);
            }
        } catch(Exception e) {
            System.debug('Exception Occured in Omni_HandlerProcsessedPETriggerHandler' + e);
            if (integrationLogs.isEmpty()) {
                Application_Log__c exceptionLog = ApplicationLogHandler.saveExceptionLog('ECM Processed Exceptions'
                                                        , e
                                                        , '');
            } else { 
                Application_Log__c exceptionLog = ApplicationLogHandler.saveExceptionLog('ECM Processed Exceptions'
                                                        , e
                                                        , integrationLogs[0].Id+'');
            }
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