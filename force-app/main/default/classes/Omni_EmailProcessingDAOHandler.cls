/**
* @Description DAO for Email Processing related
* @Author      Kejia Hu
* @Date        30/01/2020                     
*/
public with sharing class Omni_EmailProcessingDAOHandler {

    /**
    * @Description retrieve Queue by Name map
    * @Author      Kejia Hu
    * @Date        30/01/2020                     
    */
    public static final Map<String, Group> QUEUE_BY_NAME {
        get{
            if (null == QUEUE_BY_NAME) {
                QUEUE_BY_NAME = new Map<String, Group>();
                for (Group g : [SELECT Id, Type, DeveloperName FROM Group WHERE Type = 'Queue']) {
                    QUEUE_BY_NAME.put(g.DeveloperName, g);
                }
            }
            return QUEUE_BY_NAME;
        }
        set;
    }

    /**
    * @Description retrieve Emails by ids
    * @Author      Kejia Hu
    * @Date        30/01/2020                     
    */
    public static List<EmailMessage> getEmailsFromIds(Set<String> emailIds) {
        return [SELECT Id, ParentId, Parent.recordTypeId, HasAttachment
                FROM EmailMessage 
                WHERE Id IN :emailIds];
    }
}