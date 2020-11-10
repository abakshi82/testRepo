/**
* @Description: Test class for Omni_AgentWorkTriggerHandler
* @Author:      Damian Kazior, PwC
* @Date:        02/03/2020
*/
@isTest
public with sharing class Omni_AgentWorkTriggerHandlerTest {

    public static Map<Id, AgentWork> newAgents;
    public static Map<Id, AgentWork> oldAgents;

    /**
    * @Description:      To insert workitem in test class, presence status would have to be set on test 
    *                    supported in test class. Work item cannot be sucessfully 
    *                    created in test class, unless user that executes this test class is online on omnichannel which is not
    *                    feasable. Therefore there must be a separate coverage for trigger with 
    *                    before insert only, and separate test for handler. 
    * @Author:           Damian Kazior, PwC
    * @Date:             02/03/2020
    */
    static void createData(){

        MessagingEndUser msgUser = TestDataFactory.createMessagingEndUser(true); 
        MessagingSession msgSession = TestDataFactory.createMessagingSessionForEndUser(msgUser, true);
        newAgents = new Map<Id, AgentWork>();
        //Fake agentwork ID will NOT be inserted with DML. It is here jsut to create an object and cover trigger
        newAgents.put('0Bz4g00000004a6CAA', new AgentWork(
            WorkItemId = msgSession.Id
        ));
        oldAgents = new Map<Id, AgentWork>();
        oldAgents.put('0Bz4g00000004a6CAB', new AgentWork(
            WorkItemId = msgSession.Id
        ));
    }  

    @isTest 
    private static void scheduleFeedCreationTest() {
        insert new Messaging_Configuration__c(Feed_Creation_Delay_In_Minutes__c = '5');
        Omni_AgentWorkTriggerHandler.scheduleFeedCreation();
    }

    /**
    * @Description:      As per description below, AgentWork cannot be inserted. Hence no assertions are possible
    * @Author:           Damian Kazior, PwC
    * @Date:             02/03/2020
    */

    @isTest 
    private static void handleAfterUpdateTest() {
        createData();
        Omni_AgentWorkTriggerHandler agentWorkHandler = new Omni_AgentWorkTriggerHandler();
        agentWorkHandler.handleAfterUpdate(newAgents, oldAgents);
    }

    @isTest 
    private static void coverTrigger() {
        AgentWork agentWorks = new AgentWork();
        try{
            insert agentWorks; 
        }catch(Exception e){}
         
    }

    @isTest
    static void coverageMethods(){
        Test.startTest();
        Omni_AgentWorkTriggerHandler handler = new Omni_AgentWorkTriggerHandler();
        handler.handleBeforeDelete(null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        handler.handleBeforeUpdate(null, null);
        handler.handleAfterInsert(null);
        Test.stopTest();
        System.assertEquals('AgentWork', handler.getObjectAPIName(),'Object name should be User');
    }
     
}