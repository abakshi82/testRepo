@isTest
private class EmailMessageEventTriggerTest {

    @TestSetup
    static void setup(){
        EmailTemplate template = TestDataFactory.createEmailTemplate();
    }

    @isTest
    static void testPublishEmailEvent() {
        Case role = TestDataFactory.createClaimRole();
        EmailMessage__e emailEvent = new EmailMessage__e();
        emailEvent.LogId__c = null;
        emailEvent.TargetObjectId__c = role.PartyContact__c;
        emailEvent.TemplateId__c = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
        emailEvent.ReplyTo__c = 'replayto@intact.net';
        emailEvent.WhatId__c = role.id;
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(emailEvent);
        Test.stopTest();
        System.assertEquals(false
                            , [SELECT Id FROM AsyncApexJob WHERE JobType='Queueable'].isEmpty()
                            , 'Queueable job should be submitted');
    }

    @isTest
    static void testPublishBulkEmailEvents() {
        Case role = TestDataFactory.createClaimRole();
        List<EmailMessage__e> emailEvents = new List<EmailMessage__e>();
        for (Integer i=0; i<Omni_ClaimNotificationConstant.EMAIL_EVENT_BATCH_SIZE; i++) {
            EmailMessage__e emailEvent = new EmailMessage__e();
            emailEvent.LogId__c = null;
            emailEvent.TargetObjectId__c = role.PartyContact__c;
            emailEvent.TemplateId__c = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
            emailEvent.ReplyTo__c = 'replayto@intact.net';
            emailEvent.WhatId__c = role.id;
            emailEvents.add(emailEvent);
        }
        Test.startTest();
        Database.SaveResult[] srs = EventBus.publish(emailEvents);
        Test.stopTest();
        System.assertEquals(0
                            , [SELECT Id FROM Application_Log__c WHERE Application_Name__c = :Omni_ClaimNotificationConstant.APP_NAME_EMAIL_LOG].size()
                            , 'No Email Logs should be created, creation happens in future');
    }

     @isTest
    static void testSendEmailsAsyn() {
        Case role = TestDataFactory.createClaimRole();
        Integer num = 10;
        List<Omni_CommunicationDispatcher.Message> messages = new  List<Omni_CommunicationDispatcher.Message>();
        for (Integer i=0; i<num; i++) {
            Omni_CommunicationDispatcher.Message m1 = new Omni_CommunicationDispatcher.Message();
            m1.targetObjectId = role.PartyContact__c;
            m1.templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
            m1.whatId = role.id;
            m1.replyTo =  'replayto@intact.net';
            messages.add(m1);
        }
        Test.startTest();
        EmailMessageEventTriggerHandlerHelper.sendEmailMessagesBulkAsyn(messages);
        Test.stopTest();
        System.assertEquals(num
                            , [SELECT Id FROM Application_Log__c WHERE Application_Name__c = :Omni_ClaimNotificationConstant.APP_NAME_EMAIL_ASYN_LOG].size()
                            , num + ' Email Logs should be created');
    }

    @isTest
    static void testSendEmailQueueable() {
        Case role = TestDataFactory.createClaimRole();
        Integer num = 10;
        List<Omni_CommunicationDispatcher.Message> messages = new  List<Omni_CommunicationDispatcher.Message>();
        for (Integer i=0; i<num; i++) {
            Omni_CommunicationDispatcher.Message m1 = new Omni_CommunicationDispatcher.Message();
            m1.targetObjectId = role.PartyContact__c;
            m1.templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;
            m1.whatId = role.id;
            m1.replyTo =  'replayto@intact.net';
            messages.add(m1);
        }
        Test.startTest();
        System.enqueueJob(new Omni_EmailServiceAsync(JSON.serialize(messages), false, false));
        Test.stopTest();
        System.assertEquals(10
                            , [SELECT Id FROM Application_Log__c WHERE Application_Name__c = :Omni_ClaimNotificationConstant.APP_NAME_EMAIL_ASYN_LOG].size()
                            , '10 Email Logs should be created');
    }
    
    @isTest
    static void coverMethods() {
        Test.startTest();
        EmailMessageEventTriggerHandler handler = new EmailMessageEventTriggerHandler();
        handler.handleBeforeInsert(null);
        handler.handleBeforeUpdate(null,null);
        handler.handleBeforeDelete(null);
        handler.handleAfterUpdate(null,null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Omni_EmailServiceAsync.pickErrorredMessages(new List<Integer>{0}, new List<Omni_CommunicationDispatcher.Message>{new Omni_CommunicationDispatcher.Message()});
        Test.stopTest();
        System.assertEquals('EmailMessage__e', handler.getObjectAPIName(),'Object name should be EmailMessage__e');
    }

}