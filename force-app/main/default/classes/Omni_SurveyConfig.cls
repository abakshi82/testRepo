/**
* @Description Wrapper object for survey configs
* @Author      Kejia Hu
* @Date        11/02/2020
*/
public with sharing class Omni_SurveyConfig {
    public String type;
    public String key;
    public Case claim;
    public Case exposure; 
    public String parentLogId;
    public Map<String, SurveyConfig__mdt> surveyConfigByKey;

    public Omni_SurveyConfig(Case claim, Case exposure, String parentLogId) {
        if (null == exposure) {
            this.claim = claim;
            this.type = 'Claim';
            this.key = claim.ClaimId__c + '-' + this.type;   
        } else {
            this.claim = claim;
            this.exposure = exposure;
            this.type = 'Exposure';
            this.key = exposure.exposureId__c + '-' + this.type;
        }
        this.parentLogId = parentLogId;
        this.surveyConfigByKey = new Map<String, SurveyConfig__mdt>();
    }
}