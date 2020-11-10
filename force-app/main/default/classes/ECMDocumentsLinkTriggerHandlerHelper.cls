/**
* @description Helper class for ECMDocumentsLinkTriggerHandler
* @author      Vikas Sharma
* @date        13/01/2020                     
*/
public without sharing  class ECMDocumentsLinkTriggerHandlerHelper {
    
    static final string EMAILMESSAGE = 'EmailMessage';    
    public static decimal fileSizeToExclude =0;
    public static String folderName = '';
    public static Map<Id, EmailMessage> emailMessageInfo = new Map<Id, EmailMessage>();
    
    /**
	* @description Process Documents received from Email and ignore others
	* 			   for now
	* @author      Vikas Sharma
	* @date        13/01/2020                     
	*/
    public static Map<Id, Set<Id>> filterNonEmailMessageDocs(Map<Id, sObject> mapOfDocumentList){
        Asset_Library__c astLib = Asset_Library__c.getInstance();

		fileSizeToExclude  = Integer.valueOf(Omni_ECMProcessedPETriggerHandlerHelper.ECM_CONFIG_BY_NAME.get('File_Size_to_Exclude'));
        
        if (astLib.Library_Name__c != ''){
        	folderName = astLib.Library_Name__c;
        }
        
        Map<Id, Set<Id>> parentIdWithDocumentId = new Map<Id, Set<Id>>(); // To Return
        Map<Id, Set<Id>> toReturn = new Map<Id, Set<Id>>();
        
        //To ignore the Attachments if its not attached with EmailMessage
        for (Id currentId : mapOfDocumentList.keySet()){
            ContentDocumentLink contentDocumentLink = (ContentDocumentLink)mapOfDocumentList.get(currentId);
            
            // Added a new condition to filter out Knowledge Articles
            if (contentDocumentLink.LinkedEntityId.getsobjecttype()+'' != 'Knowledge__kav'){           
                if (parentIdWithDocumentId.get(contentDocumentLink.LinkedEntityId) == null){
                    parentIdWithDocumentId.put(contentDocumentLink.LinkedEntityId,new Set<Id>{contentDocumentLink.ContentDocumentId});   
                }
                else{
                    parentIdWithDocumentId.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink.ContentDocumentId);
                }    
            }     
        }
        if(parentIdWithDocumentId == null || parentIdWithDocumentId.isEmpty()){
            return null;
        }else{
			toReturn = filterFolderContents(parentIdWithDocumentId);
            return toReturn;  
        }
    }
    
    public static Map<Id,Set<Id>> filterFolderContents (Map<Id, Set<Id>> parentIdWithDocumentId){

        Set<id> contentDocumetIdsSetToRemove = new Set<id>();
		Map<Id, Set<Id>> toReturn = new Map<Id, Set<Id>>();
        toReturn = parentIdWithDocumentId;
        Set<Id> toQuery = new Set<Id>();
        for (Id currentId : parentIdWithDocumentId.keySet()){
            toQuery.addAll(parentIdWithDocumentId.get(currentId));
        }
        for (ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, LinkedEntity.Name, ContentDocumentId FROM ContentDocumentLink WHERE 
                                       ContentDocumentId in: toQuery
                                       ]){
            if(String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'ContentWorkspace')
            {
                if (folderName == '' || 
                    folderName  == ''+cdl.LinkedEntity.Name 
                   ){
						contentDocumetIdsSetToRemove.add(cdl.ContentDocumentId);
                   }
            }
        }
		//New Code - Luis
		for(id entityId : toReturn.keySet()){
			for(id documentId : contentDocumetIdsSetToRemove){
				if(toReturn.get(entityId).contains(documentId)){
                    if(toReturn.get(entityId).size() == 1){
                    	toReturn.remove(entityId);
                    }else{
                        Set<id> docIds = toReturn.get(entityId);
                        docIds.remove(documentId);
                        toReturn.remove(entityId);
                        toReturn.put(entityId, docIds);
                    }
                }
			}
		}
        return toReturn;
    }
    
    /**
* @description Get the case Id associated with EmailMessages
* @author      Vikas Sharma
* @date        13/01/2020                     
*/
    public static Map<EmailMessage,Case> populateCaseForInfo(Map<Id, Set<Id>> emailMessagesMap)
    {
        Map<EmailMessage, Case> toReturnCases = new Map<EmailMessage, Case>();// To Return
        
        Map<Id, EmailMessage> emailMessages = getEmailMessages(emailMessagesMap);
        
        toReturnCases = populateCasesWithEmailIds(emailMessages);		
        return toReturnCases; 
        
    }
    
    /**
	* @description Get all the required information from Case for EmailMessages
	* 				use this to populate metadata objects for ECM
	* @author      Vikas Sharma
	* @date        13/01/2020                     
	*/
    
    private static Map<EmailMessage,Case> populateCasesWithEmailIds(Map<Id, EmailMessage> caseToEmailMessages)
    {
        Map<EmailMessage, Case> toReturn = new Map<EmailMessage, Case>();
        for (Case cs : [SELECT Id, RecordType.Name, 
							ClaimForRole__r.Claimant__r.FirstName, ClaimForRole__r.Claimant__r.LastName, ClaimForRole__r.Claimant__r.Name,
							OwnerId, Owner.Name, LanId__c, ClaimForRole__r.ClaimNumber__c, 
							ClaimForRole__r.Owner.Name,
							ClaimForRole__r.LanId__c,
							ClaimForRole__r.IncidentDateReported__c,
							Type,
							ClaimForRole__r.DateOfLoss__c,
							ClaimForRole__r.Exposure_Number_Order__c,
							ClaimForRole__r.InsuredParty__r.Name, ClaimForRole__r.InsuredParty__r.FirstName, ClaimForRole__r.InsuredParty__r.LastName,
							ClaimForRole__r.Claim_LOB__c,
							ClaimForRole__r.PolicyNumber__c, 
							ClaimForRole__r.ProvinceOfIssuanceId__c,
							ClaimForRole__r.UnderwritingCompany__c,
							ClaimForRole__r.ClaimRegion__c,
							ClaimForRole__r.Policy_Issuing_Group__c,
							ClaimForRole__r.ProvinceOfIssuance__r.Name,
							ClaimForRole__r.Policy_Issuing_Group__r.Name,
							ExposureForRole__r.Claimant__r.FirstName, ExposureForRole__r.Claimant__r.LastName, ExposureForRole__r.Claimant__r.Name,
                        	ExposureForRole__r.ReferenceNumber__c,
							Claimant__r.FirstName, Claimant__r.LastName, Claimant__r.Name,
							ClaimNumber__c,
							IncidentDateReported__c,
							DateOfLoss__c,
							Exposure_Number_Order__c,
							InsuredParty__r.Name, InsuredParty__r.FirstName, InsuredParty__r.LastName,
							Claim_LOB__c,
							PolicyNumber__c, 
							ProvinceOfIssuanceId__c,
							UnderwritingCompany__c,
                        	ClaimRegion__c,
							Policy_Issuing_Group__c,
							ProvinceOfIssuance__r.Name,
							Policy_Issuing_Group__r.Name,
                        	ReferenceNumber__c,
							
							ClaimForExposure__r.Owner.Name,
							ClaimForExposure__r.LanId__c,
							ClaimForExposure__r.ClaimNumber__c,
							ClaimForExposure__r.IncidentDateReported__c,
							
							ClaimForExposure__r.DateOfLoss__c,
							ClaimForExposure__r.Exposure_Number_Order__c,
							ClaimForExposure__r.InsuredParty__r.Name, ClaimForExposure__r.InsuredParty__r.FirstName,ClaimForExposure__r.InsuredParty__r.LastName,
							ClaimForExposure__r.Claim_LOB__c,
							ClaimForExposure__r.PolicyNumber__c, 
							ClaimForExposure__r.ProvinceOfIssuanceId__c,
							ClaimForExposure__r.UnderwritingCompany__c,
							ClaimForExposure__r.ClaimRegion__c,
							ClaimForExposure__r.Policy_Issuing_Group__c,
							ClaimForExposure__r.ProvinceOfIssuance__r.Name,
							ClaimForExposure__r.Policy_Issuing_Group__r.Name
                        
                        from Case where Id in : caseToEmailMessages.keySet()
                        AND RecordType.Name !=  'Email Case'])
        {
            EmailMessage ems = caseToEmailMessages.get(cs.Id);
            toReturn.put(ems, cs);
        }
        return toReturn;
    }
    
    private static Map<Id, EmailMessage> getEmailMessages(Map<Id, Set<Id>> emailMessages)
    {
        Map<Id, EmailMessage> toReturn = new Map<Id, EmailMessage>();
        for (EmailMessage eMessage : [SELECT Id, ParentId, FromAddress, RelatedToId,CreatedDate  FROM EmailMessage WHERE
                                      Id in: emailMessages.keyset()])
        {
           emailMessageInfo.put(eMessage.Id,eMessage);
            toReturn.put(eMessage.ParentId, eMessage);
        }
        
        return toReturn;
    }
    
    /*@description: Fetch the DocumentInfo
	*@author: Vikas Sharma	
	*@date 15/01/2020
	*/
    public static Map<Id, ContentDocument> populateDocumentInfo(Map<Id, Set<Id>> contentDocumentIdsWithEmail)
    {
        Map<Id, ContentDocument> toReturn = new Map<Id, ContentDocument>();
        List<Id> contentDocumentIds = new List<Id>();
        for (Id parentkey : contentDocumentIdsWithEmail.keyset())
        {
            for (Id contentDocumentId : contentDocumentIdsWithEmail.get(parentKey))
            {
                contentDocumentIds.add(contentDocumentId);
            }
            
        }
        for (ContentDocument cDocument: [SElECT Id, LatestPublishedVersionId,LatestPublishedVersion.FileType, LatestPublishedVersion.CmpId__c,
                                         LatestPublishedVersion.ContentSize, LatestPublishedVersion.Title, LatestPublishedVersion.FileExtension
                                         FROM ContentDocument 
                                         WHERE Id in:contentDocumentIds
                                        ])
            
        {
            toReturn.put(cDocument.Id, cDocument);
        }
       
        return toReturn;
        
    }
    
    
    /*@description: Upsert file metadata and ECM metadata based on the requirements
	*@author: Vikas Sharma	
	*@date 15/01/2020
	*/
    public static void createFileECMMetadata(Map<Id, Set<Id>> emailDocumentsToProcess,
                                             Map<EmailMessage, Case> emailtoCaseInfo, Map<Id, ContentDocument> contentDocuments, 
                                             Map<Id, Id> junctionObjectInfo){
        Map<Id, EmailMessage> toReturn = new Map<Id, EmailMessage>();
        List<File_Metadata__c> toInsert = new List<File_Metadata__c>();
        List<File_Metadata__c> toInsertOwners = new List<File_Metadata__c>();
        Map<String, ECM_Metadata__c> ECMMetadataToInsert = new Map<String, ECM_Metadata__c>();

        EmailMessage emlM = new EmailMessage();
        List<Id> contentDocumentIdsprocessed = new List<Id>(); 
        
        for (Id emailId : emailDocumentsToProcess.keySet()){ 
            String junctionId;
            junctionId = junctionObjectInfo.get(emailId);
           
            for (Id contentDocumentId : emailDocumentsToProcess.get(emailId)){
                File_Metadata__c toInsertMetadata = new File_MetaData__c ();
                toInsertMetaData.Communication_Type__c = 'Email';
                toInsertMetaData.Document_Status__c  = 'ASG';
                
                if (emailMessageInfo != null){
                    emlM = emailMessageInfo.get(emailId);
                }
                if (emlM != null){
                    toInsertMetaData.Date_received__c = emlM.CreatedDate;
                    toInsertMetaData.MessageId__c = emlM.Id;
                    toInsertMetaData.Sender_Email__c  = emlM.FromAddress;
                }
                
                ContentDocument currentDoc = contentDocuments.get(contentDocumentId);
                if (junctionId != null && junctionId != ''){
                    toInsertMetaData.Meta_Junction__c  = junctionId;
                }
                toInsertMetaData.File_Mime_Type__c = currentDoc.LatestPublishedVersion.FileExtension;
                toInsertMetaData.Unique_Id__c = emailId + '-' + currentDoc.LatestPublishedVersionId;
                if (fileSizeToExclude != 0 && currentDoc.LatestPublishedVersion.ContentSize <= fileSizeToExclude && String.ValueOf(emailId.getSobjectType()) == 'EmailMessage'){
                    toInsertMetaData.Sent_to_Handler__c = true;
                    toInsertMetaData.Processed_by_ECM__c = true;
                    toInsertMetaData.Count__c = 1;
                    ECMMetadataToInsert.put(toInsertMetaData.Unique_Id__c, new ECM_Metadata__c(ECM_File_Mime_Type__c = currentDoc.LatestPublishedVersion.FileExtension,
                                                                                               ECM_File_Size__c	= String.valueOf(currentDoc.LatestPublishedVersion.ContentSize),
                                                                                               ECM__c = currentDoc.LatestPublishedVersion.Title));
                }
                toInsertMetaData.File_Size__c =currentDoc.LatestPublishedVersion.ContentSize;
                toInsertMetaData.Document_Title__c = currentDoc.LatestPublishedVersion.Title;
                toInsertMetaData.Reference_Id__c = currentDoc.LatestPublishedVersionId;
                //CTCI-402
                if(currentDoc.LatestPublishedVersion.CmpId__c != null){
                    toInsertMetaData.Sent_To_Handler__c = true;
                    toInsertMetaData.Processed_By_ECM__c = true;
                    toInsertMetaData.Count__c = 1;
                    ECMMetadataToInsert.put(toInsertMetaData.Unique_Id__c, new ECM_Metadata__c(CMP_Id__c = currentDoc.LatestPublishedVersion.CmpId__c,
                                                                                               ECM_File_Mime_Type__c = currentDoc.LatestPublishedVersion.FileExtension,
                                                                                               ECM_File_Size__c	= String.valueOf(currentDoc.LatestPublishedVersion.ContentSize),
                                                                                               ECM__c = currentDoc.LatestPublishedVersion.Title));
                }
                //CTCI-402 END
                for (EmailMessage emlMessage : emailtoCaseInfo.keySet()){
                    if (emlMessage.id == emailId){
                        Case currentCase = emailToCaseInfo.get(emlMessage);
                        String claimSubType = '';
                        if (currentCase.RecordType.Name == 'Bodily Injury' ){
                            claimSubType = 'BI';
                        }
                        else{
                            if (currentCase.RecordType.Name == 'Benefits - Medical/Disability' ){
                                claimSubType = 'AB';
                            }
                            else{
                                claimSubType = 'GENERAL';
                            }
                        }
                        if (currentCase.RecordType.Name == 'Exposure Role' ||
                            currentCase.RecordType.Name == 'Claim Role' ||
                            currentCase.RecordType.Name == 'Shadow Role'){
								String caseOwner = currentCase.Owner.Name;
                                if(currentCase.Owner.Name == null){
                                    caseOwner = 'Not Provided';
                                }else{
                                    if(currentCase.Owner.Name.length() > 32){
                                        caseOwner=currentCase.Owner.Name.substring(0,32);
                                    }
                                }
                                toInsertMetaData.Adjuster_Id__c = caseOwner;
                                if(currentCase.LanId__c != null){
                                    toInsertMetaData.LanId__c = currentCase.LanId__c;
                                }
                                toInsertMetaData.Case__c = currentCase.Id;
                                toInsertMetaData.Claimant_Name__c = (null!=currentCase.ExposureForRole__r.Claimant__r.LastName) 
                                    ? currentCase.ExposureForRole__r.Claimant__r.FirstName + ' ' + currentCase.ExposureForRole__r.Claimant__r.LastName
                                    : currentCase.ExposureForRole__r.Claimant__r.Name;
                                toInsertMetaData.Claim_Number__c = currentCase.ClaimForRole__r.ClaimNumber__c;
                                toInsertMetaData.Claim_Reported_Date__c = currentCase.ClaimForRole__r.IncidentDateReported__c;
                                toInsertMetaData.Claim_Sub_Type__c = claimSubType;//currentCase.RecordType.Name;
                                toInsertMetaData.Date_of_Loss__c = currentCase.ClaimForRole__r.DateOfLoss__c;
                                toInsertMetaData.Insure_Name__c = (null!=currentCase.ClaimForRole__r.InsuredParty__r.LastName) 
                                    ? currentCase.ClaimForRole__r.InsuredParty__r.FirstName + ' ' + currentCase.ClaimForRole__r.InsuredParty__r.LastName
                                    : currentCase.ClaimForRole__r.InsuredParty__r.Name;
                                toInsertMetaData.Line_of_Business__c = currentCase.ClaimForRole__r.Claim_LOB__c;
                                toInsertMetaData.Policy_Number__c = currentCase.ClaimForRole__r.PolicyNumber__c;
                                toInsertMetaData.Province__c = currentCase.ClaimForRole__r.ProvinceOfIssuance__r.Name;
                                toInsertMetaData.Region_Code__c = currentCase.ClaimForRole__r.ClaimRegion__c;
                                toInsertMetaData.Under_Writing_Company__c = currentCase.ClaimForRole__r.Policy_Issuing_Group__r.Name;
                                toInsertMetaData.Exposure_Number__c = (null!=currentCase.ExposureForRole__c) 
                                    									? currentCase.ExposureForRole__r.ReferenceNumber__c
                                    									: currentCase.ClaimForRole__r.Exposure_Number_Order__c;
                            }
                        
                        if (currentCase.RecordType.Name == 'Claim' ){
							String caseOwner = currentCase.Owner.Name;
                            if(currentCase.Owner.Name == null){
                                caseOwner = 'Not Provided';
                            }else{
                                if(currentCase.Owner.Name.length() > 32){
                                    caseOwner=currentCase.Owner.Name.substring(0,32);
                                }
                            }
                            toInsertMetaData.Adjuster_Id__c = caseOwner;
                            if(currentCase.LanId__c != null){
								toInsertMetaData.LanId__c = currentCase.LanId__c;
                            }
                            toInsertMetaData.Case__c = currentCase.Id;
                            toInsertMetaData.Claimant_Name__c = (null!=currentCase.Claimant__r.LastName) 
                                ? currentCase.Claimant__r.FirstName + ' ' + currentCase.Claimant__r.LastName
                                : currentCase.Claimant__r.Name;
                            toInsertMetaData.Claim_Number__c = currentCase.ClaimNumber__c;
                            toInsertMetaData.Claim_Reported_Date__c = currentCase.IncidentDateReported__c;
                            toInsertMetaData.Claim_Sub_Type__c = claimSubType;
                            toInsertMetaData.Date_of_Loss__c = currentCase.DateOfLoss__c;							
                            toInsertMetaData.Insure_Name__c = (null!=currentCase.InsuredParty__r.LastName) 
                                ? currentCase.InsuredParty__r.FirstName + ' ' + currentCase.InsuredParty__r.LastName
                                : currentCase.InsuredParty__r.Name;
                            toInsertMetaData.Line_of_Business__c = currentCase.Claim_LOB__c;
                            toInsertMetaData.Policy_Number__c = currentCase.PolicyNumber__c;
                            toInsertMetaData.Province__c = currentCase.ProvinceOfIssuance__r.Name;
                            toInsertMetaData.Region_Code__c = currentCase.ClaimRegion__c;
                            toInsertMetaData.Under_Writing_Company__c = currentCase.Policy_Issuing_Group__r.Name;
                            toInsertMetaData.Exposure_Number__c = currentCase.Exposure_Number_Order__c;
                        }
                        
                        
                        if (currentCase.RecordType.Name == 'Other Exposure' ||
                            currentCase.RecordType.Name == 'Benefits - Medical/Disability' ||	
                            currentCase.RecordType.Name == 'Bodily Injury'){
                                String caseOwner = currentCase.Owner.Name;
                                if(currentCase.Owner.Name == null){
                                    caseOwner = 'Not Provided';
                                }else{
                                    if(currentCase.Owner.Name.length() > 32){
                                        caseOwner=currentCase.Owner.Name.substring(0,32);
                                    }
                                }
                                toInsertMetaData.Adjuster_Id__c = caseOwner;
                                if(currentCase.LanId__c != null){
                                    toInsertMetaData.LanId__c = currentCase.LanId__c;
                                }
                                toInsertMetaData.Case__c = currentCase.Id;
                                toInsertMetaData.Claimant_Name__c = (null!=currentCase.Claimant__r.LastName) 
                                    ? currentCase.Claimant__r.FirstName + ' ' + currentCase.Claimant__r.LastName
                                    : currentCase.Claimant__r.Name;
                                toInsertMetaData.Claim_Number__c = currentCase.ClaimForExposure__r.ClaimNumber__c;
                                toInsertMetaData.Claim_Reported_Date__c = currentCase.ClaimForExposure__r.IncidentDateReported__c;
                                toInsertMetaData.Claim_Sub_Type__c = claimSubType;
                                toInsertMetaData.Date_of_Loss__c = currentCase.ClaimForExposure__r.DateOfLoss__c;
                                
                                toInsertMetaData.Insure_Name__c = (null!=currentCase.ClaimForExposure__r.InsuredParty__r.LastName) 
                                    ? currentCase.ClaimForExposure__r.InsuredParty__r.FirstName + ' ' + currentCase.ClaimForExposure__r.InsuredParty__r.LastName
                                    : currentCase.ClaimForExposure__r.InsuredParty__r.Name;
                                toInsertMetaData.Line_of_Business__c = currentCase.ClaimForExposure__r.Claim_LOB__c;
                                toInsertMetaData.Policy_Number__c = currentCase.ClaimForExposure__r.PolicyNumber__c;
                                toInsertMetaData.Province__c = currentCase.ClaimForExposure__r.ProvinceOfIssuance__r.Name;
                                toInsertMetaData.Region_Code__c = currentCase.ClaimForExposure__r.ClaimRegion__c;
                                toInsertMetaData.Under_Writing_Company__c = currentCase.ClaimForExposure__r.Policy_Issuing_Group__r.Name;
                                toInsertMetaData.Exposure_Number__c = currentCase.ReferenceNumber__c;
                            }
                    }
                }
                if (''+emailId.getSobjectType() == 'User'){
                    toInsertOwners.add(toInsertMetadata);
                }
                else
                    toInsert.add(toInsertMetadata);    
            }
        }
        insertFileMetadata(toInsert,toInsertOwners);
		//CTCI-402
        if(ECMMetadataToInsert.size() > 0){
            List<ECM_Metadata__c> ECMMetadataToInsertList = new List<ECM_Metadata__c>();
            for(File_Metadata__c fileMetadata : [SELECT id, Unique_Id__c
                                                 FROM File_Metadata__c 
                                                 WHERE Unique_Id__c IN :ECMMetadataToInsert.keySet()]){
                ECM_Metadata__c ECMMetadata = ECMMetadataToInsert.get(fileMetadata.Unique_Id__c);
                ECMMetadata.File_Metadata__c = fileMetadata.Id;
                ECMMetadataToInsertList.add(ECMMetadata);
            }
            insert ECMMetadataToInsertList;
        }
		//CTCI-402 - END
    }
    
    /*@description: Upsert file metadata and ECM metadata based on the requirements
	*@author: Vikas Sharma	
	*@date 15/01/2020
	*/
    private static void insertFileMetadata(List<File_Metadata__c> toInsert, List<File_Metadata__c> toInsertOwners)
    {
        try{
            upsert toInsert Unique_Id__c;
            updateContentVersion(toInsert);
        }
        catch(Exception e)
        {
            system.debug('Error in insertFileMetadata->' + e);
        }
        insertFileMetadataOwners(toInsertOwners);
    }
    
    private static void insertFileMetadataOwners(List<File_Metadata__c> toInsertOwners)
    {
        try{
           upsert toInsertOwners Unique_Id__c;
        }
        catch(Exception e)
        {
            system.debug('Error in insertFileMetadataOwners->' + e);
        }
    } 
    
    /*@description: Create Junction Object records
	*@author: Vikas Sharma	
	*@date 17/01/2020
	*/
    public static Map<Id, Id> insertFileJunction(Map<Id, Set<Id>> emailDocumentsToProcess)
    {
        Map<Id, Id> toReturn = new Map<Id, Id>();
        Map<Id, Id> emailToJunction = new Map<Id, Id>();
        emailToJunction = checkIfJunctionAlreadyExists(emailDocumentsToProcess);
        List<Meta_Junction__c> toInsertJunction = new List<Meta_Junction__c>();
        try
        {
            for (Id emailMessagId : emailDocumentsToProcess.keySet())
            {
                if (''+emailMessagId.getSobjectType() == 'EmailMessage'){
                    if (emailToJunction.get(emailMessagId) == null){
                        toInsertJunction.add(new Meta_Junction__c());
                    }
                }
            }
            if (toInsertJunction.size()> 0)
            {
                Database.insert(toInsertJunction);    
            }
            
            integer indx = 0;
            for (Id emlMId : emailDocumentsToProcess.keySet()){
                
                if (toInsertJunction != null && toInsertJunction.size()>0 && 
                    toInsertJunction.size() >= indx &&
                    toInsertJunction.get(indx) != null  && 
                    emlMId.getSobjectType()+'' == 'EmailMessage'
                   )
                {
                        toReturn.put(emlMId, toInsertJunction.get(indx).Id);
                        toInsertJunction.remove(indx);
                        indx++;
                    }
                else{
                    if (emailToJunction.get(emlMId) != null)
                		
                    {
                        toReturn.put(emlMId, emailToJunction.get(emlMId));
                    }
                }
            }
        }
        catch(Exception e)
        {
            system.debug('Exception while inserting fileJunction' + e.getStackTraceString());
        }
        return toReturn;
    }
    
    public static Map<Id, Id> checkIfJunctionAlreadyExists(Map<Id, Set<Id>> emailDocumentsToProcess)
    {
        Map<Id, Id> toReturn = new Map<Id, Id>();
        for (EmailMessage emlMssg : [SELECT Id, Meta_Junction__c from EmailMessage Where id in : emailDocumentsToProcess.keySet()
                                     AND Meta_Junction__c != null])
        {
            toReturn.put(emlMssg.Id, emlMssg.Meta_Junction__c);
        }
        
        for (File_Metadata__c  emlMssg : [SELECT Id, Meta_Junction__c from File_Metadata__c Where id in : emailDocumentsToProcess.keySet()
                                     AND Meta_Junction__c != null])
        {
            toReturn.put(emlMssg.Id, emlMssg.Meta_Junction__c);
        }
        return toReturn;
    }

    private static void updateContentVersion(List<File_Metadata__c> fileMetadataWithIds)
    {
        system.debug('Calling updateContentVersion' + fileMetadataWithIds);
        List<ContentVersion> toUpdateContentVersion = new List<ContentVersion>();
        try{
            
            for (File_Metadata__c fmd : fileMetadataWithIds){
                toUpdateContentVersion.add(new ContentVersion(Id  = fmd.Reference_Id__c,
                                                              File_Metadata__c = fmd.Id));
            }
            Database.update(toUpdateContentVersion);
        }
        catch(Exception e){
            system.debug('Error while saving Content Version-->' + e.getStackTraceString());
        }
    }

    public static void updateEmailMessage(Map<Id, Id> junctionObjectInfo){
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        try{
            if (junctionObjectInfo == null)
                return;
            for (Id emlId : junctionObjectInfo.keySet()){
                if (junctionObjectInfo  != null && junctionObjectInfo.get(emlId) != null && emlId.getsobjecttype()+'' == 'EmailMessage'){
                    emailMessages.add(new EmailMessage (Id = emlId, Meta_Junction__c = junctionObjectInfo.get(emlId)));
                }
            }
            if (emailMessages.size()>0)
                Database.update(emailMessages);
        }
        catch(Exception e){
            system.debug('Error while saving Email Message-->' + e.getStackTraceString());
        }
    }
}