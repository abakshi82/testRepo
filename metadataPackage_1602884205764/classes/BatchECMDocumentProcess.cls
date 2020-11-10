/**
* @description Batch Class to process ECM Documents. It will pick up the File_Metadata__c and send it to Handler
* @author      Vikas Sharma
* @date        15/01/2020                     
*/

global class BatchECMDocumentProcess implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public static String SF_RETRY_EXCEPTIONS = System.Label.eCM_Ingest_Retry_Status;
    
    private String query;
    public static Application_Log__c integrationLog;
    public static String error {get; private set;}
    public  boolean isMockTest = false;
    List<String> listOfSFIds = new List<String>();
    
    global BatchECMDocumentProcess(){}
    global BatchECMDocumentProcess(Boolean isQA, List<String> listOfSFIds)
    {
        this.isMockTest = isQA;
        this.listOfSFIds = listOfSFIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Adjuster_Id__c, LanId__c, Exposure_Number__c,  Document_Status__c, Date_received__c, Communication_Type__c, MessageId__c, File_Mime_Type__c, \n' + 
            ' File_Size__c, Document_Title__c, Reference_Id__c, Unique_Id__c, Claimant_Name__c, \n ' + 
            ' Case__c, Claim_Number__c, Claim_Reported_Date__c, Date_of_Loss__c, \n' + 
            'Claim_Sub_Type__c, Insure_Name__c, Line_of_Business__c, Policy_Number__c, \n' +
            'Province__c, Region_Code__c, Sender_Email__c, Under_Writing_Company__c \n' + 
            ' FROM File_Metadata__c WHERE Sent_to_Handler__c = false AND Claim_Number__c != null';
        if (isMockTest)
        {
            query = 'SELECT Id, Adjuster_Id__c, LanId__c, Exposure_Number__c,  Document_Status__c, Date_received__c, Communication_Type__c, MessageId__c, File_Mime_Type__c, \n' + 
                ' File_Size__c, Document_Title__c, Reference_Id__c, Unique_Id__c, Claimant_Name__c, \n ' + 
                ' Case__c, Claim_Number__c, Claim_Reported_Date__c, Date_of_Loss__c, \n' + 
                'Claim_Sub_Type__c, Insure_Name__c, Line_of_Business__c, Policy_Number__c, \n' +
                'Province__c, Region_Code__c, Sender_Email__c, Under_Writing_Company__c \n' + 
                ' FROM File_Metadata__c WHERE Name in: listOfSFIds';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<File_Metadata__c> scope){
        
        Map<Id, File_Metadata__c> fileMetaData = new Map<Id, File_Metadata__c>();
        List<ToSerializeResponse>  toSerializeObject = new List<ToSerializeResponse> (); // Response to be serialized
        ParentToSend toSend = new ParentToSend(); // Parent Serialize object which holds the list of ToSerializeResponse
        String trackingNumber = Omni_Utils.NewGuid();
        integer MAX_SIZE = Integer.valueOf(Omni_ECMProcessedPETriggerHandlerHelper.ECM_CONFIG_BY_NAME.get('BatchSize_EcmIngest'));
        integer counter = 1;
        List<HttpResponse> responses = new List<HttpResponse>();
		Ecm_Ingest__c ecm = Ecm_Ingest__c.getOrgDefaults();
		String access_token = '';

        try {
            if(scope.size() > 0){
				//Obtain oAuth Token
        		access_token = getToken(ecm); 
            }
            for (File_Metadata__c  fMeta : scope) {
                fileMetaData.put(fMeta.Id, fMeta);
                String dateOfLoss = null;
                if(fMeta.Date_of_Loss__c != null) dateOfLoss = fMeta.Date_of_Loss__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS-00:00');
                String claimReportedDate = null;
                if(fMeta.Claim_Reported_Date__c != null) claimReportedDate = fMeta.Claim_Reported_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS-00:00');
                String dateReceived = null;
                if(fMeta.Date_received__c != null) dateReceived = fMeta.Date_received__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS-00:00');
                toSerializeObject.add(
                    new ToSerializeResponse(
                        'CLM', 'CLM_ClaimRecord', fMeta.Claim_Number__c,
                        fMeta.Policy_Number__c, '', fMeta.Claimant_Name__c,
                        fMeta.Adjuster_Id__c, fMeta.Insure_Name__c, dateOfLoss,
                        fMeta.Claim_Sub_Type__c, claimReportedDate, dateReceived,
                        fMeta.Document_Status__c, fMeta.Line_of_Business__c, '6',
                        fMeta.Document_Title__c, '' + fMeta.Region_Code__c, Label.Omni_Generic_From_Address,
                        fMeta.Sender_Email__c, fMeta.File_Mime_Type__c, ''+ Integer.valueOf(fMeta.File_Size__c),
                        fMeta.Exposure_Number__c, fMeta.MessageId__c, fMeta.Reference_Id__c, fMeta.LanId__c
                    )
                );
                if (counter < MAX_SIZE) {                    
                    counter++;
                } else {
                    toSend = new ParentToSend();
                    trackingNumber = Omni_Utils.NewGuid();
                    toSend.addDocument(toSerializeObject,trackingNumber);
                    String parentObject = JSON.serialize(toSend,true); 
                    responses.add(processRequest(parentObject, trackingNumber, ecm, access_token));
                    counter = 1;
                    toSerializeObject = new List<ToSerializeResponse>();
                }
            }
            
            if(counter > 1) {
                toSend = new ParentToSend();
                trackingNumber = Omni_Utils.NewGuid();
                toSend.addDocument(toSerializeObject,trackingNumber);
                String parentObject = JSON.serialize(toSend,true); 
                responses.add(processRequest(parentObject, trackingNumber, ecm, access_token));   
            }

            processResponses(responses);

        } catch(Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            ApplicationLogHandler.addExceptionLog('ECM Create Batch Request Exception', e, null);
        } finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    }

    /**
    * @description generate request then send request to service
    * @author      Kejia Hu
    * @date        09/03/2020                    
    */
    private static  HttpResponse processRequest(String body, String trackingNumber, Ecm_Ingest__c ecm, String access_token) {         
        
        //Send ECM Ingest Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ecm.Endpoint__c + 'v1/ingestDocument');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + access_token);
        
        req.setBody(body);
        Http http = new Http();
        HttpResponse httpResponse = http.send(req);
        ApplicationLogHandler.addOutboundIntegrationLog('ECM Create Batch Request', req, httpResponse, trackingNumber);
        return httpResponse; 
    }

    /**
    * @description process responses
    * @author      Kejia Hu
    * @date        09/03/2020                    
    */
    private void processResponses(List<HttpResponse> responses) {
        List<File_Metadata__c> fileMetadataToUpdate = new List<File_Metadata__c>();
        for (HttpResponse resp : responses) {
            if (resp.getStatusCode() == 200) {     
            	JSONResponse jsonResponse =  (JSONResponse)JSON.deserialize(resp.getBody(), JSONResponse.Class);
            	fileMetadataToUpdate.addAll(updateFileMetadataFlag(jsonResponse));           
        	}
        }
        if(fileMetadataToUpdate.size() > 0) Update fileMetadataToUpdate;
    }
    
    global void finish(Database.BatchableContext bc){

    }
    
    // Update Handler Processed flag
    public static List<File_Metadata__c> updateFileMetadataFlag(JSONResponse responseFromService){
        List<File_Metadata__c> fileMetadataToUpdate = new List<File_Metadata__c>();
        List<String> uniqueIds = new List<String>();
        Map<String, String> uniqueIdsFailed = new Map<String, String>();
        
        for (Document document : responseFromService.documents)
        {
            String uniqueId = document.messageId + '-' + document.referenceNumber;
            uniqueIds.add(uniqueId);
            if (document.documentProcessingResult  != 'PASSED'){
                uniqueIdsFailed.put(uniqueId, document.documentProcessingStatus);
            }
        }
        for(File_Metadata__c fileMetadata : [SELECT Id, Sent_to_Handler__c, Unique_Id__c, Reference_Id__c from File_Metadata__c
                                               Where Unique_Id__c in: uniqueIds])
        {
            fileMetadata.Sent_to_Handler__c = true;
            String failedDocumentStatus = uniqueIdsFailed.get(fileMetadata.Unique_Id__c);
            if(failedDocumentStatus != null && !SF_RETRY_EXCEPTIONS.contains(failedDocumentStatus))
            {
                fileMetadata.Handler_ECM_Failure__c = true;
                fileMetadata.Document_Processing_Status__c = failedDocumentStatus;
            }else{
				fileMetadata.Document_Processing_Status__c = 'Processed by Handler';
            }
            fileMetadataToUpdate.add(fileMetadata);
        }
        return fileMetadataToUpdate;
    }
    
    //Obtain Access Token
    Private Static String getToken(Ecm_Ingest__c ecm){
        String tokenRequestBody = 'grant_type=client_credentials&client_id=' + ecm.Oauth_ClientId__c + '&client_secret=' + ecm.Oauth_Secret__c + '&scope=' + ecm.Oauth_Scope__c;
        
        HttpRequest accessTokenReq = new HttpRequest();
        accessTokenReq.setEndpoint(ecm.Oauth_Token_Url__c);
        accessTokenReq.setMethod('POST');
        accessTokenReq.setBody(tokenRequestBody);
        
        Http accessTokenHttp = new Http();
        HTTPResponse accessTokenResponse = accessTokenHttp.send(accessTokenReq);
        token_oauth tokenResponse =  (token_oauth)JSON.deserialize(accessTokenResponse.getBody(), token_oauth.Class);
        return tokenResponse.access_token; 
    }
    
    // Parent class to generate the JSON request
    Class ParentToSend
    {
        List<ToSerializeResponse> documents = new List<ToSerializeResponse>();
        String trackingNumber; 
        String requestor;
        public void addDocument (List<ToSerializeResponse> toAdd, String trackingNumber)
        {
            documents = toAdd;
            this.trackingNumber = trackingNumber;
            this.requestor = 'SLFC';
        }
        
    }
    // Class to parse for JSON response
    
    class ToSerializeResponse
    {
        String ecmDiscriminator = 'CLM';
        String itemTypeDiscriminator = 'CLM_ClaimRecord';
        String claimNumber = '';
        String policyNumber = '';
        String documentContent = '';
        String claimantName ='';
        String adjusterId = '';
        String insuredName = '';
        String dateOfLoss = '';
        String claimSubType = '';
        String claimReportedDate = '';
        String dateReceived = '';
        String documentStatus = 'ASG';
        String lineOfBusiness = '';
        String communicationType = '6';
        String documentTitle = '';
        String claimDocumentRegion = '';
        String inboundEmailAddress = '';
        String senderEmail = '';
        String fileTypeExtension = '';
        String fileSizeBytes = '';
        String exposureNumber = '';
        String messageId = '';
        String referenceNumber = '';
        String workpackageOwner = '';
        
        // Default Constructor		
        public ToSerializeResponse(){}
        
        public ToSerializeResponse( String ecmDiscriminator,
                                   String itemTypeDiscriminator,
                                   String claimNumber,
                                   String policyNumber,
                                   String documentContent,
                                   String claimantName,
                                   String adjusterId,
                                   String insuredName,
                                   String dateOfLoss,
                                   String claimSubType,
                                   String claimReportedDate,
                                   String dateReceived,
                                   String documentStatus,
                                   String lineOfBusiness,
                                   String communicationType,
                                   String documentTitle,
                                   String claimDocumentRegion,
                                   String inboundEmailAddress,
                                   String senderEmail,
                                   String fileTypeExtension,
                                   String fileSizeBytes,
                                   String exposureNumber,
                                   String messageId,
                                   String referenceNumber,
                                   String workpackageOwner)
        {
            this.ecmDiscriminator = ecmDiscriminator;
            this.itemTypeDiscriminator = itemTypeDiscriminator;
            this.claimNumber = claimNumber;
            this.policyNumber = policyNumber;
            this.documentContent = documentContent;
            this.claimantName = claimantName;
            this.adjusterId = adjusterId;
            this.insuredName = insuredName ;
            this.dateOfLoss = dateOfLoss;
            this.claimSubType = claimSubType;
            this.claimReportedDate = claimReportedDate;
            this.dateReceived = dateReceived;
            this.documentStatus = documentStatus;
            this.lineOfBusiness = lineOfBusiness;
            this.communicationType = communicationType;
            this.documentTitle = documentTitle;
            this.claimDocumentRegion = claimDocumentRegion;
            this.inboundEmailAddress = inboundEmailAddress;
            this.senderEmail = senderEmail;
            this.fileTypeExtension = fileTypeExtension;
            this.fileSizeBytes = fileSizeBytes;
            this.exposureNumber = exposureNumber;
            this.messageId = messageId;
            this.referenceNumber = referenceNumber;
            this.workpackageOwner = workpackageOwner;
        }
    }
    
    public class JSONResponse
    {
        public String trackingNumber;
        public Document[] documents;
    }
    
    public class Document
    {
        public string documentProcessingResult;
        public string referenceNumber;
        public string documentProcessingStatus;
        public string messageId;
    }
    
	public class token_oauth
    {
        public string access_token;
        public string scope;
        public string token_type;
        public Integer expires_in;
    }
    
    public class BatchECMDocumentProcessException extends Exception {}	
}