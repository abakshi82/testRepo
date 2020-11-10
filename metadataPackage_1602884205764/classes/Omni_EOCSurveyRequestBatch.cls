/**
* @description batch job to retry failed survey request jobs
* @author      Kejia Hu
* @date        19/05/2020                     
*/
public class Omni_EOCSurveyRequestBatch implements Database.Batchable<sobject> {
    
    public String queryString;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        queryString = 'SELECT Id, JobId__c,'
                      +   ' (SELECT Id, Key__c, ParentLogId__c, PolicyIssuingGroup__c, SurveyIndicators__c, TotalLoss__c, Type__c FROM SurveyRequestsPerJob__r)'
                      + ' FROM SurveyRequest__c'
                      + ' WHERE RecordType.DeveloperName = \'SurveyJob\'';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<SurveyRequest__c> scope) {
        try {
            if (scope != null && !scope.isEmpty()) {
                List<SurveyRequest__c> toDelete = new List<SurveyRequest__c>();
                for (SurveyRequest__c requestJob : scope) {
                    Map<String, Omni_SurveyRequest> surveyRequestByKey = new Map<String, Omni_SurveyRequest>();
                    for (SurveyRequest__c request : requestJob.SurveyRequestsPerJob__r) {
                        surveyRequestByKey.put(request.Key__c, new Omni_SurveyRequest(request));
                    }
                    if (!surveyRequestByKey.isEmpty()) {
                        System.enqueueJob(new Omni_EOCSurveyRequest(surveyRequestByKey));
                    }
                    toDelete.addAll(requestJob.SurveyRequestsPerJob__r);
                }
                toDelete.addAll(scope);
                delete toDelete;
            }
        } catch(Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ApplicationLogHandler.saveExceptionLog('EOCSurveyRequestBatch', e, null);
        }
    }
    
    public void finish(Database.BatchableContext bc){}

}