/**
* @description Selctor for EmailMessage sObject
* @author      Kejia Hu
* @date        28/06/2019                     
*/
public class Omni_EmailMessageSelector {

    /**
    * @description OM-34 retrieve EmailMessage record from Id
    * @author      Kejia Hu
    * @date        28/06/2019                     
    */
    public static EmailMessage getEmailMessageFromId(Id emailId){
        return [SELECT Id, HtmlBody FROM EmailMessage WHERE Id = :emailId];
    }

    /**
    * @description get email messages by set of ids
    * @author      Damian Kazior
    * @date        28/01/2020                      
    */
    public static List<EmailMessage> getEmailMessagesByIds(Set<Id> emailMessageIds){
        return [SELECT Id, parentId, Incoming FROM EmailMessage WHERE Id in:emailMessageIds];
    }
    
	/**
    * @description Get MetajunctionId from Email Message Record
    * @author      Luis Merinero
    * @date        03/02/2020                      
    */
    public static EmailMessage getMetaJunctionId(String emailMessageId){
        return [SELECT Id, Meta_Junction__c FROM EmailMessage WHERE Id = :emailMessageId];
    }

    /**
    * @description 
    * @author      Damian Kazior
    * @date        03/02/2020                      
    */
    public static List<EmailMessage> getEmailsByClaimAndTimestamp(String claimId, String timeStamp){
        return [SELECT Id FROM EmailMessage WHERE Claim__c = :claimId AND Pulse_Survey_Identifier__c =:timeStamp];
    }
    
}