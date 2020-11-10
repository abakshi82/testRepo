/**
* @Description: Selctor for MessagingChannel sObject
* @Author:      Damian Kazior
* @Date:        10/02/2020
*/
public with sharing class Omni_MessagingChannelSelector {

    /**
	* @description  Retrieve Messaging Session detials by Id
    * @Author:      Damian Kazior
    * @Date:        10/02/2020                  
    */
    public static MessagingChannel getMessagingChannelByName(String messagingChannelName){
      
        return [SELECT Id FROM MessagingChannel WHERE DeveloperName =: messagingChannelName];
    
    }
}