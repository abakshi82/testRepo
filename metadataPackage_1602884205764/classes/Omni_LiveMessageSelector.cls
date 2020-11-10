/**
 * @Description: Selector for LiveMessage sObject
 * @author:      Damian Kazior, PwC
 * @Date:        2019-09-24
 */
public without sharing class Omni_LiveMessageSelector {

    public static List<LiveMessage__c> getLiveMessagesByIds(List<String> ids){ 
        return [SELECT Case__c, Case__r.ExposureForRole__c,Case__r.PartyAccount__c, Case__r.ExposureForRole__r.ExposureType__c,
                Case__r.ClaimForRole__c,  Message_Text__c, Phone_Number__c, Status__c,
                Case__r.RecordTypeId, Case__r.ClaimForExposure__c, Case__r.ExposureType__c,
                Recipient_Name__c, Exposure_For_Role__r.ExposureType__c,     
                Claim_For_Role__c, Exposure_Type_Id__c, Communication_Configuration__r.SMS_Subject_EN__c, 
                Communication_Configuration__r.SMS_Subject_FR__c, Parent_Integration_Log__c
                FROM LiveMessage__c 
                WHERE Id IN : ids];
    } 

    public static LiveMessage__c getLiveMessageById(String id){ 
        List<String> ids = new List<String>();
        ids.add(id);
        return getLiveMessagesByIds(ids)[0];
    } 
}