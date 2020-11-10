public without sharing class Omni_ECMRetrieveClass {
    public static String error {get; private set;}
    public static Application_Log__c integrationLog;
    
    public static String invoke(String cmpid, String cmpUrl) {
        ServiceResponse serviceResponse = new ServiceResponse();
        String contentVersionId;
        
        try {
			//Obtain oAuth Token
            Ecm_Composition__c ecm = Ecm_Composition__c.getOrgDefaults();
            String access_token = getToken(ecm);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ecm.Endpoint__c + 'v1/retrieveDocument');
            req.setMethod('POST');
            req.setTimeout(120000);
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');	
            req.setHeader('Authorization', 'Bearer ' + access_token);
            
            String transactionId = Omni_Utils.NewGuid();
            ServiceRequest serviceRequest = makeRequest(cmpUrl, transactionId);
            String body = JSON.serialize(serviceRequest, true);
            req.setBody(body);
            
            Http http = new Http();
            HttpResponse httpResponse = http.send(req);
            
            integrationLog = ApplicationLogHandler.saveOutboundIntegrationLog('ECM Retrieve Request', req, httpResponse, transactionId);
            
            serviceResponse = (ServiceResponse)JSON.deserialize(httpResponse.getBody(), ServiceResponse.class);
            contentVersionId = serviceResponse.slfId;
            ContentVersion versionRecord = Omni_ContentVersionSelector.getContentDocumentIdFromContentVersionId(contentVersionId);
            if(versionRecord.Id != null){
                ContentDocumentLink cdLink = new ContentDocumentLink(ContentDocumentId = versionRecord.ContentDocumentId, LinkedEntityId = UserInfo.getUserId());
                Database.insert(cdLink, false);
                upsertMetadata(versionRecord.Id, cmpid);
                return versionRecord.ContentDocumentId;
           	}else{
                error = 'ContentDocumentId not found. ContentVersionId provided: ' + contentVersionId;
                throw new Omni_ECMSearchClassException(error);
            }
        }  catch (exception e) {
			if(integrationLog != null){
          		ApplicationLogHandler.saveExceptionLog('ECM Retrieve Request Exception', e, integrationLog.Id);
            }else{
                ApplicationLogHandler.saveExceptionLog('ECM Retrieve Request Exception', e, null);
            }
        }
        return null;
    }
    
    private static ServiceRequest makeRequest(String cmpUrl, String transactionId) {
        ServiceRequest serviceRequest = new ServiceRequest();
        
        serviceRequest.cmpUrl = cmpUrl;
        serviceRequest.ecmDiscriminator = 'CLM';
        serviceRequest.trackingNumber = transactionId;
        serviceRequest.requestor = 'SLFC';

        return serviceRequest;
    }
    
    public static void upsertMetadata(Id versionId, String cmpid){
        update new ContentVersion(id = versionId, CmpId__c = cmpid);
        
		File_Metadata__c[] fileMetadata = [SELECT id, File_Mime_Type__c, File_Size__c, Document_Title__c
                                         FROM File_Metadata__c WHERE Reference_Id__c = :versionId LIMIT 1];
        
        if(fileMetadata.size()>0){
            fileMetadata[0].Processed_by_ECM__c = true; 
            fileMetadata[0].Sent_to_Handler__c = true;
            fileMetadata[0].File_Deleted__c = false;
            fileMetadata[0].Count__c = 1;
            
            Update fileMetadata[0];
            
            insert new ECM_Metadata__c(CMP_Id__c = cmpid,
                                       File_Metadata__c = fileMetadata[0].Id, 
                                       ECM_File_Mime_Type__c = fileMetadata[0].File_Mime_Type__c,
                                       ECM_File_Size__c	= String.valueOf(fileMetadata[0].File_Size__c),
                                       ECM__c = fileMetadata[0].Document_Title__c);
        }
    }
	
    //Obtain Access Token
    Private Static String getToken(Ecm_Composition__c ecm){
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
    
    public class ServiceRequest {
        public String cmpUrl;
        public String ecmDiscriminator;
        public String trackingNumber;
        public String requestor;
    }
    
    public class ServiceResponse {
        public String ecmDiscriminator;
        public String mimeType;
        public String slfId;
        public String trackingNumber;
    }
    
	public class token_oauth{
        public string access_token;
        public string scope;
        public string token_type;
        public Integer expires_in;
    }
    
    public class Omni_ECMSearchClassException extends Exception {}	
}