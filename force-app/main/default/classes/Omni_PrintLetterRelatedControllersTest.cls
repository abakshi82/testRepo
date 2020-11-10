@isTest
private class Omni_PrintLetterRelatedControllersTest {

    @isTest
    static void testPreviewEditPrintLetterController() {
        Case role = TestDataFactory.createClaimRole();
        EmailTemplate emailTemp = [Select Id, Name, Subject, Body, HtmlValue from EmailTemplate LIMIT 1];
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('tempId', String.valueOf(emailTemp.Id));
        ApexPages.currentPage().getParameters().put('caseId', String.valueOf(role.Id));
        Omni_PreviewEditPrintLetterController  testController = new Omni_PreviewEditPrintLetterController();
        PageReference pageRef = testController.saveAndShowPDF();
        PageReference pageRefCase  = testController.returnToCase();
		Test.StopTest();
        System.assertEquals(true, pageRef.getUrl().contains('OMNI_ViewPrintLetterAsPDF'), 'Page need to redirect to PDF page');
    }

    @isTest
    static void testViewPrintLetterAsPDFController() {
        String htmlBody = 'test';
        Case role = TestDataFactory.createClaimRole();
        EmailMessage email = new EmailMessage();
        email.relatedToId = role.Id;
        email.headers = 'Return-Path:returnpath@intact.net\\\nReceived:Received from [1.1.1.1]\\\nMessage-ID:<message-id=0000>';
        email.htmlBody = htmlBody;
        email.subject = 'test';
        email.ToAddress = 'toaddress@intact.net';
        insert email;
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('emailId', String.valueOf(email.Id));
        Omni_ViewPrintLetterAsPDFController  testController = new Omni_ViewPrintLetterAsPDFController();
        String emailBody = testController.getBody();
		Test.StopTest();
        System.assertEquals(htmlBody, emailBody, 'Html body should be retrieved');
    }

}