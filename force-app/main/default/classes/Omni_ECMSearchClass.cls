public class Omni_ECMSearchClass {
    public static Application_Log__c integrationLog;
    public static Document[] invoke (String claimNumber, String claimSubType, Boolean includeArchive) {
        ServiceResponse serviceResponse = new ServiceResponse();
        String requestDetails;
        String responseDetails;
        
        try {
			//Obtain oAuth Token
            Ecm_Composition__c ecm = Ecm_Composition__c.getOrgDefaults();
            String access_token = getToken(ecm);
            
            HttpRequest req = new HttpRequest();
			req.setEndpoint(ecm.Endpoint__c + 'v1/searchDocument');
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setHeader('Content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');
            
            String transactionId = Omni_Utils.NewGuid();
            ServiceRequest serviceRequest = makeRequest(claimNumber, claimSubType, transactionId, includeArchive);
            String body = JSON.serialize(serviceRequest, true);
            req.setBody(body);
            
            Http http = new Http();
            HttpResponse httpResponse = http.send(req);
            
            integrationLog = ApplicationLogHandler.saveOutboundIntegrationLog('ECM Search Request', req, httpResponse, transactionId);

            requestDetails = body;
            responseDetails = httpResponse.getBody();
            serviceResponse = (ServiceResponse)JSON.deserialize(httpResponse.getBody(), ServiceResponse.class);
        }  catch (exception e) {
            if(integrationLog != null){
          		ApplicationLogHandler.saveExceptionLog('ECM Search Request Exception', e, integrationLog.Id);
            }else{
                ApplicationLogHandler.saveExceptionLog('ECM Search Request Exception', e, null);
            }
        }
        if(serviceResponse.documents != null){
        	return serviceResponse.documents;
        }else{
            return null;
        }
    }
    
    private static ServiceRequest makeRequest(String claimNumber, String claimSubType, String transactionId, Boolean includeArchive) {
        ServiceRequest serviceRequest = new ServiceRequest();
        
        serviceRequest.claimNumber = claimNumber;
        serviceRequest.claimSubType = claimSubType;
        serviceRequest.ecmDiscriminator = 'CLM';
        serviceRequest.requestor = 'SLFC';
        serviceRequest.trackingNumber = transactionId;
        serviceRequest.includeArchive = includeArchive;
        
        return serviceRequest;
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
		public String claimNumber;
        public String claimSubType;
        public String ecmDiscriminator;
        public String requestor;
        public String trackingNumber;
        public Boolean includeArchive;
    }
    
    public class ServiceResponse {
        public Document[] documents;
    }
    
    public class Document{
        public String adjusterId;
        public String claimNumber;
        public String claimSubType;
        public String claimantName;
        public String CMPID;
        public String CMPURL;
        public String communicationType;
        public String confidentiality;
        public String dateofLoss;
        public String documentClass;
        public String documentStatus;
        public String documentTitle;
        public String fileSize;
        public String insuredName;
        public String messageID;
        public String mimeType;
        public String policyNumber;
        public String referenceNumber;
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