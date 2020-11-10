/**
 * @Description: Batch job to merge DEA matched emails, emails parent case is a EmailCase in Claims - PKI/PKI Queue
 *               script to run this job:
 *               'Database.executeBatch(new Omni_MergeDEAMatchedEmailCaseBatch('2020-04-24T00:00:00Z', 'Claims - DEA Merge'), 100);'
 * @author:      Kejia Hu
 * @Date:        23-04-2019
 */
public class Omni_MergeDEAMatchedEmailCaseBatch implements Database.Batchable<sobject> {

    public String queryString;
    public String datetimeString;
    public String mergeQueueName;

    public Omni_MergeDEAMatchedEmailCaseBatch(String datetimeString, String mergeQueueName) {
        this.datetimeString = (!String.isBlank(datetimeString))
                            ? datetimeString
                            : 'TODAY';
        this.mergeQueueName = mergeQueueName;
        this.queryString = 'SELECT Id, ToAddress, CcAddress, ParentId, RelatedToId, Incoming FROM EmailMessage ' 
                                + 'WHERE Incoming = true '
                                //+ 'AND Parent.Owner.Name = \'Claims - DEA Merge\' AND createddate <'
                                + 'AND Parent.Owner.Name = :mergeQueueName AND createddate <'
                                + datetimeString;
        System.debug(this.queryString);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator queryLocator;
    	queryLocator = Database.getQueryLocator(queryString);
    	return queryLocator;
    }
    
    public void execute(Database.BatchableContext bc, List<sobject> scope) {
        Map<String, EmailMessage> emailByDEAAddressToMerge;
        Map<String, Case> masterCaseByDEAAddress;
        List<EmailMessage> emailsForTask = new List<EmailMessage>();
        Set<String> emailIdsForTask = new Set<String>();
        try {
	    	if (scope != null && !scope.isEmpty()) {
                emailByDEAAddressToMerge = EmailMessageTriggerHandlerHelper.getEmailByDEAAddress(
                                                                    (List<EmailMessage>) scope);
                System.debug('***1.emailByDEAAddressToMerge: ' + emailByDEAAddressToMerge);            
	    	}
            if (!emailByDEAAddressToMerge.isEmpty()) {
                masterCaseByDEAAddress = Omni_CaseSelector.getMasterCasesFromDEAAddresses(emailByDEAAddressToMerge.keySet());
            }
            if (!emailByDEAAddressToMerge.isEmpty()) {
                //remove invalid DEA address
                System.debug('***2.emailByDEAAddressToMerge before removeInvalidDEA: ' + emailByDEAAddressToMerge);
                EmailMessageTriggerHandlerHelper.removeInvalidDEA(emailByDEAAddressToMerge, masterCaseByDEAAddress);
                System.debug('***3.emailByDEAAddressToMerge after removeInvalidDEA: ' + emailByDEAAddressToMerge);
                EmailMessageTriggerHandlerHelper.removeEmailsWithMultipleDEAMatced(emailByDEAAddressToMerge);
                System.debug('***4.emailMessage to merge: ' + emailByDEAAddressToMerge);
                
                //Merge Email Case to Master Case
                Set<Id> masterMergeCaseIds = new Set<Id>();
                //get all master case Ids
                masterMergeCaseIds.addAll(getIdsFromCaseMap(masterCaseByDEAAddress));
                //get all merge case Ids from emails
                masterMergeCaseIds.addAll(getParentIdsFromEmailMap(emailByDEAAddressToMerge));
                System.debug('***5.masterMergeCaseIds: ' + masterMergeCaseIds);
                //get master cases and merge cases with minimum information
                Map<String, Case> masterMergeCaseById = Omni_CaseSelector.getMinCaseInfo(masterMergeCaseIds);
                System.debug('***6.masterMergeCaseById: ' + masterMergeCaseById);
                System.debug('***6-1.masterMergeCaseById: ' + emailByDEAAddressToMerge.keySet());
                System.debug('***6-2.masterCaseByDEAAddress: ' + masterCaseByDEAAddress.keySet());
                for (String deaKey : emailByDEAAddressToMerge.keySet()) {
                    System.debug('***7.masterCaseId: ' + masterCaseByDEAAddress.get(deaKey.toUpperCase()).Id);
                    Case masterCase = masterMergeCaseById.get(masterCaseByDEAAddress.get(deaKey.toUpperCase()).Id);
                    System.debug('***8.masterCase: ' + masterCase);
                    System.debug('***9.mergeCaseId: ' + emailByDEAAddressToMerge.get(deaKey).ParentId);
                    Case mergeCase = masterMergeCaseById.get(emailByDEAAddressToMerge.get(deaKey).ParentId);
                    System.debug('***10.mergeCase: ' + mergeCase);
                    if (mergeCase != null && masterCase != null) {
                        Database.MergeResult result = Database.merge(masterCase, mergeCase, false);
                        if (result.isSuccess()) {
                            emailIdsForTask.add(emailByDEAAddressToMerge.get(deaKey).Id);
                        }
                    }
                }
            }

            //create tasks after merge
            System.debug('***11.emailsForTask: ' + emailsForTask);
            if (!emailIdsForTask.isEmpty()) {
                emailsForTask = [SELECT Id, ParentId, RelatedToId, Incoming FROM EmailMessage WHERE Id IN :emailIdsForTask];
                Omni_TaskGenerator.createTaskForMatchedIncomingEmail(emailsForTask); 
            }
    	} catch(Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
    		ApplicationLogHandler.saveExceptionLog('Omni_MergeDEAMatchedEmailCaseBatch', e, null);
    	}
    }

    public void finish(Database.BatchableContext bc) {}

    /**
    * @Description get case Ids from a case map
    * @Author      Kejia Hu
    * @Date        23/04/2020                     
    */
    private static Set<Id> getIdsFromCaseMap(Map<String, Case> CaseByKey) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : CaseByKey.values()) {
            caseIds.add(c.Id);
        }
        return caseIds;
    }

    /**
    * @Description get parent Ids from a email map
    * @Author      Kejia Hu
    * @Date        23/04/2020                     
    */
    private static Set<Id> getParentIdsFromEmailMap(Map<String, EmailMessage> emailMap) {
        Set<Id> parentIds = new Set<Id>();
        for (EmailMessage email : emailMap.values()) {
            parentIds.add(email.ParentId);
        }
        return parentIds;
    }

}