/**
* @author      Lovish Tayal
* @date        22-Nov-2019 
* @description This class is a mock class for ReportAttachmentController_Test
* <p>                                                                        
* 25-Nov-2019  - Lovish Tayal - creation and inital commit                        
*/

@isTest
global with sharing class ReportAttachmentControllerMockGenerator implements HttpCalloutMock {
    protected Integer code; 
    protected String  status;
    protected boolean success; 
    protected String  responseBody;
    
    public ReportAttachmentControllerMockGenerator(Integer code, String status, boolean success, String responseBody) {
        this.code           = code;
        this.status         = status;
        this.success        = success; 
        this.responseBody   = responseBody; 
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        if(code == 0){
            throw new CalloutException('Critial error');
        }else{ 
            resp.setStatusCode(this.code);
            resp.setStatus(this.status);
            resp.setBody(this.responseBody);
            return resp; 
        }
    }  
}