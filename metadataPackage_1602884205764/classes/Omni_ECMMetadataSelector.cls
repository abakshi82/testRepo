/**
* @Description: Selctor for ECM_Metadata__c sObject
* @Author:      Luis Merinero
* @Date:        03/02/2020
*/
public class Omni_ECMMetadataSelector {
    
	/**
	* @description Retrieve Adhoc Shadow Role Cases related to the exposure
    * @author      Luis Merinero
    * @date        30/01/2020                    
    */
    public static List<ECM_Metadata__c> getECMMetadataByEmailMessage(String metaJunctionId){
        System.debug(metaJunctionId);
        return [SELECT id, ECM__c, CMP_Id__c, ECM_File_Mime_Type__c, ECM_File_Size__c, eCM_File_URL__c
                FROM ECM_Metadata__c WHERE File_Metadata__r.Meta_Junction__c = :metaJunctionId];
    }

}