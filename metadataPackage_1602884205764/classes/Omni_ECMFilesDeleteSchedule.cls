/**
* @author      Luis Merinero
* @date        2020-02-10
* @description schedualable job to send File Ingest to Handler
*/
public class Omni_ECMFilesDeleteSchedule implements Schedulable {
	
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchDeleteECMProcessedDocs(false,null), 50);
    }
}