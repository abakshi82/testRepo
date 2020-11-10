/**
* @description Insert on Content Document. Once document is coming from Email
*              Need to update some metadata accordingly
* @author      Vikas Sharma
* @date        13/01/2020                     
*/
trigger ECMDocumentsLinkTrigger on ContentDocumentLink (after insert) {
    TriggerDispatcher.execute(new ECMDocumentsLinkTriggerHandler(), Trigger.operationType);
}