/**
* @description to scheduele batch job to retry failed survey request jobs
* @author      Kejia Hu
* @date        19/05/2020                     
*/
public class Omni_EOCSurveyRequestBatchSchedule implements Schedulable {
	
    public void execute(SchedulableContext sc){
        Database.executeBatch(new Omni_EOCSurveyRequestBatch(), 1);
    }
}