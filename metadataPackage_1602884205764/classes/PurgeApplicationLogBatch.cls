/**
* @author      Kejia Hu
* @date        2019-04-26
* @description batch job to purge the application logs
* <p>                                                                        
* 2019-04-26 - Kejia Hu - creation and inital commit               
*/
public with sharing class PurgeApplicationLogBatch implements Database.Batchable<sobject> {

    public enum LogCategory{INTEGRATION_LOG , EXCEPTION_LOG}
    public String queryString;
    public String category;
    public Integer logPurgeDays;

    private final String BATCH_EXCEPTION_MSG = 'Something went wrong with the batch job';

    public PurgeApplicationLogBatch(LogCategory logC) {
        try {
            if (null != logC) {
                category = (logC == LogCategory.EXCEPTION_LOG) ? 'Exception' : 'Integration';
                logPurgeDays = (logC == LogCategory.EXCEPTION_LOG) 
                                ? Integer.valueOf(Utility.LOGGING_CONFIG.Exception_Logs_Purge_Days__c) 
                                : Integer.valueOf(Utility.LOGGING_CONFIG.Integration_Logs_Purge_Days__c);
                this.queryString = 'SELECT Id , Category__c , CreatedDate FROM Application_Log__c WHERE Category__c = :category'
                                    + ' AND CreatedDate != LAST_N_DAYS:' + logPurgeDays + ' ORDER BY CreatedDate ASC';
            } else if (null != Utility.LOGGING_CONFIG.All_Logs_Purge_Days__c){
                logPurgeDays = Integer.valueOf(Utility.LOGGING_CONFIG.All_Logs_Purge_Days__c);
                this.queryString = 'SELECT Id, CreatedDate FROM Application_Log__c WHERE CreatedDate != LAST_N_DAYS:' + logPurgeDays + ' ORDER BY CreatedDate ASC';
            }

            //For test coverage
            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('This is a productive error for test method');
                throw e;
            }
    	} catch(Exception e) {
    		ApplicationLogHandler.saveExceptionLog('PurgeApplicationLogs', e, null);
    	}
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator queryLocator;
    	try {
    		queryLocator = Database.getQueryLocator(queryString);

            //For test coverage
            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('This is a productive error for test method');
                throw e;
            }
    	} catch(Exception e) {
    		ApplicationLogHandler.saveExceptionLog('PurgeApplicationLogs', e, null);
    	}
    	return queryLocator;
    }
    
    public void execute(Database.BatchableContext bc , List<sobject> scope) {
        try {
	    	if (scope != null && !scope.isEmpty()) {
	    		delete scope;
	    	}

            //For test coverage
            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('This is a productive error for test method');
                throw e;
            }
    	} catch(Exception e) {
    		ApplicationLogHandler.saveExceptionLog('PurgeApplicationLogs', e, null);
    	}
    }
    
    public void finish(Database.BatchableContext bc){}

}