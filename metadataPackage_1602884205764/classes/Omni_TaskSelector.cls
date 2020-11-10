/**
* @Description: Selctor for Task sObject
* @Author:      Damian Kazior
* @Date:        05/01/2020
*/
public with sharing class Omni_TaskSelector {

    /**
    * @Description: Selctor for User sObject
    * @Author:      Damian Kazior
    * @Date:        05/01/2020
    */
    public static List<Task> getAllTasksForCaseIds(Set<Id> caseIds) {
        return [SELECT Id, Status, WhatId 
                FROM Task 
                WHERE whatId IN :caseIds];                    
    }
}