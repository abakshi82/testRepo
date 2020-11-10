/**
 * @Description: schedualable job to execute purge all types of logs batch job
 * 				 Code sample for Schedule t 5:25AM on the 15th day of every month
 *               System.schedule('Purge Exception Logs', '0 25 5 15 * ?', new PurgeExceptionLogSchedule());
 * @author:      Kejia Hu
 * @Date:        23-09-2019
 */
public with sharing class PurgeAllLogSchedule implements Schedulable {
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(new PurgeApplicationLogBatch(null), 200);
    }

}