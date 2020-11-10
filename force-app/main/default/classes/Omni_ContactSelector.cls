/**
   * @Description: Selctor for Account sObject
   * @Author:      Kejia Hu
   * @Date:        13/08/2019
*/
public class Omni_ContactSelector {

    /**
    * @description retrieve Contact records from Account Id, one contact per account for auto notification
    * @author      Kejia Hu
    * @date        13/08/2019                     
    */
   public static Map<String, Contact> getContactByAccountId(Set<Id> acctIds) {
         Map<String, Contact> contactByAccountId = new Map<String, Contact>();
         for(Contact c : [SELECT Id, AccountId, Email, MailingStreet, MailingCity, FirstName, LastName,
                              MailingPostalCode
                          FROM Contact 
                          WHERE AccountId IN :acctIds]) {
            contactByAccountId.put(c.AccountId, c);
         }
         return contactByAccountId;
   }

    /**
   * @description Retrieve Party Contact details informations by Ids
   * @date        16/10/2019                     
   */
   public static Map<Id, Contact> getPartyContactDetailsById(Set<Id> contactIds) {
      Map<Id, Contact> contactById = new Map<Id, Contact>([
                                    SELECT LastName, FirstName, MailingPostalCode, Email, MailingStreet, MailingCity
                                    FROM Contact
                                    WHERE Id IN:contactIds]);
      return contactById;
   }
}