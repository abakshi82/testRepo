/**
* @description Update EmailMessage records relationships once autonotification emails sent out
*			   Create FeedItem after EmailMessage records created
* @author      Kejia Hu
* @date        17/09/2019                     
*/
trigger EmailMessageTrigger on EmailMessage (before insert, after insert, before delete) {
	System.debug('***EmailMessageTrigger Queries - Before:' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
	TriggerDispatcher.execute(new EmailMessageTriggerHandler(), Trigger.operationType);
	System.debug('***EmailMessageTrigger Queries - After:' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
}