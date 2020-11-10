public with sharing class Omni_SMSConstant { 

    //WEBTEXT
    public static FINAL String  EVENT_NAME                      = 'SMS_Event__e';
    public static FINAL Integer MAX_TEXT_LENGTH                 = 150;
    public static FINAL Integer MAX_NUMBER_EVENTS_PER_PAYLOAD   = Limits.getLimitQueueableJobs() - 5;
    public static FINAL String  LONG_TEXT_PREFIX                = 'X/Y ';
    public static FINAL String  SMS_COMMUNICATION_FEED_NAME     = 'SMS';
    public static FINAL String  WEBTEXT_SUCCESS                 = '000';
    public static FINAL String  WEBTEXT_SUCCESS_JSON            = '{\"return_code\":\"000\",\"return_string\":\"OK\",\"msgref\":\"US-TBD01-1368846723\"}';
    public static FINAL String  WEBTEXT_FAIL_JSON               = '{\"return_code\":\"100\",\"return_string\":\"Error\",\"msgref\":\"\"}';
    public static FINAL String  WEBTEXT_FAILURE                 = '100';
    public static FINAL String  SMS_APPLICATION_NAME            = 'WEBTEXT';
    public static FINAL String  SMS_EVENT_CATEGROY_INTEGRATION  = 'Integration';
    public static FINAL String  SMS_EVENT_CATEGROY_EXCEPTION    = 'Exception';
    public static FINAL String  SMS_EVENT_CATEGROY_MANUAL       = 'Manual';
    public static FINAL String  SMS_STATUS_SUBMITTED            = 'Submitted';
    public static FINAL String  SMS_STATUS_FAILED               = 'Failed';
    public static FINAL String  SMS_STATUS_DELIVERED            = 'Delievered';
    public static FINAL String  SMS_STATUS_UNDELIVERED          = 'Undelivered';
    public static FINAL String  SMS_STATUS_RETRIED              = 'Retried'; 
    public static FINAL String  SMS_STATUS_CREATED              = 'Created'; 

    //Messaging (2 way)
    public static FINAL String  TWO_WAY_FEED_CREATION_JOB_NAME  = 'Create feed for 2 way SMS'; 
    public static FINAL String  CRON_JOB_TYPE_SCHEDULED_APEX    = '7'; 
    public static FINAL String  LIVEMESSAGE_2WAY_RECORDTYPE_ID  = Schema.SObjectType.LiveMessage__c.getRecordTypeInfosByDeveloperName().get('Two_Way').getRecordTypeId();
    public static FINAL String  MESSAGING_SESSION_ENTITY_NAME   = 'MessagingSession';
    public static FINAL String  WORK_ITEM_STATUS_CLOSED         = 'Closed';
    public static FINAL String  TWO_WAY_SMS_APPLICATION_NAME    = 'Messaging';
    public static FINAL String  MESSAGING_USER_TYPE             = 'Text';
    public static FINAL String  MESSAGING_CHANNEL_NAME          = 'Two_Way_SMS';

    
}