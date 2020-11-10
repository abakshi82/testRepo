/**
* @description Helper class for HandlerProcessedTriggerHandler
* @author      Vikas Sharma
* @date        13/01/2020                     
*/
public class HandlerProcessedTriggerHandlerHelper {
    
	public static String SF_RETRY_EXCEPTIONS = System.Label.eCM_Ingest_Retry_Status;
    
    /**
    * @description Update the Flag on File Metadata
    * 			   
    * @author      Vikas Sharma
    * @date        13/01/2020                     
    */
    public static void updateTheFlagForFileMetadata(Map<String, sObject> mapOfDocumentList)
    {
        List<File_Metadata__c> toUpdate = new List<File_Metadata__c>();
        Map<String, Application_Log__c> integrationLogByTransId = new Map<String, Application_Log__c>();
        Map<String,String> UniqueIdsMap = new Map<String,String>();
        String transactionIds;
        Application_Log__c integrationLog = new Application_Log__c();
        
        try{
            for (String currentId : mapOfDocumentList.keySet()){
                Application_Log__c integrationLogPerEvent;
                
                Handler_Processed__e handlerProcessedEvent = (Handler_Processed__e)mapOfDocumentList.get(currentId);
                integrationLogPerEvent = generateIntegrationLog(handlerProcessedEvent, Omni_ClaimNotificationConstant.LOG_STATUS_PROCESSED);
                integrationLogByTransId.put(handlerProcessedEvent.TrackingId__c, integrationLogPerEvent);
                transactionIds += handlerProcessedEvent.TrackingId__c + '; ';
                
                if (handlerProcessedEvent.Status__c == 'Failure'){
                    String UniqueId = handlerProcessedEvent.messageId__c + '-' + handlerProcessedEvent.SFId__c;
                	UniqueIdsMap.put(UniqueId, handlerProcessedEvent.LifeCycle_Status__c);
                }
            }
            for (File_Metadata__c fileMetadata : [SELECT Id, Unique_Id__c FROM File_Metadata__c WHERE Unique_Id__c in :UniqueIdsMap.KeySet()]){
                if(SF_RETRY_EXCEPTIONS.contains(UniqueIdsMap.get(fileMetadata.Unique_Id__c))){
                    String retryProcessingStatus = 'Retrying - ' + UniqueIdsMap.get(fileMetadata.Unique_Id__c);
					toUpdate.add(new File_Metadata__c (Id = fileMetadata.Id, Sent_to_Handler__c = false, 
                                                      Document_Processing_Status__c = retryProcessingStatus));
                }else{
                    toUpdate.add(new File_Metadata__c (Id = fileMetadata.Id, Handler_ECM_Failure__c = true,
                                                       Document_Processing_Status__c = UniqueIdsMap.get(fileMetadata.Unique_Id__c)));
                }
            }
            if (!integrationLogByTransId.isEmpty()) {
                insert integrationLogByTransId.values();
                integrationLog = integrationLogByTransId.values()[0];
            }
            update toUpdate;
        }
        catch(Exception e)
        {
            Application_Log__c exceptionLog = ApplicationLogHandler.saveExceptionLog('Handler Processed Bulk exception'
                                                                                     , new HandlerProcessedTriggerHandlerException(e.getMessage()+'.\n Transaction Ids are: '+transactionIds, e)
                                                                                     ,'');   
        }
    }
    
    public static Application_Log__c generateIntegrationLog(Handler_Processed__e notifEvent, String status) {
        String payloadBody = JSON.serialize(notifEvent);
        String transIdForLog = notifEvent.TrackingId__c;
        Application_Log__c integrationLog = genereateIntegrationLog(payloadBody, transIdForLog, status, '', '');
        return integrationLog;
    }
    
    public static Application_Log__c genereateIntegrationLog(String payload, String transactionId, String status, String referenceNum, String TrackingNum) {
        Application_Log__c eventLog = new Application_Log__c();
        eventLog.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
        eventLog.Application_Name__c = 'Handler Processed Platform Event';
        eventLog.Category__c = 'Integration';
        eventLog.Transaction_Id__c = transactionId;
        eventLog.Status__c = status;
        eventLog.ReferenceNumber__c = referenceNum;
        eventLog.TrackingNumber__c = TrackingNum;
        if (payload.length()>131072) {
            eventLog.Request_Payload__c =  payload.substring(0, 131071);
            eventLog.AdditionalPayload__c = (payload.substring(131072).length()>131072)
                ? payload.substring(131072).substring(0, 131071)
                : payload.substring(131072);
        } else {
            eventLog.Request_Payload__c =  payload;
        }
        return eventLog;
    }
    public class HandlerProcessedTriggerHandlerException extends Exception {}
}