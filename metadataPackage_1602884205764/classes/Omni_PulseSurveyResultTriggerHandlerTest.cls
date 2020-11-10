/**
* @Description: Test class for Omni_PulseSurveyResultTriggerHandler
* @Author:      Damian Kazior, PwC
* @Date:        02/03/2020
*/
@isTest
public with sharing class Omni_PulseSurveyResultTriggerHandlerTest {

    @isTest
    static void coverageMethods(){
        Test.startTest();
        Omni_PulseSurveyResultTriggerHandler handler = new Omni_PulseSurveyResultTriggerHandler();
        handler.handleBeforeDelete(null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        handler.handleBeforeUpdate(null, null);
        handler.handleAfterUpdate(null, null);
        handler.handleBeforeInsert(null);
        Test.stopTest();
        System.assertEquals('Pulse_Survey_Result__c', handler.getObjectAPIName(),'Object name should be Pulse_Survey_Result__c');
    }

}