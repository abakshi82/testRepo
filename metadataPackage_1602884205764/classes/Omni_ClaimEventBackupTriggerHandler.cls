/**
* @description handler class for claim event backup bus
*              backup bus handle only one event a time, no retry logic for backup bus
* @author      Kejia Hu
* @date        03/12/2019                     
*/
public with sharing class Omni_ClaimEventBackupTriggerHandler implements TriggerHandlerBase {

    public String getObjectAPIName() {
        return 'ClaimEvent_Backup__e';
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

        Integer counter = 0;

        ClaimEvent_Backup__e resumeCheckPointEventBackup;

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

                counter ++;
                ClaimEvent_Backup__e event = (ClaimEvent_Backup__e) oneObj;
                if (counter > Integer.valueOf(
                                    Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('BatchSizeEventBackup'))) {
                    break;
                } else {
                    resumeCheckPointEventBackup = event;
                    // Set Replay ID after which to resume event processing in new trigger execution.
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEventBackup.ReplayId);
                    integrationLogPerEvent = Omni_ClaimEventHelper.generateIntegrationLog(
                                        event, Omni_ClaimEventConstant.LOG_STATUS_PROCESSED, 'Claim Event Backup');
                    integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                }
                eventEntity = new Omni_ClaimEventEntity((SObject) event);
                eventBundle = new Omni_ClaimEventBundle(eventEntity);
                eventBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                accountByPartyId.putAll(eventBundle.accountByPartyId);
                eventNames.add(event.EventName__c);

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

            claimByClaimId = Omni_ClaimEventHelper.saveClaims(eventBundleListToSend, claimByClaimId);
            //Populate Claim Id in Claim map of each PE bundle if existing Claim Id is null after claims saved
            Omni_ClaimEventHelper.updateClaimIdsForAllBundles(eventBundleListToSend, claimByClaimId);

            exposureByExposureId = Omni_ClaimEventHelper.saveExposuresFromBundleList(eventBundleListToSend, exposureByExposureId);
            //Populate Exposure Id in Exposure map of each PE bundle if existing Exposure Id is null after claims saved
            Omni_ClaimEventHelper.updateExposureIdsForAllBundles(eventBundleListToSend, exposureByExposureId);
            

            if (!exposureByExposureId.isEmpty()) {
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

            //Publish the threshold Event to sub bus
            if (!thresholdEventMap.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(thresholdEventMap.values());
                Omni_ClaimEventHelper.logErrorsFromPublishResults(results
                                                                    , 'ClaimEventBackup Publish Error'
                                                                    , integrationLogByTransId.values()[0].Id);
            }
        } catch (Exception e) {
            if (null != sp) {
                Database.rollback(sp);
            }
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            Application_Log__c exceptionLog;
            exceptionLog = ApplicationLogHandler.saveExceptionLog('Claim Event Backup Exception'
                                                                    , e
                                                                    , integrationLogByTransId.values()[0].Id);
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