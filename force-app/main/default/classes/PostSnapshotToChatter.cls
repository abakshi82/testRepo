/**
* @author      Lovish Tayal
* @date        02-Dec-2019 
* @description This class is used to take a dashboard component snapshot and post it to chatter public group for chatter free license
* <p>                                                                        
* 05-Dec-2019  - Lovish Tayal - creation and inital commit                        
*/

global class PostSnapshotToChatter Implements  system.Schedulable, Database.AllowsCallouts { 
    global void execute(SchedulableContext sc)
        {
            postToChatter();
        }         
       
	@future(callout=true)
    public static void postToChatter(){ 
       String dashboardComp =  System.Label.Post_Dashboard_Component_Name;
        DashboardSnapshotWrapper dashboardSnapshotWrapper = new DashboardSnapshotWrapper(); 
        String dashboardComponentId = Test.isRunningTest() ? 'TestId' : [select Id from DashboardComponent where Name =: dashboardComp][0].Id;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setEndpoint(System.URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v44.0/connect/dashboards/components/' + dashboardComponentId + '/snapshots');
        req.setMethod('POST');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeObject(dashboardSnapshotWrapper);
        String dashboardResponse = gen.getAsString();   
        dashboardResponse = dashboardResponse.replace('\\"', '"');
        dashboardResponse = dashboardResponse.replace('"{', '{');
        dashboardResponse = dashboardResponse.replace('}"', '}');
        req.setBody(dashboardResponse);
        req.setCompressed(true);       
        try {
            res = http.send(req);
            if(res.getStatusCode() != 201){ 
                 throw new DashboardSnapshotException('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch(Exception e) {
            ApplicationLogHandler.addExceptionLog('TestLogForDashboardSnapshot', e , null);
        }
        finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
    } 
    public class DashboardSnapshotException extends Exception {}
    public with sharing class DashboardSnapshotWrapper {
        public String parentId = Test.isRunningTest() ? 'TestId' : [SELECT Id,Name From CollaborationGroup WHERE CollaborationType='Public' and Name='dashboardSnapshot'][0].Id;
        public String feedItemBody = '{"messageSegments" : [{"text" : "Dashboard_Snapshot","type" : "Text"}]}';
       
    } 
    
}