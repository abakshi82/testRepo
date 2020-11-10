public with sharing class Omni_Aura_MessagingSessionController {

    @AuraEnabled 
    public static Omni_AuraResponse updateSession(String sessionId, String claimId) {
        return Omni_Aura_MessagingSessionCtrlNoShare.updateSession(sessionId, claimId);
    }

    @AuraEnabled 
    public static Omni_AuraResponse fetchCaseForSession(String sessionId) {
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        MessagingSession msgSession = [SELECT CaseId FROM MessagingSession WHERE Id =:sessionId];
        if(msgSession.CaseId != null){
            Case associatedCase = [SELECT Id, RecordTypeId, RecordType.Name, ClaimNumber__c, ExposureType__r.Name, CaseNumber FROM Case WHERE Id=:msgSession.CaseId];

            if(associatedCase.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM){
                auraResponse.dataList.add(new Omni_Aura_CustomSearchController.CaseSearchResultWrapper(  
                    associatedCase.Id, 
                    System.Label.Omni_Claim + ': ' + associatedCase.ClaimNumber__c));
         
            }else if(associatedCase.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPOSURE_BENEFITS ||
                      associatedCase.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPOSURE_BODILY_INJURY ||
                      associatedCase.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_OTH_EXPOSURE) { 
                auraResponse.dataList.add(new Omni_Aura_CustomSearchController.CaseSearchResultWrapper(
                    associatedCase.Id, 
                    associatedCase.RecordType.Name + ' (' + associatedCase.ExposureType__r.Name + '): '+associatedCase.CaseNumber)
                ); 
            }else{
                auraResponse.success = false;
            }
        }
        
        return auraResponse;
    }

    @AuraEnabled 
    public static Omni_AuraResponse fetchCasesForPhoneNumber(String sessionId) { 
     
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        MessagingSession msgSession = [select id, messagingEndUser.MessagingPlatformKey From MessagingSession WHERE Id=:sessionId][0];
        String phoneNo = msgSession.messagingEndUser.MessagingPlatformKey; 

        if(phoneNo.startswith('+1')){
            phoneNo = phoneNo.substring(2);
        }
      
        List<Case> claims = new List<Case>();
        List<Case> exposures = new List<Case>();

        List<Omni_Aura_CustomSearchController.CaseSearchResultWrapper> results = new List<Omni_Aura_CustomSearchController.CaseSearchResultWrapper>();
        //TODO use SOSL maybe and some fuzzy seach?
        List<Case> roles = [select Id, RecordTypeId, OwnerId, ClaimForRole__c, ClaimForRole__r.ClaimNumber__c, ClaimForExposure__r.OwnerId, ExposureForRole__c, ExposureForRole__r.RecordType.Name, ExposureForRole__r.OwnerId, ExposureForRole__r.UserRecordAccess.HasReadAccess,
        ExposureForRole__r.ExposureType__r.Name, ExposureForRole__r.CaseNumber  from case where PartyAccount__c IN (Select Id from account where phone =:phoneNo) ORDER BY RecordType.Name];

        Set<Id> caseIds = new Set<Id>();
        for(Case cas : roles){
            if(cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM_ROLE &&
               !caseIds.contains(cas.ClaimForRole__c)){
                results.add(new Omni_Aura_CustomSearchController.CaseSearchResultWrapper(  
                    cas.ClaimForRole__c, 
                    System.Label.Omni_Claim + ': ' + cas.ClaimForRole__r.ClaimNumber__c));
                caseIds.add(cas.ClaimForRole__c);
            }else if((cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPO_ROLE ||
                        cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_SHADOW_ROLE ||
                        cas.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_ADHOC_ROLE) &&
                        cas.ExposureForRole__r.UserRecordAccess.HasReadAccess && !caseIds.contains(cas.ExposureForRole__c)) { 
                results.add(new Omni_Aura_CustomSearchController.CaseSearchResultWrapper(
                    cas.ExposureForRole__c, 
                    cas.ExposureForRole__r.RecordType.Name + ' (' + cas.ExposureForRole__r.ExposureType__r.Name + '): '+cas.ExposureForRole__r.CaseNumber)
                ); 
                caseIds.add(cas.ExposureForRole__c);
            }else{
                //email for non-role. assign claim or exposure
            } 
            
        }
        auraResponse.dataList.addAll(results);
        return auraResponse;
    }

    public class ClaimExposure {
        @AuraEnabled  public List<Case> claims;
        @AuraEnabled  public List<Case> exposures;

        public ClaimExposure(){
            this.claims = new List<Case>(); 
            this.exposures = new List<Case>();
        }
    }

}