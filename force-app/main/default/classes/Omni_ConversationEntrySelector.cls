/**
* @Description: Selctor for ConverastionEntry sObject
* @Author:      Damian Kazior
* @Date:        10/02/2020
*/
public without sharing class Omni_ConversationEntrySelector {

    /**
	* @description  Retrieve Conversation Entries detials by Id
    * @Author:      Damian Kazior
    * @Date:        10/02/2020                  
    */
    public static List<ConversationEntry> getConversationEntriesBySessionIds(Set<Id> endedMessagingSessions){
      
        return [SELECT Message, MessageDeliverTime, ConversationId, Seq, ActorType 
                FROM ConversationEntry 
                WHERE ConversationId IN :endedMessagingSessions 
                AND (ActorType = 'EndUser' OR ActorType='Agent')];
        
    
    }
}