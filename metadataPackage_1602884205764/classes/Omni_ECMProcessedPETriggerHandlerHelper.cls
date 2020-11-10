/**
* @description Helper class for ECMProcessedPETriggerHandler
* @author      Vikas Sharma
* @date        13/01/2020                     
*/
public class Omni_ECMProcessedPETriggerHandlerHelper {

    /**
    * @description retrieve ECM related event config by name map
    * @author      Kejia Hu
    * @date        02/03/2020                     
    */
    public static final Map<String, String> ECM_CONFIG_BY_NAME {
        get {
            if(null == ECM_CONFIG_BY_NAME) {
                ECM_CONFIG_BY_NAME = new Map<String, String>();
                ECMConfig__mdt[] elementsForMappings = [
                    SELECT DeveloperName, Value__c FROM ECMConfig__mdt];
                for(ECMConfig__mdt element : elementsForMappings) {
                    ECM_CONFIG_BY_NAME.put(element.DeveloperName, element.Value__c);
                }
            }
            return ECM_CONFIG_BY_NAME;
        }
        set;
    }

/**
* @description Update the Flag on File Metadata
* 			   
* @author      Vikas Sharma
* @date        13/01/2020                     
*/
    public static void updateTheFlagForFileMetadata(Map<String, sObject> mapOfDocumentList)
    {
        List<File_Metadata__c> toUpsert = new List<File_Metadata__c>();
        List<ECM_Metadata__c> ECMtoUpsert = new List<ECM_Metadata__c>();
        
  		for (String currentId : mapOfDocumentList.keySet())
        {
            ECM_Processed__e handlerProcessedEvent = (ECM_Processed__e)mapOfDocumentList.get(currentId);
            if (handlerProcessedEvent.Status__c == 'SUCCESS')
            {
                String uniqueIdFileMetadata = handlerProcessedEvent.messageId__c + '-' + handlerProcessedEvent.SFId__c;
                toUpsert.add(new File_Metadata__c (Reference_Id__c = handlerProcessedEvent.SFId__c,
                                                   Unique_Id__c = uniqueIdFileMetadata,
                                                  	Processed_by_ECM__c = true, Count__c = handlerProcessedEvent.Count__c));
                ECMtoUpsert.add(new ECM_Metadata__c(
                							 ECM_File_Mime_Type__c = handlerProcessedEvent.Document_File_Extension__c,
                                             ECM_File_Size__c = handlerProcessedEvent.Document_File_Size__c,
                                             ECM__c = handlerProcessedEvent.Document_Name__c,
                                             File_Metadata__r = new File_Metadata__c(Unique_Id__c = uniqueIdFileMetadata), 
                    						 Unique_Id__c = handlerProcessedEvent.CMP_Id__c + uniqueIdFileMetadata,
                    						 CMP_Id__c = handlerProcessedEvent.CMP_Id__c));
            }
        }
        
        upsert toUpsert Unique_Id__c;
        upsert ECMtoUpsert Unique_Id__c;
    }
}