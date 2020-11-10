@isTest
private class ApplicationLogHandlerTest {

    @isTest
    static void logException(){
        System.assertequals(true, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Exception'].isEmpty(),'No Logs should existe');
        Test.startTest();
        performDMLExceptionLogging();
        Test.stopTest();
        List<Application_Log__c> newlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Exception'];
        System.assertequals(1, newlogs.size(), 'One log should be created');
        System.assertequals('Exception', newlogs[0].Category__c, 'Log category should be Exception');
        System.assertequals('Failure', newlogs[0].Status__c, 'Log status should be Failure');
    }

    @isTest
    static void logSuccessOutboundCallout(){
        System.assertequals(true, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].isEmpty(), 'No logs should existe');
        Test.startTest();
        performSuccessCalloutLogging();
        Test.stopTest();
        List<Application_Log__c> newlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Integration'];
        System.assertequals(1, newlogs.size(), 'One log should be created');
        System.assertequals('Integration', newlogs[0].Category__c, 'Log category should be Integration');
        System.assertequals('Success', newlogs[0].Status__c, 'Log status should be Success');
    }

    @isTest
    static void logInboundCallout(){
        System.assertequals(true, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].isEmpty(), 'No logs should existe');
        Test.startTest();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setBody('{"Name" : "TestAccount"}');
        HttpResponse httpRes = new HttpResponse();
        httpRes.setBody('{"Id" : "012345"}');
        httpRes.setStatusCode(200);
        ApplicationLogHandler.saveInboundIntegrationLog('Inbound Test', httpReq , httpRes, 'External Source 1', UserInfo.getOrganizationId()+'-'+ System.now().getTime());
        Test.stopTest();
        List<Application_Log__c> newlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Integration' AND Integration_Type__c = 'Inbound'];
        System.assertequals(1, newlogs.size(), 'One log should be created');
        System.assertequals('Integration', newlogs[0].Category__c, 'Log category should be Integration');
        System.assertequals('Success', newlogs[0].Status__c, 'Log status should be Success');
    }

     @isTest
    static void addInboundCallout(){
        System.assertequals(true, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].isEmpty(), 'No logs should existe');
        Test.startTest();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setBody('{"Name" : "TestAccount"}');
        HttpResponse httpRes = new HttpResponse();
        httpRes.setBody('{"Id" : "012345"}');
        httpRes.setStatusCode(200);
        ApplicationLogHandler.addInboundIntegrationLog('Inbound Test', httpReq , httpRes, 'External Source 1', UserInfo.getOrganizationId()+'-'+ System.now().getTime());
        ApplicationLogHandler.persistApplicationLogs();
        Test.stopTest();
        List<Application_Log__c> newlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Integration' AND Integration_Type__c = 'Inbound'];
        System.assertequals(1, newlogs.size(), 'One log should be created');
        System.assertequals('Integration', newlogs[0].Category__c, 'Log category should be Integration');
        System.assertequals('Success', newlogs[0].Status__c, 'Log status should be Success');
    }

    @isTest
    static void logFailureOutboundCallout(){
        System.assertequals(true, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].isEmpty(), 'No logs should existe');
        Test.startTest();
        performFailureCalloutLogging();
        Test.stopTest();
        List<Application_Log__c> newlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Integration'];
        System.assertequals(1, newlogs.size(), 'One log should be created');
        System.assertequals('Integration', newlogs[0].Category__c, 'Log category should be Integration');
        System.assertequals('Failure', newlogs[0].Status__c, 'Log category should be Failure');
    }

    @isTest
    static void logFailureOutboundCalloutnoResponse(){
        System.assertequals(true, [SELECT Id FROM Application_Log__c WHERE Category__c = 'Integration'].isEmpty(), 'No logs should existe');
        Test.startTest();
        performFailureCalloutNoResponseLogging();
        Test.stopTest();
        List<Application_Log__c> newlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Integration'];
        System.assertequals(1, newlogs.size(), 'One log should be created');
        System.assertequals('Integration', newlogs[0].Category__c, 'Log category should be Integration');
        System.assertequals('Failure', newlogs[0].Status__c, 'Log category should be Failure');
    }

    @isTest
    static void logSuccessOutboundCalloutAndDMLException() {
        System.assertequals(true, [SELECT Id FROM Application_Log__c].isEmpty(), 'No logs should existe');
        Test.startTest();
        performCalloutAndDMLExceptionLogging();
        Test.stopTest();
        List<Application_Log__c> newIntegrationlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Integration'];
        List<Application_Log__c> newExceptionlogs = [SELECT Id, Category__c, Status__c FROM Application_Log__c WHERE Category__c = 'Exception'];
        System.assertequals(1, newIntegrationlogs.size(), 'One Integration log should be created');
        System.assertequals('Integration', newIntegrationlogs[0].Category__c, 'Log category should be Integration');
        System.assertequals('Success', newIntegrationlogs[0].Status__c, 'Log category should be Success');
        System.assertequals(1, newExceptionlogs.size(), 'One Exception log should be created');
        System.assertequals('Exception', newExceptionlogs[0].Category__c, 'Log category should be Exception');
        System.assertequals('Failure', newExceptionlogs[0].Status__c, 'Log category should be Failure');
    }

    static void performDMLExceptionLogging() {
        try{
            Account a = new Account();
            insert a;
        }catch (Exception e){ // gotta catch em all!
            ApplicationLogHandler.saveExceptionLog('DML Failure Test', e, null);
            new ApplicationLog.ExceptionData(new ApplicationLog('DML Failure Test', null, null, e, null, null, null, null));
        }
    }

    static void performSuccessCalloutLogging() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
        request.setMethod('GET');
        HttpResponse response = new HttpResponse();
        response.setBody('{"animals":["majestic badger","fluffy bunny","scary bear","chicken"]}');
        response.setStatusCode(200);
        ApplicationLogHandler.saveOutboundIntegrationLog('CalloutTest', request, response, null);
    }

    static void performFailureCalloutLogging() {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
            request.setMethod('GET');
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            ApplicationLogHandler.addOutboundIntegrationLog('CalloutTest', request, response, null);
        } catch (Exception e) { // gotta catch em all!
            ApplicationLogHandler.addExceptionLog('CalloutTest', e , null);
        } finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    }

    static void performFailureCalloutNoResponseLogging() {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
            request.setMethod('GET');
            ApplicationLogHandler.addoutboundIntegrationLog('CalloutTest', request, null, null);
        } catch (Exception e) { // gotta catch em all!
            ApplicationLogHandler.addExceptionLog('CalloutTest', e, null);
        } finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    }

    static void performCalloutAndDMLExceptionLogging(){
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
            request.setMethod('GET');
            HttpResponse response = new HttpResponse();
            response.setBody('{"animals":["majestic badger","fluffy bunny","scary bear","chicken"]}');
            response.setStatusCode(200);
            ApplicationLogHandler.addOutboundIntegrationLog('CalloutTest', request, response, null);
            Account a = new Account();
            insert a;
        } catch (Exception e) { // gotta catch em all!
            ApplicationLogHandler.addExceptionLog('CalloutTest', e, null);
        } finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    }
}