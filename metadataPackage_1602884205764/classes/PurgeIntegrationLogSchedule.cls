/**
* @author      Kejia Hu
* @date        2019-04-26
* @description schedualable job to execute purge integration logs batch job
* <p>                                                                        
* 2019-04-26 - Kejia Hu - creation and inital commit
* <p>
* Code sample for Schedule t 5:25AM on the 15th day of every month
* System.schedule('Purge Integration Logs', '0 25 5 15 * ?', new PurgeIntegrationLogSchedule());                 
*/
public with sharing class PurgeIntegrationLogSchedule implements Schedulable {
	
    public void execute(SchedulableContext sc){
        Database.executeBatch(new PurgeApplicationLogBatch(
                                PurgeApplicationLogBatch.LogCategory.INTEGRATION_LOG), 2000);
    }
}