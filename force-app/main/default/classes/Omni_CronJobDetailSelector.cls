/**
* @Description: Selctor for CronJobDetail sObject
* @Author:      Damian Kazior
* @Date:        10/02/2020
*/
public with sharing class Omni_CronJobDetailSelector {

    /**
	* @description  Retrieve cron jobs by type and name
    * @Author:      Damian Kazior
    * @Date:        10/02/2020                  
    */
    public static List<CronJobDetail> getCronJobsByTypeAndName(String type, String name){
      
        return [SELECT Id 
                FROM CronJobDetail 
                WHERE JobType =: type
                AND Name =: name];
    
    }
}