/**
* @description Test class for Omni_Aura_SurveyFormController
* @author      Damian Kazior
* @date        29/01/2020                     
*/ 
@isTest
public class Omni_Aura_SurveyFormControllerTest {

    public static Case role;
    //public static Case claim;
    public static EmailMessage email;
    public static String testSurveyScore;
    public static final String SURVEY_IDENTIFIER = TestDataFactory.generateRandomNumber(10);

    @isTest
    private static void prepareData(){
         role                               = TestDataFactory.createClaimRole();
         email                              = TestDataFactory.createEmailMessages(1, role, false)[0]; 
         email.Pulse_Survey_Identifier__c   = SURVEY_IDENTIFIER;
         insert email;
         list<SelectOption>  
         surveyScoreOptions                 = getSurveyScoringOptions();
         testSurveyScore                    = surveyScoreOptions[0].getValue();
    }

    @isTest
    private static void updateSurveyResultsPositive(){

        String testComment;
        prepareData();
        Omni_AuraResponse auraResponse = Omni_Aura_SurveyFormController.validateSurvey(role.ClaimForRole__c, null, SURVEY_IDENTIFIER, testSurveyScore);
        Pulse_Survey_Result__c createdSurvey = [SELECT Id, Score__c, Responded__c FROM Pulse_Survey_Result__c][0]; 
        
        Omni_Aura_SurveyFormController.updateSurveyResults(createdSurvey.Id, testComment);
        createdSurvey = [SELECT Id, Score__c, Comments__c FROM Pulse_Survey_Result__c WHERE Id =: createdSurvey.Id][0]; 
        System.assertEquals(testComment, createdSurvey.Comments__c, 'Survey should have its comment'); 

        List<Application_Log__c> appLogs = [SELECT Id, Application_Name__c, Category__c
                                            FROM Application_Log__c
                                            WHERE Category__c = 'Exception'];
        System.assertEquals(0, appLogs.size(), 'Exception should not be created');
    }

    @isTest
    private static void updateSurveyResultsNegative(){

        Omni_Aura_SurveyFormController.updateSurveyResults(null, 'hi');
        
        List<Application_Log__c> appLogs = [SELECT Id, Application_Name__c, Category__c
                                            FROM Application_Log__c
                                            WHERE Category__c = 'Exception'];

        System.assertEquals(1, appLogs.size(), 'Exception must be created');
    }

    @isTest
    private static void validateSurveyPositive(){

        prepareData();
        Omni_AuraResponse auraResponse = Omni_Aura_SurveyFormController.validateSurvey(role.ClaimForRole__c, null, SURVEY_IDENTIFIER, testSurveyScore);
        System.assertEquals(true, auraResponse.success, 'Validation should pass'); 

        List<Pulse_Survey_Result__c> surveyResutls = [SELECT Id FROM Pulse_Survey_Result__c
                                                      WHERE Score__c =: testSurveyScore
                                                      AND Case__c =: role.ClaimForRole__c];
        System.assertEquals(1, surveyResutls.size(), 'One survey should be created');

        List<Application_Log__c> appLogs = [SELECT Id, Application_Name__c, Category__c
                                             FROM Application_Log__c
                                             WHERE Category__c = 'Exception'];
        System.assertEquals(0, appLogs.size(), 'Exception should not be created');
    }

    @isTest
    private static void createSurveyResultsNegative(){
        Omni_AuraResponse auraResponse = Omni_Aura_SurveyFormController.createSurveyResults(null, null, null);     
        System.assertEquals(auraResponse.success, false, 'invalid parameters should return error');
    }

    @isTest
    private static void validateSurveyNegative(){ 
        Omni_AuraResponse auraResponse = Omni_Aura_SurveyFormController.validateSurvey(null, null, null, null);    
        System.assertEquals(auraResponse.success, false, 'invalid parameters should return error');
    }


    private static List<SelectOption> getSurveyScoringOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
                
        Schema.DescribeFieldResult fieldResult =
        Pulse_Survey_Result__c.Score__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }



}