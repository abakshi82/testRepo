/**
* @Description: Service for Pulse surveys
* @Author:      Damian Kazior
* @Date:        05/01/2020
*/
public with sharing class Omni_PulseSurveyService {

    public static FINAL String SURVEY_ID_GET_PARAM   = '?c_id=';
    public static FINAL String SURVEY_TIME_GET_PARAM = '&time=';
    public static String surveyBaseUrl;
    public static String timestampAnchor;

    /**
    * @Description: Check outgoing emails and create pending pulse survey records for applicable emails
    * @Author:      Damian Kazior
    * @Date:        20/01/2020
    */
    public static void preparePulseSurveys(List<EmailMessage> emailMessages){ 

        Pulse_Survey_Configuration__c surveyConfig = Pulse_Survey_Configuration__c.getOrgDefaults();
        surveyBaseUrl = surveyConfig.Base_Url__c + SURVEY_ID_GET_PARAM;
        timestampAnchor = surveyConfig.Timestamp_Anchor__c;
 
        for(EmailMessage emailMsg : emailMessages){
            if(qualifiesForPulseSurvey(emailMsg)){
                emailMsg.Pulse_Survey_Identifier__c = fetchTimeFromEmail(emailMsg);
            }
        }
    }   

    /**
    * @Description: 
    * @Author:      Damian Kazior
    * @Date:        20/01/2020
    */
    private static boolean qualifiesForPulseSurvey(EmailMessage emailMsg){

        if(!emailMsg.Incoming && emailMsg.HtmlBody != null){
            if(isSurveyUrlPresentInEmail(emailMsg)){
                return true;
            }
        }
        return false;
    }    

    /**
    * @Description: Check if outgoing has a midclaim survey orl in the body
    * @Author:      Damian Kazior
    * @Date:        20/01/2020
    */
    private static boolean isSurveyUrlPresentInEmail(EmailMessage emailMsg){
        
        return emailMsg.HtmlBody.contains(surveyBaseUrl);
    }

    /**
    * @Description: Timestamp in seconds from Jan 1, 2020 is generated in the formula field on case. 
    *               Fetch taht value from email template
    * @Author:      Damian Kazior
    * @Date:        20/01/2020
    */
    private static String fetchTimeFromEmail(EmailMessage emailMsg){ 
        //index where role Id starts (right at the end of survey url)
        Integer roleIdIndex  = emailMsg.HtmlBody.indexOf(surveyBaseUrl) + surveyBaseUrl.length();
        //index where timestamp end and dumy anchor starts
        Integer endIndex    = emailMsg.HtmlBody.indexOf(timestampAnchor);
        String  roleIdAndTime = emailMsg.HtmlBody.substring(roleIdIndex, endIndex);
        Integer timestampIndex  = roleIdAndTime.indexOf(SURVEY_TIME_GET_PARAM) + SURVEY_TIME_GET_PARAM.length();        
        return roleIdAndTime.substring(timestampIndex);
    
    }
}