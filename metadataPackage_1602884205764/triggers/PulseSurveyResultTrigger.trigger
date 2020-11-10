trigger PulseSurveyResultTrigger on Pulse_Survey_Result__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.execute(new Omni_PulseSurveyResultTriggerHandler(), Trigger.operationType);
}