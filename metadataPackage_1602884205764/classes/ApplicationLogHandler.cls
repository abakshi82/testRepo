/**
* @author      Kejia Hu
* @date        2019-04-25
* @description handle logging opeartion information to Application_Log__c
* <p>                                                                        
* 2019-04-25 - Kejia Hu - creation and inital commit                        
*/
public with sharing class ApplicationLogHandler {

    private static List<Application_Log__c> logs;

    static {
        logs = new List<Application_Log__c>();
    }

    /**
    * @description clear list logs in handler
    * @author      Kejia Hu
    * @date        2019-04-25
    */
    public static void clear() {
        logs.clear(); 
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       Exception e
    * @param       String parentLogId
    * @return      Application_Log__c
    * @description generate an Application_Log__c record and add it into a Application_Log__c list
    */
    public static Application_Log__c addExceptionLog(String applicationName, Exception e, String parentLogId) {
        return addLog(applicationName, null, null, e, null, null, parentLogId, null);
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       HttpRequest request
    * @param       HttpResponse response
    * @param       String sourceSystem
    * @param       String transactionId
    * @return      Application_Log__c
    * @description generate an Inbound Integration Application_Log__c record and add it into a Application_Log__c list
    */
    public static Application_Log__c addInboundIntegrationLog(String applicationName, HttpRequest request, HttpResponse response, 
                                                                String sourceSystem, String transactionId) {
        return addLog(applicationName, request, response, null, sourceSystem, 'Inbound', null, transactionId);
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       HttpRequest request
    * @param       HttpResponse response
    * @param       String transactionId
    * @return      Application_Log__c
    * @description generate an Outbound Integration Application_Log__c record and add it into a Application_Log__c list
    */
    public static Application_Log__c addOutboundIntegrationLog(String applicationName, HttpRequest request, HttpResponse response, String transactionId) {
        return addLog(applicationName, request, response, null, null, 'Outbound', null, transactionId);
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       HttpRequest request
    * @param       HttpResponse response
    * @param       Exception e
    * @param       String parentLogId
    * @param       String transactionId
    * @return      Application_Log__c
    * @description generate an Application_Log__c record and add it into a Application_Log__c list
    */
    public static Application_Log__c addLog(String applicationName, HttpRequest request, HttpResponse response, Exception e, 
                                                String sourceSystem, String integrationType, String parentLogId, String transactionId) {
        ApplicationLog appLog = new ApplicationLog(applicationName, request, response, e, sourceSystem, integrationType, parentLogId, transactionId);
        Application_Log__c logInst = appLog.createApplicationLog(appLog);
        if(null != logInst)
            logs.add(logInst);
        return logInst;
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       Exception e
    * @return      Application_Log__c
    * @description generate and prersist an Application_Log__c record
    */
    public static Application_Log__c saveExceptionLog(String applicationName, Exception e, String parentLogId) {
        return saveLog(applicationName, null, null, e, null, null, parentLogId, null);
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       HttpRequest request
    * @param       HttpResponse response
    * @param       String sourceSystem
    * @param       String transactionId
    * @return      Application_Log__c
    * @description generate and prersist an Outbound Application_Log__c record
    */
    public static Application_Log__c saveOutboundIntegrationLog(String applicationName, HttpRequest request, HttpResponse response, String transactionId) {
        return saveLog(applicationName, request, response, null, null, 'Outbound', null, transactionId);

    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       HttpRequest request
    * @param       HttpResponse response
    * @param       String sourceSystem
    * @param       String transactionId
    * @return      Application_Log__c
    * @description generate and prersist an Inbound Application_Log__c record
    */
    public static Application_Log__c saveInboundIntegrationLog(String applicationName, HttpRequest request, HttpResponse response, 
                                                                    String sourceSystem, String transactionId) {
        return saveLog(applicationName, request, response, null, sourceSystem, 'Inbound', null, transactionId);

    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       String applicationName
    * @param       HttpRequest request
    * @param       HttpResponse response
    * @param       Exception e
    * @param       String sourceSystem
    * @param       String integrationType
    * @param       String parentLogId
    * @param       String transactionId
    * @return      Application_Log__c
    * @description generate and prersist an Application_Log__c record
    */
    public static Application_Log__c saveLog(String applicationName, HttpRequest request, HttpResponse response, Exception e, 
                                                String sourceSystem, String integrationType, String parentLogId, String transactionId) {
        ApplicationLog appLog = new ApplicationLog(applicationName, request, response, e, sourceSystem, integrationType, parentLogId, transactionId);
        return appLog.save();
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @return      void
    * @description persist a list of Application_Log__c records
    */
    public static void persistApplicationLogs() {
        if(null != logs && !logs.isEmpty()) {
            insert logs;
        }
        ApplicationLogHandler.clear();
    }

    /**
    * @Description generate an Application_Log__c record and add it into a Application_Log__c list
    * @Author      Kejia Hu
    * @Date        2019-10-23
    */
    public static Application_Log__c addAutoLog(String applicationName,  String description, String parentLogId) {
        ApplicationLog appLog = new ApplicationLog(applicationName, description, parentLogId);
        Application_Log__c logInst = appLog.createApplicationLog(appLog);
        if (null != logInst) {
            logs.add(logInst);
        }
        return logInst;
    }

    /**
    * @Description generate an Application_Log__c record and add it into a Application_Log__c list
    * @Author      Kejia Hu
    * @Date        2019-10-23
    */
    public static Application_Log__c addLogWithAppName(String applicationName,  String description, String parentLogId) {
        ApplicationLog appLog = new ApplicationLog(applicationName, description, parentLogId);
        Application_Log__c logInst = appLog.createApplicationLog(appLog);
        if (null != logInst) {
            logs.add(logInst);
        }
        return logInst;
    }

    /**
    * @Description generate an Application_Log__c record and add it into a Application_Log__c list
    * @Author      Kejia Hu
    * @Date        2019-10-23
    */
    public static Application_Log__c addLogWithTransId(String applicationName,  String description, String parentLogId, String transactionId) {
        ApplicationLog appLog = new ApplicationLog(applicationName, description, parentLogId, transactionId);
        Application_Log__c logInst = appLog.createApplicationLog(appLog);
        if (null != logInst) {
            logs.add(logInst);
        }
        return logInst;
    }
	
    /**
    * @author      Vikas Sharma
    * @date        2019-09-09
    * @param       String applicationName
    * @param       Exception e
    * @return      Application_Log__c
    * @description generate and prersist an Application_Log__c record
    */
    public static Application_Log__c saveAutoLog(String applicationName,  String description, String parentLogId) {
        return saveAutoLogs(applicationName, description, parentLogId);
    }
    
    /**
    * @author      Vikas Sharma
    * @date        2019-04-25
    * @param       String applicationName
    * @param      StringDescription
    * @description generate and prersist an Application_Log__c record
    */
    public static Application_Log__c saveAutoLogs(String applicationName, String description, String parentLogId ) {
        ApplicationLog appLog = new ApplicationLog(applicationName,  description, parentLogId);
        return appLog.save();
    }	
    
    /**
    * @description OM-925 generate an integration log from payload
    * @author      Kejia Hu
    * @date        11/08/2019                     
    */
    public static Application_Log__c createIntegrationLogs(String payload, String transactionId, String status, String referenceNum, String TrackingNum, String eventName) {
        Application_Log__c eventLog = new Application_Log__c();
        eventLog.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
        eventLog.Application_Name__c = eventName;
        eventLog.Category__c = 'Integration';
        eventLog.Transaction_Id__c = transactionId;
        eventLog.Status__c = status;
        eventLog.ReferenceNumber__c = referenceNum;
        eventLog.TrackingNumber__c = TrackingNum;
        if (payload.length()>131072) {
            eventLog.Request_Payload__c =  payload.substring(0, 131071);
            eventLog.AdditionalPayload__c = (payload.substring(131072).length()>131072)
                ? payload.substring(131072).substring(0, 131071)
                : payload.substring(131072);
        } else {
            eventLog.Request_Payload__c =  payload;
        }
        return eventLog;
    }
}