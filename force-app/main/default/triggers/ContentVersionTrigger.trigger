/**
* @description Trigger on contectVersion (Salesfroce file)
* @author      Damian Kazior
* @date        23/08/2019                     
*/
trigger ContentVersionTrigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.execute(new Omni_ContentVersionTriggerHandler(), Trigger.operationType);
}