/**
* @description ECM Metadata Component Controller
* @author      Luis Merinero
* @date        03/02/2020                   
*/

public with sharing class Omni_ECMMetadataFilesController {
    
	/**
    * @description Query to Retrieve ECM Metadata Records by Metajunction Id
    * @author      Luis Merinero
    * @date        03/02/2020                     
    */
	@auraEnabled
	public static List<ECM_Metadata__c> getECMMetadataByEmailMessage(String emailMessageId){
        EmailMessage message = Omni_EmailMessageSelector.getMetaJunctionId(emailMessageId);
        if(message.Meta_Junction__c != null){
        	return Omni_ECMMetadataSelector.getECMMetadataByEmailMessage(message.Meta_Junction__c);
        }
        return null;
	}
    
}