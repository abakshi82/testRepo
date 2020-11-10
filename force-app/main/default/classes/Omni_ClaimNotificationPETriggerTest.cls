@isTest
private class Omni_ClaimNotificationPETriggerTest {

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
        List<Communication_Configuration__c> emailConfigs = TestDataFactory.createCommunicationConfiguration(1, true, 'Email', 'CommunicationContact');

		List<Communication_Configuration__c> smsConfigs =  TestDataFactory.createCommunicationConfiguration(1, true, 'SMS', 'CommunicationContact');
        
        String emailTemplateName = emailTemplates[0].DeveloperName;	
        
        TestDataFactory.createCommunicationConfiguration(1, true, 'Fax', 'CommunicationContact');
        TestDataFactory.createCommunicationConfiguration(1, true, 'Print', 'CommunicationContact');
        
        
		TestDataFactory.createSMSTemplate(smsConfigs,'');
        TestDataFactory.createSMSTemplate(emailConfigs,emailTemplateName);
    }

    @isTest
    static void publishEventHappyPath(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Claim_Notification__e claimNotifPE = TestDataFactory.createCalimNotificationPayload('shdsd-hjsx-001');
        
        
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(claimNotifPE);
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimNotificationConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishEventsSameClaimId(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        List<Claim_Notification__e> events = new List<Claim_Notification__e>();
        events.add(TestDataFactory.createCalimNotificationPayload('shdsd-hjsx-001'));
        events.add(TestDataFactory.createCalimNotificationPayload('shdsd-hjsx-002'));
        
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult[] srs = EventBus.publish(events);
        Test.stopTest();
                
        System.assertEquals(true, srs[0].isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimNotificationConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishSubEvent(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Claim_Notification__e claimNotifPE = TestDataFactory.createCalimNotificationPayload('shdsd-hjsx-001');
        
        System.assertEquals(true, [SELECT Id FROM Case].isEmpty(), 'No Case should exist');
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(Omni_ClaimNotificationPETriggerHelper.convertToSubEvent(claimNotifPE));
        Test.stopTest();
                
        System.assertEquals(true, sr.isSuccess(),'Event pusblish should be success');
        
        List<Case> claim = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimNotificationConstant.CLAIM_RECORD_TYPE_NAME).getRecordTypeId()];
        System.assertEquals(1, claim.size(),'One claim should be created after PE');
        List<Case> otherExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_OTH_EXPOSURE];
        System.assertEquals(1, otherExposure.size(),'One Other Exposure should be created after PE');
        System.assertEquals(true, null != otherExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> benefitsExposure = [SELECT Id, ExposureType__c FROM Case WHERE RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimNotificationConstant.EXPOSURE_TYPE_BENEFITS).getRecordTypeId()];
        System.assertEquals(1, benefitsExposure.size(),'One Benefits Exposure should be created after PE');
        System.assertEquals(true, null != benefitsExposure[0].ExposureType__c, 'ExposureType should be populated');
        List<Case> roles = [SELECT Id FROM Case WHERE 
                                RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPO_ROLE 
                                OR 
                                RecordTypeId = :Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM_ROLE];
        System.assertEquals(3, roles.size(),'Two roles should be created after PE');
    }

    @isTest
    static void publishThreshold(){
        TestDataFactory.createrUserWithProfile('System Administrator');
        Claim_Notification__e claimNotifPE = TestDataFactory.createCalimNotificationPayload('shdsd-hjsx-001');
        claimNotifPE.PartyCount__c = 60;
        Test.startTest();
        Database.SaveResult[] srs = EventBus.publish(new List<Claim_Notification__e>{claimNotifPE});
        Test.stopTest();   
        System.assertEquals(true, srs[0].isSuccess(),'Event pusblish should be success');
    }

    @isTest
    static void coverMethods() {
        Test.startTest();
        Omni_ClaimNotificationPETriggerHandler handler = new Omni_ClaimNotificationPETriggerHandler();
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('Claim_Notification__e', handler.getObjectAPIName(),'Object name should be Claim_Notification__e');
    }

     @isTest
    static void coverMethodsForSubEvent() {
        Test.startTest();
        Omni_ClaimNotificationSubTriggerHandler handler = new Omni_ClaimNotificationSubTriggerHandler();
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('Claim_Notification_Sub__e', handler.getObjectAPIName(),'Object name should be Claim_Notification_Sub__e');
    }
}