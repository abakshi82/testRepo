/**
* @Description: Selctor for Aplication Log sObject
* @Author:      Damian Kazior, PwC
* @Date:        30/09/2019
*/
public with sharing class Omni_ApplicationLogSelector {

    /**
    * @Description: Selctor for Aplication Log sObject
    * @Author:      Damian Kazior, PwC
    * @Date:        30/09/2019
    */
   public static Application_Log__c getApplicationLogById(String Id) {
       return [SELECT Transaction_Id__c FROM Application_Log__c WHERE Id =:Id];
    }

}