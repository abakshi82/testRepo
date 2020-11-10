/**
* @description Test class for Omni_SMSController
* @author      Damian Kazior
* @date        29/08/2019                     
*/ 
@isTest
private class Omni_SMSControllerTest {

    static Omni_SMSController.ResendSMSRequest resendReq;
    static final String NEW_PHONE_NUMBER = '123456789';  

    private static void prepareSmsData(){
        Case claim = TestDataFactory.createClaim();
        LiveMessage__c liveMessage = TestDataFactory.createLiveMessages(1, true, claim)[0];
        
        resendReq = new Omni_SMSController.ResendSMSRequest();
        resendReq.newPhoneNumber = NEW_PHONE_NUMBER;
        resendReq.recordId = liveMessage.Id;
    }

    @isTest
    private static void resendSMSPositive(){ 
        prepareSmsData();
        List<Omni_SMSController.ResendSMSRequest> resendRequests = new List<Omni_SMSController.ResendSMSRequest>(); 
        resendRequests.add(resendReq); 

        System.Test.setMock(HttpCalloutMock.class, new Omni_WebserviceCalloutMock(
                           200, 'Success', true, Omni_SMSConstant.WEBTEXT_SUCCESS_JSON));
        System.Test.startTest();
        Omni_SMSController.resendSMS(resendRequests);
        System.Test.stopTest();

        //verify feed items 
        List<FeedItem> feedItems = [SELECT Id, Body 
                                    FROM FeedItem 
                                    WHERE Type =: Omni_ClaimNotificationConstant.COMM_FEED_TYPE];
        System.assertEquals(1, feedItems.size(), 'There should be one feed item created for resend SMS with new phone number');
        System.assertEquals(true, feedItems[0].Body.contains(NEW_PHONE_NUMBER), 'There should be one feed item created for resend SMS with new phone number');
   }  
}