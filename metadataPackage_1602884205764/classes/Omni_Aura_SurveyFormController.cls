/**
* @Description: Aura controller for Omni_SurveyForm component
* @Author:      Damian Kazior, PwC
* @Date:        12/01/2020
*/
public without sharing class Omni_Aura_SurveyFormController {
    
    /**
    * @Description: Update pending survey result with score and optional comment
    * @Author:      Damian Kazior, PwC
    * @Date:        12/01/2020
    */
    @AuraEnabled  
    public static Omni_AuraResponse updateSurveyResults(String surveyId, String comment) {
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        try{  
            Pulse_Survey_Result__c pulseSurvey = new Pulse_Survey_Result__c();
            pulseSurvey.Id = surveyId;
            pulseSurvey.Comments__c = comment;
            update pulseSurvey;
            auraResponse.data = pulseSurvey;
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_Aura_SurveyFormController', e , null); 
            auraResponse.success = false;
            auraResponse.message = e.getMessage();
        }
        return auraResponse; 
    }

    /**
    * @Description: Update pending survey result with score and optional comment
    * @Author:      Damian Kazior, PwC
    * @Date:        12/01/2020
    */ 
    @testVisible
    private static Omni_AuraResponse createSurveyResults(String faceId, String caseId, String timestamp) {
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        try{  
            Pulse_Survey_Result__c pulseSurvey = new Pulse_Survey_Result__c();
            Case caseDetails = Omni_CaseSelector.getCasesByIds(new Set<Id>{caseId}).values()[0]; 
            pulseSurvey.Responded__c = true;
            pulseSurvey.Name         = Label.Omni_Task_PulseSurveyResult; 
            pulseSurvey.Score__c     = faceId;
            pulseSurvey.Case__c      = caseId;
            pulseSurvey.Survey_URL_DateTime__c = timestamp;
            if(caseDetails.ownerId.getsobjecttype() == User.sobjecttype && caseDetails.owner.isActive){
                pulseSurvey.ownerId = caseDetails.ownerId;
            }
            insert pulseSurvey;  
            auraResponse.data = pulseSurvey;
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_Aura_SurveyFormController', e , null); 
            auraResponse.success = false;
            auraResponse.message = e.getMessage();
        }
        return auraResponse; 
    }

    /**
    * @Description: survey can be submitted only once. Verify if there is already a survey response for given combination of timestamp and case id
    * @Author:      Damian Kazior, PwC
    * @Date:        12/01/2020
    */
    @AuraEnabled  
    public static Omni_AuraResponse validateSurvey(String claimId, String exposureId, String timeStamp, String faceId) {
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        try{  
            List<EmailMessage> emailMessages = Omni_EmailMessageSelector.getEmailsByClaimAndTimestamp(claimId, timeStamp);
            if(emailMessages.size() != 0){
                String caseId;
                if(exposureId == null){
                    caseId = claimId;
                }else if(exposureId == ''){
                    caseId = claimId;
                }else{
                    caseId = exposureId;
                }

                List<Pulse_Survey_Result__c> surveyResults = Omni_PulseSurveyResultSelector.getSurveyResultsByTimestampAndCaseId(timeStamp, caseId);
                System.debug('timeStamp::'+timeStamp);
                System.debug('caseId::'+caseId);
                if(surveyResults.size() >= 1){
                    auraResponse.success = false;
                    auraResponse.message = 'You cannot answer this survey twice';
                }else{
                    auraResponse = createSurveyResults(faceId, caseId, timeStamp);
                }
            }else{
                auraResponse.success = false;
                auraResponse.message = 'URL Invalid';
            }
        }catch(Exception e){
            ApplicationLogHandler.addExceptionLog('Omni_Aura_SurveyFormController', e, null); 
            auraResponse.success = false;
            auraResponse.message = e.getMessage();
        }
        return auraResponse; 
    }

    /**
    * @Description: custom exception for survey issues
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-16
    */
    public class SurveyException extends Exception {
    }

}