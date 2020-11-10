/**
* @Description: Selctor for MessagingEndUser sObject
* @Author:      Damian Kazior
* @Date:        10/02/2020
*/
public with sharing class Omni_MessagingEndUserSelector {

    /**
	* @description  Retrieve Messaging End Users detials by Phone number
    * @Author:      Damian Kazior
    * @Date:        10/02/2020                  
    */
    public static List<MessagingEndUser> getMessagingEndUserByPhoneNumber(String phoneNumber){
      
        return [SELECT Id, Name FROM MessagingEndUser WHERE MessagingPlatformKey =: phoneNumber];
    
    }
}