/**
* @description Batch Class to delete  ECM processed Documents. It will pick up the 
File_Metadata__c and send it to Handler
* @author      Vikas Sharma
* @date        15/01/2020                     
*/

global class BatchDeleteECMProcessedDocs implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    private String query;
    public static Application_Log__c integrationLog;
    public static String error {get; private set;}
    public  boolean isMockTest = false;
    List<String> listOfSFIds = new List<String>();
    
    global BatchDeleteECMProcessedDocs(Boolean isQA, List<String> listOfSFIds){
        this.isMockTest = isQA;
        this.listOfSFIds = listOfSFIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Reference_Id__c,File_Mime_Type__c, Count__c FROM File_Metadata__c WHERE Processed_by_ECM__c = true AND File_Deleted__c = false';
        if (isMockTest)
        {
            query = 'SELECT Id, Reference_Id__c,File_Mime_Type__c,Count__c FROM File_Metadata__c WHERE Name in: listOfSFIds AND Processed_by_ECM__c = true  AND File_Deleted__c = false';
        }
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<File_Metadata__c> scope){
	Application_Log__c integrationLog;
        integrationLog = ApplicationLogHandler.createIntegrationLogs('', '','Success', '','', 'Delete Batch ECM Docs');
        insert integrationLog;
	try{		
        Set<Id> contentVersionIds = new Set<Id>();
        List<ContentDocument> contentDocumentsToDelete = new List<ContentDocument>();
        List<File_Metadata__c> toUpdateFileMetadata = new List<File_Metadata__c>();
        
        Map<Id, Decimal> contentVersionCountMap = new Map<Id,Decimal>();
        
        for (File_Metadata__c  fMeta : scope){
			contentVersionCountMap.put(fMeta.Id,fMeta.Count__c);
        }
        contentVersionIds.addAll(compareCountAndECMMetadata(contentVersionCountMap));
        contentVersionIds = removeFilesPendingProcess(contentVersionIds);
        
        for (ContentVersion currentContentVersion : [SELECT ContentDocumentId ,Id from ContentVersion 
                                                Where Id in: contentVersionIds 
                                               ]){
            contentDocumentsToDelete.add(new ContentDocument(Id = currentContentVersion.ContentDocumentId));
        }
        deleteContentDocuments(contentDocumentsToDelete, integrationLog);
        updateFileMetadata(contentVersionIds);    
        }
        catch(Exception e){
         	Application_Log__c exceptionLog;	
            exceptionLog = ApplicationLogHandler.saveExceptionLog('ECM Delete Batch Request Exception', e, integrationLog.Id);
        }
    }
    
    private void updateFileMetadata (Set<Id> contentVersionIds){
        List<File_Metadata__c> toDelete = new List<File_Metadata__c>();
        
        for (File_MetaData__c fileMetadata : [SELECT Id, File_Deleted__c FROM File_Metadata__c
                                              Where Reference_Id__c in : contentVersionIds]){
        	toDelete.add(new File_Metadata__c(Id = fileMetadata.Id, 
                                               File_Deleted__c = true ));    
        }
        update toDelete;
    }
    
    // to popluate the list of files to delete if 
    // file type is zipped
     private Set<Id> compareCountAndECMMetadata(Map<Id, Decimal> fileMetadataCount){
         Set<Id> toReturn = new Set<Id>();
         Map<Id, List<String>> ecmCounts = new Map<Id, List<String>>();
         Map<Id,Id> metaContentMap = new Map<Id,Id>();
         for(ECM_Metadata__c ecmMetadata : [SELECT Id,File_Metadata__c, File_Metadata__r.Reference_Id__c FROM ECM_Metadata__c 
                                            WHERE File_Metadata__c in : fileMetadataCount.keyset()]){
             metaContentMap.put(ecmMetadata.File_Metadata__c, ecmMetadata.File_Metadata__r.Reference_Id__c);
             if (ecmCounts.get(ecmMetadata.File_Metadata__c) == null){
                 ecmCounts.put(ecmMetadata.File_Metadata__c, new List<String>{ecmMetadata.Id});
             }
             else{
                 ecmCounts.get(ecmMetadata.File_Metadata__c).add(ecmMetadata.Id);
             }
         }
         
         for(Id currentFileMetadata : fileMetadataCount.keyset()){
             decimal currentCount = fileMetadataCount.get(currentFileMetadata);
         	if (ecmCounts.get(currentFileMetadata) != null &&
                ecmCounts.get(currentFileMetadata).size() >= currentCount){
                toReturn.add(metaContentMap.get(currentFileMetadata));
            }
         }
         return toReturn;
	}
    
    private Set<Id> removeFilesPendingProcess(Set<Id> contentVersionIds){
        for(File_Metadata__c fileMetadata : [SELECT id, Reference_Id__c FROM File_Metadata__c 
                                             WHERE Processed_By_ECM__c = false 
                                             AND Claim_Number__c != null
                                             AND Reference_Id__c IN :contentVersionIds]){
            if(contentVersionIds.contains(fileMetadata.Reference_Id__c)){
				contentVersionIds.remove(fileMetadata.Reference_Id__c);
            }
        }
        return contentVersionIds;
    }
    
    private static void deleteContentDocuments(List<ContentDocument> toDelete, Application_Log__c integrationLog){
        Database.DeleteResult[] drList = Database.delete(toDelete, false);
        // Iterate through each returned result
        for(Database.DeleteResult dr : drList) {
            if (!dr.isSuccess()) {
                // Operation failed, Log Erros               
                for(Database.Error err : dr.getErrors()) {
                    BatchECMDocumentDeleteException e = new BatchECMDocumentDeleteException(err.getMessage());
					ApplicationLogHandler.saveExceptionLog('ECM Delete Batch Request Exception', e, integrationLog.Id);
                }
            }
        }
        //delete toDelete;
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
	public class BatchECMDocumentDeleteException extends Exception {}	
}