public with sharing class Omni_Aura_EmailReplyController {

    @AuraEnabled 
    public static Omni_AuraResponse getemailMessageDetails(String messageId) { 
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        
            EmailMessage emailMsg = [SELECT Id, FromAddress, FromName, CcAddress, ToAddress, Incoming, MessageDate, HtmlBody, textBody, Parent.RecordType.DeveloperName, Parent.Id, Parent.ClaimNumber__c,
                                    Parent.Claimant__r.Name, Parent.CaseNumber,  Parent.ExposureType__r.Name, Parent.ExposureId__c,
                                    Parent.ClaimForExposure__r.Id, Parent.ClaimForExposure__r.ClaimNumber__c, Status, Subject 
                                    FROM EmailMessage WHERE Id=:messageId][0];
            auraResponse.data = emailMsg;  
        
        return auraResponse;
    }

    @auraEnabled
    public static String getUserId(){
        return UserInfo.getUserId();
    }
    

}