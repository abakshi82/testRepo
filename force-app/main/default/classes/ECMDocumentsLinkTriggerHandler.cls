/**
* @description: Update Metadata Objects for ECM documents. Either create
metadata skeleton or fill it all.
* @author      Vikas Sharma
* @date        13/01/2020                     
*/

public class ECMDocumentsLinkTriggerHandler implements TriggerHandlerBase {    
    public String getObjectAPIName() {
        return 'ContentDocumentLink';
    }
    
    /**
* @description Update EmailMessage records relationships based on roles related
* @author      Kejia Hu
* @date        18/09/2019                     
*/
    public void handleBeforeInsert(List<SObject> listNew) {
        try{
            
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            //  ApplicationLogHandler.saveExceptionLog('Claim Notification Event Handler', e, null); 
        }
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for Before Update logic
        return;
    }
    
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        //Placeholder for Before Delete logic
        return;
    }
    
    /**
* @description Created for ECMDocuments Trigger handler
* 			   to handle what happens after insert. Filter
*				only the ones which are linked to EmailMessage
* @author      Vikas
* @date        13/01/2020                     
*/
    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        System.debug('Handle After Insert');
        if(Limits.getQueries() > 70){
            System.enqueueJob(new ECMDocumentsLinkTriggerHandlerQueueable(mapNew));
        }else{
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
    
    public void handleAfterUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for After Update logic
        system.debug('Inside after Update____');
        return;
    }
    
    public void handleAfterDelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Delete logic
        return;
    }
    
    public void handleAfterUndelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Undelete logic
        return;
    }
    public static void manualTriggerHandler(List<EmailMessage> emailMessages)
    {
        try{
            
            Map<Id, SObject> mapNew = new Map<Id, SObject>();
            mapNew = populateMapNew(emailMessages);
            Map<Id, Set<Id>> parentToDocInfo = ECMDocumentsLinkTriggerHandlerHelper.filterNonEmailMessageDocs(mapNew);
            Map<EmailMessage, Case> emailtoCaseInfo = ECMDocumentsLinkTriggerHandlerHelper.populateCaseForInfo(parentToDocInfo);
            Map<Id, ContentDocument> contentDocument = ECMDocumentsLinkTriggerHandlerHelper.populateDocumentInfo(parentToDocInfo);
            Map<Id, Id> junctionObjectInfo = ECMDocumentsLinkTriggerHandlerHelper.insertFileJunction(parentToDocInfo);
            ECMDOcumentsLinkTriggerHandlerHelper.createFileECMMetadata(parentToDocInfo,emailtoCaseInfo,contentDocument, junctionObjectInfo);
            ECMDOcumentsLinkTriggerHandlerHelper.updateEmailMessage(junctionObjectInfo);
        }
        catch(Exception e)
        {
            system.debug('Error while manualTriggerHandler' + e.getMessage());
        }
    }
    public static Map<Id,  sObject> populateMapNew(List<EmailMessage> emailMessages){
        Map<Id, sObject> toReturn = new Map<Id, sObject>();
        List<Id> emailIds = new List<Id>();
        for (EmailMessage emlM : emailMessages)
        {
            emailIds.add(emlM.Id);
        }
        try{
            
            system.debug('emailMessages::' + emailMessages);
            FOR(ContentDocumentLink contentDocumentLink : [SELECT Id,  LinkedEntityId,
                                                           ContentDocumentId
                                                           FROM ContentDocumentLink 
                                                           Where LinkedEntityId in: emailIds ])
            {
                toReturn.put(contentDocumentLink.Id, contentDocumentLink);
            }
            system.debug('populateMapNew toReturn' + toReturn);
        }
        catch(Exception e)
        {
            system.debug('Error while populateMapNew' + e.getMessage()); 
        }
        return toReturn;
        
    }
}