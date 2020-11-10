/**
 * @Description: delete Case records which have record type Shadow Role
 * @author:      Kejia Hu
 * @Date:        24-09-2019
 */
public with sharing class PurgeShadowRoleBatch implements Database.Batchable<sobject> {

    public String queryString;

    public PurgeShadowRoleBatch(Integer purgeDays) {
        String shadowRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                        Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId();
        if (purgeDays < 0 || purgeDays == null) {
            this.queryString = 'SELECT Id FROM Case WHERE RecordTypeId = \'' + shadowRecordTypeId + '\'';
        } else if (purgeDays == 0) {
            this.queryString = 'SELECT Id FROM Case WHERE RecordTypeId = \'' + shadowRecordTypeId + '\''
                                    + ' AND CreatedDate != TODAY';
        } else {
            this.queryString = 'SELECT Id FROM Case WHERE RecordTypeId = \'' + shadowRecordTypeId + '\''
                                    + ' AND CreatedDate != LAST_N_DAYS:' + purgeDays;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator queryLocator;
    	queryLocator = Database.getQueryLocator(queryString);
    	return queryLocator;
    }
    
    public void execute(Database.BatchableContext bc, List<sobject> scope) {
        try {
	    	if (scope != null && !scope.isEmpty()) {
	    		delete scope;
	    	}
    	} catch(Exception e) {
    		ApplicationLogHandler.saveExceptionLog('PurgeShadowRoles', e, null);
    	}
    }

    public void finish(Database.BatchableContext bc){}

}