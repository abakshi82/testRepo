/**
* @description Selector for GroupMember sObject
* @author      Luis Merinero
* @date        03/03/2020                   
*/
public class Omni_GroupMemberSelector {

	/**
    * @description Retrieve List of GroupMembers by User and Group Name
    * @author      Luis Merinero
    * @date        03/03/2020                      
    */
	public static List<GroupMember> getGroupMembersByUserAndGroupName(Id userId, String groupName){
        return [SELECT Id FROM GroupMember WHERE Group.DeveloperName = :groupName AND UserOrGroupId = :userId];
    }
    
}