public with sharing class Omni_SMSUtilities {

    /**
    * @description Wrapper class to store data for one SMS payload. This sms payload might potenitally be broken down 
                   into multiple messages if it's length is too large. 
    * @author      Damian Kazior, PwC
    * @date        2019-09-18                 
    */
    public static Omni_SMSService.SMSDataWrapper createSMSDataWrapperFromLivemessage(LiveMessage__c liveMessage){
        
        Omni_SMSService.SMSDataWrapper smsData = new Omni_SMSService.SMSDataWrapper();
        smsData.cas                    = liveMessage.Case__r; 
        smsData.liveMessage            = liveMessage;
        smsData.smsTemplate            = liveMessage.Message_Text__c; 
        smsData.phoneNumber            = liveMessage.Phone_Number__c;
        smsData.recipientName          = liveMessage.Recipient_Name__c;
        smsData.exposureForRole        = liveMessage.Exposure_For_Role__r;
        smsData.communicationConfig    = liveMessage.Communication_Configuration__r;
        smsData.parentIntegrationLogId = liveMessage.Parent_Integration_Log__c;
        return smsData;
    }

}