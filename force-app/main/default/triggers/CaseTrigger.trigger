/**
* @description Populate Case role record values for auto notification
* @author      Kejia Hu
* @date        16/10/2019                     
*/
trigger CaseTrigger on Case (before insert, before update) {

    TriggerDispatcher.execute(new CaseTriggerHandler(), Trigger.operationType);

}