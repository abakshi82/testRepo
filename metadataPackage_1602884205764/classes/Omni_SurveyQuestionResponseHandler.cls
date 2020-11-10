/**
* @description: Updates Survey Subject with the NPS Score received and creates a Task to the manager if equal or less than 6
* @author      Luis Merinero
* @date        27/02/2020                     
*/
public class Omni_SurveyQuestionResponseHandler {
    
    @InvocableMethod(label='Survey Responses' description='Survey Responses' category= 'SurveyQuestionResponse')
    public static void addNPSToSurveySubject(List<SurveyQuestionResponse> responseList){
        Map<id,SurveyQuestionResponse> responsesMap = new Map<id,SurveyQuestionResponse>();
        for(SurveyQuestionResponse response : responseList){
            responsesMap.put(response.id, response);
        }
        List<SurveyQuestionResponse> NPSResponses = [SELECT id, Question.QuestionType, NumberValue, Response.InvitationId
                                                     FROM SurveyQuestionResponse 
                                                     WHERE Id in :responsesMap.keySet()];
        if(NPSResponses.size() > 0 || Test.isRunningTest()){
            try{
                Survey_NPS__c SurveyNPS = Survey_NPS__c.getOrgDefaults();
                Map<id, Decimal> invitationNPSMap = new Map<id, Integer>();
                for(SurveyQuestionResponse response : NPSResponses){
                    if(response.Response.InvitationId != null && response.NumberValue != null){
                        invitationNPSMap.put(response.Response.InvitationId, response.NumberValue);
                    }
                }
                Set<Id> surveySubjectId = new Set<Id>();
                List<SurveySubject> surveySubjectList = new List<SurveySubject>();
                List<Task> managerTaskList = new List<Task>();
                Id recordTypeSurvey = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Survey').getRecordTypeId();
                for(SurveySubject subject : [SELECT id, SurveyInvitationId, SubjectId, Survey_Owner__c,
                                             Survey_Owner__r.Delegated_User__c, Case__c, Case__r.ClaimNumber__c
                                             FROM SurveySubject WHERE SurveyInvitationId IN :invitationNPSMap.keySet()]){
                    if(!surveySubjectId.contains(subject.Id)){
                        surveySubjectId.add(subject.Id);
                        subject.NPS__c = invitationNPSMap.get(subject.SurveyInvitationId);
                        surveySubjectList.add(subject);
                        if(subject.NPS__c <= SurveyNPS.SurveyNPSScore__c){
                            String taskOwner = '';
                            if(subject.Survey_Owner__r.Delegated_User__c != null){
                                taskOwner = subject.Survey_Owner__r.Delegated_User__c;
                            }else{
                                if(subject.Survey_Owner__c != null){
                                    taskOwner = subject.Survey_Owner__c;
                                }
                            }
                            if(subject.Survey_Owner__c != null && taskOwner != ''){
                                String description = Label.Omni_EOCLowNPSOf + ' ' + String.valueOf(subject.NPS__c) + '. \n\n';
                                description += Label.Omni_EOCLowNPSDescription + ' ' + URL.getOrgDomainUrl().toExternalForm() + '/' + subject.SurveyInvitationId;
                                managerTaskList.add(new Task(Subject = Label.Omni_EOCLowNPSScore,
                                                             RecordTypeId = recordTypeSurvey,
                                                             TaskSubtype='Task',
                                                             ActivityDate = System.today(),
                                                             WhatId = subject.Case__c, 
                                                             OwnerId = taskOwner,
                                                             Description = description));
                            }
                        }
                    }
                }
                if(surveySubjectList.size() > 0) Update surveySubjectList;
                if(managerTaskList.size() > 0) Insert managerTaskList;
            }catch(exception e){
            	ApplicationLogHandler.saveExceptionLog('Survey Response Exception', e, null);    
            }
        }
    }
    
}