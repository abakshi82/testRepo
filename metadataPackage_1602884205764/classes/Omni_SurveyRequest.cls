/**
* @Description Wrapper object for survey
* @Author      Kejia Hu
* @Date        11/02/2020
*/
public with sharing class Omni_SurveyRequest {

    public String key; //ClaimId or ExposureId
    public String type; // Claim or Exposure
    public String policyIssuingGroup;
    public String totalLoss;
    public String parentLogId;
    public List<String> surveyIndicators; // List of survey flag field API names

    public Omni_SurveyRequest(Omni_SurveyConfig surveyConfig) {
        this.key = surveyConfig.key;
        this.type = surveyConfig.type;
        this.parentLogId = surveyConfig.parentLogId;
        this.totalLoss = surveyConfig.claim.TotalLoss__c;
        this.policyIssuingGroup = Omni_ClaimEventDAOHelper.POLICY_ISSUING_GROUP_BY_ID.get(surveyConfig.claim.Policy_Issuing_Group__c).TypeCode__c;
        this.surveyIndicators = new List<String>(surveyConfig.surveyConfigByKey.keySet());
    }

    public Omni_SurveyRequest(SurveyRequest__c request) {
        this.key = request.Key__c;
        this.type = request.Type__c;
        this.parentLogId = request.ParentLogId__c;
        this.totalLoss = request.TotalLoss__c;
        this.policyIssuingGroup = request.PolicyIssuingGroup__c;
        this.surveyIndicators = request.SurveyIndicators__c.split(';');
    }
}