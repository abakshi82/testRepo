/**
* @Description: Selctor for Profile sObject
* @Author:      Damian Kazior, PwC
* @Date:        23-08-2019
*/
public with sharing class Omni_ProfileSelector {

    public static Profile getProfileById(String id){
        return [SELECT Id, Name
                FROM Profile
                WHERE Id =: id];
    } 
}