/**
* @author      Lovish Tayal
* @date        20-Nov-2019 
* @description This class is used to fetch a specific report using report Api and download that report in formatted way for client
It is linked with known issue https://success.salesforce.com/issues_view?id=a1p3A000001HlU3QAK
* <p>                                                                        
* 25-Nov-2019  - Lovish Tayal - creation and inital commit                        
*/

public class ReportAttachmentController {
    
    public static HttpResponse ReportAttachmentCallout(string emailAddress, string reportId){
        Http http = new http();
        HttpRequest request = new HttpRequest();
        string sessionId = System.UserInfo.getSessionId();                
        request.setEndpoint(System.URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v47.0/analytics/reports/' + reportId);
        request.setMethod('GET');    
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        request.setHeader('Accept', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        HttpResponse response = http.send(request);
        try {
            if(response.getStatusCode() == 200){         
                // Create Email Attachment
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                String today = Date.today().format();
                efa.setFileName('Requested Report'+ today + '.xlsx');
                efa.setBody(response.getBodyAsBlob());            
                // Create email
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                semail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                semail.setSubject(Label.Chat_ExportReportEmail_Subject);
                String[] sendTo = new String[]{emailAddress};
                    semail.setToAddresses(sendTo);
                semail.setPlainTextBody(Label.Chat_ExportReportEmail_Body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            }                
            else {
                throw new ExportReportException('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } 
        }
        catch (Exception e) { 
            ApplicationLogHandler.addExceptionLog('testLogforExportareport', e , null);
        }
        finally {
            ApplicationLogHandler.persistApplicationLogs();
        }
        return response;
    }
    
    public class ExportReportException extends Exception {}
}