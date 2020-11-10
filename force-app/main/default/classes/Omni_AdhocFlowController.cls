/**
* @description Adhoc Communication controller to retrieve queries into Lightning Components
* @author      Luis Merinero
* @date        05/12/2019                     
*/

global without sharing class Omni_AdhocFlowController {
    public static String[] exposuresRTIds = new String[]{Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPOSURE_BENEFITS, Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPOSURE_BODILY_INJURY, Omni_ClaimNotificationConstant.RECORD_TYPE_ID_OTH_EXPOSURE};
	public static String[] rolesRTIds = new String[]{Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM_ROLE, Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPO_ROLE};
            
    /**
    * @description Query Roles related to Claim
    * @author      Luis Merinero
    * @date        05/12/2019                      
    */
	@auraEnabled
	public static List<Case> getRoles(String claimId){
        return Omni_CaseSelectorWithSharing.getRolesFromClaim(claimId, rolesRTIds, exposuresRTIds); 
	}
    
	/**
    * @description Query Exposures related to Claim
    * @author      Luis Merinero
    * @date        05/12/2019                     
    */
    @auraEnabled
    public static List<Case> getExposures(String claimId){
        return Omni_CaseSelectorWithSharing.getExposuresFromClaim(claimId, exposuresRTIds); 
    }
    
	/**
    * @description Query List of Email Templates
    * @author      Luis Merinero
    * @date        05/12/2019                     
    */
    @auraEnabled 
    public static List<EmailTemplate> getEmailTemplatesList(String folderName, String language){
        return Omni_EmailTemplateSelector.getAllEmailTemplatesByFolderNameAndLanguage(folderName, language);
    }
    
	/**
    * @description Query List of Email Folders
    * @author      Luis Merinero
    * @date        02/01/2020                     
    */
    @auraEnabled 
    public static List<Folder> getFolderList(String objectType){
        return Omni_FolderSelector.getAllFoldersByType(objectType);
    }
    
	/**
    * @description ECM Search request
    * @author      Luis Merinero
    * @date        15/01/2020                     
    */
	@AuraEnabled
    Public static String ECMSearch(String claimNumber, String exposureType, Boolean includeArchive){
        String claimSubType = 'GENERAL';
        if(exposureType == Omni_ClaimNotificationConstant.EXPOSURE_TYPE_BENEFITS) claimSubType = 'AB';
        if(exposureType == Omni_ClaimNotificationConstant.EXPOSURE_TYPE_BODILY_INJURY) claimSubType = 'BI';
        Omni_EcmSearchClass.Document[] documents = Omni_ECMSearchClass.invoke(claimNumber, claimSubType, includeArchive);
        return JSON.serialize(documents);
    }
	
    /**
    * @description ECM Search request
    * @author      Luis Merinero
    * @date        15/01/2020                     
    */
	@AuraEnabled
    Public static String ECMRetrieveDocumentUrl(String cmpid, String cmpUrl){
        return Omni_ECMRetrieveClass.invoke(cmpid, cmpUrl);
    }
  	/**
    * @description Clone role and insert shadow role
    * @author      Luis Merinero
    * @date        05/12/2019                     
    */
    @auraEnabled
    public static String getShadowRoleId(String roleId, String exposureId){
        Case[] adhocRoleCases = Omni_CaseSelector.getAdhocRoleByExposureAndOriginRole(roleId, exposureId);
        Map<id,Case> exposures = Omni_CaseSelector.getCaseById(new List<String>{exposureId});
        String adhocRoleId;
        if(adhocRoleCases.size() > 0){
            adhocRoleId = adhocRoleCases[0].Id; 
        }
        String soql = Omni_Utils.getCreatableFieldsSOQL('Case','id=\'' + roleId + '\'');
        Case role = (Case)Database.query(soql);
        Case adhocRole = role.clone(false, true);
        if(exposures.get(exposureId).Owner.isActive){
        	adhocRole.OwnerId = exposures.get(exposureId).OwnerId;
        }else{
            adhocRole.OwnerId = UserInfo.getUserId();
        }
        adhocRole.RecordTypeId = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_ADHOC_ROLE;
        adhocRole.OriginRoleForShadow__c = roleId;
        adhocRole.ExposureForRole__c = exposureId;
        adhocRole.RoleId__c = adhocRole.RoleId__c + Utility.generateRandomChar(8) + DateTime.now().getTime();
        if(adhocRoleId != null){
            adhocRole.Id = adhocRoleId;
        }
        upsert adhocRole;
        return adhocRole.Id;
    }
    
	/**
    * @description Retrieve User Id
    * @author      Luis Merinero
    * @date        05/12/2019                     
    */
    @auraEnabled
    public static String getUserId(){
        return UserInfo.getUserId();
    }
    
	/**
    * @description Check if User is part of AB/BI Group
    * @author      Luis Merinero
    * @date        03/03/2020                    
    */
    @auraEnabled
    public static Boolean isABBIMember(){
        List<GroupMember> memberListAB = Omni_GroupMemberSelector.getGroupMembersByUserAndGroupName(UserInfo.getUserId(), 'AB_Agent');
        List<GroupMember> memberListBI = Omni_GroupMemberSelector.getGroupMembersByUserAndGroupName(UserInfo.getUserId(), 'BI_Agent');
        if(memberListAB.isEmpty() && memberListBI.isEmpty()){
            return false;
        }
        return true;
    }
    
	/**
    * @description Get Blank Template Id
    * @author      Luis Merinero
    * @date        03/03/2020                    
    */
    @auraEnabled
    public static String getBlankTemplate(){
        List<EmailTemplate> blankTemplate = Omni_EmailTemplateSelector.getBlankEmailTemplate();
        return blankTemplate[0].Id;
    }
    
}