/**
* @description OM-925 helper class holds additional methods for trigger handler
* @author      Kejia Hu
* @date        08/08/2019                     
*/
public with sharing class Omni_ClaimNotificationPETriggerHelper {

    /**
    * @description setup Exposure lookup values on Claims 
    * @author      Kejia Hu
    * @date        06/12/2019                    
    */
    public static Map<String, Case> setExposureLookupsOnClaims(
                                        List<Omni_ClaimNotificationBundle> notifBundleListToSend, 
                                        Map<String, Case> claimsToUpdate) {
        for (Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            oneBundle.setExposureLookupsForClaim();
            String claimId = oneBundle.peEntity.claimId;
            claimsToUpdate.put(claimId, oneBundle.claimByClaimId.get(claimId));
        }
        update claimsToUpdate.values();
        return claimsToUpdate;
    }

    /**
    * @description check if counts pass the maximum values 
    * @author      Kejia Hu
    * @date        15/11/2019                    
    */
    public static Boolean isPassMax(Decimal expoCount, Decimal transCount, Decimal partyCount, Decimal roleCount) {
        return (expoCount > Decimal.valueOf(Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('MaxSizeClaimExposures'))
                || transCount > Decimal.valueOf(Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('MaxSizeFinancialTransactions'))
                || partyCount > Decimal.valueOf(Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('MaxSizeParty'))
                || roleCount > Decimal.valueOf(Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('MaxSizePartyRoles'))
                );
    }
    
    /**
    * @description convert events to a sub events
    * @author      Kejia Hu
    * @date        24/10/2019                    
    */
    public static List<Claim_Notification_Sub__e> convertToSubEvents(List<Claim_Notification__e> events) {
        List<Claim_Notification_Sub__e> subEvents = new List<Claim_Notification_Sub__e>();
        for (Claim_Notification__e event : events) {
            subEvents.add(convertToSubEvent(event));
        }
        return subEvents;
    }

    /**
    * @description convert an event to a sub event
    * @author      Kejia Hu
    * @date        24/10/2019                    
    */
    public static Claim_Notification_Sub__e convertToSubEvent(Claim_Notification__e event) {
        Claim_Notification_Sub__e subEvent = new Claim_Notification_Sub__e();
        subEvent.EventId__c = event.EventId__c;
        subEvent.TransactionID__c = event.TransactionID__c;
        subEvent.EventName__c = event.EventName__c;
        subEvent.EventTime__c = event.EventTime__c;
        subEvent.EventTrackingNumber__c = event.EventTrackingNumber__c;
        subEvent.EventVersion__c = event.EventVersion__c;
        subEvent.ClaimId__c = event.ClaimId__c;
        subEvent.ClaimNumber__c = event.ClaimNumber__c;
        subEvent.DateOfLoss__c = event.DateOfLoss__c;
        subEvent.TypeOfLoss__c = event.TypeOfLoss__c;
        subEvent.CauseOfLoss__c = event.CauseOfLoss__c;
        subEvent.InsuredProbableFaultPercentage__c = event.InsuredProbableFaultPercentage__c;
        subEvent.IncidentDescription__c = event.IncidentDescription__c;
        subEvent.LiabilityConfirmed__c = event.LiabilityConfirmed__c;
        subEvent.PolicyNumber__c = event.PolicyNumber__c;
        subEvent.PolicyIssuingGroup__c = event.PolicyIssuingGroup__c;
        subEvent.AssignedUserId__c = event.AssignedUserId__c;
        subEvent.ClaimDeductibleAmount__c = event.ClaimDeductibleAmount__c;
        subEvent.ClaimDeductibleAmountCurrencyCode__c = event.ClaimDeductibleAmountCurrencyCode__c;
        subEvent.IncidentAddressLine__c = event.IncidentAddressLine__c;
        subEvent.IncidentPostalCode__c = event.IncidentPostalCode__c;
        subEvent.IncidentProvince__c = event.IncidentProvince__c;
        subEvent.IncidentCity__c = event.IncidentCity__c;
        subEvent.IncidentCountry__c = event.IncidentCountry__c;
        subEvent.AppraiserPartyId__c = event.AppraiserPartyId__c;
        subEvent.DamageRepairPartyId__c = event.DamageRepairPartyId__c;
        subEvent.RentalCompanyPartyId__c = event.RentalCompanyPartyId__c;
        subEvent.LossVehicleId__c = event.LossVehicleId__c;
        subEvent.ProvinceOfIssuanceId__c = event.ProvinceOfIssuanceId__c;
        subEvent.InjuredParty__c = event.InjuredParty__c;
        subEvent.BranchReferenceNumber__c = event.BranchReferenceNumber__c;
        subEvent.ClaimNumberReplaced__c = event.ClaimNumberReplaced__c;
        subEvent.ClaimLOBGroup__c = event.ClaimLOBGroup__c;
        subEvent.ClaimLOB__c = event.ClaimLOB__c;
        subEvent.UnderwritingCompanyNumber__c = event.UnderwritingCompanyNumber__c;
        subEvent.SellingChannelDistributorNumber__c = event.SellingChannelDistributorNumber__c;
        subEvent.SellingChannelDistributionChannel__c = event.SellingChannelDistributionChannel__c;
        subEvent.ClaimContractEffectiveDate__c = event.ClaimContractEffectiveDate__c;
        subEvent.ClaimContractExpiryDate__c = event.ClaimContractExpiryDate__c;
        subEvent.AppraisalTaskStatus__c = event.AppraisalTaskStatus__c;
        subEvent.AppraisalAppointmentDate__c = event.AppraisalAppointmentDate__c;
        subEvent.AppraisalAppointmentTime__c = event.AppraisalAppointmentTime__c;
        subEvent.InitialGrossEstimateCurrency__c = event.InitialGrossEstimateCurrency__c;
        subEvent.InitialGrossEstimateAmount__c = event.InitialGrossEstimateAmount__c;
        subEvent.RentalContractStatus__c = event.RentalContractStatus__c;
        subEvent.RentalLimit__c = event.RentalLimit__c;
        subEvent.InjuriesInvolved__c = event.InjuriesInvolved__c;
        subEvent.VirtualAppraisal__c = event.VirtualAppraisal__c;
        subEvent.ClientPIN__c = event.ClientPIN__c;
        subEvent.IncidentDateReported__c = event.IncidentDateReported__c;
        subEvent.TotalLoss__c = event.TotalLoss__c;
        subEvent.AssignedVehicleId__c = event.AssignedVehicleId__c;
        subEvent.AssignedDriverPartyId__c = event.AssignedDriverPartyId__c;
        subEvent.InformationSensitivity__c = event.InformationSensitivity__c;
        subEvent.IncidentReportOnly__c = event.IncidentReportOnly__c;
        subEvent.ManuallyEnteredPolicy__c = event.ManuallyEnteredPolicy__c;
        subEvent.ConversionOrigin__c = event.ConversionOrigin__c;
        subEvent.ClaimStatus__c = event.ClaimStatus__c;
        subEvent.ClaimClosedDate__c = event.ClaimClosedDate__c;
        subEvent.AppraisalQualifier__c = event.AppraisalQualifier__c;
        subEvent.AssignedLossDriverId__c = event.AssignedLossDriverId__c;
        subEvent.InjuredParty__c = event.InjuredParty__c;
        subEvent.ClaimOriginEffectiveDate__c = event.ClaimOriginEffectiveDate__c;
        subEvent.PrimaryAdjuster__c = event.PrimaryAdjuster__c;
        subEvent.NonCasualtyWithoutPrejudice__c = event.NonCasualtyWithoutPrejudice__c;
        subEvent.NonCasualtyCoverageInQuestion__c = event.NonCasualtyCoverageInQuestion__c;
        subEvent.InsuredPartyId__c = event.InsuredPartyId__c;
        subEvent.RentalNumberOfAuthorizedDays__c = event.RentalNumberOfAuthorizedDays__c;
        subEvent.AgentPartyId__c = event.AgentPartyId__c;
        subEvent.ClaimExposures__c = event.ClaimExposures__c;
        subEvent.Party__c = event.Party__c;
        subEvent.FinancialTransactions__c = event.FinancialTransactions__c;
        subEvent.PartyRoles__c = event.PartyRoles__c;
        subEvent.Addresses__c = event.Addresses__c;
        subEvent.Emails__c = event.Emails__c;
        subEvent.Phones__c = event.Phones__c;
        subEvent.Vehicles__c = event.Vehicles__c;
        subEvent.DrivingLicenses__c = event.DrivingLicenses__c;
        subEvent.LastOpenedNonBIExposureId__c = event.LastOpenedNonBIExposureId__c;
        subEvent.ClaimOpenedDate__c = event.ClaimOpenedDate__c;
        subEvent.ClaimReopenedDate__c = event.ClaimReopenedDate__c;
        subEvent.TotalIndemnity__c = event.TotalIndemnity__c;
        subEvent.TotalRecovery__c = event.TotalRecovery__c;
        subEvent.QCLNClaimExpVehicleChapAPaid__c = event.QCLNClaimExpVehicleChapAPaid__c;
        subEvent.QCLNClaimExpVehicleChapBPaid__c = event.QCLNClaimExpVehicleChapBPaid__c;
        subEvent.NLPClaimSectionAPaidThirdParty__c = event.NLPClaimSectionAPaidThirdParty__c;
        subEvent.InsuredIncDriverPartyId__c = event.InsuredIncDriverPartyId__c;
        subEvent.InsuredIncCustodianPartyId__c = event.InsuredIncCustodianPartyId__c;
        subEvent.QCLNExposureId__c = event.QCLNExposureId__c;
        subEvent.NLPLExposureId__c = event.NLPLExposureId__c;
        return subEvent;
    }
    
    /**
    * @description OM-925 persist claim from platform event
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Case> saveClaims(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,
        Map<String, Case> claimByClaimId) {
            for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                notifBundle.setClaimByClaimId();
                claimByClaimId.putAll(notifBundle.claimByClaimId);
            }
            upsert claimByClaimId.values() ClaimId__c;
            return claimByClaimId;
        }
    
    /**
    * @description OM-925 persist vehicles from platform event
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Vehicle__c> saveVehicles(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,
        Map<String, Vehicle__c> vehicleById) {
            for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                notifBundle.setVehicleById();
                vehicleById.putAll(notifBundle.vehicleById);
            }
            if (!vehicleById.isEmpty()) {
                upsert vehicleById.values() VehicleId__c;
            }
            return vehicleById;
        }
    
    /**
    * @description OM-925 persist exposures(Case) from Bundle list
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Case> saveExposuresFromBundleList(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,  
        Map<String, Case> exposureByExposureId) {
            for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                notifBundle.setExposureByExposureId();
                exposureByExposureId.putAll(notifBundle.exposureByExposureId);
            }
            if (!exposureByExposureId.isEmpty()) {
                upsert exposureByExposureId.values() ExposureId__c;
            }
            return exposureByExposureId;
        }
    
    /**
    * @description OM-925 persist transactions from platform event
    * @author      Kejia Hu
    * @date        05/09/2019                    
    */
    public static Map<String, Transaction__c> saveTransactionsFromBundleList(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,
        Map<String, Transaction__c> transactionById) {
            for(Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                notifBundle.setTransactionById();
                transactionById.putAll(notifBundle.transactionById);
            }
            if (!transactionById.isEmpty()) {
                upsert transactionById.values() Transaction_Id__c;
            }
            return transactionById;
        }
    
    /**
    * @description OM-925 update exposure last transaction
    * @author      Kejia Hu
    * @date        06/09/2019                    
    */
    public static Map<String, Case> updateExposureLastTransaction(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,
        Map<String, Case> exposureByExposureId) {
            for(Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                notifBundle.populateExposuresLastTransaction();
                exposureByExposureId.putAll(notifBundle.exposureByExposureId);
            }
            update exposureByExposureId.values();
            return exposureByExposureId;
        }
    
    /**
    * @description OM-925 persist roles(Case) from Bundle list
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public static Map<String, Case> saveRolesFromBundleList(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,
        Map<String, Case> roleByPartyRoleId) {
            Map<String,Account> allAccountByPartyId = new Map<String,Account>();
            for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                allAccountByPartyId.putAll(notifBundle.accountByPartyId);
            }
            Set<Id> accIds = getAccountIds(allAccountByPartyId.values());
            Map<String, Contact> contactByAccountId = Omni_ContactSelector.getContactByAccountId(accIds);
            for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                notifBundle.setRoleByPartyRoleId(contactByAccountId);
                roleByPartyRoleId.putAll(notifBundle.roleByPartyRoleId);
            }
            if (!roleByPartyRoleId.isEmpty()) {
                upsert roleByPartyRoleId.values() RoleId__c;
            }
            return roleByPartyRoleId;
        }
    
    /**
    * @description OM-925 persist contacts from Bundle list
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Contact> saveContactsFromBundleList(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,  
        Map<String, Contact> contactByPartyId) {
            for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                notifBundle.setContactByPartyId();
                contactByPartyId.putAll(notifBundle.contactByPartyId);
            }
            if (!contactByPartyId.isEmpty()) {
                upsert contactByPartyId.values() PartyId__c;
            }
            return contactByPartyId;
        }
    
    /**
    * @description OM-925 generate and persist shadow exposures from exposures
    * @author      Kejia Hu
    * @date        09/08/2019                    
    */
    public static Map<String, ShadowExposure__c> saveShadowExposures(List<Case> exposures) {
        Map<String, ShadowExposure__c> shadowExposureByExposureId = new Map<String, ShadowExposure__c>();
        for (Case exposure : exposures) {
            shadowExposureByExposureId.put(exposure.ExposureId__c, generateShadowExposureFromExposure(exposure));
        }
        if (!shadowExposureByExposureId.isEmpty()) {
            upsert shadowExposureByExposureId.values() ExposureId__c;
        }
        return shadowExposureByExposureId;
    }
    
    /**
    * @description OM-925 generate shadow exposure from an exposure
    * @author      Kejia Hu
    * @date        09/08/2019                    
    */
    public static ShadowExposure__c generateShadowExposureFromExposure(Case exposure) {
        ShadowExposure__c shadow =  new ShadowExposure__c(
            ExposureId__c = exposure.ExposureId__c,
            Claim__c = exposure.ClaimForExposure__c,
            Exposure__c = exposure.Id,
            ExposureType__c = exposure.ExposureType__c);
        return shadow;
    }
    
    /**
    * @description OM-925 generate ContactIdByPartyId map from bundle list and contact Map
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public static Map<String, String> getContactIdByPartyId(
        List<Omni_ClaimNotificationBundle> notifBundleListToSend,
        Map<String, Contact> contactByPartyId,
        Map<String, String> contactIdByPartyId) {
            for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend) {
                for (Contact c : notifBundle.contactByPartyId.values()) {
                    contactIdByPartyId.put(c.PartyId__c, C.Id);
                }
            }
            return contactIdByPartyId;
        }
    
    /**
    * @description OM-925 generate ContactIdByPartyId map from person account Id list
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public static Map<String, String> getContactIdByPartyId(
        Set<String> accoutPartyIdList, 
        Map<String, String> contactIdByPartyId) {
            Map<String, Account> personAccountsByPartyId = Omni_AccountSelector.getPersonAccountsByPartyId(accoutPartyIdList);
            for (Account personAcc: personAccountsByPartyId.values()) {
                contactIdByPartyId.put(personAcc.PartyId__c, personAcc.PersonContactId);
            }
            return contactIdByPartyId;
        }
    
    /**
    * @description save Integration log from one Event with Status
    * @author      Kejia Hu
    * @date        25/10/2019                     
    */
    public static Application_Log__c generateIntegrationLog(Claim_Notification__e notifEvent, String status) {
        String payloadBody = JSON.serialize(notifEvent);
        String transIdForLog = notifEvent.TransactionId__c;
        String refNumForLog = notifEvent.ClaimNumber__c;
        String trackingNumForLog = notifEvent.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description save Integration log from one Sub Event
    * @author      Kejia Hu
    * @date        27/08/2019                     
    */
    public static Application_Log__c generateIntegrationLog(Claim_Notification_Sub__e notifEvent, String status) {
        String payloadBody = JSON.serialize(notifEvent);
        String transIdForLog = notifEvent.TransactionId__c;
        String refNumForLog = notifEvent.ClaimNumber__c;
        String trackingNumForLog = notifEvent.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, refNumForLog, trackingNumForLog);
        return integrationLog;                                            
    }
    
    /**
    * @description OM-925 generate an integration log from payload
    * @author      Kejia Hu
    * @date        11/08/2019                     
    */
    public static Application_Log__c genereateIntegrationLog(String payload, String transactionId, String status, String referenceNum, String TrackingNum) {
        Application_Log__c eventLog = new Application_Log__c();
        eventLog.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
        eventLog.Application_Name__c = (payload.contains(Omni_ClaimNotificationConstant.EVENT_NAME)) 
                                            ? 'Claim Notification Event' 
                                            : 'Claim Notification Sub Event';
        eventLog.Category__c = 'Integration';
        eventLog.Transaction_Id__c = transactionId;
        eventLog.Status__c = status;
        eventLog.ReferenceNumber__c = referenceNum;
        eventLog.TrackingNumber__c = TrackingNum;
        if (payload.length()>131072) {
            eventLog.Request_Payload__c =  payload.substring(0, 131071);
            eventLog.AdditionalPayload__c = (payload.substring(131072).length()>131072)
                ? payload.substring(131072).substring(0, 131071)
                : payload.substring(131072);
        } else {
            eventLog.Request_Payload__c =  payload;
        }
        return eventLog;
    }
    
    /**
    * @description OM-925 to get the association between Event Names and ConfigNames
    * @author      Vikas Sharma
    * @date        21/08/2019                     
    */
    public static Map<String, List<Communication_Configuration__c>> generateEventConfigurations(Set<String> eventNames) 
    {
        
        return Omni_ConfigurationSelector.getConfigurationsByEventNames(eventNames);
    }
    
    /**
    * @description OM-925 to populate the list of categories for every claim bundle
    * @author      Vikas Sharma
    * @date        21/08/2019                     
    */
    public static void populateCategories(List<Omni_ClaimNotificationBundle> notifBundleListToSend,
                                          Map<String, List<Communication_Configuration__c>> eventNameWithConfigurations,
                                          Map<String, ContactRole__c> idWithContactRolesMap,
                                          Map<String, ExposureType__c> idWithExposureTypeMap, Map<String, String> sfIdsWithCC,
                                          Map<String, ExposureType__c> typeCodeToExposures)
    {
        
        for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend)
        {
            if (eventNameWithConfigurations != null &&
                eventNameWithConfigurations.get(notifBundle.peEntity.eventName) != null)
            {
                notifBundle.generateConfigurations(eventNameWithConfigurations.get(notifBundle.peEntity.eventName),
                                                   idWithContactRolesMap,
                                                   idWithExposureTypeMap,sfIdsWithCC,typeCodeToExposures);
            }
            
        }
        
    }
    
    /**
    * @description OM-925 to finalize the templates based on eligibility criteria
    * @author      Vikas Sharma
    * @date        29/08/2019                     
    */
    public static List<Case> checkCategoriesforCriteria(List<Omni_ClaimNotificationBundle> notifBundleListToSend, 
                                                        Set<String> listOfFields )
    {
        List<Case> toReturn = new List<Case>();
        
        List<String> listToVerify = new List<String>(listOfFields);
        String fields = String.join(listToVerify, ',');
        List<Id> listOfIds = new List<Id>();
        for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend)
        {
            if (notifBundle.rolesByConfigurations != null){
                for (Case cs : notifBundle.rolesByConfigurations.keySet())
                {
                    listOfIds.add(cs.Id);    
                    
                }
            }
        }
        String queryToExecute = 'SELECT Id, RecordTypeId, DEAForRole__c,' + fields + ' FROM Case WHERE Id IN : listOfIds' + ' AND Retired__c = false'; 	
        if (fields != '')
        {        
            toReturn = Database.query(queryToExecute);
        }
        return toReturn;
    }
    
    /**
    * @description OM-925 to check the final list of roles after validating eligibility critera
    * @author      Vikas Sharma
    * @date        29/08/2019                     
    */
    public static void checkFinalConfigurations(List<Omni_ClaimNotificationBundle> notifBundleListToSend, 
                                                List<Case> cases)
    {
        
        List<Case> toDeleteShadowRoles = new List<Case>();
        
        String shadowRoleId = ''+Omni_ClaimNotificationConstant.RECORD_TYPE_ID_SHADOW_ROLE;
        for(Omni_ClaimNotificationBundle currentBundle : notifBundleListToSend)
        {
            Map<Case, List<Communication_Configuration__c>> setFinal = new Map<Case, List<Communication_Configuration__c>>();
            if(currentBundle.rolesByConfigurations == null)
            {continue;}
            for (Case crCase : currentBundle.rolesByConfigurations.keySet())
            {
                for (Case currentCase : cases)
                {
                    if (crCase.Id == currentCase.Id)
                    {
                        Set<Communication_Configuration__c> configurations = currentBundle.rolesByConfigurations.get(crCase);
                        for(Communication_Configuration__c cc : configurations)
                        {
                            if (cc.Eligibility_Criteria__c == null)
                            {
                                if (setFinal.get(crCase) == null)
                                {
                                    setFinal.put(crCase, new List<Communication_Configuration__c>{cc});
                                }
                                else
                                {
                                    setFinal.get(crCase).add(cc);    
                                }
                            }
                            else
                            {
                                
                                if ('' + currentCase.get(cc.Eligibility_Criteria__c) == 'true')
                                {
                                    if (setFinal.get(crCase) == null)
                                    {
                                        setFinal.put(crCase, new List<Communication_Configuration__c>{cc});
                                    }
                                    else
                                    {
                                        setFinal.get(crCase).add(cc);    
                                        
                                    }
                                }
                                else
                                {
                                    if (currentCase.RecordTypeId == shadowRoleId)
                                    {
                                        toDeleteShadowRoles.add(currentCase);
                                    }
                                    // Ignore the role as its not eligible 
                                }
                            }
                        }
                    }
                }
                
                currentBundle.finalListToSendEmail = setFinal;
            }
        }
    }
    
    
    
    
    /**
    * @description OM-925 To Send emails
    * @author      Vikas Sharma
    * @date        21/08/2019                     
    */
    public static void processCommunication(List<Omni_ClaimNotificationBundle> notifBundleListToSend,
                                            Map<String, Id> emailTemplateIdWithName, Map<Id, List<Language_Config__c>> languageConfigWithIds,
                                            List<Case> fullCases, String parentLogId)
    {
        Map<Case, List<String>> toSendEmail = new Map<Case, List<String>>();
        //Replace toSendEmail
        Map<Omni_CommunicationDispatcher.RoleWithLog, List<String>> toSendEmailWithLog = new Map<Omni_CommunicationDispatcher.RoleWithLog, List<String>>();
        Map<Case, List<String>> toSendSMS = new Map<Case, List<String>>();
        
        Map<Case, Set<Communication_Configuration__c>> toSendFaxPrint = new Map<Case, Set<Communication_Configuration__c>>();
        //Replace toSendFaxPrint
        Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> toSendFaxPrintWithLog 
            = new Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>>();
        Map<Case, Set<Communication_Configuration__C>> toSendFax = new Map<Case, Set<Communication_Configuration__c>>();
        //Replace toSendFax
        Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__C>> toSendFaxWithLog = new Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>>();
        Map<Case, Set<Communication_Configuration__C>> toSendPrint = new Map<Case, Set<Communication_Configuration__c>>();
        //Replace toSendFax
        Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__C>> toSendPrintWithLog = new Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>>();
        
        Map<String, Account>  accountDetailInfo = new Map<String, Account>();
        Map<Case, Set<Communication_Configuration__c>> toSendSMSCaseWithConfig = new Map<Case, Set<Communication_Configuration__c>>();
        Map<Case, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplate = new Map<Case, Map<Communication_Configuration__c, List<String>>>();
        //Replace toSendRoleWithListOfCommWithTemplate
        Map<Omni_CommunicationDispatcher.RoleWithLog, Map<Communication_Configuration__c, List<String>>> toSendRoleLogWithListOfCommWithTemplate 
            = new Map<Omni_CommunicationDispatcher.RoleWithLog, Map<Communication_Configuration__c, List<String>>>();

        Set<Id> integrationLogIds = new Set<Id>();
        for (Omni_ClaimNotificationBundle notifBundle : notifBundleListToSend)
        {
            integrationLogIds.add(notifBundle.integrationLog.Id);
            for (Case finalCase : notifBundle.finalListToSendEmail.keySet())
            {
                List<Communication_Configuration__c> currentConfigs = notifBundle.finalListToSendEmail.get(finalCase);
                Omni_CommunicationDispatcher.RoleWithLog finalCaseWithLog = new Omni_CommunicationDispatcher.RoleWithLog(
                                                                                notifBundle.integrationLog, finalCase);
                for (Communication_Configuration__c currentConfig : currentConfigs){
                    if ( currentConfig != null)
                    {
                        List<String> communications = currentConfig.Communication_Type__c.split(';');
                        
                        for(String communicationType : communications)
                        {
                            // Process EMAIL Logic
                            if (communicationType == 'EMAIL')
                            {
                                List<String> listOfTemplates = new List<String>();
                                listOfTemplates = Utility.getTemplateNames(currentConfig, fullCases,
                                                                           languageConfigWithIds, 'EMAIL',
                                                                           finalCase);
                                
                                if (toSendEmail.get(finalCase)==null){
                                    toSendEmail.put(finalCase, listOfTemplates);	        
                                }
                                else{
                                    toSendEmail.get(finalCase).addAll(listOfTemplates);	        
                                }
                                //Replace toSendEmail
                                if (toSendEmailWithLog.get(finalCaseWithLog)==null){
                                    toSendEmailWithLog.put(finalCaseWithLog, listOfTemplates);	        
                                }
                                else{
                                    toSendEmailWithLog.get(finalCaseWithLog).addAll(listOfTemplates);	        
                                }
                                
                            }
                            // Process SMS logic
                            if (communicationType == 'SMS')
                            {
                                List<String> listOfTemplates = new List<String>();
                                
                                listOfTemplates = Utility.getTemplateNames(currentConfig, fullCases,
                                                                           languageConfigWithIds, 'SMS',
                                                                           finalCase);
                                
                                if (toSendSMS.get(finalCase) == null){
                                    toSendSMS.put(finalCase, listOfTemplates.clone());	        
                                }
                                else
                                {
                                    toSendSMS.get(finalCase).addAll(listOfTemplates.clone());	        
                                }
                                
                                if (toSendSMSCaseWithConfig.get(finalCase)==null){
                                    toSendSMSCaseWithConfig.put(finalCase, new Set<Communication_Configuration__c>{currentConfig});	        
                                }
                                else{
                                    toSendSMSCaseWithConfig.get(finalCase).add(currentConfig);	        
                                }
                                
                                accountDetailInfo.putAll(populateAccountDetailInfo(finalCase, notifBundle.accountByPartyId));
                                
                                
                                // Well this is the final for SMS logic, NEEDS CLEANUP
                                
                                if (toSendRoleWithListOfCommWithTemplate.get(finalCase)==null){
                                    
                                    Map<Communication_Configuration__c, List<String>> commsWithTemplaets = new Map<Communication_Configuration__c, List<String>>();
                                    commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                    toSendRoleWithListOfCommWithTemplate.put(finalCase, commsWithTemplaets);	        
                                }
                                else{
                                    Map<Communication_Configuration__c, List<String>> commsWithTemplaets = toSendRoleWithListOfCommWithTemplate.get(finalCase);
                                    
                                    if (commsWithTemplaets.get(currentConfig) != null)
                                    {
                                        commsWithTemplaets.get(currentConfig).addAll(listOfTemplates.clone());
                                    }
                                    else
                                    {
                                        commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                    }
                                    toSendRoleWithListOfCommWithTemplate.get(finalCase).putAll(commsWithTemplaets);	        
                                }

                                //Replace toSendRoleWithListOfCommWithTemplate
                                if (toSendRoleLogWithListOfCommWithTemplate.get(finalCaseWithLog) == null){
                                    Map<Communication_Configuration__c, List<String>> commsWithTemplaets = new Map<Communication_Configuration__c, List<String>>();
                                    commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                    toSendRoleLogWithListOfCommWithTemplate.put(finalCaseWithLog, commsWithTemplaets);	        
                                } else {
                                    Map<Communication_Configuration__c, List<String>> commsWithTemplaets = toSendRoleLogWithListOfCommWithTemplate.get(finalCaseWithLog);
                                    
                                    if (commsWithTemplaets.get(currentConfig) != null) {
                                        commsWithTemplaets.get(currentConfig).addAll(listOfTemplates.clone());
                                    } else {
                                        commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                    }
                                    toSendRoleLogWithListOfCommWithTemplate.get(finalCaseWithLog).putAll(commsWithTemplaets);	        
                                }   
                            }
                            if (communicationType == 'PRINT' || communicationType == 'FAX'){
                                
                                if (toSendFaxPrint.get(finalCase)==null){
                                    toSendFaxPrint.put(finalCase, new Set<Communication_Configuration__c>{currentConfig});	        
                                }
                                else{
                                    toSendFaxPrint.get(finalCase).add(currentConfig);	        
                                }
                                //Replace toSendFaxPrint
                                if (toSendFaxPrintWithLog.get(finalCaseWithLog)==null){
                                    toSendFaxPrintWithLog.put(finalCaseWithLog, new Set<Communication_Configuration__c>{currentConfig});	        
                                }
                                else{
                                    toSendFaxPrintWithLog.get(finalCaseWithLog).add(currentConfig);	        
                                }
                            }
                            
                            
                            if (communicationType == 'FAX'){
                                
                                if (toSendFax.get(finalCase)==null){
                                    toSendFax.put(finalCase, new Set<Communication_Configuration__c>{currentConfig});	        
                                }
                                else{
                                    toSendFax.get(finalCase).add(currentConfig);	        
                                }
                            }
                            //Replace toSendFax
                            if (communicationType == 'FAX') {
                                if (toSendFaxWithLog.get(finalCaseWithLog)==null) {
                                    toSendFaxWithLog.put(finalCaseWithLog, new Set<Communication_Configuration__c>{currentConfig});	        
                                } else {
                                    toSendFaxWithLog.get(finalCaseWithLog).add(currentConfig);	        
                                }
                            }

                            if (communicationType == 'PRINT'){
                                
                                if (toSendPrint.get(finalCase)==null){
                                    toSendPrint.put(finalCase, new Set<Communication_Configuration__c>{currentConfig});	        
                                }
                                else{
                                    toSendPrint.get(finalCase).add(currentConfig);	        
                                }
                            }
                            //Replace toSendPrint
                            if (communicationType == 'PRINT') {
                                if (toSendPrintWithLog.get(finalCaseWithLog)==null) {
                                    toSendPrintWithLog.put(finalCaseWithLog, new Set<Communication_Configuration__c>{currentConfig});	        
                                } else {
                                    toSendPrintWithLog.get(finalCaseWithLog).add(currentConfig);	        
                                }
                            }
                            
                            // Process if Communication type is custom Criteria
                            if (communicationType == 'Custom Criteria')
                            {
                                List<String> configCommunicationTypes = new List<String>();
                                configCommunicationTypes = Utility.getCaseFielValue(finalCase.Id, 
                                                                                    currentConfig.Custom_Criteria__c, 
                                                                                    fullCases
                                                                                   );
                                for (String configComm : configCommunicationTypes){
                                    if (configComm == 'EMAIL')
                                    {
                                        List<String> listOfTemplates = new List<String>();
                                        listOfTemplates = Utility.getTemplateNames(currentConfig, fullCases,
                                                                                   languageConfigWithIds, 'EMAIL',
                                                                                   finalCase);
                                        
                                        if (toSendEmail.get(finalCase)==null){
                                            toSendEmail.put(finalCase, listOfTemplates);	        
                                        }
                                        else{
                                            toSendEmail.get(finalCase).addAll(listOfTemplates);	        
                                        }
                                        //Replace toSendEmail
                                        if (toSendEmailWithLog.get(finalCaseWithLog)==null){
                                            toSendEmailWithLog.put(finalCaseWithLog, listOfTemplates);	        
                                        }
                                        else{
                                            toSendEmailWithLog.get(finalCaseWithLog).addAll(listOfTemplates);	        
                                        }
                                        
                                    }
                                    if (configComm == 'SMS')
                                    {
                                        List<String> listOfTemplates = new List<String>();
                                        listOfTemplates = Utility.getTemplateNames(currentConfig, fullCases,
                                                                                   languageConfigWithIds, 'SMS',
                                                                                   finalCase);
                                        
                                        
                                        
                                        
                                        if (toSendSMS.get(finalCase)==null){
                                            toSendSMS.put(finalCase, listOfTemplates.clone());	        
                                        }
                                        else{
                                            toSendSMS.get(finalCase).addAll(listOfTemplates.clone());	        
                                        }
                                        
                                        // Well this is the final for SMS logic, NEEDS CLEANUP
                                        
                                        if (toSendRoleWithListOfCommWithTemplate.get(finalCase)==null){
                                            
                                            Map<Communication_Configuration__c, List<String>> commsWithTemplaets = new Map<Communication_Configuration__c, List<String>>();
                                            
                                       		commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                            toSendRoleWithListOfCommWithTemplate.put(finalCase, commsWithTemplaets);	        
                                            
                                            
                                            
                                            
                                        }
                                        else{
                                            
                                            Map<Communication_Configuration__c, List<String>> commsWithTemplaets = toSendRoleWithListOfCommWithTemplate.get(finalCase);
                                            
                                            if (commsWithTemplaets.get(currentConfig) != null)
                                            {
                                                commsWithTemplaets.get(currentConfig).addAll(listOfTemplates.clone());
                                            }
                                            else
                                            {
                                                commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                            }
                                            
                                            toSendRoleWithListOfCommWithTemplate.get(finalCase).putAll(commsWithTemplaets);	        
                                        }

                                        //Replace toSendRoleWithListOfCommWithTemplate
                                        if (toSendRoleLogWithListOfCommWithTemplate.get(finalCaseWithLog)==null){
                                            Map<Communication_Configuration__c, List<String>> commsWithTemplaets = new Map<Communication_Configuration__c, List<String>>();                                        
                                       		commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                            toSendRoleLogWithListOfCommWithTemplate.put(finalCaseWithLog, commsWithTemplaets);	        
                                        } else {
                                            
                                            Map<Communication_Configuration__c, List<String>> commsWithTemplaets = toSendRoleLogWithListOfCommWithTemplate.get(finalCaseWithLog);
                                            
                                            if (commsWithTemplaets.get(currentConfig) != null) {
                                                commsWithTemplaets.get(currentConfig).addAll(listOfTemplates.clone());
                                            } else {
                                                commsWithTemplaets.put(currentConfig, listOfTemplates.clone());
                                            }
                                            toSendRoleLogWithListOfCommWithTemplate.get(finalCaseWithLog).putAll(commsWithTemplaets);	        
                                        }
                                        
                                        accountDetailInfo.putAll(populateAccountDetailInfo(finalCase, notifBundle.accountByPartyId));
                                    }
                                    
                                    if (configComm == 'PRINT' || configComm == 'FAX'){
                                        
                                        if (toSendFaxPrint.get(finalCase)==null){
                                            toSendFaxPrint.put(finalCase, new Set<Communication_Configuration__c>{currentConfig});	        
                                        }
                                        else{
                                            toSendFaxPrint.get(finalCase).add(currentConfig);	        
                                        }
                                        //Replace toSendFaxPrint
                                        if (toSendFaxPrintWithLog.get(finalCaseWithLog)==null){
                                            toSendFaxPrintWithLog.put(finalCaseWithLog, new Set<Communication_Configuration__c>{currentConfig});	        
                                        }
                                        else{
                                            toSendFaxPrintWithLog.get(finalCaseWithLog).add(currentConfig);	        
                                        }
                                    }
                                    
                                    if (configComm == 'FAX'){
                                        
                                        if (toSendFax.get(finalCase)==null){
                                            toSendFax.put(finalCase, new Set<Communication_Configuration__c>{currentConfig});	        
                                        }
                                        else{
                                            toSendFax.get(finalCase).add(currentConfig);	        
                                        }
                                    }
                                    //Replace toSendFax
                                    if (configComm == 'FAX') {
                                        if (toSendFaxWithLog.get(finalCaseWithLog)==null) {
                                            toSendFaxWithLog.put(finalCaseWithLog, new Set<Communication_Configuration__c>{currentConfig});	        
                                        } else {
                                            toSendFaxWithLog.get(finalCaseWithLog).add(currentConfig);	        
                                        }
                                    }
                                    
                                    if (configComm == 'PRINT'){
                                        
                                        if (toSendPrint.get(finalCase)==null){
                                            toSendPrint.put(finalCase, new Set<Communication_Configuration__c>{currentConfig});	        
                                        }
                                        else{
                                            toSendPrint.get(finalCase).add(currentConfig);	        
                                        }
                                    }
                                    //Replace toSendPrint
                                    if (configComm == 'PRINT') {
                                        if (toSendPrintWithLog.get(finalCaseWithLog)==null) {
                                            toSendPrintWithLog.put(finalCaseWithLog, new Set<Communication_Configuration__c>{currentConfig});	        
                                        } else {
                                            toSendPrintWithLog.get(finalCaseWithLog).add(currentConfig);	        
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                    }
                }
            }
            
        }
        
        // Omni_CommunicationHelper.send('EMAIL', toSendEmail, emailTemplateIdWithName,
        //                               accountDetailInfo,
        //                               toSendSMSCaseWithConfig,
        //                               parentLogId, toSendFaxPrint,toSendRoleWithListOfCommWithTemplate,toSendPrint,toSendFax);
        //Replace
        Omni_CommunicationDispatcher.send('EMAIL', toSendEmailWithLog, emailTemplateIdWithName,
                                      accountDetailInfo,
                                      toSendSMSCaseWithConfig,
                                      parentLogId, toSendFaxPrint,toSendRoleLogWithListOfCommWithTemplate,null,null);
        // Omni_CommunicationHelper.send('SMS', toSendSMS,
        //                               emailTemplateIdWithName, 
        //                               accountDetailInfo,
        //                               toSendSMSCaseWithConfig,
        //                               parentLogId,toSendFaxPrint,toSendRoleWithListOfCommWithTemplate,toSendPrint,toSendFax);
        //Replace
        Omni_CommunicationDispatcher.send('SMS', null,
                                      emailTemplateIdWithName, 
                                      accountDetailInfo,
                                      toSendSMSCaseWithConfig,
                                      parentLogId,toSendFaxPrint,toSendRoleLogWithListOfCommWithTemplate,null,null);
        
        
        if(toSendPrintWithLog != null && toSendPrintWithLog.size() > 0){
            // Omni_CommunicationHelper.send('PRINT', toSendEmail, emailTemplateIdWithName,
            //                               accountDetailInfo,
            //                               toSendSMSCaseWithConfig,
            //                               parentLogId, toSendFaxPrint,toSendRoleWithListOfCommWithTemplate,toSendPrint,toSendFax);
            //Replace
            Omni_CommunicationDispatcher.send('PRINT', null, null,
                                null,
                                null,
                                null, null,null,toSendPrintWithLog,null);
        }
        if(toSendFaxWithLog != null && toSendFaxWithLog.size() > 0){
            // Omni_CommunicationHelper.send('FAX', toSendEmail, emailTemplateIdWithName,
            //                               accountDetailInfo,
            //                               toSendSMSCaseWithConfig,
            //                               parentLogId, toSendFaxPrint,toSendRoleWithListOfCommWithTemplate,toSendPrint,toSendFax);
            //Replace
            Omni_CommunicationDispatcher.send('FAX', null, null,
                                null,
                                null,
                                null, null,null,null,toSendFaxWithLog);
        }
        
        //processLogs(toSendEmail, toSendSMS,notifBundleListToSend,parentLogId,toSendFaxPrint, toSendRoleWithListOfCommWithTemplate);
        //Replace processLogs
        for (Id logId : integrationLogIds) {
            //Filter out role and call processLogs
            Map<Case, List<String>> toSendEmailsPerLog = getToSendEmailsPerLog(toSendEmailWithLog, logId);
            Map<Case, Set<Communication_Configuration__c>> toSendFaxPrintPerLog = getToSendFaxPrintPerLog(toSendFaxPrintWithLog, logId);
            Map<Case, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplatePerLog = getToSendRoleWithListOfCommWithTemplatePerLog(
                toSendRoleLogWithListOfCommWithTemplate, logId);
            processLogs(toSendEmailsPerLog, null, notifBundleListToSend, logId, toSendFaxPrintPerLog, toSendRoleWithListOfCommWithTemplatePerLog);
        }
        ApplicationLogHandler.persistApplicationLogs();
    }    
    public static void processLogs(Map<Case, List<String>> toSendEmails, 
                                   Map<Case, List<String>> toSendSMS,
                                   List<Omni_ClaimNotificationBundle> notifBundleListToSend,String parentLogId,
                                   Map<Case, Set<Communication_Configuration__c>> toSendFaxPrint,
                                   Map<Case, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplate)
    {
        
        
        
        String emailMainText = 'Sending Emails to\n\n';
        String emailConfigSelected = '';
        String emailConfigMainText = 'Configurations Selected : \n\n\n:';
        String emailRoles = '';
        String templatesMain = 'Templates Selected \n\n';
        String templatesNames = '';
        
        String SMSMainText = '\n\nSending SMS to\n\n';
        String SMSConfigSelected = '';
        
        
        String smsString = 'SMS Sending to below roles::\n\n';        
        
        for (Case currCase : toSendRoleWithListOfCommWithTemplate.keySet())
        {
            if (currCase.PartyContact__c != null){
                smsString = smsString + 'Contact Id with (Role):: '+  currCase.PartyContact__c + '(' + currCase.Id + ')' + '\n\n';
            }
            smsString = smsString + 'SMS Configurations::\n\n';
            Map<Communication_Configuration__c, List<String>> commString = toSendRoleWithListOfCommWithTemplate.get(currCase);
            
            for (Communication_Configuration__c comConfig : commString.keySet())
            {
                if (comConfig != null){
                    
                    smsString = smsString + 'Config:: ' + comConfig.Id + '\n\n';
                    smsString = smsString + 'Templates ::';
                    for (String templateBody : commString.get(comConfig))
                    {	
                        templatesNames = templatesNames + templateBody + ',';
                        smsString = smsString + 'Template:: ' + templateBody + '\n\n';
                    }
                    
                }
            }
            
        }
        
        
        String emailString = '\n\nEmail Sending to below roles::\n\n';
        for (Case currCase : toSendEmails.keySet())
        {
            if (currCase.PartyContact__c != null){
                emailString = emailString + 'Contact Id with (Role) :: '+  currCase.PartyContact__c  + '(' + currCase.Id + ')' + '\n\n';
            }
            emailString = emailString + 'Email Configurations::\n\n';
            for (Omni_ClaimNotificationBundle  notifBundle : notifBundleListToSend){
                List<Communication_Configuration__c> currentConfigs = notifBundle.finalListToSendEmail.get(currCase);
                if (currentConfigs != null){
                    for (Communication_Configuration__c currentConfig : currentConfigs){
                        if ( currentConfig != null)
                        {
                            emailString = emailString + 'Config:: ' + currentConfig.Id + '\n\n';
                            emailString = emailString + 'Templates ::';
                            for (String templateBody :toSendEmails.get(currCase))
                            {
                                templatesNames = templatesNames + templateBody + ',';
                                emailString = emailString + 'Template:: ' + templateBody + '\n\n';
                            }
                        }
                        
                    }
                }
            }
            
        }
        
        String sendingSMSorFAX = '\n\n PRINT OR FAX Sending to below roles::\n\n';
        for (Case currCase : toSendFaxPrint.keySet())
        {
            if (currCase.PartyContact__c != null){
                sendingSMSorFAX = sendingSMSorFAX + 'Contact Id with (Role) :: '+  currCase.PartyContact__c  + '(' + currCase.Id + ')' + '\n\n';
            }
            sendingSMSorFAX = sendingSMSorFAX + 'Print OR FAX Configurations::\n\n';
            for (Omni_ClaimNotificationBundle  notifBundle : notifBundleListToSend){
                List<Communication_Configuration__c> currentConfigs = notifBundle.finalListToSendEmail.get(currCase);
                if (currentConfigs != null){
                    for (Communication_Configuration__c currentConfig : currentConfigs){
                        if ( currentConfig != null)
                        {
                            sendingSMSorFAX = sendingSMSorFAX + 'Config:: ' + currentConfig.Id + '\n\n';
                            
                        }
                        
                    }
                }
            }
            
        } 
        
        if (toSendEmails.size() == 0){
            emailString = '';
        }
        
        if (toSendRoleWithListOfCommWithTemplate.size() == 0){
            smsString = '';
        }
        
        if (toSendFaxPrint.size() == 0){
            sendingSMSorFAX = '';
        }

        //Replace saveAutoLog
        ApplicationLogHandler.addLogWithAppName('Auto Log', smsString + emailString + sendingSMSorFAX,parentLogId);
    }
    
    public static Map<String, Account> populateAccountDetailInfo(Case currentCase, Map<String, Account> accountInfo)
    {
        Map<String, Account> toReturn = new Map<String, Account>();
        for (String partyId : accountInfo.keySet())
        {
            Account curAccount = accountInfo.get(partyId);
            if (accountInfo.get(partyId) != null && curAccount.Id == currentCase.PartyAccount__c)
            {
                toReturn.put(curAccount.Id, curAccount);
            }
        }
        return toReturn;
    }
    
    /**
    * @description OM-925 To PopulateSFIDs with CC
    * @author      Vikas Sharma
    * @date        19/09/2019                     
    */
    public static Map<String, String> populateSFIDsWithCC(Map<String, Case> roleByPartyRoleIdRoleId, 
                                                          Map<String, Case> exposureByExposureId,
                                                          Map<String,Account> accountByPartyId)
    {
        Map<String, String> toReturn = new Map<String,String>();
        for (String roleId : roleByPartyRoleIdRoleId.keySet()) 
        {
            toReturn.put(roleByPartyRoleIdRoleId.get(roleId).Id, roleId);
        }
        
        for (String exposureId : exposureByExposureId.keySet()) 
        {
            toReturn.put(exposureByExposureId.get(exposureId).Id, exposureId);
        }
        
        for (String acId : accountByPartyId.keySet()) 
        {
            toReturn.put(accountByPartyId.get(acId).Id, acId );
        }
        
        return toReturn;
    }

    /**
    * @description Get account ids from account list
    * @author      Kejia Hu
    * @date        17/10/2019                     
    */
    private static Set<Id> getAccountIds(List<Account> accounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        return accountIds;
    }

    /**
    * @description transform the map key from Omni_CommunicationDispatcher.RoleWithLog to Case
    * @author      Kejia Hu
    * @date        22/10/2019                     
    */
    private static Map<Case, List<String>> getToSendEmailsPerLog (
                                                Map<Omni_CommunicationDispatcher.RoleWithLog, List<String>> toSendEmailWithLog
                                                ,Id logId) {
        Map<Case, List<String>> toSendEmailsPerLog = new Map<Case, List<String>>();
        for (Omni_CommunicationDispatcher.RoleWithLog oneRoleWithLog : toSendEmailWithLog.keySet()) {
            if (oneRoleWithLog.log.Id == logId) {
                toSendEmailsPerLog.put(oneRoleWithLog.role, toSendEmailWithLog.get(oneRoleWithLog));
            }
        }
        return toSendEmailsPerLog;
    }

    /**
    * @description transform the map key from Omni_CommunicationDispatcher.RoleWithLog to Case
    * @author      Kejia Hu
    * @date        22/10/2019                     
    */
    private static Map<Case, Set<Communication_Configuration__c>> getToSendFaxPrintPerLog (
                                                Map<Omni_CommunicationDispatcher.RoleWithLog, Set<Communication_Configuration__c>> toSendFaxPrintWithLog
                                                ,Id logId) {
        Map<Case, Set<Communication_Configuration__c>> toSendFaxPrintPerLog = new Map<Case, Set<Communication_Configuration__c>>();
        for (Omni_CommunicationDispatcher.RoleWithLog oneRoleWithLog : toSendFaxPrintWithLog.keySet()) {
            if (oneRoleWithLog.log.Id == logId) {
                toSendFaxPrintPerLog.put(oneRoleWithLog.role, toSendFaxPrintWithLog.get(oneRoleWithLog));
            }
        }
        return toSendFaxPrintPerLog;
    }

    /**
    * @description transform the map key from Omni_CommunicationDispatcher.RoleWithLog to Case
    * @author      Kejia Hu
    * @date        22/10/2019                     
    */
    private static Map<Case, Map<Communication_Configuration__c, List<String>>> getToSendRoleWithListOfCommWithTemplatePerLog (
            Map<Omni_CommunicationDispatcher.RoleWithLog, Map<Communication_Configuration__c, List<String>>> toSendRoleLogWithListOfCommWithTemplate
            , Id logId) {
        Map<Case, Map<Communication_Configuration__c, List<String>>> toSendRoleWithListOfCommWithTemplatePerLog = 
            new Map<Case, Map<Communication_Configuration__c, List<String>>>();
        for (Omni_CommunicationDispatcher.RoleWithLog oneRoleWithLog : toSendRoleLogWithListOfCommWithTemplate.keySet()) {
            if (oneRoleWithLog.log.Id == logId) {
                toSendRoleWithListOfCommWithTemplatePerLog.put(oneRoleWithLog.role, toSendRoleLogWithListOfCommWithTemplate.get(oneRoleWithLog));
            }
        }
        return toSendRoleWithListOfCommWithTemplatePerLog;
    }

    /**
    * @description Update logs status to Exception Retry and set related to Exception Log Id
    * @author      Kejia Hu
    * @date        22/10/2019                     
    */
    public static List<Application_Log__c> updateLogsForExceptionRetry(List<Application_Log__c> appLogs, Application_Log__c exceptionLog) {
        for (Application_Log__c appLog : appLogs) {
            appLog.Status__c = Omni_ClaimNotificationConstant.LOG_STATUS_EXCEPTION_RETRY;
            appLog.Related_To__c = exceptionLog.Id;
        }
        update appLogs;
        return appLogs;
    }

    /**
    * @description Update logs status
    * @author      Kejia Hu
    * @date        28/10/2019                     
    */
    public static List<Application_Log__c> updateCurrentLogsStatusForEventSub(Map<String, Application_Log__c> appLogsMap, Set<String> transIds) {
        List<Application_Log__c> appLogsToUpdate = new List<Application_Log__c>();
        for (String oneKey : appLogsMap.keySet()) {
            if(transIds.contains(oneKey)) {
                Application_Log__c log = appLogsMap.get(oneKey);
                log.Status__c = Omni_ClaimNotificationConstant.LOG_STATUS_DUPLICATED;
                appLogsToUpdate.add(appLogsMap.get(oneKey));
            }
        }
        update appLogsToUpdate;
        return appLogsToUpdate;
    }

    /**
    * @description Update Ids of Accounts in Account Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateAccountIdsForAllBundles(List<Omni_ClaimNotificationBundle> notifBundleListToSend, Map<String, Account> accountByPartyId) {
        for(Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            for (String key :  oneBundle.accountByPartyId.keySet()) {
                if (null == oneBundle.accountByPartyId.get(key).Id) {
                    oneBundle.accountByPartyId.put(key, accountByPartyId.get(key));
                }
            }
        }
    }

    /**
    * @description Update Ids of Contacts in Contact Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateContactIdsForAllBundles(List<Omni_ClaimNotificationBundle> notifBundleListToSend, Map<String, Contact> contactByPartyId) {
        for(Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            for (String key :  oneBundle.contactByPartyId.keySet()) {
                if (null == oneBundle.contactByPartyId.get(key).Id) {
                    oneBundle.contactByPartyId.put(key, contactByPartyId.get(key));
                }
            }
        }
    }

    /**
    * @description Update Ids of Vehicles in Vehicle Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateVehicleIdsForAllBundles(List<Omni_ClaimNotificationBundle> notifBundleListToSend, Map<String, Vehicle__c> vehicleById) {
        for(Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            for (String key :  oneBundle.vehicleById.keySet()) {
                if (null == oneBundle.vehicleById.get(key).Id) {
                    oneBundle.vehicleById.put(key, vehicleById.get(key));
                }
            }
        }
    }

    /**
    * @description Update Ids of Claims(Cases) in Claim Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateClaimIdsForAllBundles(List<Omni_ClaimNotificationBundle> notifBundleListToSend, Map<String, Case> claimByClaimId) {
        for(Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            for (String key :  oneBundle.claimByClaimId.keySet()) {
                if (null == oneBundle.claimByClaimId.get(key).Id) {
                    oneBundle.claimByClaimId.put(key, claimByClaimId.get(key));
                }
            }
        }
    }
    
    /**
    * @description Update Ids of Exposures(Cases) in Exposure Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateExposureIdsForAllBundles(List<Omni_ClaimNotificationBundle> notifBundleListToSend, Map<String, Case> exposureByExposureId) {
        for(Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            for (String key :  oneBundle.exposureByExposureId.keySet()) {
                if (null == oneBundle.exposureByExposureId.get(key).Id) {
                    oneBundle.exposureByExposureId.put(key, exposureByExposureId.get(key));
                }
            }
        }
    }
    
    /**
    * @description Update Ids of Transaction in Transaction Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateTransactionIdsForAllBundles(List<Omni_ClaimNotificationBundle> notifBundleListToSend, Map<String, Transaction__c> transactionById) {
        for(Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            for (String key :  oneBundle.transactionById.keySet()) {
                if (null == oneBundle.transactionById.get(key).Id) {
                    oneBundle.transactionById.put(key, transactionById.get(key));
                }
            }
        }
    }
    
    /**
    * @description Update Ids of Role(Cases) in Role Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateRoleIdsForAllBundles(List<Omni_ClaimNotificationBundle> notifBundleListToSend, Map<String, Case> roleByPartyRoleId) {
        for(Omni_ClaimNotificationBundle oneBundle : notifBundleListToSend) {
            for (String key :  oneBundle.roleByPartyRoleId.keySet()) {
                if (null == oneBundle.roleByPartyRoleId.get(key).Id) {
                    oneBundle.roleByPartyRoleId.put(key, roleByPartyRoleId.get(key));
                }
            }
        }
    }
}