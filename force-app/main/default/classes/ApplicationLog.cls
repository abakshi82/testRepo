/**
* @author      Kejia Hu
* @date        2019-04-24
* @description model class for Application_Log__c
* <p>                                                                        
* 2019-04-24 - Kejia Hu - creation and inital commit                        
*/
public with sharing class ApplicationLog { 
    private enum statusEnum {Failure, Success}
    private String applicationName;
    private String category;
    private String description;
    private String endpoint;
    private String exceptionType;
    private String method;
    private String requestPayload;
    private String responsePayload;
    private String status;
    private Integer statusCode;
    private String transactionId;
    private String sourceSystem;
    private String integrationType;
    private String parentLogId;
    private Exception exceptionInst;
	private String logDesc;

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
    * @description ApplicationLog consturctor
    */
    public ApplicationLog(String applicationName, HttpRequest request, HttpResponse response, Exception e, 
                            String sourceSystem, String integrationType, String parentLogId, String transactionId) {
        this.applicationName = applicationName;
        this.exceptionInst = e;
        this.sourceSystem = sourceSystem;
        this.integrationType = integrationType;
        this.parentLogId = parentLogId;
        this.transactionId = transactionId;
        this.status = (null == this.exceptionInst) ? this.status : statusEnum.Failure.Name();
        if (request != null) {
            this.method = request.getMethod();
            this.requestPayload = request.getBody();
            this.endpoint = request.getEndpoint();
            if (response != null) {
                this.responsePayload = response.getBody();
                Integer sc = response.getStatusCode();
                this.status = (sc < 300 && sc >= 100) ? statusEnum.Success.Name() : statusEnum.Failure.Name();
                this.statusCode = response.getStatusCode();
            } else {
                this.Status = statusEnum.Failure.Name();
                this.responsePayload = 'No Http Response';
            }
        }
    }
	
	/**
    * @author      Vikas Sharma
    * @date        2019-09-09
    * @param       String applicationName
    * @param	   String description
    * @param       HttpRequest request
    * @description ApplicationLog consturctor
    */
    public ApplicationLog(String applicationName,  String description, String parentLogId) {
        this.applicationName = applicationName;
        this.logDesc = description;
        this.parentLogId = parentLogId;
    }

    /**
    * @Description ApplicationLog consturctor
    * @Author      Kejia Hu
    * @Date        05/11/2019
    */
	public ApplicationLog(String applicationName,  String description, String parentLogId, String transactionId) {
        this.applicationName = applicationName;
        this.logDesc = description;
        this.parentLogId = parentLogId;
        this.transactionId = transactionId;
    }

    
    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @return      Application_Log__c
    * @description persist an Application_Log__c record
    */
    public Application_Log__c save() {
        return persistApplicationLog(this);
    }
	
	/*public Application_Log__c saveAutoLogs() {
        return persistApplicationLog(this);
    }*/
	
    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       ApplicationLog appLog
    * @return      Application_Log__c
    * @description persist an Application_Log__c record
    */
    public Application_Log__c persistApplicationLog(ApplicationLog appLog) {
        Application_Log__c logInst;
        logInst = createApplicationLog(appLog);
        if(null != logInst) {
            insert logInst;
        }
        return logInst;
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @param       ApplicationLog appLog
    * @return      Application_Log__c
    * @description generate an Application_Log__c record from a instance of ApplicationLog
    *              check if the log is enabled before generating
    */
    public Application_Log__c createApplicationLog(ApplicationLog appLog) {
        Application_Log__c logInst;
        if(Utility.LOGGING_CONFIG.Exception_Logging_Enabled__c && null != appLog.exceptionInst) {
            logInst = new Application_Log__c();
            logInst.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('ExceptionLog');
            logInst.Application_Name__c = appLog.applicationName;
            logInst.Category__c = 'Exception';
            logInst.Description__c = appLog.exceptionInst.getMessage();
            logInst.Exception_Type__c = appLog.exceptionInst.getTypeName();
            logInst.Exception_Stack_Trace__c = appLog.exceptionInst.getStackTraceString();
            logInst.Status__c = appLog.status;
            logInst.Application_Log__c = appLog.parentLogId;
        }
        if(Utility.LOGGING_CONFIG.Integration_Logging_Enabled__c && null != appLog.requestPayload) {
            logInst = new Application_Log__c();
            logInst.Application_Name__c = appLog.applicationName;
            logInst.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
            logInst.Category__c = 'Integration';
            logInst.Endpoint__c = Utility.truncateString(appLog.endpoint,
                                                Application_Log__c.Endpoint__c.getDescribe().getLength());
            logInst.Method__c = appLog.method;
            logInst.Request_Payload__c = Utility.truncateString(appLog.requestPayload,
                                                Application_Log__c.Request_Payload__c.getDescribe().getLength());
            logInst.Response_Payload__c = Utility.truncateString(appLog.responsePayload,
                                                Application_Log__c.Response_Payload__c.getDescribe().getLength());
            logInst.Status__c = appLog.status;
            logInst.Status_Code__c = appLog.statusCode;
            logInst.Integration_Type__c = appLog.integrationType;
            logInst.Source_System__c = appLog.sourceSystem;
            logInst.Transaction_Id__c = appLog.transactionId;
        }
        if (Omni_ClaimNotificationConstant.APP_NAME_PRINT_LOG == appLog.applicationName 
                || Omni_ClaimNotificationConstant.APP_NAME_FAX_LOG == appLog.applicationName
                || Omni_ClaimNotificationConstant.APP_NAME_EMAIL_LOG == appLog.applicationName) {
            logInst = new Application_Log__c();
            logInst.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('IntegrationLog');
            logInst.Application_Name__c = appLog.applicationName;
            logInst.Category__c = Omni_SMSConstant.SMS_EVENT_CATEGROY_INTEGRATION;
            logInst.Description__c = appLog.logDesc;
            logInst.Application_Log__c = appLog.parentLogId;
            logInst.Transaction_Id__c = appLog.transactionId; 
        }
		
		if(null != appLog.logDesc && 'Auto Log' == appLog.applicationName) {
            logInst = new Application_Log__c();
            logInst.RecordTypeId = Utility.LOG_RECORD_TYPE_BY_APINAME.get('Auto_Log');
            logInst.Application_Name__c = 'Auto Log';
            logInst.Category__c = 'Auto Log';
            logInst.Description__c = appLog.logDesc;
            logInst.Exception_Type__c =''; //appLog.exceptionInst.getTypeName();
            logInst.Exception_Stack_Trace__c = appLog.logDesc;//appLog.exceptionInst.getStackTraceString();
            logInst.Status__c = '';//appLog.status;
            logInst.Application_Log__c = appLog.parentLogId;
            
        }
        return logInst;
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-24
    * @description model class for Error message return to client                     
    */
    public class ExceptionData {
        String applicationName;
        String exceptionType;
        String description;
        String stackTrace;

        /**
        * @author      Kejia Hu
        * @date        2019-04-25
        * @param       ApplicationLog log
        * @description ExceptionDate consturctor
        */
        public ExceptionData(ApplicationLog log) {
            this.applicationName = log.applicationName;
            this.description = log.exceptionInst.getMessage();
            this.exceptionType = log.exceptionInst.getTypeName();
            this.stackTrace = log.exceptionInst.getStackTraceString();
        }
    }
}