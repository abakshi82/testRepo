@isTest
public with sharing class Omni_Aura_EmailReplyControllerTest {

    @isTest
    static void getemailMessageDetailsTest(){ 
        Case cas = TestDataFactory.createOtherExposures(1)[0]; 
        EmailMessage email = TestDataFactory.createEmailMessages(1, cas, true)[0];
        insert email; 

        Omni_AuraResponse resp = Omni_Aura_EmailReplyController.getemailMessageDetails(email.Id); 
        System.assertEquals(true, resp.success);
    }  

    @isTest
    static void getUserIdTest(){
        Omni_Aura_EmailReplyController.getUserId();
    }

}