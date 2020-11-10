/**
   * @Description: Selctor for User sObject
   * @Author:      Kejia Hu
   * @Date:        05/08/2019
*/
public with sharing class Omni_UserSelector {

    public static List<User> activeUsers;
    
    /**
    * @description retrieve User SF Id by GWCC User Id map
    * @author      Kejia Hu
    * @date        05/08/2019                     
    */
    public static final Map<String, String> USER_ID_BY_GWCC_ID {
        get{
            if (null == USER_ID_BY_GWCC_ID) {
                USER_ID_BY_GWCC_ID = new Map<String, String>();
                if (null == activeUsers) {
                    //TODO: Add profile filter once profile setup
                    activeUsers = [SELECT Id, UserId__c, Street, City, PostalCode, Title_1_FR__c, Title_2_FR__c, CompanyName, 
                                       Email, Fax, Name, Phone, State, Title_1__c, Title_2__c, ManagerId  
                                   FROM User 
                                   WHERE UserId__c != null AND isActive = true];
                }
                for (User u : activeUsers) {
                    USER_ID_BY_GWCC_ID.put(u.UserId__c, u.Id);
                }
            }
            return USER_ID_BY_GWCC_ID;
        }
        set;
    }

    /**
    * @description retrieve User by Id map
    * @author      Kejia Hu
    * @date        05/08/2019                     
    */
    public static final Map<String, User> USER_BY_ID {
        get{
            if (null == USER_BY_ID) {
                USER_BY_ID = new Map<String, User>();
                if (null == activeUsers) {
                    //TODO: Add profile filter once profile setup
                    activeUsers = [SELECT Id, UserId__c, Street, City, PostalCode, Title_1_FR__c, Title_2_FR__c, CompanyName, 
                                       Email, Fax, Name, Phone, State, Title_1__c, Title_2__c, ManagerId  
                                   FROM User 
                                   WHERE UserId__c != null AND isActive = true];
                }
                for (User u : activeUsers) {
                    USER_BY_ID.put(u.Id, u);
                }
            }
            return USER_BY_ID;
        }
        set;
    }

    /**
    * @description Retrieve User details informations by Ids
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    public static Map<Id, User> getUserDetailsById(Set<Id> userIds) {
        Map<Id, User> users = new Map<Id, User>([
                                SELECT Street, City, PostalCode, Title_1_FR__c ,Title_2_FR__c ,CompanyName ,Email ,Fax, 
                                        Name, Phone, State, Title_1__c, Title_2__c, Delegated_User__c, IsActive, Delegated_User__r.IsActive
                                FROM User 
                                WHERE Id IN:userIds]);
        return users;                                                        
    }
}