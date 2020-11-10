/**
   * @Description: Selctor for Account sObject
   * @Author:      Kejia Hu
   * @Date:        05/08/2019
*/
public with sharing class Omni_AccountSelector {

   /**
    * @description retrieve Person Account records Map from Id
    * @author      Kejia Hu
    * @date        05/08/2019                     
    */
   public static Map<String, Account> getPersonAccountsByPartyId(Set<String> acctPartyIds) {
      Map<String, Account> personAccountsByPartyId = new Map<String, Account>();
      List<Account> accts = [SELECT Id, PartyId__c, PersonContactId 
                        FROM Account 
                        WHERE PartyId__c IN :acctPartyIds
                        AND RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimNotificationConstant.PERSON_ACCT_RECORD_TYPE_NAME).getRecordTypeId()
                        FOR UPDATE];
      if (!accts.isEmpty()) {
         for(Account acct : accts) {
            personAccountsByPartyId.put(acct.PartyId__c, acct);
         }
      }
      return personAccountsByPartyId;
    }

   /**
   * @description Retrieve Party Account details informations by Ids
   * @date        16/10/2019                     
   */
   public static Map<Id, Account> getPartyAccountDetailsById(Set<Id> accIds) {
      Map<Id, Account> accounts = new Map<Id, Account>([
                                    SELECT Name, Phone, Fax, Language__c, FirstName
                                    , State__r.L_FR_CA__c, State__r.L_EN_CA__c
                                    FROM Account
                                    WHERE Id IN:accIds]);
      return accounts;
   }  
}