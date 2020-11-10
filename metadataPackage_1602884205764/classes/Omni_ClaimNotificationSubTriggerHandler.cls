/**
* @description logic once Platform Event Claim_Notification_Sub__e trigger fires
* @author      Kejia Hu
* @date        01/08/2019                     
*/
public class Omni_ClaimNotificationSubTriggerHandler implements TriggerHandlerBase {
	public String getObjectAPIName() {
        return Omni_ClaimNotificationConstant.SUB_EVENT_NAME;
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
        
		//Initializing idRolesMap
        idWithContactRolesMap = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_ID;
        idWithExposureTypeMap = Omni_ClaimNotificationDAOHelper.EXPOSURE_TYPE_BY_ID;
        configWithEC  = Omni_ConfigurationSelector.getAllConfigurations();

        //Set variables for desired event batch size
        Integer counter = 0;
        Claim_Notification_Sub__e resumeCheckPointEvent;

        // Create a savepoint before DML Operation
        Savepoint sp;

        try{
            for(Claim_Notification_Sub__e event: (List<Claim_Notification_Sub__e>) mapNew.values()){
                counter ++;
                Application_Log__c integrationLogPerEvent;
                //when reached the desired event batch size, quit loop and set resume point
                if (counter > Omni_ClaimNotificationConstant.CLAIM_NOTIF_SUB_PE_BATCH_SIZE) {
                    break;
                } else {
                    resumeCheckPointEvent = event;
                    // Set Replay ID after which to resume event processing in new trigger execution.
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(resumeCheckPointEvent.ReplayId);
                    integrationLogPerEvent = Omni_ClaimNotificationPETriggerHelper.generateIntegrationLog(
                                                event, Omni_ClaimNotificationConstant.LOG_STATUS_PROCESSED);
                    integrationLogs.add(integrationLogPerEvent);
                }

                //Persist JSON payload data into Salesforce DB when Instantiating  Omni_ClaimNotificationBundle
                Omni_ClaimNotificationPEEntity peEntity = new Omni_ClaimNotificationPEEntity(event);
                Omni_ClaimNotificationBundle notifBundle = new Omni_ClaimNotificationBundle(peEntity);
                notifBundle.integrationLog = integrationLogPerEvent;
                notifBundleListToSend.add(notifBundle);
                accountByPartyId.putAll(notifBundle.accountByPartyId);
                eventNames.add(event.EventName__c);
            }
            if (!integrationLogs.isEmpty()) {
                insert integrationLogs;
                integrationLog = integrationLogs[0];
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
                contactByPartyId = Omni_ClaimNotificationPETriggerHelper.saveContactsFromBundleList(
                                    notifBundleListToSend, contactByPartyId);
                //Get contact Ids map of person accounts
                contactIdByPartyId = Omni_ClaimNotificationPETriggerHelper.getContactIdByPartyId(
                                        accountByPartyId.keySet(), contactIdByPartyId);
                //Get contact Ids map of business accounts
                contactIdByPartyId = Omni_ClaimNotificationPETriggerHelper.getContactIdByPartyId(
                                        notifBundleListToSend, contactByPartyId, contactIdByPartyId);
            }
            vehicleById = Omni_ClaimNotificationPETriggerHelper.saveVehicles(notifBundleListToSend, vehicleById);

            claimByClaimId = Omni_ClaimNotificationPETriggerHelper.saveClaims(notifBundleListToSend, 
                                claimByClaimId);

            exposureByExposureId = Omni_ClaimNotificationPETriggerHelper.saveExposuresFromBundleList(
                                    notifBundleListToSend, exposureByExposureId);
            
            

            if (!exposureByExposureId.isEmpty()) {
                //Generate and save custom object ShadowExposure__c reocords from exposures
                Omni_ClaimNotificationPETriggerHelper.saveShadowExposures(exposureByExposureId.values());
                //Generate and save Transactions
                transactionById = Omni_ClaimNotificationPETriggerHelper.saveTransactionsFromBundleList(
                                    notifBundleListToSend, transactionById);
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
        } catch (Exception e) {
            if (null != sp) {
                Database.rollback(sp);
            }
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ApplicationLogHandler.saveExceptionLog('Claim Notification Sub Event Exception', e , integrationLog.Id); 
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