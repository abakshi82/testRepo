/**
   * @Description: Selctor for Content Version sObject
   * @Author:      Luis Merinero
   * @Date:        02/01/2020
*/
public class Omni_ContentVersionSelector {
    
	/**
    * @description Query ContenDocumentId From ContentVersionId
    * @author      Luis Merinero
    * @date        16/01/2020                     
    */
    @AuraEnabled
    Public static ContentVersion getContentDocumentIdFromContentVersionId(String contentVersionId){
        return [SELECT id, File_Metadata__c, ContentDocumentId FROM ContentVersion WHERE id = :contentVersionId];
    }
}