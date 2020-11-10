/**
* @description Trigger logic for Platform Event ECM_Processed__e
* @author      Vikas Sharma
* @date        19/01/2020                     
*/
trigger ECMProcessedPETrigger on ECM_Processed__e (after insert) {
    
        TriggerDispatcher.execute(new Omni_ECMProcessedPETriggerHandler(), Trigger.operationType);

}