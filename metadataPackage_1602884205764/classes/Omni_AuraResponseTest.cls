/**
   * @Description: Test for Omni_AuraResponse class
   * @Author:      Damian Kazior, PwC
   * @Date:        25/06/2019
*/
@isTest
public with sharing class Omni_AuraResponseTest {

    @isTest private static void auraResponse(){
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(123, true, 'test');
    }
}