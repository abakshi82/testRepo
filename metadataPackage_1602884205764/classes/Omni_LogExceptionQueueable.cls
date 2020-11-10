public class Omni_LogExceptionQueueable implements Queueable {
    
    public Exception exceptionToLog;
    public String parentLogId;
    
    public Omni_LogExceptionQueueable(Exception exceptionToLog, String parentLogId){
        this.exceptionToLog = exceptionToLog;
        this.parentLogId = parentLogId;
    }
    
    public void execute(QueueableContext context){
        if (parentLogId != null) {
            Application_Log__c log = ApplicationLogHandler.saveExceptionLog('EOC Survey Exception', exceptionToLog, parentLogId);
            System.debug('In Finally log : ' + log);
        } else {
            Application_Log__c log = ApplicationLogHandler.saveExceptionLog('EOC Survey Exception', exceptionToLog, null);
        }
    }
    
    @future
    public static void test() {
       Account acc = new Account(Name = 'Future Account');
       insert acc;
       System.debug('In Finally acc : ' + acc);
    }
    
}