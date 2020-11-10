/**
* @Description: Selctor for MessagingSession sObject
* @Author:      Damian Kazior
* @Date:        10/02/2020
*/
public without sharing class Omni_MessagingSessionSelector {

    /**
	* @description  Retrieve Messaging Session detials by Id
    * @Author:      Damian Kazior
    * @Date:        10/02/2020                  
    */
    public static Map<Id, MessagingSession> getMessagingSessionsById(Set<Id> endedMessagingSessions){
      
        Map<Id, MessagingSession> messagingSessionDetails = new Map<Id, MessagingSession>([SELECT Id, MessagingEndUser.Account.Name,  MessagingEndUser.Account.FirstName,  MessagingEndUser.Account.LastName,  MessagingEndUser.MessagingPlatformKey, CaseId
                                                                                          FROM MessagingSession   
                                                                                          WHERE Id In:endedMessagingSessions]);
        return messagingSessionDetails;
    
    }
}