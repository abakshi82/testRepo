public without sharing class Omni_TaskTriggerHandler implements TriggerHandlerBase {

    public static FINAL String SOBJECT_NAME                = 'Task';
    public static FINAL String TASK_STATUS_COMPLETED       = 'Completed';
    public static FINAL String CASE_STATUS_ACTION_REQUIRED = 'Action Required';

    public String getObjectAPIName() {
        return SOBJECT_NAME;
    }

    public void handleBeforeInsert(List<SObject> listNew) { 
        //Placeholder for Before Insert logic
        return;
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
         return;
    } 
    
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        //Placeholder for Before Delete logic
        return;
    }

    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        updateOpenCasesTaskStatus(mapNew.values(), CASE_STATUS_ACTION_REQUIRED);
    }
    
    public void handleAfterUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        updateClosedCasesTaskStatus(mapNew.values());      
    }

    /**
    * @Description: Once all tasks for given case close, update task status on case
    * @Author:      Damian Kazior
    * @Date:        28/01/2020
    */
    private static void updateClosedCasesTaskStatus(List<task> tasks){
        try{
            Set<Id> caseIds = getCaseForTask(tasks);
            if(!caseIds.isEmpty()){
                Map<Id, Case> cases = Omni_CaseSelector.getCasesByIds(caseIds);
                List<Task> allTasksTofCases = Omni_TaskSelector.getAllTasksForCaseIds(cases.keySet());
                
                Map<Id, List<Task>> caseIdToTasks = mapCaseToTasks(allTasksTofCases);
                List<Case> casesToUpdate = getCasesWithAllTasksComplete(caseIdToTasks);
                
                if(!casestoUpdate.isEmpty()){
                    update casestoUpdate;
                }
            }   
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_TaskTriggerHandler', e , null); 
        }
    }

    /**
    * @Description: Create a map of case to a list of all related tasks for easier processing
    * @Author:      Damian Kazior
    * @Date:        28/01/2020
    */
    private static Map<Id, List<Task>> mapCaseToTasks(List<Task> allTasksTofCases){
        Map<Id, List<Task>> caseIdToTasks = new Map<Id, List<Task>>();
        for(Task tas : allTasksTofCases){
            if(caseIdToTasks.containsKey(tas.whatId) ){
                caseIdToTasks.get(tas.whatId).add(tas);
            }else{
                List<Task> t= new List<Task>();
                t.add(tas);
                caseIdToTasks.put(tas.whatId, t);
            }
        }
        return caseIdToTasks;
    }

    /**
    * @Description: Fetch cases with complete tasks. When all tasks for case are complete, add parent case to compelted list
    * @Author:      Damian Kazior
    * @Date:        28/01/2020
    */
    private static List<Case> getCasesWithAllTasksComplete(Map<Id, List<Task>> caseIdToTasks){
        List<Case> casesWithCompleteTasks = new List<Case>();
        for(Id caseId : caseIdToTasks.keySet()){
            boolean allCompleted = true;
            for(Task ta : caseIdToTasks.get(caseId)){
                if(ta.Status != TASK_STATUS_COMPLETED){
                    allCompleted = false;
                }
            }
            if(allCompleted && caseIdToTasks.get(caseId).size() > 0){ 
                casesWithCompleteTasks.add(new Case(Id= caseId, Tasks_Status__c = ''));
            }
        }
        return casesWithCompleteTasks;
    }

    /**
    * @Description: Update task status on case related to tasks
    * @Author:      Damian Kazior
    * @Date:        28/01/2020
    */
    private static void updateOpenCasesTaskStatus(List<Task> tasks, String statusName){
        try{
            Set<Id> caseIds = getCaseForTask(tasks);
            if(!caseIds.isEmpty()){
                Map<Id, Case> cases = Omni_CaseSelector.getCasesByIds(caseIds);
                for(Case cas : cases.values()){
                    cas.Tasks_Status__c = statusName;
                }
                if(!cases.isEmpty()){
                    update cases.values();
                }
            }
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_TaskTriggerHandler', e , null); 
        }
    }

    /**
    * @Description: fetch case ids for tasks
    * @Author:      Damian Kazior
    * @Date:        28/01/2020
    */
    private static Set<Id> getCaseForTask(List<Task> tasks){
        Set<Id> caseIds = new Set<Id>();
        for(Task tas: tasks){
            caseIds.add(tas.whatId);
        }
        return caseIds;
    }
    
    public void handleAfterDelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Delete logic
        return;
    }
    
    public void handleAfterUndelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Undelete logic
        return;
    }
}