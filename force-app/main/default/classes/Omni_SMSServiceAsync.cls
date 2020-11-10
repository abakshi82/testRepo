global with sharing class Omni_SMSServiceAsync implements Queueable, Database.AllowsCallouts{  
    
    LiveMessage__c liveMessage;
    String parentLogId;
    String parentTransactionId;
    Webtext_Parameters_Configuration__c webtextConfig;
    Boolean isRetry; 

    global Omni_SMSServiceAsync(LiveMessage__c liveMessage, String parentLogId, Boolean isRetry) {
        this.liveMessage = liveMessage;
        this.parentLogId = parentLogId;
        this.isRetry     = isRetry;
        this.webtextConfig = Webtext_Parameters_Configuration__c.getOrgDefaults();
    }

    /**
    * @Description: When multiple messages need to be sent to one recipient, call webtext with each message separetly
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-29
    */ 
    public void execute(QueueableContext context) { 
        List<Application_Log__c> applicationLogs = new List<Application_Log__c>(); 
        try{
            this.liveMessage = Omni_LiveMessageSelector.getLiveMessageById(this.liveMessage.Id);
            if(!this.isRetry){
                updateTemplateBody();
            }
            List<String> textBodies = preprocessMessageBody(liveMessage.Message_Text__c);    
            for(String textBody : textBodies){ 
                HttpRequest req = generateHttpRequest(liveMessage, textBody);
                Application_Log__c appLog = genereateIntegrationLog(req.getBody(), parentLogId, liveMessage.Status__c);
                applicationLogs.add(appLog);
                 
                if(this.webtextConfig.Service_Enabled__c || Test.isRunningTest()){
                    Http http = new Http();
                    HTTPResponse response = http.send(req); 
                    Omni_SMSResponseWrapper smsResponse = (Omni_SMSResponseWrapper)JSON.deserialize(response.getBody(), Omni_SMSResponseWrapper.class);
                    if(smsResponse.return_code == Omni_SMSConstant.WEBTEXT_SUCCESS){
                        liveMessage.Status__c = Omni_SMSConstant.SMS_STATUS_SUBMITTED;
                        appLog.Transaction_Id__c = this.parentTransactionId;
                        appLog.Response_Payload__c = 'Return string: '+ smsResponse.return_string + ' Transaction : '+ smsResponse.msgref;
                    }else{
                        liveMessage.Status__c = Omni_SMSConstant.SMS_STATUS_FAILED;
                        appLog.Response_Payload__c = 'Return code: '+ smsResponse.return_code + 'Return string: '+ smsResponse.return_string;
                        throw new Omni_SMSServiceAsync.WebtextException(response.getBody()); 
                    }
                }                
            }
            if(this.isRetry){
                genereateAndInsertFeedItemsForRetry();
            }else{
                genereateAndInsertFeedItems();
                reparentLiveMessageRecord();
            }
        }catch (Exception e) {
            System.debug(e.getLineNumber());
            ApplicationLogHandler.saveExceptionLog(Omni_SMSConstant.SMS_APPLICATION_NAME, e , parentLogId); 
        }finally{
            insert applicationLogs;  
            update this.liveMessage;  
        }
    } 
     
    /**
    * @Description: Generate HTTP request for webtext integration
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-24
    */
    private HttpRequest generateHttpRequest(LiveMessage__c liveMessage, String textBody){

        HttpRequest req = new HttpRequest();  
        req.setheader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint('callout:'+webtextConfig.Environment__c);
        req.setMethod('POST');     
        req.setBody(generatePayload(liveMessage.Phone_Number__c, textBody));        
        return req;
    }  
   
    /**
    * @Description: Generate payload for webtext
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-29
    */
    private String generatePayload(String toNumber, String messageBody){
        
        return  'tag='    + this.webtextConfig.Short_Code__c    
               +'&dest='  + toNumber
               +'&txt='   + EncodingUtil.urlEncode(messageBody,'UTF-8')
               +'&api_id={!$Credential.UserName}'
               +'&api_pwd={!$Credential.Password}'
               +'&json='  +'1';
               //+'&receipt_url='+ 'https://dev1b-intact.cs142.force.com/SMSService/services/apexrest/testsms'; 
    }

    /**
    * @Description: custom exception for webtext issues
    * @author:      Damian Kazior, PwC
    * @Date:        2019-09-16
    */
    public class WebtextException extends Exception {
    }
    
    /**
    * @description Generate integration log before calling out
    * @author      Damian Kazior, PwC
    * @date        2019-09-18                 
    */
    public Application_Log__c genereateIntegrationLog(String payload, String parentLog, String liveMessageStatus) {
        Application_Log__c eventLog  = new Application_Log__c();
        eventLog.RecordTypeId        = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
        eventLog.Application_Name__c = Omni_SMSConstant.SMS_APPLICATION_NAME;
        if(liveMessageStatus==Omni_SMSConstant.SMS_STATUS_RETRIED){
            eventLog.Category__c         = Omni_SMSConstant.SMS_EVENT_CATEGROY_MANUAL;      
        }else{
            eventLog.Category__c         = Omni_SMSConstant.SMS_EVENT_CATEGROY_INTEGRATION; 
        }
        eventLog.Request_Payload__c  = payload;
        eventLog.Application_Log__c  = parentLog;

        return eventLog;
    }

    /**
    * @Description: Break text message into chunks whenever message is longer than MAX_TEXT_LENGTH
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-24
    */
    @testVisible
    private List<String> preprocessMessageBody(String messageBody){
        List<String> messages = new List<String>();
        if(messageBody.length() > Omni_SMSConstant.MAX_TEXT_LENGTH){
            List<String> words = messageBody.split(' ');
            String part = ''; 
            //create array of messages with extra room for prefix
            for(String word : words){
                //is this word's length + sentence so far length +  length of message prefix (1/2) less than max?
                if (part.length() + word.length() + Omni_SMSConstant.LONG_TEXT_PREFIX.length() + 1 <= Omni_SMSConstant.MAX_TEXT_LENGTH){
                    //add this word to the sentence
                    part += String.isEmpty(part) ? word : ' ' + word;
                }else{ 
                    //add sentence so far to the array and start new sentence with word we tried above
                    messages.add(part);
                    part = word; 
                }
            } 
            messages.add(part);
            //add prefix to each message
            for(Integer k=0; k<messages.size(); k++){
                String prefix = Omni_SMSConstant.LONG_TEXT_PREFIX.replace('X',String.valueOf(k+1)).replace('Y', String.valueOf(messages.size()));
                messages[k] = prefix+messages[k];
            }
        }else{
            messages.add(messageBody);
        }
        
        return messages;
    }    


    /**
    * @Description: Break text message into chunks whenever message is longer than MAX_TEXT_LENGTH
    * @author:      Damian Kazior, PwC
    * @Date:        2019-08-24
    */
    @testVisible
    private void updateTemplateBody(){
        List<String> template = new List<String>();
        template.add(this.liveMessage.Message_Text__c);
        List<Messaging.RenderEmailTemplateBodyResult> smsTemplateBody = Messaging.renderEmailTemplate(this.liveMessage.Case__r.PartyAccount__c, this.liveMessage.Case__c, template);
        for(Messaging.RenderEmailTemplateBodyResult emailTemplateMergeResult : smsTemplateBody){
            if(emailTemplateMergeResult.getMergedBody() != null){
                if(emailTemplateMergeResult.getSuccess()){
                    this.liveMessage.Message_Text__c  = emailTemplateMergeResult.getMergedBody();
                }
            }
        }    
    }    


    /**
    * @description Generate integration log before calling out
    * @author      Damian Kazior, PwC
    * @date        2019-09-18                 
    */
    public List<FeedItem> genereateAndInsertFeedItems() {
        System.debug('this.liveMessage'+this.liveMessage);    
        System.debug('this.liveMessage'+this.liveMessage.Case__r);
        Map<String, ExposureType__c> exposures = Omni_ClaimNotificationDAOHelper.EXPOSURE_TYPE_BY_ID;

        List<Omni_Feed> feeds = new List<Omni_Feed>();

            if(this.liveMessage.Case__r.ExposureForRole__c == null){
                Omni_Feed claimFeed          = generateBaseFeed();
                claimFeed.bodyOfSMS          = this.liveMessage.Message_Text__c;
                claimFeed.recipientsName     = this.liveMessage.Recipient_Name__c;
                claimFeed.parentId           = this.liveMessage.Case__r.ClaimForRole__c;
                feeds.add(claimFeed);
            }else{ 
                Omni_Feed exposureFeed      = generateBaseFeed(); 
                exposureFeed.bodyOfSMS      = this.liveMessage.Message_Text__c;
                exposureFeed.recipientsName = this.liveMessage.Recipient_Name__c;
                exposureFeed.parentId       = this.liveMessage.Case__r.ExposureForRole__c;
                feeds.add(exposureFeed);   
        
                Omni_Feed claimFeed         = generateBaseFeed();
                claimFeed.exposure          = exposures.get(this.liveMessage.Exposure_For_Role__r.ExposureType__c).Name;
                claimFeed.parentId          = this.liveMessage.Case__r.ClaimForRole__c;
                feeds.add(claimFeed);                 
            }
     
        return Omni_FeedHandler.persistFeedItems(feeds);
    }

    private Omni_Feed generateBaseFeed(){
        Omni_Feed omnifeed = new Omni_Feed();
        omnifeed.channel               = Omni_SMSConstant.SMS_COMMUNICATION_FEED_NAME;
        omnifeed.recipientsPhoneNumber = this.liveMessage.Phone_Number__c;
        omnifeed.communicationName     = this.liveMessage.Communication_Configuration__r.SMS_Subject_EN__c + ' / ' + this.liveMessage.Communication_Configuration__r.SMS_Subject_FR__c;
        omnifeed.recordId              = this.liveMessage.Id;
        return omnifeed;
    }   

    public List<FeedItem> genereateAndInsertFeedItemsForRetry() {
        System.debug('this.liveMessage'+this.liveMessage);    
        System.debug('this.liveMessage'+this.liveMessage.Case__r);
        Map<String, ExposureType__c> exposures = Omni_ClaimNotificationDAOHelper.EXPOSURE_TYPE_BY_ID;

        List<Omni_Feed> feeds = new List<Omni_Feed>();
        
            if(this.liveMessage.Case__r.RecordTypeId == Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM){
                Omni_Feed claimFeed          = generateBaseFeed();
                claimFeed.bodyOfSMS          = this.liveMessage.Message_Text__c;
                claimFeed.recipientsName     = this.liveMessage.Recipient_Name__c;
                claimFeed.parentId           = this.liveMessage.Case__r.Id;
                feeds.add(claimFeed);
            }else{ 
                Omni_Feed exposureFeed      = generateBaseFeed(); 
                exposureFeed.bodyOfSMS      = this.liveMessage.Message_Text__c;
                exposureFeed.recipientsName = this.liveMessage.Recipient_Name__c;
                exposureFeed.parentId       = this.liveMessage.Case__r.Id;
                feeds.add(exposureFeed);   
        
                Omni_Feed claimFeed         = generateBaseFeed();
                claimFeed.exposure          = exposures.get(this.liveMessage.Case__r.ExposureType__c).Name;
                claimFeed.parentId          = this.liveMessage.Case__r.ClaimForExposure__c;
                feeds.add(claimFeed);                 
            }
     
        return Omni_FeedHandler.persistFeedItems(feeds);
    }

    /**
    * @description LiveMessage is a child of role for which sms is sent out. Once sms is processed, reparent Livemessage
                   to claim/exposure instead.
    * @author      Damian Kazior, PwC
    * @date        2019-09-18                 
    */
    private void reparentLiveMessageRecord(){
        if(this.liveMessage.Case__r.ExposureForRole__c == null){
            this.liveMessage.Case__c = this.liveMessage.Case__r.ClaimForRole__c;
        }else{
            this.liveMessage.Case__c = this.liveMessage.Case__r.ExposureForRole__c;
        }
    }  
}