/**
* @Description: Selctor for Task PulseSurveyResult__c
* @Author:      Damian Kazior
* @Date:        05/01/2020
*/
public without sharing class Omni_PulseSurveyResultSelector {

    /**
    * @Description: Selctor for User sObject
    * @Author:      Damian Kazior
    * @Date:        05/01/2020
    */
    public static List<Pulse_Survey_Result__c> getSurveyResultsByTimestampAndCaseId(String timestamp, String caseId) {
        return  [SELECT ID, Case__c, Responded__c
                FROM Pulse_Survey_Result__c 
                WHERE Case__c =:caseId AND Survey_URL_DateTime__c=:timestamp];            
    }

}