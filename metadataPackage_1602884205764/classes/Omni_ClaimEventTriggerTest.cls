@isTest
private class Omni_ClaimEventTriggerTest {

    @testSetup 
    
    static void setup() {
        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
         System.runAs ( new User(Id = UserInfo.getUserId()) ) {
              Template_Management_Config__mdt templateConfiguration = Utility.getTemplateManagementConfigurations();
         emailTemplates =  TestDataFactory.generateEmailTemplates(1
                                                                  , templateConfiguration.Cloned_Emails_Folder_Name__c
                                                                  , true);
         }
        
        TestDataFactory.createExposureTypes();
        TestDataFactory.createExposureStatus();
        TestDataFactory.createContactTypeRole();
        TestDataFactory.createPolicyIssuingGroup();
        List<Communication_Configuration__c> emailConfigs = TestDataFactory.createCommunicationConfiguration(1, true, 'Email', 'CommunicationContact');

		List<Communication_Configuration__c> smsConfigs =  TestDataFactory.createCommunicationConfiguration(1, true, 'SMS', 'CommunicationContact');
        
        String emailTemplateName = emailTemplates[0].DeveloperName;	
        
        TestDataFactory.createCommunicationConfiguration(1, true, 'Fax', 'CommunicationContact');
        TestDataFactory.createCommunicationConfiguration(1, true, 'Print', 'CommunicationContact');
        
        
		TestDataFactory.createSMSTemplate(smsConfigs,'');
        TestDataFactory.createSMSTemplate(emailConfigs,emailTemplateName);
    }

    @isTest
    static void publishClaimEvent1(){
        TestDataFactory.createrUserWithProfile('System Administrator');   
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_1));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c, SendAccidentBenefitsSurvey__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        if (Utility.SURVEY_SWITCH_BY_KEY.get('SurveyMapping').IsEnabled__c) {
            System.assertEquals(true, claim[0].SendAccidentBenefitsSurvey__c,'Survey flag should be set to true');
        }
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

     @isTest
    static void publishClaimEvent2(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_2));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

     @isTest
    static void publishClaimEvent3(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_3));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

     @isTest
    static void publishClaimEvent4(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_4));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

     @isTest
    static void publishClaimEvent5(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_5));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

     @isTest
    static void publishClaimEvent6(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_6));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

     @isTest
    static void publishClaimEvent7(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_7));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent8(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_8));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent9(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_9));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent10(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_10));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent11(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_11));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent12(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_12));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent13(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_13));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent14(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_14));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent15(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_15));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent16(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_16));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent17(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_17));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent18(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_18));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent19(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_19));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishClaimEvent20(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(TestDataFactory.createCommonClaimEventPayload(
                                                    'shdsd-hjsx-001', '1', Omni_ClaimEventConstant.NAME_CLAIM_EVENT_20));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void coverMethods() {
        Test.startTest();
        Omni_ClaimEventTriggerHandler handler = new Omni_ClaimEventTriggerHandler();
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('ClaimEvent__e', handler.getObjectAPIName(),'Object name should be ClaimEvent__e');
    }
}