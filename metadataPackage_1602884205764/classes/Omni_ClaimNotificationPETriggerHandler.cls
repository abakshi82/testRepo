/**
* @description OM-98 logic once Platform Event Claim_Notification__e trigger fires
* @author      Kejia Hu
* @date        01/08/2019                     
*/
public with sharing class Omni_ClaimNotificationPETriggerHandler implements TriggerHandlerBase {
    public String getObjectAPIName() {
        return Omni_ClaimNotificationConstant.EVENT_NAME;
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
    * @date        01/08/2019                     
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
        Application_Log__c integrationLog = new Application_Log__c();
        List<Application_Log__c> integrationLogs = new List<Application_Log__c>();
        Map<String, Application_Log__c> integrationLogByTransId = new Map<String, Application_Log__c>();
        List<Omni_ClaimNotificationBundle> notifBundleListToSend = new List<Omni_ClaimNotificationBundle>();
		Map<String, List<Communication_Configuration__c>> eventNameWithConfigurations = new Map<String, List<Communication_Configuration__c>>();
        // Storing the reference of all Role Natures at the begining to avoid it calling again and again
        Map<String, ContactRole__c> idWithContactRolesMap =  new Map<String,ContactRole__c>();
        //Storing the references of all Exposure types at the begining to avoid it calling again and again
        Map<String, ExposureType__c> idWithExposureTypeMap = new Map<String, ExposureType__c>();
        //To get the list of All Configurations with field names ( to query from Roles)
        Set<String> configWithEC = new Set<String>();
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
        //Events for resubmit to Sub event bus
        Map<String, Claim_Notification__e> eventMapToResubmit = new Map<String, Claim_Notification__e>();
        //events in current scope, if exception occurs, the scope events will be sent for Sub event bus
        Map<String, Claim_Notification__e> eventMapInScope = new Map<String, Claim_Notification__e>();
        //Events for submit to Sub event bus for Threshold
        Map<String, Claim_Notification__e> thresholdEventMapTosubmit = new Map<String, Claim_Notification__e>();
        
		//Initializing idRolesMap
        idWithContactRolesMap = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_ID;
        idWithExposureTypeMap = Omni_ClaimNotificationDAOHelper.EXPOSURE_TYPE_BY_ID;
        configWithEC  = Omni_ConfigurationSelector.getAllConfigurations();

        //Set variables for desired event batch size
        Integer counter = 0;
        Claim_Notification__e resumeCheckPointEvent;
        //All transactionIds will be saved into the first integration log
        String transactionIds = '';

        // Create a savepoint before DML Operation
        Savepoint sp;
        Set<String> claimIds = new Set<String>();

        try{
            for (Claim_Notification__e event : (List<Claim_Notification__e>) mapNew.values()){

                counter ++;
                Application_Log__c integrationLogPerEvent;
                //when reached the desired event batch size, quit loop and set resume point
                if (counter > Integer.valueOf(Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('ClaimNotificationBatchSize'))) {
                    break;
                } else {
                    resumeCheckPointEvent = event;
                    // Set Replay ID after which to resume event processing in new trigger execution.
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEvent.ReplayId);
                    integrationLogPerEvent = Omni_ClaimNotificationPETriggerHelper.generateIntegrationLog(
                                        event, Omni_ClaimNotificationConstant.LOG_STATUS_PROCESSED);
                    integrationLogByTransId.put(event.TransactionID__c, integrationLogPerEvent);
                    transactionIds += event.TransactionId__c + '; ';
                }
                eventMapInScope.put(event.TransactionId__c, event);
                //if (!eventMapToProcess.containsKey(event.TransactionId__c)) {
                if (!claimIds.contains(event.ClaimId__c)) {
                    claimIds.add(event.ClaimId__c);
                } else {
                    eventMapToResubmit.put(event.TransactionId__c, event);
                    continue;
                }
                //if any count pass max size, submit event to sub bus
                if (Omni_ClaimNotificationPETriggerHelper.isPassMax(event.ClaimExposuresCount__c, event.FinancialTransactionsCount__c, 
                                                                        event.PartyCount__c, event.PartyRolesCount__c)) {
                    integrationLogPerEvent.Status__c = 'Threshold';
                    thresholdEventMapTosubmit.put(event.TransactionId__c, event);
                    continue;                                                                
                }
                //Persist JSON payload data into Salesforce DB when Instantiating  Omni_ClaimNotificationBundle
                Omni_ClaimNotificationPEEntity peEntity = new Omni_ClaimNotificationPEEntity(event);
                Omni_ClaimNotificationBundle notifBundle = new Omni_ClaimNotificationBundle(peEntity);
                notifBundle.integrationLog = integrationLogByTransId.get(event.TransactionID__c);
                notifBundleListToSend.add(notifBundle);
                accountByPartyId.putAll(notifBundle.accountByPartyId);
                eventNames.add(event.EventName__c);
            }

            if (!integrationLogByTransId.isEmpty()) {
                insert integrationLogByTransId.values();
                integrationLog = integrationLogByTransId.values()[0];
            }

            // Create a savepoint before DML Operation
            sp = Database.setSavepoint();
			if (!eventNames.isEmpty())
            {
                eventNameWithConfigurations = Omni_ClaimNotificationPETriggerHelper.generateEventConfigurations(eventNames);
                emailTemplateNameId = Omni_ConfigurationSelector.getEmailTemplatesId(eventNames);
                languageConfigWithIds = Omni_ConfigurationSelector.getLanguageConfigurations(eventNames);
                configWithEC.addAll(Omni_ConfigurationSelector.getFieldNamesFromLanguageConfig());
            }
			
            if (!accountByPartyId.isEmpty()) {
                upsert accountByPartyId.values() PartyId__c;
                //Populate Account Id in Account map of each PE bundle if existing account Id is null
                Omni_ClaimNotificationPETriggerHelper.updateAccountIdsForAllBundles(notifBundleListToSend, accountByPartyId);

                contactByPartyId = Omni_ClaimNotificationPETriggerHelper.saveContactsFromBundleList(
                                    notifBundleListToSend, contactByPartyId);
                //Populate Contact Id in Contact map of each PE bundle if existing contact Id is null after accounts saved
                Omni_ClaimNotificationPETriggerHelper.updateContactIdsForAllBundles(notifBundleListToSend, contactByPartyId);

                //Get contact Ids map of person accounts
                contactIdByPartyId = Omni_ClaimNotificationPETriggerHelper.getContactIdByPartyId(
                                        accountByPartyId.keySet(), contactIdByPartyId);
                //Get contact Ids map of business accounts
                contactIdByPartyId = Omni_ClaimNotificationPETriggerHelper.getContactIdByPartyId(
                                        notifBundleListToSend, contactByPartyId, contactIdByPartyId);
            }
            
            vehicleById = Omni_ClaimNotificationPETriggerHelper.saveVehicles(notifBundleListToSend, vehicleById);
            //Populate Vehicle Id in Vehicle map of each PE bundle if existing Vehicle Id is null after vehicle saved
            Omni_ClaimNotificationPETriggerHelper.updateVehicleIdsForAllBundles(notifBundleListToSend, vehicleById);

            claimByClaimId = Omni_ClaimNotificationPETriggerHelper.saveClaims(notifBundleListToSend, 
                                claimByClaimId);
            //Populate Claim Id in Claim map of each PE bundle if existing Claim Id is null after claims saved
            Omni_ClaimNotificationPETriggerHelper.updateClaimIdsForAllBundles(notifBundleListToSend, claimByClaimId);

            exposureByExposureId = Omni_ClaimNotificationPETriggerHelper.saveExposuresFromBundleList(
                                    notifBundleListToSend, exposureByExposureId);
            //Populate Exposure Id in Exposure map of each PE bundle if existing Exposure Id is null after claims saved
            Omni_ClaimNotificationPETriggerHelper.updateExposureIdsForAllBundles(notifBundleListToSend, exposureByExposureId);
            

            if (!exposureByExposureId.isEmpty()) {
                //Generate and save custom object ShadowExposure__c reocords from exposures
                Omni_ClaimNotificationPETriggerHelper.saveShadowExposures(exposureByExposureId.values());
                //Generate and save Transactions
                transactionById = Omni_ClaimNotificationPETriggerHelper.saveTransactionsFromBundleList(
                                    notifBundleListToSend, transactionById);
                //Populate Transaction Id in Transaction map of each PE bundle if existing Transaction Id is null after transactions saved
                Omni_ClaimNotificationPETriggerHelper.updateTransactionIdsForAllBundles(notifBundleListToSend, transactionById);
                //Populate exposure lookups on claims
                claimByClaimId = Omni_ClaimNotificationPETriggerHelper.setExposureLookupsOnClaims(notifBundleListToSend, claimByClaimId);

                //Populate last financial transaction on Exposures
                if(!transactionById.isEmpty()) {
                    exposureByExposureId = Omni_ClaimNotificationPETriggerHelper.updateExposureLastTransaction(
                                            notifBundleListToSend, exposureByExposureId);
                }
            }
            
            roleByPartyRoleIdRoleId = Omni_ClaimNotificationPETriggerHelper.saveRolesFromBundleList(
                                            notifBundleListToSend, roleByPartyRoleIdRoleId);
            //Populate Role Id in Role map of each PE bundle if existing Role Id is null after roles saved
            Omni_ClaimNotificationPETriggerHelper.updateRoleIdsForAllBundles(notifBundleListToSend, roleByPartyRoleIdRoleId);

			sfIdByCCId = Omni_ClaimNotificationPETriggerHelper.populateSFIDsWithCC(roleByPartyRoleIdRoleId, 
                                                                                   exposureByExposureId,
                                                                                   accountByPartyId);
            
            typeCodeToExposures = Omni_ClaimNotificationDAOHelper.exposureTypeByName;
			
            // Populate catergories assigned to the claims based on the event Name
			Omni_ClaimNotificationPETriggerHelper.populateCategories(notifBundleListToSend, 
                                                                     eventNameWithConfigurations,
                                                                    idWithContactRolesMap,
                                                                    idWithExposureTypeMap,
                                                                     sfIdByCCId,
                                                                    typeCodeToExposures);

            // check configurations and Eligibility Criteria
            claimInformationWithFields = Omni_ClaimNotificationPETriggerHelper.checkCategoriesforCriteria(
                																notifBundleListToSend,
                                                                                configWithEC);

            // check configuration, role, exposure types and eligbility criteria 
            Omni_ClaimNotificationPETriggerHelper.checkFinalConfigurations(notifBundleListToSend,
                                                          		               claimInformationWithFields);

          	Omni_ClaimNotificationPETriggerHelper.processCommunication(notifBundleListToSend, 
            															 emailTemplateNameId,
            															 languageConfigWithIds,
                                                                      	claimInformationWithFields,integrationLog.Id);

            //Publish Event Sub and event sub will be processed 1 by 1
            if (!eventMapToResubmit.isEmpty()) {
                EventBus.publish(Omni_ClaimNotificationPETriggerHelper.convertToSubEvents(eventMapToResubmit.values()));
                //Set logs status to duplicated for Events go to Event Sub
                Omni_ClaimNotificationPETriggerHelper.updateCurrentLogsStatusForEventSub(integrationLogByTransId, eventMapToResubmit.keySet());
            }
            //Publish the threshold Event to sub bus
            if (!thresholdEventMapTosubmit.isEmpty()) {
                EventBus.publish(Omni_ClaimNotificationPETriggerHelper.convertToSubEvents(thresholdEventMapTosubmit.values()));
            }
        } catch (Exception e) {
            if (null != sp) {
                Database.rollback(sp);
            }
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            Application_Log__c exceptionLog = ApplicationLogHandler.saveExceptionLog('Claim Notification Event Bulk Exceptions'
                                                    , new ClaimNotificationHandlerException(e.getMessage()+'.\n Transaction Ids are: '+transactionIds, e)
                                                    , integrationLog.Id);
            //Publish failed Events to Sub Events if more that 1 event get failed
            if (eventMapInScope.size() >1) {
                Omni_ClaimNotificationPETriggerHelper.updateLogsForExceptionRetry(integrationLogByTransId.values(), exceptionLog);
                EventBus.publish(Omni_ClaimNotificationPETriggerHelper.convertToSubEvents((List<Claim_Notification__e>)eventMapInScope.values()));
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