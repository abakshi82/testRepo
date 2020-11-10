/**
* @description OM-925 this class contains constants related to Claim Notification flow
* @author      Kejia Hu
* @date        06/08/2019                     
*/
public with sharing class Omni_ClaimNotificationConstant {
    
    public static final String EVENT_NAME = 'Claim_Notification__e';
    public static final String SUB_EVENT_NAME = 'Claim_Notification_Sub__e';
    public static final String PERSON_ACCT_RECORD_TYPE_NAME = 'PersonAccount';
    public static final String BIZ_ACCT_RECORD_TYPE_NAME = 'BusinessAccount';
    public static final String CLAIM_RECORD_TYPE_NAME = 'Claim';
    public static final String CLAIM_ROLE_RECORD_TYPE_NAME = 'ClaimRole';
    public static final String EXPOSURE_ROLE_RECORD_TYPE_NAME = 'ExposureRole';
    public static final String MAIN_CONTACT_VAL = 'maincontact';
    public static final String EXPOSURE_TYPE_BENEFITS = 'Benefits';
    public static final String EXPOSURE_TYPE_BODILY_INJURY = 'BodilyInjury';
    public static final String EXPOSURE_TYPE_OTH_EXPOSURE = 'OtherExposure';
    public static final String COMMUNICATION_SMS = 'SMS';
    public static final String COMMUNICATION_EMAIL = 'EMAIL';
    public static final String COMMUNICATION_CUSTOM_CRITERIA = 'Custom Criteria';
    public static final String COMM_CHANNEL_EMAIL = 'Email';
    public static final String COMM_CHANNEL_SMS = 'SMS';
    public static final String COMM_CHANNEL_FAX = 'Fax';
    public static final String COMM_CHANNEL_PRINT = 'Print';
    public static final String COMM_FEED_TYPE = 'TextPost';
    public static final String COMM_FEED_STATUS = 'Published';
    public static final String SHADOW_ROLE_RECORD_TYPE_NAME = 'ShadowRole';
    public static final String ADHOC_ROLE_RECORD_TYPE_NAME = 'AdhocShadowRole';
    public static final String CELL_PHONE_TYPE_CODE = 'CP';
    public static final String BUSINESS_PHONE_TYPE_CODE = 'BP';
    public static final String FAX_TYPE_CODE = 'FX';
    public static final String CLAIM_CONTACT_RECORD_TYPE = 'IntactClaim';
    public static final String APP_NAME_PRINT_LOG = 'Print Log';
    public static final String APP_NAME_FAX_LOG = 'Fax Log';
    public static final String APP_NAME_EMAIL_LOG = 'Email Event Log';
    public static final String APP_NAME_EMAIL_ASYN_LOG = 'Email Asynchronous Log';
    public static final String APP_NAME_EMAIL_ASYN_LOG_RETRY = 'Email Retry Asynchronous Log';
    public static final String LOG_STATUS_PROCESSED = 'Processed';
    public static final String LOG_STATUS_DUPLICATED = 'Duplicated';
    public static final String LOG_STATUS_EXCEPTION_RETRY = 'Exception Retry';
    public static final Integer CLAIM_NOTIF_SUB_PE_BATCH_SIZE = 1; //desired EventBatch Size for Claim Notification Sub Event
    public static final Integer NUM_EMAILS_TO_SEND_ASYN = 10; //this number should not be bigger than 9
    public static final String EMAIL_EVENT_NAME = 'EmailMessage__e';
    public static final Integer EMAIL_EVENT_BATCH_SIZE = 50; //desired EventBatch Size for Email Message Event

    public static final String RECORD_TYPE_ID_CLAIM_ROLE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'ClaimRole').getRecordTypeId();
    public static final String RECORD_TYPE_ID_EXPO_ROLE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'ExposureRole').getRecordTypeId();
    public static final String RECORD_TYPE_ID_SHADOW_ROLE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'ShadowRole').getRecordTypeId();
    public static final String RECORD_TYPE_ID_ADHOC_ROLE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'AdhocShadowRole').getRecordTypeId();
    public static final String RECORD_TYPE_ID_CLAIM = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                            'Claim').getRecordTypeId();
    public static final String RECORD_TYPE_ID_EXPOSURE_BENEFITS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'Benefits').getRecordTypeId();                                                                                                                  
    public static final String RECORD_TYPE_ID_EXPOSURE_BODILY_INJURY = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'BodilyInjury').getRecordTypeId();                                                                                                                  
    public static final String RECORD_TYPE_ID_OTH_EXPOSURE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'OtherExposure').getRecordTypeId();                                                                                                                  
}