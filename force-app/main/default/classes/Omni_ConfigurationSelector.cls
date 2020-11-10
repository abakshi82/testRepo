/**
* @Description: Selctor for Configuration sObject
* @Author:      Vikas Sharma
* @Date:        21/08/2019
*/
public with sharing class Omni_ConfigurationSelector {
    
    
    /**
* @description retrieve Configurations associated with Event Names
* @author      Vikas Sharma
* @date        21/08/2019                     
*/
    public static Map<String, List<Communication_Configuration__c>> getConfigurationsByEventNames(Set<String> eventNames) {
        Map<String, List<Communication_Configuration__c>> eventNamesWithConfigurations = new Map<String, List<Communication_Configuration__c>>();
        List<Communication_Configuration__c> configurations = [SELECT EventName__c, Communication_Type__c, Name,Custom_Criteria__c,
                                                               Role__c,Exposure_Type__c,Eligibility_Criteria__c,SMS_Subject_EN__c,
                                                               SMS_Subject_FR__c,Fax_Subject_EN__c,
                                                               Fax_Subject_FR__c, Print_Subject_EN__c,
                                                               Print_Subject_FR__c,Explicit__c
                                                               FROM Communication_Configuration__c 
                                                               WHERE EventName__c in:  eventNames
                                                               AND Active__c = true
                                                              ];
        if (!configurations.isEmpty()) {
            for(Communication_Configuration__c config : configurations) {
                if (eventNamesWithConfigurations.get(config.EventName__c) == null){
                    eventNamesWithConfigurations.put(config.EventName__c, new List<Communication_Configuration__c>{config});
                }
                else
                {
                    eventNamesWithConfigurations.get(config.EventName__c).add(config);
                }
            }
        }
        return eventNamesWithConfigurations;
    }
    
    /**
* @description retrieve Configurations associated with Event Names
* @author      Vikas Sharma
* @date        21/08/2019                     
*/
    public static Set<String> getAllConfigurations() {
        Set<String> toReturn = new Set<String>();
        
        for (Communication_Configuration__c config : [SELECT EventName__c, Communication_Type__c,
                                                      Name,Custom_Criteria__c,Explicit__c, 
                                                      Role__c,Exposure_Type__c,Eligibility_Criteria__c
                                                      FROM Communication_Configuration__c 
                                                      WHERE Eligibility_Criteria__c  != null
                                                      AND Active__c = true])       
        {
            toReturn.add(config.Eligibility_Criteria__c);
            
            if (config.Custom_Criteria__c != null)
            {
                toReturn.add(config.Custom_Criteria__c);	   
            }
        }
        
        return toReturn;
    }
    /**
* @description retrieve Configurations associated with Event Names
* @author      Vikas Sharma
* @date        21/08/2019                     
*/
    public static Map<String, Id> getEmailTemplatesId(Set<String> eventNames) {
        
        Map<String, Id> toReturn = new Map<String, Id>();
        List<String> listOfTemplates = new List<String>();
        
        /*for (Communication_Configuration__c config : [SELECT TemplateName__c
                                                      FROM Communication_Configuration__c 
                                                      WHERE EventName__c in:  eventNames
                                                     ])
        {
            listOfTemplates.add(config.TemplateName__c);
        }*/
        
        for (Language_Config__c langConfig : [SELECT Email_Template__c FROM Language_Config__c
                                             	WHERE Communication_Configuration__r.EventName__c in : eventNames
                                                AND Active__c = true])
        {
            listOfTemplates.add(langConfig.Email_Template__c);
        }
        for (EmailTemplate template : [SELECT Name, DeveloperName, Id from EmailTemplate 
                                       WHERE DeveloperName in : listOfTemplates 
                                      ])
        {
            toReturn.put(template.DeveloperName, template.Id);
        }
        return toReturn;
    }
    
    
    /**
* @description:  To retrieve the list of all language configurations
* 				Currently only fetching configurations for current event names
* @author      Vikas Sharma
* @date        10/09/2019                     
*/
    public static Map<Id, List<Language_Config__c>> getLanguageConfigurations(Set<String> eventNames) {
        
        Map<Id, List<Language_Config__c>> toReturn = new Map<Id, List<Language_Config__c>>();
        List<Id> configIds = new List<Id>();
        
        for (Communication_Configuration__c config : [SELECT Id
                                                      FROM Communication_Configuration__c 
                                                      WHERE EventName__c in:  eventNames
                                                      AND Active__c = true
                                                     ])
        {
            configIds.add(config.Id);
        }
        
        
        for (Language_Config__c langConfig : [SELECT Communication_Configuration__c	, Email_Template__c,
                                              Language_Qualifier__c, SMS_Template__r.Message__c ,Id
                                              FROM Language_Config__c 
                                              WHERE Communication_Configuration__c in : configIds
                                              AND Active__c = true 
                                             ])
        {
            if (toReturn.get(langConfig.Communication_Configuration__c) == null)
            {
                toReturn.put(langConfig.Communication_Configuration__c, new List<Language_Config__c>{langConfig});
            }
            else{
                toReturn.get(langConfig.Communication_Configuration__c).add(langConfig);
            }
            
        }
        return toReturn;
    }   
    
    /**
* @description:  To retrieve the list of all language configurations
* 				Currently only fetching configurations for current event names
* @author      Vikas Sharma
* @date        10/09/2019                     
*/
    public static Set<String> getFieldNamesFromLanguageConfig() {
        Set<String> toReturn = new Set<String>();
        
        for (Language_Config__c config : [SELECT Communication_Configuration__c	, Email_Template__c, 
                                                      Language_Qualifier__c, SMS_Template__c ,Id
                                                      FROM Language_Config__c 
                                                      WHERE Language_Qualifier__c != null
                                                      AND Active__c = true])       
        {
            toReturn.add(config.Language_Qualifier__c);	                                                  
        }
        
        return toReturn;
    }
}