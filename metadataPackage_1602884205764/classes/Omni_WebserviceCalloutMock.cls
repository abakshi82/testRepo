/**
 * @Description: Mock class for testing webservices
 * @author:      Damian Kazior, PwC
 * @Date:        2019-08-24
 */
@isTest
global with sharing class Omni_WebserviceCalloutMock implements HttpCalloutMock {
    
    protected Integer code; 
    protected String  status;
    protected boolean success; 
    protected String  responseBody;

    public Omni_WebserviceCalloutMock(Integer code, String status, boolean success, String responseBody) {
        this.code           = code;
        this.status         = status;
        this.success        = success; 
        this.responseBody   = responseBody; 
    }

    public HTTPResponse respond(HTTPRequest req) {
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