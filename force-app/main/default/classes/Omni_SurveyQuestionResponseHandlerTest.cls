/**
* @description Test class for Omni_SurveyQuestionResponseHandler
* @author      Luis Merinero
* @date        10/03/2020                   
*/
@isTest
public class Omni_SurveyQuestionResponseHandlerTest {
	
	@isTest
    static void createNPSSurveyResponse(){
        SurveyQuestionResponse sqr = new SurveyQuestionResponse();
        SurveyQuestionResponse sqr2 = new SurveyQuestionResponse();
        SurveyQuestionResponse[] sqrList = new SurveyQuestionResponse[]{sqr, sqr2};
		Omni_SurveyQuestionResponseHandler.addNPSToSurveySubject(sqrList);
        
        List<Application_Log__c> logs = [SELECT id FROM Application_Log__c];
		System.assertEquals(0, logs.size());
    } 
    
}