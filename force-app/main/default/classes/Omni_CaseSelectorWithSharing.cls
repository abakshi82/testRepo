/**
* @Description: Selctor for Case sObject with sharing
* @Author:      Luis Merinero
* @Date:        17/09/2019
*/

public with sharing class Omni_CaseSelectorWithSharing {

	/**
    * @description Retrieve Roles related to Claim
    * @author      Luis Merinero
    * @date        20/12/2019                     
    */
	public static List<Case> getRolesFromClaim(String claimId, List<String> rolesRTIds, List<String> exposuresRTIds){
        List<Case> exposures = [SELECT id FROM Case WHERE ClaimForExposure__c = :claimId AND recordTypeId IN :exposuresRTIds];
       
		return [SELECT id, CaseNumber, CreatedDate, Owner.Name, ClaimForRole__r.ClaimNumber__c
                , RoleName_EN__c, Nature_of_Role__c, PartyAccount__r.Name, ExposureForRole__r.ExposureType__r.Name
                , Email_Address_for_Role__c, Language_Preference__c, ExposureForRole__c
			FROM Case 
			WHERE recordTypeId IN :rolesRTIds 
                AND ClaimForRole__c = :claimId 
                AND Email_Address_for_Role__c != null 
                AND Retired__c = FALSE
                AND (ExposureForRole__c = null OR ExposureForRole__c IN :exposures)
                ORDER BY Nature_of_Role__c ASC];  
	}

	/**
    * @description Retrieve Exposures related to Claim
    * @author      Luis Merinero 
    * @date        20/12/2019                     
    */
    public static List<Case> getExposuresFromClaim(String claimId, List<String> exposuresRTIds){
        return [SELECT id, CaseNumber, RecordType.Name, RecordType.DeveloperName, ExposureType__r.Name, 
                Exposure_Type__c, Exposure_Number_Order__c, ExposureId__c, Claimant__r.Name FROM Case 
                WHERE recordTypeId IN :exposuresRTIds AND ClaimForExposure__c = :claimId AND Retired__c = false];
    }

}