/**
* @author      Lovish Tayal
* @date        22-Nov-2019 
* @description This class is a test class for ReportAttachmentController
* <p>                                                                        
* 25-Nov-2019  - Lovish Tayal - creation and inital commit                        
*/
@isTest
public class ReportAttachmentController_Test {  
    public static  final String RESPONSEBODY  = '{"reportMetadata":{"name":"2TestReport1bSupport","reportFormat": "SUMMARY","reportType":{"type":"Opportunity"}}}'; 
    public static  final String EMAIL = 'tayallovish1@gmail.com';
   
    @isTest 
    static void ReportAttachmentControllertestCalloutPositive() {
        String reportId;
        // Set mock callout class
        System.Test.setMock(HttpCalloutMock.class, new ReportAttachmentControllerMockGenerator(200, 'Success', true, RESPONSEBODY));         
        System.Test.startTest();
        HttpResponse res = ReportAttachmentController.ReportAttachmentCallout(EMAIL, 'TestID123');   
        System.Test.stopTest();
        String contentType = res.getHeader('Content-Type');        
        String actualValue = res.getBody();
        String expectedValue = RESPONSEBODY;
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());       
    }
    
    @isTest 
    static void ReportAttachmentControllertestCalloutNegative() {
        String reportId;
        // Set mock callout class
        System.Test.setMock(HttpCalloutMock.class, new ReportAttachmentControllerMockGenerator(401, 'Fail', true, RESPONSEBODY));                
        System.Test.startTest();
        HttpResponse res = ReportAttachmentController.ReportAttachmentCallout(EMAIL, 'TestID123');   
        System.Test.stopTest();
        String contentType = res.getHeader('Content-Type');        
        System.assertNotEquals('Critial error', res.getBody());
        System.assertEquals(401, res.getStatusCode());  
        Integer x =  [SELECT Count() from Application_Log__c where Exception_Type__c = 'ReportAttachmentController.ExportReportException'];
        System.assertEquals(1,x);  
    }    
}