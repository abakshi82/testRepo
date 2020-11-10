/**
* @description constants that used in claim events 
* @author      Kejia Hu
* @date        03/12/2019                     
*/
public with sharing class Omni_ClaimEventConstant {

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
    public static final String RECORD_TYPE_ID_OTH_EXPOSURE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                'OtherExposure').getRecordTypeId();
    public static final String RECORD_TYPE_ID_BI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                        'BodilyInjury').getRecordTypeId();
    public static final String RECORD_TYPE_ID_BENEFITS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                            'Benefits').getRecordTypeId();
    public static final String RECORD_TYPE_ID_EMAIL_CASE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                            'EmailCase').getRecordTypeId();

    public static final Schema.SObjectType CLAIM_BUS_1_TYPE = Schema.ClaimEvent_1__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_2_TYPE = Schema.ClaimEvent_2__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_3_TYPE = Schema.ClaimEvent_3__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_4_TYPE = Schema.ClaimEvent_4__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_5_TYPE = Schema.ClaimEvent_5__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_6_TYPE = Schema.ClaimEvent_6__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_7_TYPE = Schema.ClaimEvent_7__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_8_TYPE = Schema.ClaimEvent_8__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_9_TYPE = Schema.ClaimEvent_9__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_10_TYPE = Schema.ClaimEvent_10__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_11_TYPE = Schema.ClaimEvent_11__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_12_TYPE = Schema.ClaimEvent_12__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_13_TYPE = Schema.ClaimEvent_13__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_14_TYPE = Schema.ClaimEvent_14__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_15_TYPE = Schema.ClaimEvent_15__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_16_TYPE = Schema.ClaimEvent_16__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_17_TYPE = Schema.ClaimEvent_17__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_18_TYPE = Schema.ClaimEvent_18__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_19_TYPE = Schema.ClaimEvent_19__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_20_TYPE = Schema.ClaimEvent_20__e.getSObjectType();
    public static final Schema.SObjectType CLAIM_BUS_BACKUP_TYPE = Schema.ClaimEvent_Backup__e.getSObjectType();

    public static final String NAME_CLAIM_EVENT_1 = ClaimEvent_1__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_2 = ClaimEvent_2__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_3 = ClaimEvent_3__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_4 = ClaimEvent_4__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_5 = ClaimEvent_5__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_6 = ClaimEvent_6__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_7 = ClaimEvent_7__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_8 = ClaimEvent_8__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_9 = ClaimEvent_9__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_10 = ClaimEvent_10__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_11 = ClaimEvent_11__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_12 = ClaimEvent_12__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_13 = ClaimEvent_13__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_14 = ClaimEvent_14__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_15 = ClaimEvent_15__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_16 = ClaimEvent_16__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_17 = ClaimEvent_17__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_18 = ClaimEvent_18__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_19 = ClaimEvent_19__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_20 = ClaimEvent_20__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_BACKUP = ClaimEvent_Backup__e.sObjectType.getDescribe().getName();
    public static final String NAME_CLAIM_EVENT_DISPATCH = ClaimEvent_Dispatcher__e.sObjectType.getDescribe().getName();
}