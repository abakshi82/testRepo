/**
* @description trigger logic for Platform Event Handler_Processed__e
* @author      Vikas Sharma
* @date        19/01/2020                     
*/
trigger HandlerProcessedPETrigger on Handler_Processed__e (after insert) {
    TriggerDispatcher.execute(new Omni_HandlerProcessedPETriggerHandler(), Trigger.operationType);

}