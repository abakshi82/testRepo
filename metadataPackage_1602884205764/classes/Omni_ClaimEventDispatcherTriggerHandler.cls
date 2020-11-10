/**
* @description handler class for claim events dispacher
*              dispacher distributes claim events to paralled event buses
* @author      Kejia Hu
* @date        03/12/2019                     
*/
public with sharing class Omni_ClaimEventDispatcherTriggerHandler implements TriggerHandlerBase {

public String getObjectAPIName() {
        return 'ClaimEvent_Dispatcher__e';
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
    * @description Dispatch sync events to differents buses based on the criteria
    * @author      Kejia Hu
    * @date        01/08/2019                     
    */
    public void handleAfterInsert(Map<Id, SObject> mapNew) {

        List<ClaimEvent_1__e> claimEvent1List = new List<ClaimEvent_1__e>();
        List<ClaimEvent_2__e> claimEvent2List = new List<ClaimEvent_2__e>();
        List<ClaimEvent_3__e> claimEvent3List = new List<ClaimEvent_3__e>();
        List<ClaimEvent_4__e> claimEvent4List = new List<ClaimEvent_4__e>();
        List<ClaimEvent_5__e> claimEvent5List = new List<ClaimEvent_5__e>();
        List<ClaimEvent_6__e> claimEvent6List = new List<ClaimEvent_6__e>();
        List<ClaimEvent_7__e> claimEvent7List = new List<ClaimEvent_7__e>();
        List<ClaimEvent_8__e> claimEvent8List = new List<ClaimEvent_8__e>();
        List<ClaimEvent_9__e> claimEvent9List = new List<ClaimEvent_9__e>();
        List<ClaimEvent_10__e> claimEvent10List = new List<ClaimEvent_10__e>();
        List<ClaimEvent_11__e> claimEvent11List = new List<ClaimEvent_11__e>();
        List<ClaimEvent_12__e> claimEvent12List = new List<ClaimEvent_12__e>();
        List<ClaimEvent_13__e> claimEvent13List = new List<ClaimEvent_13__e>();
        List<ClaimEvent_14__e> claimEvent14List = new List<ClaimEvent_14__e>();
        List<ClaimEvent_15__e> claimEvent15List = new List<ClaimEvent_15__e>();
        List<ClaimEvent_16__e> claimEvent16List = new List<ClaimEvent_16__e>();
        List<ClaimEvent_17__e> claimEvent17List = new List<ClaimEvent_17__e>();
        List<ClaimEvent_18__e> claimEvent18List = new List<ClaimEvent_18__e>();
        List<ClaimEvent_19__e> claimEvent19List = new List<ClaimEvent_19__e>();
        List<ClaimEvent_20__e> claimEvent20List = new List<ClaimEvent_20__e>();

        Map<String, Application_Log__c> integrationLogByTransId = new Map<String, Application_Log__c>();
        //events in current scope, if exception occurs, the scope events will be sent for Sub event bus
        Map<String, ClaimEvent_Dispatcher__e> eventMapInScope = new Map<String, ClaimEvent_Dispatcher__e>();

        Integer counter = 0;
        ClaimEvent_Dispatcher__e resumeCheckPointEvent;

        try {
            for (ClaimEvent_Dispatcher__e event : (List<ClaimEvent_Dispatcher__e>) mapNew.values()) {
                counter ++;
                Application_Log__c integrationLogPerEvent;
                //Number of events get processed == batch size, the rest will be process in different transactions
                //Batch size is set in Claim Event Config
                if (counter > Integer.valueOf(
                                Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEventDispatcher'))) {
                    break;
                } else {
                    resumeCheckPointEvent = event;
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEvent.ReplayId);
                    integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                                event
                                                , Omni_ClaimEventConstant.LOG_STATUS_PROCESSED
                                                , 'Claim Event Dispatcher');
                    integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                }
                eventMapInScope.put(event.TransactionId__c, event);
                //Check enabled rule number and dispach the event to claim event buses
                //One parallel bus enabled when rule set to 1
                if ('1' == Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('RuleEnabled')) {
                    claimEvent1List.add((ClaimEvent_1__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_1));
                }
                //Twenty parallel buses enabled when rule set to 20
                //Events are distributed to parallel buses based on last two digits of Claim Number
                //e.g. 00-04 to bus1, 05-09 to bus2, 95-99 to bus 20, etc...
                if ('20' == Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('RuleEnabled')) {
                    Integer lastDigi = Integer.valueOf(event.ClaimNumber__c.right(2));
                    if (lastDigi < 5) {
                        claimEvent1List.add((ClaimEvent_1__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_1));
                    } else if (lastDigi < 10) {
                        claimEvent2List.add((ClaimEvent_2__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_2));
                    } else if (lastDigi < 15) {
                        claimEvent3List.add((ClaimEvent_3__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_3));
                    } else if (lastDigi < 20) {
                        claimEvent4List.add((ClaimEvent_4__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_4));
                    } else if (lastDigi < 25) {
                        claimEvent5List.add((ClaimEvent_5__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_5));
                    } else if (lastDigi < 30) {
                        claimEvent6List.add((ClaimEvent_6__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_6));
                    } else if (lastDigi < 35) {
                        claimEvent7List.add((ClaimEvent_7__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_7));
                    } else if (lastDigi < 40) {
                        claimEvent8List.add((ClaimEvent_8__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_8));
                    } else if (lastDigi < 45) {
                        claimEvent9List.add((ClaimEvent_9__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_9));
                    } else if (lastDigi < 50) {
                        claimEvent10List.add((ClaimEvent_10__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_10));
                    } else if (lastDigi < 55) {
                        claimEvent11List.add((ClaimEvent_11__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_11));
                    } else if (lastDigi < 60) {
                        claimEvent12List.add((ClaimEvent_12__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_12));
                    } else if (lastDigi < 65) {
                        claimEvent13List.add((ClaimEvent_13__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_13));
                    } else if (lastDigi < 70) {
                        claimEvent14List.add((ClaimEvent_14__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_14));
                    } else if (lastDigi < 75) {
                        claimEvent15List.add((ClaimEvent_15__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_15));
                    } else if (lastDigi < 80) {
                        claimEvent16List.add((ClaimEvent_16__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_16));
                    } else if (lastDigi < 85) {
                        claimEvent17List.add((ClaimEvent_17__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_17));
                    } else if (lastDigi < 90) {
                        claimEvent18List.add((ClaimEvent_18__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_18));
                    } else if (lastDigi < 95) {
                        claimEvent19List.add((ClaimEvent_19__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_19));
                    } else {
                        claimEvent20List.add((ClaimEvent_20__e)Omni_ClaimEventHelper.convertToCommonEvent(
                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_20));
                    }
                }
            }
            
            //Save Integration logs for dispacher events
            if (!integrationLogByTransId.isEmpty()) {
                insert integrationLogByTransId.values();
            }

            //Puslish paralled buses, log exceptions if error occurred
            if (!claimEvent1List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent1List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent1 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent2List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent2List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent2 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent3List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent3List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent3 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent4List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent4List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent4 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent5List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent5List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent5 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent6List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent6List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent6 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent7List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent7List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent7 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent8List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent8List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent8 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent9List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent9List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent9 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent10List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent10List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent10 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent11List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent11List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent11 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent12List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent12List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent12 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent13List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent13List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent13 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent14List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent14List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent14 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent15List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent15List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent15 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent16List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent16List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent16 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent17List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent17List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent17 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent18List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent18List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent18 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent19List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent19List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent19 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            if (!claimEvent20List.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(claimEvent20List);
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEvent20 Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            Application_Log__c exceptionLog = ApplicationLogHandler.saveExceptionLog('Claim Event Dispatcher Exception'
                                                    , e, integrationLogByTransId.values()[0].Id);
            //When there are more that one event in current scope
            //Send events in scope to backup bus to process sequentially when exception
            if (eventMapInScope.size() >1) {
                Omni_ClaimEventHelper.updateLogsForExceptionRetry(integrationLogByTransId.values(), exceptionLog);
                List<Database.SaveResult> results = EventBus.publish(Omni_ClaimEventHelper.convertToBackupEvents(eventMapInScope.values()));
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEventBackup Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
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
}