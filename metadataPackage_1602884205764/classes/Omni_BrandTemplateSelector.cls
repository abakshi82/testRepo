/**
* @description Selctor for Email letterhead sObject
* @author      Damian Kazior
* @date        05/07/2019                     
*/
public with sharing class Omni_BrandTemplateSelector {

     /**
    * @description fetch letterheads by name
    * @author      Damian Kazior
    * @date        05/07/2019                  
    */
    public static BrandTemplate getBrandTemplatesByName(String brandTemplateName){
        return [SELECT Id, Name FROM BrandTemplate WHERE Name =:brandTemplateName];
    }
}