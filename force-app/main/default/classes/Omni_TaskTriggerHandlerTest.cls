/**
* @description Test class for Omni_TaskTriggerHandler
* @author      Damian Kazior
* @date        29/01/2020                     
*/ 
@isTest
public with sharing class Omni_TaskTriggerHandlerTest {

    public static Case parentCase;
    public static List<Task> tasks;

    @isTest
    private static void prepareData(){
        parentCase = TestDataFactory.createClaim();
        //re-query created case to fetch ownerId
        parentCase = [SELECT Id, OwnerId FROM Case WHERE Id=:parentCase.Id][0];
        tasks = TestDataFactory.createTasks(TestDataFactory.TEST_SIZE_SMALL, parentCase, false);
    }

    @isTest
    private static void updateOpenCasesTaskStatusPositive(){

        prepareData(); 
        Test.startTest();
        insert tasks;
        Test.stopTest();

        parentCase = [select Id, Tasks_Status__c FROM CASE WHERE Id=:parentCase.Id][0];
        System.assertEquals(Omni_TaskTriggerHandler.CASE_STATUS_ACTION_REQUIRED, parentCase.Tasks_Status__c, 'There are open tasks for a case, hence case must have status updated');
        List<Application_Log__c> appLogs = [SELECT Id from Application_Log__c];
        System.assertEquals(0, appLogs.size(), 'No exception should have been thrown');
    }

    @isTest
    private static void updateClosedCasesTaskStatusPositive(){

        prepareData(); 
        Test.startTest();
        insert tasks;
        //update all tasks except one
        for(Integer k =0; k< TestDataFactory.TEST_SIZE_SMALL -1 ; k++){
            tasks[k].Status = 'Completed';    
        }   
        update tasks;
        Test.stopTest();

        parentCase = [select Id, Tasks_Status__c FROM CASE WHERE Id=:parentCase.Id][0];
        System.assertEquals(Omni_TaskTriggerHandler.CASE_STATUS_ACTION_REQUIRED, parentCase.Tasks_Status__c, 'There is one open tasks for this case. Case status should still reflect open tasks');
        
        //update all tasks
        for(Integer k =0; k< TestDataFactory.TEST_SIZE_SMALL; k++){
            tasks[k].Status = 'Completed';    
        }  
        update tasks;

        parentCase = [select Id, Tasks_Status__c FROM CASE WHERE Id=:parentCase.Id][0];
        System.assertNotEquals(Omni_TaskTriggerHandler.CASE_STATUS_ACTION_REQUIRED, parentCase.Tasks_Status__c, 'All tasks for case are complete. emove status from case');
        
        List<Application_Log__c> appLogs = [SELECT Id from Application_Log__c];
        System.assertEquals(0, appLogs.size(), 'No exception should have been thrown');
    }

}