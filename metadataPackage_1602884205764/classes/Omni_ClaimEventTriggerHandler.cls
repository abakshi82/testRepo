/**
* @description handler class for all parallel claim event buses
*              this class contains mapping, saving data into SF, processing configurations
*              and sending out communications
* @author      Kejia Hu
* @date        03/12/2019                     
*/
public with sharing class Omni_ClaimEventTriggerHandler implements TriggerHandlerBase {

    public String getObjectAPIName() {
        return 'ClaimEvent__e';
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
    * @author      Kejia Hu
    * @date        03/12/2019                     
    */
    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        
        Set<String> eventNames = new Set<String>();

        //Maps hold records with reference external Ids
        Map<String, Account> accountByPartyId = new Map<String, Account>();
        Map<String, Contact> contactByPartyId = new Map<String, Contact>();
        Map<String, String> contactIdByPartyId = new Map<String, String>();
        Map<String, Case> claimByClaimId = new Map<String, Case>();
        Map<String, Case> exposureByExposureId = new Map<String, Case>();
        Map<String, Case> roleByPartyRoleIdRoleId = new Map<String, Case>();
        Map<String, Vehicle__c> vehicleById = new Map<String, Vehicle__c>();
        Map<String, Transaction__c> transactionById = new Map<String, Transaction__c>();

        List<Omni_ClaimEventBundle> eventBundleListToSend = new List<Omni_ClaimEventBundle>();
        Map<String, Application_Log__c> integrationLogByTransId = new Map<String, Application_Log__c>();
        Map<String, ClaimEvent_Backup__e> thresholdEventMap = new Map<String, ClaimEvent_Backup__e>();
        //Map for resubmit to sub bus in case of excetion
        Map<String, ClaimEvent_Backup__e> eventMapInScopeForSub = new Map<String, ClaimEvent_Backup__e>();
        //Map for resubmit for the events that have duplicated claim Id
        Map<String, ClaimEvent_Backup__e> eventsWithDupClaimIdToResubmit = new Map<String, ClaimEvent_Backup__e>();
        Map<String, List<Communication_Configuration__c>> eventNameWithConfigurations = new Map<String, List<Communication_Configuration__c>>();
        //To hold the information of claims for fields specified in configuration object;
		List<Case> claimInformationWithFields  = new List<Case>();        
        // To hold the template name and Ids
        Map<String, Id> emailTemplateNameId = new Map<String, Id>();
        // To get the list of Language Configurations
        Map<Id, List<Language_Config__c>> languageConfigWithIds = new Map<Id, List<Language_Config__c>>();
        //General Map to hold SF ids associated with CC Ids
        Map<String, String> sfIdByCCId = new Map<String, String>();
        // Keeping track of TypeCodes with Expsores
        Map<String, ExposureType__c> typeCodeToExposures = new Map<String, ExposureType__c>();
        Set<String> claimIds = new Set<String>();
        Map<String, Case> existingClaimExpoForSurveyByKey = new Map<String, Case>();
        Map<String, Omni_SurveyConfig> surveyConfigByKey = new Map<String, Omni_SurveyConfig>();

        Integer busCounter = 0;

        ClaimEvent_1__e resumeCheckPointEventBus1;
        ClaimEvent_2__e resumeCheckPointEventBus2;
        ClaimEvent_3__e resumeCheckPointEventBus3;
        ClaimEvent_4__e resumeCheckPointEventBus4;
        ClaimEvent_5__e resumeCheckPointEventBus5;
        ClaimEvent_6__e resumeCheckPointEventBus6;
        ClaimEvent_7__e resumeCheckPointEventBus7;
        ClaimEvent_8__e resumeCheckPointEventBus8;
        ClaimEvent_9__e resumeCheckPointEventBus9;
        ClaimEvent_10__e resumeCheckPointEventBus10;
        ClaimEvent_11__e resumeCheckPointEventBus11;
        ClaimEvent_12__e resumeCheckPointEventBus12;
        ClaimEvent_13__e resumeCheckPointEventBus13;
        ClaimEvent_14__e resumeCheckPointEventBus14;
        ClaimEvent_15__e resumeCheckPointEventBus15;
        ClaimEvent_16__e resumeCheckPointEventBus16;
        ClaimEvent_17__e resumeCheckPointEventBus17;
        ClaimEvent_18__e resumeCheckPointEventBus18;
        ClaimEvent_19__e resumeCheckPointEventBus19;
        ClaimEvent_20__e resumeCheckPointEventBus20;

        //Initializing idRolesMap
        Map<String, ContactRole__c> idWithContactRolesMap = Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_ID;
        Map<String, ExposureType__c> idWithExposureTypeMap = Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID;
        Set<String> configWithEC  = Omni_ConfigurationSelector.getAllConfigurations();

        Savepoint sp;

        try{
            for (Sobject oneObj : mapNew.values()) {
                
                Omni_ClaimEventEntity eventEntity;
                Omni_ClaimEventBundle eventBundle;

                Application_Log__c integrationLogPerEvent;

                //Convert a parallel event into one Event Bundle
                //For each parallel bus, Number of events get processed == batch size, the rest will be process in different transactions
                //Batch size is set in Claim Event Config
                if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_1_TYPE) {
                    busCounter ++;
                    ClaimEvent_1__e event = (ClaimEvent_1__e) oneObj;
                    Integer batchSizeE1 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent1'));
                    if (busCounter > batchSizeE1) {
                        break;
                    } else {
                        resumeCheckPointEventBus1 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus1.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 1');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    
                    //If multiple events in current scope have same ClaimId, only the first one will be process in current process
                    //The rest will be send to backup bus
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //If any count in event passes max size in claim event config and event bus batch size > 1, the event will be send to backup bus
                    if (batchSizeE1>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_2_TYPE) {
                    busCounter ++;
                    ClaimEvent_2__e event = (ClaimEvent_2__e) oneObj;
                    Integer batchSizeE2 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent2'));
                    if (busCounter > batchSizeE2) {
                        break;
                    } else {
                        resumeCheckPointEventBus2 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus2.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 2');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE2>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_3_TYPE) {
                    busCounter ++;
                    ClaimEvent_3__e event = (ClaimEvent_3__e) oneObj;
                    Integer batchSizeE3 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent3'));
                    if (busCounter > batchSizeE3) {
                        break;
                    } else {
                        resumeCheckPointEventBus3 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus3.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 3');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE3>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_4_TYPE) {
                    busCounter ++;
                    ClaimEvent_4__e event = (ClaimEvent_4__e) oneObj;
                    Integer batchSizeE4 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent4'));
                    if (busCounter > batchSizeE4) {
                        break;
                    } else {
                        resumeCheckPointEventBus4 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus4.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 4');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE4>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_5_TYPE) {
                    busCounter ++;
                    ClaimEvent_5__e event = (ClaimEvent_5__e) oneObj;
                    Integer batchSizeE5 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent5'));
                    if (busCounter > batchSizeE5) {
                        break;
                    } else {
                        resumeCheckPointEventBus5 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus5.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 5');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE5>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_6_TYPE) {
                    busCounter ++;
                    ClaimEvent_6__e event = (ClaimEvent_6__e) oneObj;
                    Integer batchSizeE6 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent6'));
                    if (busCounter > batchSizeE6) {
                        break;
                    } else {
                        resumeCheckPointEventBus6 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus6.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 6');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE6>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_7_TYPE) {
                    busCounter ++;
                    ClaimEvent_7__e event = (ClaimEvent_7__e) oneObj;
                    Integer batchSizeE7 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent7'));
                    if (busCounter > batchSizeE7) {
                        break;
                    } else {
                        resumeCheckPointEventBus7 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus7.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 7');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE7>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_8_TYPE) {
                    busCounter ++;
                    ClaimEvent_8__e event = (ClaimEvent_8__e) oneObj;
                    Integer batchSizeE8 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent8'));
                    if (busCounter > Integer.valueOf(
                                        Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent8'))) {
                        break;
                    } else {
                        resumeCheckPointEventBus8 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus8.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 8');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE8>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_9_TYPE) {
                    busCounter ++;
                    ClaimEvent_9__e event = (ClaimEvent_9__e) oneObj;
                    Integer batchSizeE9 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent9'));
                    if (busCounter > batchSizeE9) {
                        break;
                    } else {
                        resumeCheckPointEventBus9 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus9.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 9');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE9>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_10_TYPE) {
                    busCounter ++;
                    ClaimEvent_10__e event = (ClaimEvent_10__e) oneObj;
                    Integer batchSizeE10 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent10'));
                    if (busCounter > batchSizeE10) {
                        break;
                    } else {
                        resumeCheckPointEventBus10 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus10.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 10');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE10>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_11_TYPE) {
                    busCounter ++;
                    ClaimEvent_11__e event = (ClaimEvent_11__e) oneObj;
                    Integer batchSizeE11 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent11'));
                    if (busCounter > batchSizeE11) {
                        break;
                    } else {
                        resumeCheckPointEventBus11 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus11.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 11');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE11>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }                    
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_12_TYPE) {
                    busCounter ++;
                    ClaimEvent_12__e event = (ClaimEvent_12__e) oneObj;
                    Integer batchSizeE12 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent12'));
                    if (busCounter > batchSizeE12) {
                        break;
                    } else {
                        resumeCheckPointEventBus12 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus12.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 12');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE12>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_13_TYPE) {
                    busCounter ++;
                    ClaimEvent_13__e event = (ClaimEvent_13__e) oneObj;
                    Integer batchSizeE13 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent13'));
                    if (busCounter > batchSizeE13) {
                        break;
                    } else {
                        resumeCheckPointEventBus13 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus13.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 13');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE13>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_14_TYPE) {
                    busCounter ++;
                    ClaimEvent_14__e event = (ClaimEvent_14__e) oneObj;
                    Integer batchSizeE14 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent14'));
                    if (busCounter > batchSizeE14) {
                        break;
                    } else {
                        resumeCheckPointEventBus14 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus14.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 14');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE14>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_15_TYPE) {
                    busCounter ++;
                    ClaimEvent_15__e event = (ClaimEvent_15__e) oneObj;
                    Integer batchSizeE15 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent15'));
                    if (busCounter > batchSizeE15) {
                        break;
                    } else {
                        resumeCheckPointEventBus15 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus15.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 15');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE15>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_16_TYPE) {
                    busCounter ++;
                    ClaimEvent_16__e event = (ClaimEvent_16__e) oneObj;
                    Integer batchSizeE16 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent16'));
                    if (busCounter > batchSizeE16) {
                        break;
                    } else {
                        resumeCheckPointEventBus16 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus16.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 16');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE16>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_17_TYPE) {
                    busCounter ++;
                    ClaimEvent_17__e event = (ClaimEvent_17__e) oneObj;
                    Integer batchSizeE17 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent17'));
                    if (busCounter > batchSizeE17) {
                        break;
                    } else {
                        resumeCheckPointEventBus17 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus17.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 17');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE17>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_18_TYPE) {
                    busCounter ++;
                    ClaimEvent_18__e event = (ClaimEvent_18__e) oneObj;
                    Integer batchSizeE18 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent18'));
                    if (busCounter > batchSizeE18) {
                        break;
                    } else {
                        resumeCheckPointEventBus18 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus18.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 18');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE18>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_19_TYPE) {
                    busCounter ++;
                    ClaimEvent_19__e event = (ClaimEvent_19__e) oneObj;
                    Integer batchSizeE19 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent19'));
                    if (busCounter > batchSizeE19) {
                        break;
                    } else {
                        resumeCheckPointEventBus19 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus19.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 19');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE19>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                } else if (oneObj.getSObjectType() == Omni_ClaimEventConstant.CLAIM_BUS_20_TYPE) {
                    busCounter ++;
                    ClaimEvent_20__e event = (ClaimEvent_20__e) oneObj;
                    Integer batchSizeE20 = Integer.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEvent20'));
                    if (busCounter > batchSizeE20) {
                        break;
                    } else {
                        resumeCheckPointEventBus20 = event;
                        // Set Replay ID after which to resume event processing in new trigger execution.
                        EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBus20.ReplayId);
                        integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                            event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event 20');
                        integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    }
                    eventMapInScopeForSub.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                    (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                    //prepare the duplicated CliamId events for resubmit
                    if (!claimIds.contains(event.ClaimId__c)) {
                        claimIds.add(event.ClaimId__c);
                    } else {
                        integrationLogPerEvent.Status__c = Omni_ClaimEventConstant.LOG_STATUS_DUPLICATED;
                        eventsWithDupClaimIdToResubmit.put(event.TransactionId__c
                                                            , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;
                    }
                    //if any count pass max size and event bus batch size > 1, submit event to backup bus
                    if (batchSizeE20>1 && Omni_ClaimEventHelper.isThreshold(event.ClaimExposuresCount__c, 
                                                                            event.FinancialTransactionsCount__c, 
                                                                            event.PartyCount__c, 
                                                                            event.PartyRolesCount__c)) {
                        integrationLogPerEvent.Status__c = 'Threshold';
                        thresholdEventMap.put(event.TransactionId__c
                                                , (ClaimEvent_Backup__e) Omni_ClaimEventHelper.convertToCommonEvent(
                                                                (SObject) event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
                        continue;                                                                
                    }
                    eventEntity = new Omni_ClaimEventEntity((SObject) event);
                    eventBundle = new Omni_ClaimEventBundle(eventEntity);
                    eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                    accountByPartyId.putAll(eventBundle.accountByPartyId);
                    eventNames.add(event.EventName__c);
                }
                
                if (null != eventBundle) {
                    eventBundleListToSend.add(eventBundle);
                }
            }  

        if (!integrationLogByTransId.isEmpty()) {
                insert integrationLogByTransId.values();
        }

        sp = Database.setSavepoint();
        if (!eventNames.isEmpty()) {
                eventNameWithConfigurations = Omni_ClaimEventHelper.generateEventConfigurations(eventNames);
                emailTemplateNameId = Omni_ConfigurationSelector.getEmailTemplatesId(eventNames);
                languageConfigWithIds = Omni_ConfigurationSelector.getLanguageConfigurations(eventNames);
                configWithEC.addAll(Omni_ConfigurationSelector.getFieldNamesFromLanguageConfig());
        }
        if (!accountByPartyId.isEmpty()) {
                upsert accountByPartyId.values() PartyId__c;
                //Populate Account Id in Account map of each PE bundle if existing account Id is null
                Omni_ClaimEventHelper.updateAccountIdsForAllBundles(eventBundleListToSend, accountByPartyId);

                contactByPartyId = Omni_ClaimEventHelper.saveContactsFromBundleList(eventBundleListToSend, contactByPartyId);
                //Populate Contact Id in Contact map of each PE bundle if existing contact Id is null after accounts saved
                Omni_ClaimEventHelper.updateContactIdsForAllBundles(eventBundleListToSend, contactByPartyId);

                //Get contact Ids map of person accounts
                contactIdByPartyId = Omni_ClaimEventHelper.getContactIdByPartyId(accountByPartyId.keySet(), contactIdByPartyId);
                //Get contact Ids map of business accounts
                contactIdByPartyId = Omni_ClaimEventHelper.getContactIdByPartyId(eventBundleListToSend, 
                                                                                 contactByPartyId, 
                                                                                 contactIdByPartyId);
            }
            
            vehicleById = Omni_ClaimEventHelper.saveVehicles(eventBundleListToSend, vehicleById);
            //Populate Vehicle Id in Vehicle map of each PE bundle if existing Vehicle Id is null after vehicle saved
            Omni_ClaimEventHelper.updateVehicleIdsForAllBundles(eventBundleListToSend, vehicleById);

            //Get survey indicators before upsert claim and exposure
            if (Utility.SURVEY_SWITCH_BY_KEY.get('SurveyMapping').IsEnabled__c) {
                Set<String> claimKeys = Omni_ClaimEventHelper.getClaimKeys(eventBundleListToSend);
                Set<String> expoKeys = Omni_ClaimEventHelper.getExposureKeys(eventBundleListToSend);

                //Retrieve exisiting claim exposure records that have survey flag false
                List<Case> claimExposureList = Omni_ClaimEventHelper.getClaimExpoList(claimKeys, expoKeys);
                existingClaimExpoForSurveyByKey = (null == claimExposureList) 
                                                        ? existingClaimExpoForSurveyByKey 
                                                        : Omni_ClaimEventHelper.getClaimExpoByKey(claimExposureList);
            }

            claimByClaimId = Omni_ClaimEventHelper.saveClaims(eventBundleListToSend, claimByClaimId);
            //Populate Claim Id in Claim map of each PE bundle if existing Claim Id is null after claims saved
            Omni_ClaimEventHelper.updateClaimIdsForAllBundles(eventBundleListToSend, claimByClaimId);

            //Retrieve exsiting shadow roles
            Map<String, List<Case>> existingShadowRolesByClaimId = Omni_CaseSelector.getShadowRolesByClaimId(claimByClaimId.keySet());
            //Add shadow roles to bundle list elements
            if (!existingShadowRolesByClaimId.isEmpty()) {
                Omni_ClaimEventHelper.addShadowRolesForAllBundles(eventBundleListToSend, existingShadowRolesByClaimId);
            }

            //Get claims that has survey indicator changed from false to true
            if (!Utility.SURVEY_CONFIG_BY_FIELD.isEmpty()) {
                surveyConfigByKey = Omni_ClaimEventHelper.getSurveyConfigByKey(
                                                            existingClaimExpoForSurveyByKey,
                                                            surveyConfigByKey,
                                                            claimByClaimId,
                                                            integrationLogByTransId.values()[0].Id,
                                                            true);
            }

            exposureByExposureId = Omni_ClaimEventHelper.saveExposuresFromBundleList(eventBundleListToSend, exposureByExposureId);
            //Populate Exposure Id in Exposure map of each PE bundle if existing Exposure Id is null after claims saved
            Omni_ClaimEventHelper.updateExposureIdsForAllBundles(eventBundleListToSend, exposureByExposureId);

            if (!exposureByExposureId.isEmpty()) {
                //Get exposures that has survey indicator changed from false to true
                if (!Utility.SURVEY_CONFIG_BY_FIELD.isEmpty()) {
                    Map<String, Case> claimExpoByCompositeKey = new Map<String, Case>();
                    if (!exposureByExposureId.isEmpty())
                        claimExpoByCompositeKey.putAll(Omni_ClaimEventHelper.buildCaseByCompositeKey(exposureByExposureId, false));
                    claimExpoByCompositeKey.putAll(Omni_ClaimEventHelper.buildCaseByCompositeKey(claimByClaimId, true));
                    surveyConfigByKey = Omni_ClaimEventHelper.getSurveyConfigByKey(
                                                                existingClaimExpoForSurveyByKey,
                                                                surveyConfigByKey,
                                                                claimExpoByCompositeKey,
                                                                integrationLogByTransId.values()[0].Id,
                                                                false);
                }

                //populate claim survey flag for exposure survey
                if (!surveyConfigByKey.isEmpty()) {
                    claimByClaimId = Omni_ClaimEventHelper.populateClaimFlagForExpoSurvey(claimByClaimId, exposureByExposureId, surveyConfigByKey);
                }

                //Generate and save custom object ShadowExposure__c reocords from exposures
                Omni_ClaimEventHelper.saveShadowExposures(exposureByExposureId.values());
                //Generate and save Transactions
                transactionById = Omni_ClaimEventHelper.saveTransactionsFromBundleList(eventBundleListToSend, transactionById);
                //Populate Transaction Id in Transaction map of each PE bundle if existing Transaction Id is null after transactions saved
                Omni_ClaimEventHelper.updateTransactionIdsForAllBundles(eventBundleListToSend, transactionById);
                //Populate exposure lookups on claims
                claimByClaimId = Omni_ClaimEventHelper.setExposureLookupsOnClaims(eventBundleListToSend, claimByClaimId);

                //Populate last financial transaction on Exposures
                if(!transactionById.isEmpty()) {
                    exposureByExposureId = Omni_ClaimEventHelper.updateExposureLastTransaction(eventBundleListToSend, 
                                                                                                exposureByExposureId);
                }
            }
            
            roleByPartyRoleIdRoleId = Omni_ClaimEventHelper.saveRolesFromBundleList(eventBundleListToSend, 
                                                                                    roleByPartyRoleIdRoleId);
                                            
            //Populate Role Id in Role map of each PE bundle if existing Role Id is null after roles saved
            Omni_ClaimEventHelper.updateRoleIdsForAllBundles(eventBundleListToSend, roleByPartyRoleIdRoleId);
            sfIdByCCId = Omni_ClaimEventHelper.populateSFIDsWithCC(roleByPartyRoleIdRoleId, 
                                                                    exposureByExposureId,
                                                                    accountByPartyId);
            
            typeCodeToExposures = Omni_ClaimEventDAOHelper.exposureTypeByName;
			
            // Populate catergories assigned to the claims based on the event Name
			Omni_ClaimEventHelper.populateCategories(eventBundleListToSend, 
                                                     eventNameWithConfigurations,
                                                     idWithContactRolesMap,
                                                     idWithExposureTypeMap,
                                                     sfIdByCCId,
                                                     typeCodeToExposures);

            // check configurations and Eligibility Criteria
            claimInformationWithFields = Omni_ClaimEventHelper.checkCategoriesforCriteria(
                																eventBundleListToSend,
                                                                                configWithEC);

            // check configuration, role, exposure types and eligbility criteria 
            Omni_ClaimEventHelper.checkFinalConfigurations(eventBundleListToSend,
                                                           claimInformationWithFields);

          	Omni_ClaimEventHelper.processCommunication(eventBundleListToSend, 
            										   emailTemplateNameId,
                                                       languageConfigWithIds,
                                                       claimInformationWithFields,
                                                       integrationLogByTransId.values()[0].Id);
            //Publish in Event Backup bus and event Backup will be processed 1 by 1
            if (!eventsWithDupClaimIdToResubmit.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(eventsWithDupClaimIdToResubmit.values());
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEventBackup Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
            //Publish the threshold Event to Event Backup  bus
            if (!thresholdEventMap.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(thresholdEventMap.values());
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEventBackup Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }

            //Send suvery requests
            if (Utility.SURVEY_SWITCH_BY_KEY.get('SurveySend').IsEnabled__c && !surveyConfigByKey.isEmpty()) {
                Map<String, Omni_SurveyRequest> surveyRequestByKey = Omni_ClaimEventHelper.getSurveyRequestFromConfig(surveyConfigByKey);
                    //Sending survey, based on the config and query used, either sync or async
                if (Utility.SURVEY_SWITCH_BY_KEY.get('SurveySendingInFuture').IsEnabled__c || Limits.getQueries() > 90) {
                    System.debug('****1.EOC Request: '  + surveyRequestByKey);
                    System.enqueueJob(new Omni_EOCSurveyRequest(surveyRequestByKey));
                } else {
                    Omni_EOCSurveyServiceSync surveySerivce = new Omni_EOCSurveyServiceSync(surveyRequestByKey);
                    surveySerivce.createAndSendSurveys();
                }
            }
        } catch (Exception e) {
            if (null != sp) {
                Database.rollback(sp);
            }
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            Application_Log__c exceptionLog;
            exceptionLog = ApplicationLogHandler.saveExceptionLog('Claim Event Exception'
                                                                    , e
                                                                    , integrationLogByTransId.values()[0].Id);
            //Publish failed Events to Sub Events if more that 1 event get failed
            if (eventMapInScopeForSub.size() >1) {
                Omni_ClaimEventHelper.updateLogsForExceptionRetry(integrationLogByTransId.values(), exceptionLog);
                List<Database.SaveResult> results = EventBus.publish(eventMapInScopeForSub.values());
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