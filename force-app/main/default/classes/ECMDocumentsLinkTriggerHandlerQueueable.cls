/**
    * @description Created for ContentDocumentLink Trigger handler
    * 			   to handle what happens after insert. Filter
    *				only the ones which are linked to EmailMessage
    * @author      Luis Merinero
    * @date        20/04/2020                     
    */
public class ECMDocumentsLinkTriggerHandlerQueueable implements Queueable{
	private Map<Id, SObject> mapNew;
    
	public ECMDocumentsLinkTriggerHandlerQueueable(Map<Id, SObject> mapNew) {
        this.mapNew = mapNew;
	}
    
	public void execute(QueueableContext context) {
       	system.debug('Inside execute');        
        Application_Log__c integrationLog;
        String payLoad;
        if (mapNew != null)
        {
            payLoad = JSON.serialize(mapNew);
        }
        integrationLog = ApplicationLogHandler.createIntegrationLogs(payLoad, '','Success', '','', 'File Metadata Created');
        
        try {
            system.debug('Inside Handler after Insert');
         	Map<Id, Set<Id>> parentToDocInfo = new Map<Id,Set<ID>>();
            parentToDocInfo  = ECMDocumentsLinkTriggerHandlerHelper.filterNonEmailMessageDocs(mapNew);
            if (parentToDocInfo != null){
            Map<EmailMessage, Case> emailtoCaseInfo = ECMDocumentsLinkTriggerHandlerHelper.populateCaseForInfo(parentToDocInfo);
            Map<Id, ContentDocument> contentDocument = ECMDocumentsLinkTriggerHandlerHelper.populateDocumentInfo(parentToDocInfo);
            Map<Id, Id> junctionObjectInfo = ECMDocumentsLinkTriggerHandlerHelper.insertFileJunction(parentToDocInfo);
            ECMDOcumentsLinkTriggerHandlerHelper.createFileECMMetadata(parentToDocInfo,emailtoCaseInfo,contentDocument, junctionObjectInfo);
            ECMDOcumentsLinkTriggerHandlerHelper.updateEmailMessage(junctionObjectInfo);
            }
         
            
        } catch (Exception e) {
            system.debug('Exception occured after Handler Insert' + e);
            ApplicationLogHandler.saveExceptionLog('File Metadata Created Exception', e, integrationLog.Id); 
        }
    }

}