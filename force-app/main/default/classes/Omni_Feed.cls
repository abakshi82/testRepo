/**
* @description Wrapper object for create FeedItem in auto notification flow
*              apply for Email/SMS/Print/Fax
* @author      Kejia Hu
* @date        09/20/2019                     
*/
public with sharing class Omni_Feed {

    public String channel;
    public String exposure;
    public String parentId;
    public String recordId;
    public String eventTimeStamp;
    public String communicationName;
    public String recipientsName;
    public String recipients;
    public String recipientsPhoneNumber;
    public String bodyOfSMS;
    public String message;
    public Datetime createdDate;

    /**
    * @description build feed body based on the Omni_Feed instance
    * @author      Kejia Hu
    * @date        20/09/2019                     
    */
    public String generateFeedBody() {
        System.debug('generate feed');
        String bodyToReturn = '';
        if (null != this.channel) {
            bodyToReturn += System.Label.Omni_FeedBody_Channel_EN.toUpperCase() + ' / '+ 
                            System.Label.Omni_FeedBody_Channel_FR.toUpperCase() + ': ' + this.channel + '\n';
        }
        if (null != this.eventTimeStamp) {
            bodyToReturn += System.Label.Omni_FeedBody_EventTime_EN.toUpperCase() + ' / '+ 
                            System.Label.Omni_FeedBody_EventTime_FR.toUpperCase() + ': ' + this.eventTimeStamp + '\n';
        }
        if (null != this.communicationName) {
            bodyToReturn += System.Label.Omni_FeedBody_CommName_EN.toUpperCase() + ' / '+ 
                            System.Label.Omni_FeedBody_CommName_FR.toUpperCase() + ': ' + this.communicationName + '\n';
        }
        if (null != this.exposure) {
            bodyToReturn += System.Label.Omni_FeedBody_Exposure_EN.toUpperCase() + ' / '+ 
                            System.Label.Omni_FeedBody_Exposure_FR.toUpperCase() + ': ' + this.exposure + '\n';
        }
        if (null != this.recipients) {
            bodyToReturn += System.Label.Omni_FeedBody_Recipients_EN.toUpperCase() + ' / '+ 
                            System.Label.Omni_FeedBody_Recipients_FR.toUpperCase() + ': ' + this.recipients + '\n';
        }
        if (null != this.message) {
            bodyToReturn += System.Label.Omni_FeedBody_Message_EN.toUpperCase()  + ': ' + this.message + '\n';
        }
        if (null != this.recipientsName) {
            bodyToReturn += System.Label.Omni_FeedBody_RecipientsName_EN.toUpperCase() + ' / '+  
                            System.Label.Omni_FeedBody_RecipientsName_FR.toUpperCase() + ': ' + this.recipientsName + '\n';
        }
        if (null != this.recipientsPhoneNumber) {
            bodyToReturn += System.Label.Omni_FeedBody_RecipientsPhone_EN.toUpperCase() + ' / '+  
                            System.Label.Omni_FeedBody_RecipientsPhone_FR.toUpperCase() + ': ' +  this.recipientsPhoneNumber + '\n';
        }
        if (null != this.bodyOfSMS) {
            bodyToReturn += System.Label.Omni_FeedBody_Body_EN.toUpperCase() + ' / '+ 
                            System.Label.Omni_FeedBody_Body_FR.toUpperCase() + ': ' +  this.bodyOfSMS + '\n';
        }
        return bodyToReturn;
    }

}