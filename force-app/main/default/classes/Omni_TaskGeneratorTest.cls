/**
* @description Test class for Omni_TaskGenerator
* @author      Damian Kazior
* @date        29/01/2020                     
*/ 
@isTest 
public without sharing class Omni_TaskGeneratorTest {

    public static Case parentCase;
    public static List<EmailMessage> emailMessages;

    @isTest
    private static void prepareData(){
        parentCase              = TestDataFactory.createClaim();
        List<Case> tasks = [select id, ownerId from Case where id=:parentCase.Id];
        emailMessages           = TestDataFactory.createEmailMessages(TestDataFactory.TEST_SIZE_SMALL, parentCase, true);
        TestDataFactory.createPulseSurveyResult(TestDataFactory.TEST_SIZE_SMALL, parentCase, Omni_TaskGenerator.PULSE_BAD_SCORE, true);

    }

    @isTest
    private static void createTaskForEmailPositive(){ 

        prepareData(); 
        Test.startTest();
        insert emailMessages;
        Test.stopTest();

        List<Task> tasks = [select Id, whatId, ownerid from Task WHERE RecordtypeId =: Omni_TaskGenerator.RECORD_TYPE_ID_EMAIL];
        System.assertEquals(TestDataFactory.TEST_SIZE_SMALL, tasks.size(), 'There must be one task per each emailmessage');
        List<Application_Log__c> appLogs = [SELECT Id from Application_Log__c];
        System.assertEquals(0, appLogs.size(), 'No exception should have been thrown');
    }

    @isTest
    private static void createTaskForSurveyPositive(){

        prepareData(); 
        List<Pulse_Survey_Result__c> pulseSurveyResults = [SELECT Id, Score__c, OwnerId FROM Pulse_Survey_Result__c WHERE Case__c =:parentCase.Id];
        List<Task> tasks = [select Id, whatId, ownerid from Task WHERE RecordtypeId =: Omni_TaskGenerator.RECORD_TYPE_ID_SURVEY];
        
        System.assertEquals(pulseSurveyResults.size(), tasks.size(), 'There must be one task per each survey');
        List<Application_Log__c> appLogs = [SELECT Id , Description__c,Exception_Stack_Trace__c from Application_Log__c];
        System.assertEquals(0, appLogs.size(), 'No exception should have been thrown');
    }

    @isTest
    private static void createTaskForMatchedDEAEmailTest(){

        prepareData(); 
        Omni_TaskGenerator.createTaskForMatchedDEAEmail(parentCase, emailMessages);
    }

    @isTest
    private static void createTaskForDEAEmailTest(){

        prepareData(); 
        Omni_EmailProcessingEntity entity = new Omni_EmailProcessingEntity('test');
        entity.masterCase = parentCase;
        List<Omni_EmailProcessingEntity> emailMessageEntites = new List<Omni_EmailProcessingEntity>();
        emailMessageEntites.add(entity);
        Omni_TaskGenerator.createTaskForMatchedDEAEmail(emailMessageEntites);

    }

}