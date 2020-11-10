global with sharing class Omni_PayloadReplayerBatch implements Database.Batchable<sObject>{

   global final String Query;


   global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }


   global void execute(Database.BatchableContext BC, List<Application_Log__c> scope){
       System.debug(scope);
    }

   global void finish(Database.BatchableContext BC){
   }

}