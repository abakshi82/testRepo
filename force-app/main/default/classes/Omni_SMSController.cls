/**
 * @Description: Controller for SMSRetry visual flow
 * @author:      Damian Kazior, PwC
 * @Date:        2019-09-24
 */
global with sharing class Omni_SMSController {

    /**
    * @Description: Method called by ResendSMS flow. Recreate LiveMessage and send request to SMSService
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-24
    */
    @InvocableMethod 
    public static void resendSMS(List<ResendSMSRequest> resendRequests) { 
        //method can be called from flow with one recordId only
        List<String> liveMessagesIds = new List<String>();
        liveMessagesIds.add(resendRequests[0].recordId);
        LiveMessage__c liveMessages = Omni_LiveMessageSelector.getLiveMessagesByIds(liveMessagesIds)[0];   
        Omni_SMSService.SMSDataWrapper smsData = createSMSDataWrapper(liveMessages, resendRequests[0].newPhoneNumber);
        sendSMS(smsData); 
    }

    /**
    * @Description: Call SMSService to enqueue new sms message
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-24
    */
    private static void sendSMS(Omni_SMSService.SMSDataWrapper smsData){
        Omni_SMSService smsService = new Omni_SMSService();
        List<Omni_SMSService.SMSDataWrapper> dataWrappers = new List<Omni_SMSService.SMSDataWrapper>();
        dataWrappers.add(smsData);
        smsService.smsDataWrappers = dataWrappers;
        smsService.isRetry = true;
        smsService.sendSMSMessages(); 
    } 

    /**
    * @Description: Recreate sms wrapper from livemessage
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-24
    */
    private static Omni_SMSService.SMSDataWrapper createSMSDataWrapper(LiveMessage__c liveMessage, String newPhoneNumber){
        LiveMessage__c newLiveMessage = createLiveMessage(liveMessage, newPhoneNumber);
        Omni_SMSService.SMSDataWrapper smsData = Omni_SMSUtilities.createSMSDataWrapperFromLivemessage(newLiveMessage);
        System.debug('smsData::'+smsData);
        return smsData;  
    }
 
    private static LiveMessage__c createLiveMessage(LiveMessage__c liveMessage, String newPhoneNumber){
        //create deepclone of livemessage
        LiveMessage__c newLiveMessage =  liveMessage.clone(false, true, false, false); 
        newLiveMessage.Phone_Number__c = newPhoneNumber;
        newLiveMessage.Status__c = Omni_SMSConstant.SMS_STATUS_RETRIED;
        //fetch details about case for this livemessage for further feeditem processing
        //newLiveMessage.Case__c = [SELECT Id, Recordtype.Name, ExposureType__c FROM Case WHERE Id=:newLiveMessage.Case__c][0]; 
        insert newLiveMessage;
        return newLiveMessage;
    }

    /**
    * @Description: Collection of invocable parameters passed from the flow
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-24
    */
    global class ResendSMSRequest {
        @InvocableVariable(required=true)
        global String newPhoneNumber;

        @InvocableVariable(required=true)
        global String recordId;
    }
}