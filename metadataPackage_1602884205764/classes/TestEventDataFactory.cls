@isTest
public class TestEventDataFactory {

    /**
    * @Description: Create ECM_Processed__e event
    * @Author:      Kejia Hu
    * @Date:        06/03/2020
    */
    public static ECM_Processed__e createECMProcessedEvent(String trackingId, String messageId, String sfId) { 
        return new ECM_Processed__e(
            CMP_Id__c = '93 3 ICM6 claims15 CLM_ClaimRecord59 26 A1001001A20C06B20146E0041618 A20C06B20146E004161 14 1085',
            Document_File_Size__c = '2460028',
            LifeCycle_Status__c = 'PASSED_ARCHIVED_DOCUMENT',
            Document_Name__c = 'Adhoc Communication',
            Count__c = 1.0,
            SFId__c = sfId,
            Document_File_Extension__c = 'docx',
            Status__c = 'SUCCESS',
            TrackingId__c = trackingId,
            MessageId__c = messageId
        );
    }

    /**
    * @Description: Create failed Handler_Processed__e event
    * @Author:      Kejia Hu
    * @Date:        06/03/2020
    */
    public static Handler_Processed__e createHandlerProcessedEventFailure(String trackingId, String sfId, String messageId) { 
        return new Handler_Processed__e(
            LifeCycle_Status__c = 'FAILED_SF_DOC_BINARY_RETRIEVAL',
            Count__c = 1.0,
            SFId__c = sfId,
            Status__c = 'FAILURE',
            TrackingId__c = trackingId,
            messageId__c = messageId
        );
    }

    /**
    * @Description: Create successed Handler_Processed__e event
    * @Author:      Kejia Hu
    * @Date:        06/03/2020
    */
    public static Handler_Processed__e createHandlerProcessedEventSuccess(String trackingId, String sfId, String messageId) { 
        return new Handler_Processed__e(
            LifeCycle_Status__c = 'SUCCEEDED_SF_DOC_BINARY_RETRIEVAL',
            Count__c = 1.0,
            SFId__c = sfId,
            Status__c = 'SUCCESS',
            TrackingId__c = trackingId,
            messageId__c = messageId
        );
    }

}