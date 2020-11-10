/**
* @description helper class holds additional methods for Claim Events trigger logic
* @author      Kejia Hu
* @date        03/12/2019                     
*/
public with sharing class Omni_ClaimEventHelper {

    /**
    * @description save EOC requests and job
    * @author      Kejia Hu
    * @date        19/05/2020                    
    */
    public static void saveEOCRequests(Map<String, Omni_SurveyRequest> surveyRequestByKey, String jobId) {
        SurveyRequest__c surveyJob = new SurveyRequest__c(
                                            JobId__c = jobId, 
                                            SurveyJobStatus__c = 'Submitted', 
                                            RecordTypeId = Schema.SObjectType.SurveyRequest__c.getRecordTypeInfosByDeveloperName().get(
                                                                'SurveyJob').getRecordTypeId());
        insert surveyJob;
        List<SurveyRequest__c> surveyRequests = new List<SurveyRequest__c>();
        for(Omni_SurveyRequest surveyRequest : surveyRequestByKey.values()) {
            surveyRequests.add(
                new SurveyRequest__c(
                        Job__c = surveyJob.Id,
                        Key__c = surveyRequest.key,
                        ParentLogId__c = surveyRequest.parentLogId,
                        PolicyIssuingGroup__c = surveyRequest.policyIssuingGroup,
                        SurveyIndicators__c = String.join(surveyRequest.surveyIndicators,';'),
                        TotalLoss__c = surveyRequest.totalLoss,
                        Type__c = surveyRequest.type,
                        RecordTypeId = Schema.SObjectType.SurveyRequest__c.getRecordTypeInfosByDeveloperName().get(
                                            'SurveyRequest').getRecordTypeId()
            ));
        }
        insert surveyRequests;
    }

    /**
    * @description add existing shadow roles to each bundle list elements
    * @author      Kejia Hu
    * @date        04/05/2020                    
    */
    public static void addShadowRolesForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, 
                                                    Map<String, List<Case>> existingShadowRolesByClaimId) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            if (existingShadowRolesByClaimId.containsKey(oneBundle.eventEntity.claimId)) {
                oneBundle.existingShadowRoles = existingShadowRolesByClaimId.get(oneBundle.eventEntity.claimId);
            }
        }
    }
    
    /**
    * @description build a string-case map, key is external Id + type, e.g. 1234-Claim
    * @author      Kejia Hu
    * @date        21/02/2020                    
    */
    public static Map<String, Case> buildCaseByCompositeKey(Map<String, Case> caseByKey, Boolean isClaim) {
        Map<String, Case> caseByNewKey = new Map<String, Case>();
        for (String key : caseByKey.keySet()) {
            if (isClaim) {
                caseByNewKey.put(key + '-Claim', caseByKey.get(key));
            } else {
                caseByNewKey.put(key + '-Exposure', caseByKey.get(key));
            }
        }
        return caseByNewKey;
    }

    /**
    * @description populate claim survey flags after sending surveys for exposures
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static Map<String, Case> populateClaimFlagForExpoSurvey(Map<String, Case> claimByClaimId, 
                                                                    Map<String, Case> exposureByExposureId, 
                                                                    Map<String, Omni_SurveyConfig> surveyConfigByKey) {
        for (String key : surveyConfigByKey.keySet()) {
            Omni_SurveyConfig oneConfig = surveyConfigByKey.get(key);
            if (oneConfig.type == 'Exposure') {
                claimByClaimId = updateClaimSurveyFlag(claimByClaimId, exposureByExposureId.get(oneConfig.key.substringBefore('-')), oneConfig);
            }
        }
        return claimByClaimId;
    }

    /**
    * @description populate claim survey flags after sending surveys for one exposure
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static Map<String, Case> updateClaimSurveyFlag(Map<String, Case> claimByClaimId, Case exposure, Omni_SurveyConfig oneConfig) {
        for (String apiFieldName : oneConfig.surveyConfigByKey.keySet()) {
            claimByClaimId = updateOneClaimSurveyFlag(claimByClaimId, exposure, oneConfig.surveyConfigByKey.get(apiFieldName));
        }
        return claimByClaimId;
    }

    /**
    * @description populate one claim survey flag after sending survey for one exposure
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static Map<String, Case> updateOneClaimSurveyFlag(Map<String, Case> claimByClaimId, Case exposure, SurveyConfig__mdt oneConfigMdt) {
        for (Case claim : claimByClaimId.values()) {
            if (claim.Id == exposure.ClaimForExposure__c && true == oneConfigMdt.SendSurveyOnce__c) {
                claim.put(oneConfigMdt.SurveyIndicatorAPIName__c, true);
            }
        }
        return claimByClaimId;
    }

    /**
    * @description generate survey request from survey config
    * @author      Kejia Hu
    * @date        12/02/2020                    
    */
    public static Map<String, Omni_SurveyRequest> getSurveyRequestFromConfig(Map<String, Omni_SurveyConfig> surveyConfigByKey) {
        Map<String, Omni_SurveyRequest> requestByKey = new Map<String, Omni_SurveyRequest>();
        for (String key : surveyConfigByKey.keySet()) {
            requestByKey.put(key, new Omni_SurveyRequest(surveyConfigByKey.get(key)));
        }
        return requestByKey;
    }

    /**
    * @description get survey config of Claim and Exposure that have survey flags changed from false to true
    * @author      Kejia Hu
    * @date        12/02/2020                    
    */
    public static Map<String, Omni_SurveyConfig> getSurveyConfigByKey(
                                    Map<String, Case> existingClaimExpoByKey, 
                                    Map<String, Omni_SurveyConfig> surveyConfigByKey,
                                    Map<String, Case> claimExpoPEByKey,
                                    String parentLogId,
                                    Boolean isClaim) {
        if (isClaim) {
           Map<String, Omni_SurveyConfig> claimSurveyConfigByKey =  getClaimSurveyConfigByKey(
                                                                        existingClaimExpoByKey, 
                                                                        claimExpoPEByKey, 
                                                                        parentLogId);
           if (!claimSurveyConfigByKey.isEmpty()) {
               surveyConfigByKey.putAll(claimSurveyConfigByKey);
           }
        } else {
            Map<String, Omni_SurveyConfig> exposureSurveyConfigByKey =  getExposureSurveyConfigByKey(
                                                                            existingClaimExpoByKey, 
                                                                            claimExpoPEByKey, 
                                                                            parentLogId);
            if (!exposureSurveyConfigByKey.isEmpty()) {
                surveyConfigByKey.putAll(exposureSurveyConfigByKey);
            }
        }
        return surveyConfigByKey;
    }

    /**
    * @description get survey config of Claim that have survey flags changed from false to true
    * @author      Kejia Hu
    * @date        12/02/2020                    
    */
    public static Map<String, Omni_SurveyConfig> getClaimSurveyConfigByKey(
                                    Map<String, Case> existingClaimExpoByKey,
                                    Map<String, Case> claimPEByKey,
                                    String parentLogId) {
        Map<String, Omni_SurveyConfig> claimSurveyConfigByKey = new Map<String, Omni_SurveyConfig>();
        for (String aKey : claimPEByKey.keySet()) {
            if (true == claimPEByKey.get(aKey).Retired__c) {
                continue;
            }
            String aClaimKey = aKey + '-Claim';
            Omni_SurveyConfig claimSurveyConfig;
            if (!existingClaimExpoByKey.isEmpty() && existingClaimExpoByKey.containsKey(aClaimKey)) {
                claimSurveyConfig = setClaimSurveyConfig(claimPEByKey.get(aKey), 
                                                         existingClaimExpoByKey.get(aClaimKey),
                                                         parentLogId);
            }
            if (existingClaimExpoByKey.isEmpty()) {
                claimSurveyConfig = setClaimSurveyConfig(claimPEByKey.get(aKey), 
                                                         null,
                                                         parentLogId);
            }
            if (null != claimSurveyConfig) {
                claimSurveyConfigByKey.put(claimSurveyConfig.key, claimSurveyConfig);
            }
        }
        return claimSurveyConfigByKey;
    }

    /**
    * @description generate a survey config when exisiting claim survey flag changes to true or new claim has flag to true
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static Omni_SurveyConfig setClaimSurveyConfig(Case claimNew, Case claimOld, String parentLogId) {
        Omni_SurveyConfig claimSurveyConfig;
        Map<String, SurveyConfig__mdt> claimSurveyConfigMdtByKey = getsurveyConfigMdtByKey('Claim');
        for (String oneField : claimSurveyConfigMdtByKey.keySet()) {
            if ((null == claimOld || false == claimOld.get(oneField)) && true == claimNew.get(oneField)) {
                claimSurveyConfig = new Omni_SurveyConfig(claimNew, null, parentLogId);
                claimSurveyConfig.surveyConfigByKey.put(oneField, claimSurveyConfigMdtByKey.get(oneField));
            }
        }
        return claimSurveyConfig;
    }

    /**
    * @description get survey config of Exposure that have survey flags changed from false to true
    * @author      Kejia Hu
    * @date        12/02/2020                    
    */
    public static Map<String, Omni_SurveyConfig> getExposureSurveyConfigByKey(
                                    Map<String, Case> existingClaimExpoByKey,
                                    Map<String, Case> claimExposurePEByKey,
                                    String parentLogId) {
        Map<String, Omni_SurveyConfig> exposureSurveyConfigByKey = new Map<String, Omni_SurveyConfig>();
        Map<String, Case> claimExposurePEById = new Map<String, Case>(claimExposurePEByKey.values());
        //key in this map is external Id + '-Exposure'
        for (String aKey : claimExposurePEByKey.keySet()) {
            if (true == claimExposurePEByKey.get(aKey).Retired__c) {
                continue;
            }
            Omni_SurveyConfig exposureSurveyConfig;
            if (!existingClaimExpoByKey.isEmpty() && existingClaimExpoByKey.containsKey(aKey)) {
                exposureSurveyConfig = setExposureSurveyConfig(claimExposurePEByKey.get(aKey), 
                                                                existingClaimExpoByKey.get(aKey),
                                                                existingClaimExpoByKey.get(
                                                                    existingClaimExpoByKey.get(aKey).ClaimForExposure__r.ClaimId__c + '-Claim'),
                                                                claimExposurePEById.get(claimExposurePEByKey.get(aKey).ClaimForExposure__c),
                                                                parentLogId);
            }
            if (existingClaimExpoByKey.isEmpty() || (!existingClaimExpoByKey.isEmpty() && !existingClaimExpoByKey.containsKey(aKey))) {
                exposureSurveyConfig = setExposureSurveyConfig(claimExposurePEByKey.get(aKey), 
                                                                null,
                                                                null,
                                                                claimExposurePEById.get(claimExposurePEByKey.get(aKey).ClaimForExposure__c),
                                                                parentLogId);
            }
            if (null != exposureSurveyConfig) {
                exposureSurveyConfigByKey.put(exposureSurveyConfig.key, exposureSurveyConfig);
            }
        }
        return exposureSurveyConfigByKey;
    }

    /**
    * @description generate a survey config when exisiting exposure survey flag changes to true or new exposure has flag to true
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static Omni_SurveyConfig setExposureSurveyConfig(Case exposureNew, Case exposureOld, Case claimOld, Case claimNew, String parentLogId) {
        Omni_SurveyConfig exposureSurveyConfig;
        Map<String, SurveyConfig__mdt> exposureSurveyConfigMdtByKey = getsurveyConfigMdtByKey('Exposure');
        for (String oneField : exposureSurveyConfigMdtByKey.keySet()) {
            if (null != exposureOld && false == exposureOld.get(oneField) && true == exposureNew.get(oneField)) {
                if(!isSentOnceAlready(exposureSurveyConfigMdtByKey.get(oneField), claimOld)) {
                    exposureSurveyConfig = new Omni_SurveyConfig(claimOld, exposureNew, parentLogId);
                    exposureSurveyConfig.surveyConfigByKey.put(oneField, exposureSurveyConfigMdtByKey.get(oneField));
                }
            } else if (null == exposureOld && true == exposureNew.get(oneField)) {
                exposureSurveyConfig = new Omni_SurveyConfig(claimNew, exposureNew, parentLogId);
                exposureSurveyConfig.surveyConfigByKey.put(oneField, exposureSurveyConfigMdtByKey.get(oneField));
            }
        }
        return exposureSurveyConfig;
    }

    /**
    * @description check if claim has sent the expusre survey
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static Boolean isSentOnceAlready(SurveyConfig__mdt config, Case ClaimOld) {
        Boolean isSentOnceAlready = false;
        if (config.SendSurveyOnce__c && ClaimOld.get(config.SurveyIndicatorAPIName__c)==true) {
            isSentOnceAlready = true;
        }
        return isSentOnceAlready;
    }

    /**
    * @description get SurveyConfig__mdt by type (claim or exposure)
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static Map<String, SurveyConfig__mdt> getSurveyConfigMdtByKey(String type){
        Map<String, SurveyConfig__mdt> surveyConfigMdtByKey = new Map<String, SurveyConfig__mdt>();
        for (SurveyConfig__mdt oneConfig : Utility.SURVEY_CONFIG_BY_FIELD.values()) {
            if (type == oneConfig.Type__c) {
                surveyConfigMdtByKey.put(oneConfig.SurveyIndicatorAPIName__c, oneConfig);
            }
        }
        return surveyConfigMdtByKey;
    }

    /**
    * @description get existing claims and exposures from claim Ids and exposure Ids
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static List<Case> getClaimExpoList(Set<String> claimIds, Set<String> exposureIds){
        String surveyFields = String.join(new List<String>(Utility.SURVEY_CONFIG_BY_FIELD.keyset()),',');
        surveyFields = (String.isBlank(surveyFields)) ? '' :  + ', ' + surveyFields;
        String claimWhereClause = ' ( ClaimId__c IN :claimIds )';
        String expoWhereClause = (!exposureIds.isEmpty()) ? ' ( ExposureId__c IN :exposureIds )' : '';
        String whereClause = getWhereClause(claimWhereClause, expoWhereClause);
        String claimTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM;
        String otherExpoTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE;
        String benefitsExpoTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS;
        String biExpoTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_BI;
        String s =  'SELECT Id, ClaimId__c, ExposureId__c, ClaimForExposure__r.ClaimId__c, TotalLoss__c, Policy_Issuing_Group__c '
                    +       surveyFields
                    + ' FROM Case'
                    + ' WHERE'
                    + whereClause
                    +        '  (RecordTypeId = :claimTypeId'
                    +        '      OR RecordTypeId = :otherExpoTypeId'
                    +        '      OR RecordTypeId = :benefitsExpoTypeId'
                    +        '      OR RecordTypeId = :biExpoTypeId)'
                    +        '  AND Retired__c = false';
        List<Case> claimExpoList = (String.isBlank(whereClause)) ? null : Database.query(s);
         return claimExpoList;
    }

    /**
    * @description build query where clause based on type (claim or exposure)
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static String getWhereClause(String claimWhere, String exposureWhere){
        String whereClause;
        if (!String.isBlank(exposureWhere)) {
            whereClause = ' (' + claimWhere
                            + ' OR ' + exposureWhere + ') AND';
        } else {
            whereClause = claimWhere + ' AND';
        }
        return whereClause;
    }

    /**
    * @description build query where clause based on type (claim or exposure)
    *               claim query should include exposure's fields
    * @author      Kejia Hu
    * @date        17/02/2020                    
    */
    public static String getWhereClause(String type){
        String whereClause = '';
        for (String oneFieldName : Utility.SURVEY_CONFIG_BY_FIELD.keySet()) {
            SurveyConfig__mdt oneConfig = Utility.SURVEY_CONFIG_BY_FIELD.get(oneFieldName);
            if (type == oneConfig.Type__c) {
                whereClause = (String.isBlank(whereClause)) 
                                ? oneFieldName + ' = false '
                                : whereClause + ' OR ' + oneFieldName  + ' = false ';
            }
        }
        return whereClause;
    }

    /**
    * @description get Claim and Exposure by external key map
    * @author      Kejia Hu
    * @date        12/02/2020                    
    */
     public static Map<String, Case> getClaimExpoByKey(List<Case> claimExpoList) {
        Map<String, Case> claimExpoByKey = new Map<String, Case>();
        for (Case oneCase : claimExpoList){
            if (null != oneCase.ClaimId__c) {
                claimExpoByKey.put(oneCase.ClaimId__c + '-Claim', oneCase);
            } else {
                claimExpoByKey.put(oneCase.ExposureId__c + '-Exposure', oneCase);
            }
        }
        return claimExpoByKey;
     }

    /**
    * @description get Claim Ids from bundleList
    * @author      Kejia Hu
    * @date        20/02/2020                    
    */
     public static Set<String> getClaimKeys(List<Omni_ClaimEventBundle> eventBundleListToSend) {
        Set<String> ids = new Set<String>();
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend){
            ids.add(oneBundle.eventEntity.claimId);
        }
        return ids;
     }

     /**
    * @description get Exposure Ids from bundleList
    * @author      Kejia Hu
    * @date        20/02/2020                    
    */
     public static Set<String> getExposureKeys(List<Omni_ClaimEventBundle> eventBundleListToSend) {
        Set<String> ids = new Set<String>();
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend){
            List<String> expoIds = oneBundle.getAllExposureIdsFromEventEntity();
            if (!expoIds.isEmpty()) {
                ids.addAll(expoIds);
            }
        }
        return ids;
     }

    /**
    * @description setup Exposure lookup values on Claims 
    * @author      Kejia Hu
    * @date        06/12/2019                    
    */
    public static Map<String, Case> setExposureLookupsOnClaims(
                                            List<Omni_ClaimEventBundle> eventBundleListToSend, 
                                            Map<String, Case> claimsToUpdate) {
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            oneBundle.setExposureLookupsForClaim();
            String claimId = oneBundle.eventEntity.claimId;
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
    public static Boolean isThreshold(Decimal expoCount, Decimal transCount, Decimal partyCount, Decimal roleCount) {
        return (expoCount > Decimal.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('MaxSizeClaimExposures'))
                || transCount > Decimal.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('MaxSizeFinancialTransactions'))
                || partyCount > Decimal.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('MaxSizeParty'))
                || roleCount > Decimal.valueOf(Omni_ClaimEventHelper.CLAIM_EVENT_CONFIG_BY_NAME.get('MaxSizePartyRoles'))
                );
    }

    /**
    * @description convert events to common type events
    * @author      Kejia Hu
    * @date        05/02/2020                    
    */
    public static List<SObject> convertToBackupEvents(List<SObject> events) {
        List<SObject> backupEvents = new List<SObject>();
        for (SObject event : events) {
            backupEvents.add(convertToCommonEvent(event, Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP));
        }
        return backupEvents;
    }

    /**
    * @description convert an event to another based on event type
    * @author      Kejia Hu
    * @date        05/02/2020                    
    */
    public static SObject convertToCommonEvent(SObject event, String eventType) {
        SObject oneObj;
        if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_1) {
            oneObj = new ClaimEvent_1__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_2) {
            oneObj = new ClaimEvent_2__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_3) {
            oneObj = new ClaimEvent_3__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_4) {
            oneObj = new ClaimEvent_4__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_5) {
            oneObj = new ClaimEvent_5__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_6) {
            oneObj = new ClaimEvent_6__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_7) {
            oneObj = new ClaimEvent_7__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_8) {
            oneObj = new ClaimEvent_8__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_9) {
            oneObj = new ClaimEvent_9__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_10) {
            oneObj = new ClaimEvent_10__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_11) {
            oneObj = new ClaimEvent_11__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_12) {
            oneObj = new ClaimEvent_12__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_13) {
            oneObj = new ClaimEvent_13__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_14) {
            oneObj = new ClaimEvent_14__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_15) {
            oneObj = new ClaimEvent_15__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_16) {
            oneObj = new ClaimEvent_16__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_17) {
            oneObj = new ClaimEvent_17__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_18) {
            oneObj = new ClaimEvent_18__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_19) {
            oneObj = new ClaimEvent_19__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_20) {
            oneObj = new ClaimEvent_20__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP) {
            oneObj = new ClaimEvent_Backup__e();
        }
        
        oneObj.put('EventId__c',event.get('EventId__c'));
        oneObj.put('TransactionID__c',event.get('TransactionID__c'));
        oneObj.put('EventName__c',event.get('EventName__c'));
        oneObj.put('EventTime__c',event.get('EventTime__c'));
        oneObj.put('EventTrackingNumber__c',event.get('EventTrackingNumber__c'));
        oneObj.put('EventVersion__c',event.get('EventVersion__c'));
        oneObj.put('ClaimId__c',event.get('ClaimId__c'));
        oneObj.put('ClaimNumber__c',event.get('ClaimNumber__c'));
        oneObj.put('DateOfLoss__c',event.get('DateOfLoss__c'));
        oneObj.put('TypeOfLoss__c',event.get('TypeOfLoss__c'));
        oneObj.put('CauseOfLoss__c',event.get('CauseOfLoss__c'));
        oneObj.put('InsuredProbableFaultPercentage__c',event.get('InsuredProbableFaultPercentage__c'));
        oneObj.put('IncidentDescription__c',event.get('IncidentDescription__c'));
        oneObj.put('LiabilityConfirmed__c',event.get('LiabilityConfirmed__c'));
        oneObj.put('PolicyNumber__c',event.get('PolicyNumber__c'));
        oneObj.put('PolicyIssuingGroup__c',event.get('PolicyIssuingGroup__c'));
        oneObj.put('AssignedUserId__c',event.get('AssignedUserId__c'));
        oneObj.put('ClaimDeductibleAmount__c',event.get('ClaimDeductibleAmount__c'));
        oneObj.put('ClaimDeductibleAmountCurrencyCode__c',event.get('ClaimDeductibleAmountCurrencyCode__c'));
        oneObj.put('IncidentAddressLine__c',event.get('IncidentAddressLine__c'));
        oneObj.put('IncidentPostalCode__c',event.get('IncidentPostalCode__c'));
        oneObj.put('IncidentProvince__c',event.get('IncidentProvince__c'));
        oneObj.put('IncidentCity__c',event.get('IncidentCity__c'));
        oneObj.put('IncidentCountry__c',event.get('IncidentCountry__c'));
        oneObj.put('AppraiserPartyId__c',event.get('AppraiserPartyId__c'));
        oneObj.put('DamageRepairPartyId__c',event.get('DamageRepairPartyId__c'));
        oneObj.put('RentalCompanyPartyId__c',event.get('RentalCompanyPartyId__c'));
        oneObj.put('LossVehicleId__c',event.get('LossVehicleId__c'));
        oneObj.put('ProvinceOfIssuanceId__c',event.get('ProvinceOfIssuanceId__c'));
        oneObj.put('InjuredParty__c',event.get('InjuredParty__c'));
        oneObj.put('BranchReferenceNumber__c',event.get('BranchReferenceNumber__c'));
        oneObj.put('ClaimNumberReplaced__c',event.get('ClaimNumberReplaced__c'));
        oneObj.put('ClaimLOBGroup__c',event.get('ClaimLOBGroup__c'));
        oneObj.put('ClaimLOB__c',event.get('ClaimLOB__c'));
        oneObj.put('UnderwritingCompanyNumber__c',event.get('UnderwritingCompanyNumber__c'));
        oneObj.put('SellingChannelDistributorNumber__c',event.get('SellingChannelDistributorNumber__c'));
        oneObj.put('SellingChannelDistributionChannel__c',event.get('SellingChannelDistributionChannel__c'));
        oneObj.put('ClaimContractEffectiveDate__c',event.get('ClaimContractEffectiveDate__c'));
        oneObj.put('ClaimContractExpiryDate__c',event.get('ClaimContractExpiryDate__c'));
        oneObj.put('AppraisalTaskStatus__c',event.get('AppraisalTaskStatus__c'));
        oneObj.put('AppraisalAppointmentDate__c',event.get('AppraisalAppointmentDate__c'));
        oneObj.put('AppraisalAppointmentTime__c',event.get('AppraisalAppointmentTime__c'));
        oneObj.put('InitialGrossEstimateCurrency__c',event.get('InitialGrossEstimateCurrency__c'));
        oneObj.put('InitialGrossEstimateAmount__c',event.get('InitialGrossEstimateAmount__c'));
        oneObj.put('RentalContractStatus__c',event.get('RentalContractStatus__c'));
        oneObj.put('RentalLimit__c',event.get('RentalLimit__c'));
        oneObj.put('InjuriesInvolved__c',event.get('InjuriesInvolved__c'));
        oneObj.put('VirtualAppraisal__c',event.get('VirtualAppraisal__c'));
        oneObj.put('ClientPIN__c',event.get('ClientPIN__c'));
        oneObj.put('IncidentDateReported__c',event.get('IncidentDateReported__c'));
        oneObj.put('TotalLoss__c',event.get('TotalLoss__c'));
        oneObj.put('AssignedVehicleId__c',event.get('AssignedVehicleId__c'));
        oneObj.put('AssignedDriverPartyId__c',event.get('AssignedDriverPartyId__c'));
        oneObj.put('InformationSensitivity__c',event.get('InformationSensitivity__c'));
        oneObj.put('IncidentReportOnly__c',event.get('IncidentReportOnly__c'));
        oneObj.put('ManuallyEnteredPolicy__c',event.get('ManuallyEnteredPolicy__c'));
        oneObj.put('ConversionOrigin__c',event.get('ConversionOrigin__c'));
        oneObj.put('ClaimStatus__c',event.get('ClaimStatus__c'));
        oneObj.put('ClaimClosedDate__c',event.get('ClaimClosedDate__c'));
        oneObj.put('AppraisalQualifier__c',event.get('AppraisalQualifier__c'));
        oneObj.put('AssignedLossDriverId__c',event.get('AssignedLossDriverId__c'));
        oneObj.put('InjuredParty__c',event.get('InjuredParty__c'));
        oneObj.put('ClaimOriginEffectiveDate__c',event.get('ClaimOriginEffectiveDate__c'));
        oneObj.put('PrimaryAdjuster__c',event.get('PrimaryAdjuster__c'));
        oneObj.put('NonCasualtyWithoutPrejudice__c',event.get('NonCasualtyWithoutPrejudice__c'));
        oneObj.put('NonCasualtyCoverageInQuestion__c',event.get('NonCasualtyCoverageInQuestion__c'));
        oneObj.put('InsuredPartyId__c',event.get('InsuredPartyId__c'));
        oneObj.put('RentalNumberOfAuthorizedDays__c',event.get('RentalNumberOfAuthorizedDays__c'));
        oneObj.put('AgentPartyId__c',event.get('AgentPartyId__c'));
        oneObj.put('ClaimExposures__c',event.get('ClaimExposures__c'));
        oneObj.put('Party__c',event.get('Party__c'));
        oneObj.put('FinancialTransactions__c',event.get('FinancialTransactions__c'));
        oneObj.put('PartyRoles__c',event.get('PartyRoles__c'));
        oneObj.put('Addresses__c',event.get('Addresses__c'));
        oneObj.put('Emails__c',event.get('Emails__c'));
        oneObj.put('Phones__c',event.get('Phones__c'));
        oneObj.put('Vehicles__c',event.get('Vehicles__c'));
        oneObj.put('DrivingLicenses__c',event.get('DrivingLicenses__c'));
        oneObj.put('ClaimExposuresCount__c',event.get('ClaimExposuresCount__c'));
        oneObj.put('FinancialTransactionsCount__c',event.get('FinancialTransactionsCount__c'));
        oneObj.put('PartyCount__c',event.get('PartyCount__c'));
        oneObj.put('PartyRolesCount__c',event.get('PartyRolesCount__c'));
        oneObj.put('LastOpenedNonBIExposureId__c',event.get('LastOpenedNonBIExposureId__c'));
        oneObj.put('ClaimOpenedDate__c',event.get('ClaimOpenedDate__c'));
        oneObj.put('ClaimReopenedDate__c',event.get('ClaimReopenedDate__c'));
        oneObj.put('TotalIndemnity__c',event.get('TotalIndemnity__c'));
        oneObj.put('TotalRecovery__c',event.get('TotalRecovery__c'));
        oneObj.put('QCLNClaimExpVehicleChapAPaid__c',event.get('QCLNClaimExpVehicleChapAPaid__c'));
        oneObj.put('QCLNClaimExpVehicleChapBPaid__c',event.get('QCLNClaimExpVehicleChapBPaid__c'));
        oneObj.put('NLPClaimSectionAPaidThirdParty__c',event.get('NLPClaimSectionAPaidThirdParty__c'));
        oneObj.put('InsuredIncDriverPartyId__c',event.get('InsuredIncDriverPartyId__c'));
        oneObj.put('InsuredIncCustodianPartyId__c',event.get('InsuredIncCustodianPartyId__c'));
        oneObj.put('QCLNExposureId__c',event.get('QCLNExposureId__c'));
        oneObj.put('NLPLExposureId__c',event.get('NLPLExposureId__c'));
        oneObj.put('PoliceReportNumber__c',event.get('PoliceReportNumber__c'));
        oneObj.put('VehicleLocationNote__c',event.get('VehicleLocationNote__c'));
        oneObj.put('SendAutoPropertySurvey__c',event.get('SendAutoPropertySurvey__c'));
        return oneObj;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_Dispatcher__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_1__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_2__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_3__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_4__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_5__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_6__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_7__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_8__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_9__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_10__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_11__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_12__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_13__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_14__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_15__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_16__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_17__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_18__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_19__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        09/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_20__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log from given event
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c generateIntegrationLog(ClaimEvent_Backup__e event, String status, String applicationName) {
        String payloadBody = JSON.serialize(event);
        String transIdForLog = event.TransactionId__c;
        String refNumForLog = event.ClaimNumber__c;
        String trackingNumForLog = event.EventTrackingNumber__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, applicationName, refNumForLog, trackingNumForLog);
        return integrationLog;
    }

    /**
    * @description generate application log
    * @author      Kejia Hu
    * @date        03/12/2019                    
    */
    public static Application_Log__c genereateIntegrationLog(String payload, String transactionId, 
                                                             String status, String applicationName,
                                                             String referenceNum, String TrackingNum) {
        Application_Log__c integrationLog = new Application_Log__c();
        integrationLog.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
        integrationLog.Application_Name__c = applicationName;
        integrationLog.Category__c = 'Integration';
        integrationLog.Transaction_Id__c = transactionId;
        integrationLog.Status__c = status;
        integrationLog.ReferenceNumber__c = referenceNum;
        integrationLog.TrackingNumber__c = TrackingNum;
        if (payload.length()>131072) {
            integrationLog.Request_Payload__c =  payload.substring(0, 131071);
            integrationLog.AdditionalPayload__c = (payload.substring(131072).length()>131072)
                ? payload.substring(131072).substring(0, 131071)
                : payload.substring(131072);
        } else {
            integrationLog.Request_Payload__c =  payload;
        }
        return integrationLog;
    }

    /**
    * @description Update logs status to Exception Retry and set related to Exception Log Id
    * @author      Kejia Hu
    * @date        22/10/2019                     
    */
    public static List<Application_Log__c> updateLogsForExceptionRetry(List<Application_Log__c> appLogs, Application_Log__c exceptionLog) {
        for (Application_Log__c appLog : appLogs) {
            appLog.Status__c = Omni_ClaimEventConstant.LOG_STATUS_EXCEPTION_RETRY;
            appLog.Related_To__c = exceptionLog.Id;
        }
        update appLogs;
        return appLogs;
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
    * @description persist contacts from Bundle list
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Contact> saveContactsFromBundleList(List<Omni_ClaimEventBundle> eventBundleListToSend,  
                                                                    Map<String, Contact> contactByPartyId) {
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            oneBundle.setContactByPartyId();
            contactByPartyId.putAll(oneBundle.contactByPartyId);
        }
        if (!contactByPartyId.isEmpty()) {
            upsert contactByPartyId.values() PartyId__c;
        }
        return contactByPartyId;
    }

    /**
    * @description OM-925 generate ContactIdByPartyId map from bundle list and contact Map
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public static Map<String, String> getContactIdByPartyId(List<Omni_ClaimEventBundle> eventBundleListToSend,
                                                            Map<String, Contact> contactByPartyId, 
                                                            Map<String, String> contactIdByPartyId) {
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            for (Contact c : oneBundle.contactByPartyId.values()) {
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
    public static Map<String, String> getContactIdByPartyId(Set<String> accoutPartyIdList, 
                                                            Map<String, String> contactIdByPartyId) {
        Map<String, Account> personAccountsByPartyId = Omni_AccountSelector.getPersonAccountsByPartyId(accoutPartyIdList);
        for (Account personAcc: personAccountsByPartyId.values()) {
            contactIdByPartyId.put(personAcc.PartyId__c, personAcc.PersonContactId);
        }
        return contactIdByPartyId;
    }

    /**
    * @description OM-925 persist vehicles from platform event
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Vehicle__c> saveVehicles(List<Omni_ClaimEventBundle> eventBundleListToSend,
                                                       Map<String, Vehicle__c> vehicleById) {
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            oneBundle.setVehicleById();
            vehicleById.putAll(oneBundle.vehicleById);
        }
        if (!vehicleById.isEmpty()) {
            upsert vehicleById.values() VehicleId__c;
        }
        return vehicleById;
    }

    /**
    * @description OM-925 persist claim from platform event
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Case> saveClaims(List<Omni_ClaimEventBundle> eventBundleListToSend,
                                                Map<String, Case> claimByClaimId) {
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            oneBundle.setClaimByClaimId();
            claimByClaimId.putAll(oneBundle.claimByClaimId);
        }
        upsert claimByClaimId.values() ClaimId__c;
        return claimByClaimId;
    }

    /**
    * @description OM-925 persist exposures(Case) from Bundle list
    * @author      Kejia Hu
    * @date        08/08/2019                    
    */
    public static Map<String, Case> saveExposuresFromBundleList(List<Omni_ClaimEventBundle> eventBundleListToSend,  
                                                                Map<String, Case> exposureByExposureId) {
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            oneBundle.setExposureByExposureId();
            exposureByExposureId.putAll(oneBundle.exposureByExposureId);
        }
        if (!exposureByExposureId.isEmpty()) {
            upsert exposureByExposureId.values() ExposureId__c;
        }
        return exposureByExposureId;
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
    * @description OM-925 persist transactions from platform event
    * @author      Kejia Hu
    * @date        05/09/2019                    
    */
    public static Map<String, Transaction__c> saveTransactionsFromBundleList(List<Omni_ClaimEventBundle> eventBundleListToSend,
                                                                             Map<String, Transaction__c> transactionById) {
            for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
                oneBundle.setTransactionById();
                transactionById.putAll(oneBundle.transactionById);
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
    public static Map<String, Case> updateExposureLastTransaction(List<Omni_ClaimEventBundle> eventBundleListToSend,
                                                                    Map<String, Case> exposureByExposureId) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            oneBundle.populateExposuresLastTransaction();
            exposureByExposureId.putAll(oneBundle.exposureByExposureId);
        }
        update exposureByExposureId.values();
        return exposureByExposureId;
    }

    /**
    * @description OM-925 persist roles(Case) from Bundle list
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public static Map<String, Case> saveRolesFromBundleList(List<Omni_ClaimEventBundle> eventBundleListToSend,
                                                            Map<String, Case> roleByPartyRoleId) {
        Map<String,Account> allAccountByPartyId = new Map<String,Account>();
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            allAccountByPartyId.putAll(oneBundle.accountByPartyId);
        }
        Set<Id> accIds = getAccountIds(allAccountByPartyId.values());
        Map<String, Contact> contactByAccountId = Omni_ContactSelector.getContactByAccountId(accIds);
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            oneBundle.setRoleByPartyRoleId(contactByAccountId);
            roleByPartyRoleId.putAll(oneBundle.roleByPartyRoleId);
        }
        if (!roleByPartyRoleId.isEmpty()) {
            upsert roleByPartyRoleId.values() RoleId__c;
        }
        return roleByPartyRoleId;
    }

    /**
    * @description Update Ids of Accounts in Account Map of Bundle in Bundle list
    * @author      Kejia Hu
    * @date        31/10/2019                     
    */
    public static void updateAccountIdsForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, Map<String, Account> accountByPartyId) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
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
    public static void updateContactIdsForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, Map<String, Contact> contactByPartyId) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
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
    public static void updateVehicleIdsForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, Map<String, Vehicle__c> vehicleById) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
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
    public static void updateClaimIdsForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, Map<String, Case> claimByClaimId) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
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
    public static void updateExposureIdsForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, Map<String, Case> exposureByExposureId) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
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
    public static void updateTransactionIdsForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, Map<String, Transaction__c> transactionById) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
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
    public static void updateRoleIdsForAllBundles(List<Omni_ClaimEventBundle> eventBundleListToSend, Map<String, Case> roleByPartyRoleId) {
        for(Omni_ClaimEventBundle oneBundle : eventBundleListToSend) {
            for (String key :  oneBundle.roleByPartyRoleId.keySet()) {
                if (null == oneBundle.roleByPartyRoleId.get(key).Id) {
                    oneBundle.roleByPartyRoleId.put(key, roleByPartyRoleId.get(key));
                }
            }
        }
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
    * @description OM-925 to populate the list of categories for every claim bundle
    * @author      Vikas Sharma
    * @date        21/08/2019                     
    */
    public static void populateCategories(List<Omni_ClaimEventBundle> eventBundleListToSend,
                                          Map<String, List<Communication_Configuration__c>> eventNameWithConfigurations,
                                          Map<String, ContactRole__c> idWithContactRolesMap,
                                          Map<String, ExposureType__c> idWithExposureTypeMap, Map<String, String> sfIdsWithCC,
                                          Map<String, ExposureType__c> typeCodeToExposures)
    {
        
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend)
        {
            if (eventNameWithConfigurations != null &&
                eventNameWithConfigurations.get(oneBundle.eventEntity.eventName) != null)
            {
                oneBundle.generateConfigurations(eventNameWithConfigurations.get(oneBundle.eventEntity.eventName),
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
    public static List<Case> checkCategoriesforCriteria(List<Omni_ClaimEventBundle> eventBundleListToSend, 
                                                        Set<String> listOfFields )
    {
        List<Case> toReturn = new List<Case>();
        
        List<String> listToVerify = new List<String>(listOfFields);
        String fields = String.join(listToVerify, ',');
        List<Id> listOfIds = new List<Id>();
        for (Omni_ClaimEventBundle oneBundle : eventBundleListToSend)
        {
            if (oneBundle.rolesByConfigurations != null){
                for (Case cs : oneBundle.rolesByConfigurations.keySet())
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
    public static void checkFinalConfigurations(List<Omni_ClaimEventBundle> eventBundleListToSend, 
                                                List<Case> cases)
    {
        
        List<Case> toDeleteShadowRoles = new List<Case>();
        
        String shadowRoleId = ''+Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE;
        for(Omni_ClaimEventBundle currentBundle : eventBundleListToSend)
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
    public static void processCommunication(List<Omni_ClaimEventBundle> notifBundleListToSend,
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
        for (Omni_ClaimEventBundle notifBundle : notifBundleListToSend)
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
                                   List<Omni_ClaimEventBundle> notifBundleListToSend,String parentLogId,
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
            for (Omni_ClaimEventBundle  notifBundle : notifBundleListToSend){
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
            for (Omni_ClaimEventBundle  notifBundle : notifBundleListToSend){
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
    * @description Log publish events results error messages
    * @author      Kejia Hu
    * @date        03/01/2020                     
    */
    public static void logErrorsFromPublishResults(List<Database.SaveResult> results, String applicationName, String parentId) { 
        String msg = processPublishResults(results);
        if (null != msg) {
            ApplicationLogHandler.addExceptionLog(applicationName, new PublishEventException(msg), parentId);
        }
    }

    /**
    * @description Process publish events results and return error messages if exist
    * @author      Kejia Hu
    * @date        03/01/2020                     
    */
    public static String processPublishResults(List<Database.SaveResult> results) {
        Boolean hasErrors = false;
        String errorMsg = 'Publishing Errors: ';
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                hasErrors = true;
                for(Database.Error err : sr.getErrors()) {
                    errorMsg += err.getStatusCode() +
                                ' - ' +
                                err.getMessage() + '\n';
                }
            }       
        }
        return hasErrors ? errorMsg : null;
    }

    /**
    * @Description: custom exception for publish event
    * @author:      Kejia Hu
    * @Date:        03/01/2020
    */
    public class PublishEventException extends Exception {}

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
    * @description retrieve claim event config by name map
    * @author      Kejia Hu
    * @date        25/11/2019                     
    */
    public static final Map<String, String> CLAIM_EVENT_CONFIG_BY_NAME {
        get {
            if(null == CLAIM_EVENT_CONFIG_BY_NAME) {
                CLAIM_EVENT_CONFIG_BY_NAME = new Map<String, String>();
                ClaimEventConfig__mdt[] elementsForMappings = [
                    SELECT DeveloperName, Value__c FROM ClaimEventConfig__mdt];
                for(ClaimEventConfig__mdt element : elementsForMappings) {
                    CLAIM_EVENT_CONFIG_BY_NAME.put(element.DeveloperName, element.Value__c);
                }
            }
            return CLAIM_EVENT_CONFIG_BY_NAME;
        }
        set;
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
}