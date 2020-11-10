/**
* @description Test class for Omni_SMSService
* @author      Damian Kazior
* @date        29/08/2019                     
*/ 
@isTest
private class Omni_SMSServiceTest {
   static FINAL Integer NUMBER_OF_CLAIMS_PER_PAYLOAD         = TestDataFactory.TEST_SIZE_LARGE;
   static FINAL Integer NUMBER_OF_COMMUNICATIONS_PER_PAYLOAD = NUMBER_OF_CLAIMS_PER_PAYLOAD*NUMBER_OF_CLAIMS_PER_PAYLOAD;

   static Map<Omni_CommunicationDispatcher.RoleWithLog, Map<Communication_Configuration__c, List<String>>> toSendSMSCaseWithConfig;
   static Map<String, Account> accountIdToAccount;

   private static void prepareSmsData(Boolean isCreateExposuresForRoles){

      List<Communication_Configuration__c> communicationConfigs = TestDataFactory.createCommunicationConfiguration(
                                                                  NUMBER_OF_CLAIMS_PER_PAYLOAD,
                                                                  false,
                                                                  'SMS',
                                                                  'CommunicationContact');
      Map<Communication_Configuration__c, List<String>> configToTemplates = new Map<Communication_Configuration__c, List<String>>();
      
      for(Communication_Configuration__c communicationConfig : communicationConfigs){
         configToTemplates.put(communicationConfig, TestDataFactory.generateSMSTemplates(NUMBER_OF_CLAIMS_PER_PAYLOAD));
      }

      List<Account> accounts = TestDataFactory.createPersonAccounts(NUMBER_OF_CLAIMS_PER_PAYLOAD, true);

      List<Case> roleCases = TestDataFactory.createCases(NUMBER_OF_CLAIMS_PER_PAYLOAD, false);
      for(Integer k =0; k<roleCases.size(); k++){
          roleCases[k].PartyAccount__c = accounts[k].Id;  
      }
      insert roleCases;

      List<Case> roles = TestDataFactory.createCases(NUMBER_OF_CLAIMS_PER_PAYLOAD, false);
      List<Application_Log__c> appLogs = TestDataFactory.createApplicationLogs(NUMBER_OF_CLAIMS_PER_PAYLOAD, true);
      List<Case> otherExposures;
      if(isCreateExposuresForRoles){
         otherExposures = TestDataFactory.createOtherExposures(NUMBER_OF_CLAIMS_PER_PAYLOAD);
      }
      for(Integer k =0; k<roles.size(); k++){
          roles[k].PartyAccount__c = accounts[k].Id;  
          roles[k].ClaimForRole__c = roleCases[k].Id;
          if(isCreateExposuresForRoles){
            roles[k].ExposureForRole__c = otherExposures[k].Id;
          }
      }
      insert roles;

      toSendSMSCaseWithConfig = new Map<Omni_CommunicationDispatcher.RoleWithLog, Map<Communication_Configuration__c, List<String>>>();
      for(Integer k = 0; k<roles.size(); k++){
         Omni_CommunicationDispatcher.RoleWithLog roleWithLog = new Omni_CommunicationDispatcher.RoleWithLog(appLogs[k], roles[k]);
         toSendSMSCaseWithConfig.put(roleWithLog, configToTemplates);  
      }

      accountIdToAccount = new Map<String, Account>(accounts);
   } 

   @isTest
   private static void sendSMSPositiveWithExposures(){ 
      prepareSmsData(true);  

      Omni_SMSService smsService = new Omni_SMSService();
      smsService.sendSMS(accountIdToAccount, toSendSMSCaseWithConfig);
      System.assertEquals(NUMBER_OF_COMMUNICATIONS_PER_PAYLOAD, smsService.smsDataWrappers.size(), 'There should be 100 LiveMessages created');
     
   }  
}