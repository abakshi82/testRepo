/**
* @Description: Selctor for ServiceChannel sObject
* @Author:      Damian Kazior
* @Date:        10/02/2020
*/
public without sharing class Omni_ServiceChannelSelector {

    /**
    * @Description retrieve case records with minimum information
    * @Author      Kejia Hu
    * @Date        30/01/2020                     
    */
    public static List<ServiceChannel> getServiceChannelByEntityName(String entityName) {
        return [SELECT Id 
                FROM Servicechannel
                WHERE RelatedEntity =:entityName];
    }
}