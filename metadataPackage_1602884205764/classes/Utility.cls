/**
* @author      Kejia Hu
* @date        2019-04-25
* @description utility methods
* <p>                                                                        
* 2019-04-25 - Kejia Hu - creation and inital commit 
*/
public with sharing class Utility {

    /**
    * @Description get Communication Test Channel configs
    * @Author      Kejia Hu
    * @Date        13/02/2020
    */
    public static final Map<String, CommunicationTestChannel__mdt> COMM_TEST_CHANNEL_BY_NAME {
        get{
            if(null == COMM_TEST_CHANNEL_BY_NAME) {
                COMM_TEST_CHANNEL_BY_NAME = new Map<String, CommunicationTestChannel__mdt>();
                for (CommunicationTestChannel__mdt aConfig : [SELECT DeveloperName, ContactId__c, Active__c
                                                  FROM CommunicationTestChannel__mdt WHERE Active__c = true]) {
                    COMM_TEST_CHANNEL_BY_NAME.put(aConfig.DeveloperName, aConfig);
                }
            }
            return COMM_TEST_CHANNEL_BY_NAME;
        }
        set;
    }

    /**
    * @Description get survey configs
    * @Author      Kejia Hu
    * @Date        13/02/2020
    */
    public static final Map<String, SurveyConfig__mdt> SURVEY_CONFIG_BY_FIELD {
        get{
            if(null == SURVEY_CONFIG_BY_FIELD) {
                SURVEY_CONFIG_BY_FIELD = new Map<String, SurveyConfig__mdt>();
                for (SurveyConfig__mdt aConfig : [SELECT SendSurveyOnce__c, SurveyIndicatorAPIName__c, Type__c
                                                  FROM SurveyConfig__mdt WHERE Active__c = true]) {
                    SURVEY_CONFIG_BY_FIELD.put(aConfig.SurveyIndicatorAPIName__c, aConfig);
                }
            }
            return SURVEY_CONFIG_BY_FIELD;
        }
        set;
    }

    /**
    * @Description get survey switches
    * @Author      Kejia Hu
    * @Date        13/02/2020
    */
    public static final Map<String, SurveySwitch__mdt> SURVEY_SWITCH_BY_KEY {
        get{
            if(null == SURVEY_SWITCH_BY_KEY) {
                SURVEY_SWITCH_BY_KEY = new Map<String, SurveySwitch__mdt>();
                for (SurveySwitch__mdt aConfig : [SELECT MasterLabel, IsEnabled__c FROM SurveySwitch__mdt]) {
                    SURVEY_SWITCH_BY_KEY.put(aConfig.MasterLabel, aConfig);
                }
            }
            return SURVEY_SWITCH_BY_KEY;
        }
        set;
    }

    /**
    * @description parse email headers and build a header map
    * @author      Kejia Hu
    * @date        27/01/2020                     
    */
    public static Map<String, String> parseHeaders(String headers) {
        Map<String, String> headerMap = new Map<String, String>();
        String[] aHeaders = headers.split('\\\n'); 
        for(String header: aHeaders) {
            if(header.trim().length() > 0) {                
                headerMap.put(header.left(header.IndexOf(':')), header.right( header.length() - header.IndexOf(':') -1));
            }
        }
        return headerMap;
    }

    /**
    * @Description get string value of decimal with scale
    * @Author      Kejia Hu
    * @Date        27/01/2020
    */
    public static final Map<String, String> EMAIL_CONFIG_BY_KEY {
        get{
            if(null == EMAIL_CONFIG_BY_KEY) {
                EMAIL_CONFIG_BY_KEY = new Map<String, String>();
                for (EmailProcessingConfig__mdt aConfig : [SELECT MasterLabel, Value__c FROM EmailProcessingConfig__mdt]) {
                    EMAIL_CONFIG_BY_KEY.put(aConfig.MasterLabel, aConfig.Value__c);
                }
            }
            return EMAIL_CONFIG_BY_KEY;
        }
        set;
    }

    /**
    * @description get string value of decimal with scale
    * @author      Kejia Hu
    * @date        11/09/2019
    */
    public static String getStringValWithScale(Decimal input, Integer scale) {
        return (null != input)
                    ? String.valueOf(input.setScale(scale))
                    : '';
    }

    /**
    * @Description: Generate random string for given length. 
    * @Author:      Damian Kazior, PwC
    * @Date:        12/11/2019
    */
    public static String generateRandomChar(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String randStr = '';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr;  
    }

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @description Retrieve logging config for current environment
    */
    public static final Application_Logging_Config__mdt LOGGING_CONFIG {
        get{
            if(null == LOGGING_CONFIG) {
                LOGGING_CONFIG = [
                    SELECT Exception_Logging_Enabled__c, Exception_Logs_Purge_Days__c, 
                        Integration_Logging_Enabled__c, Integration_Logs_Purge_Days__c,
                        All_Logs_Purge_Days__c
                    FROM Application_Logging_Config__mdt LIMIT 1];
            }
            return LOGGING_CONFIG;
        }
        set;
    }
    
    /**
    * @Description: Selctor for Template Management Config custom metadata
    * @Author:      Damian Kazior, PwC
    * @Date:        10/07/2019
    */
    public static Template_Management_Config__mdt getTemplateManagementConfigurations(){
        return [SELECT Id, Cloned_Emails_Folder_Name__c, Letterhead_name__c, Template_Style__c, Template_Type__c
                FROM Template_Management_Config__mdt
                LIMIT 1];
    } 

    /**
    * @author      Kejia Hu
    * @date        2019-04-25
    * @description truncate string base on the length
    */
    public static String truncateString(String str, Integer length) {
        return (!String.isBlank(str) && str.length()>length)
                ? str.substring(0,length)
                : str;
    }

    /**
    * @author      Kejia Hu
    * @date        2019-05-17
    * @description Retrieve notification config by application map from custom metadata
    */
    public static final Map<String, Error_Notification_Config__mdt> NOTIFICATION_CONFIG_BY_APP {
        get{
            if(null == NOTIFICATION_CONFIG_BY_APP) {
                NOTIFICATION_CONFIG_BY_APP = new Map<String, Error_Notification_Config__mdt>();
                Error_Notification_Config__mdt[] elementsOrgMappings = [
                    SELECT Application_Name__c, Email_Addresses__c, Error_Notification_Enabled__c
                    FROM Error_Notification_Config__mdt];
                for(Error_Notification_Config__mdt element : ElementsOrgMappings) {
                    NOTIFICATION_CONFIG_BY_APP.put(element.Application_Name__c, element);
                }
            }
            return NOTIFICATION_CONFIG_BY_APP;
        }
        set;
    }

    /**
    * @description retrieve trigger swtich map
    * @author      Kejia Hu
    * @date        03/07/2019                     
    */
    public static final Map<String, Boolean> TRIGGER_SWTICH_BY_OBJ_NAME {
        get {
            if(null == TRIGGER_SWTICH_BY_OBJ_NAME) {
                TRIGGER_SWTICH_BY_OBJ_NAME = new Map<String, Boolean>();
                Trigger_Switch__mdt[] elementsForMappings = [
                    SELECT Object_API_Name__c, isEnabled__c FROM Trigger_Switch__mdt];
                for(Trigger_Switch__mdt element : elementsForMappings) {
                    TRIGGER_SWTICH_BY_OBJ_NAME.put(element.Object_API_Name__c, element.isEnabled__c);
                }
            }
            return TRIGGER_SWTICH_BY_OBJ_NAME;
        }
        set;
    }

    /**
    * @description Application_Log__c RecordType Id by Name map
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public static final Map<String, String> LOG_RECORD_TYPE_BY_APINAME {
        get {
             if (null == LOG_RECORD_TYPE_BY_APINAME) {
                LOG_RECORD_TYPE_BY_APINAME = new Map<String, String>();
                for (RecordType rt: [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Application_Log__c']) {
                    LOG_RECORD_TYPE_BY_APINAME.put(rt.DeveloperName, rt.Id);
                }
            }
            return LOG_RECORD_TYPE_BY_APINAME;
        }
        set;
    }

    /**
    * @description Get Datetime for CC Datetime String
    * @author      Kejia Hu
    * @date        11/09/2019
    */
    public static DateTime getDateTime(String dateTimeStr) {
        return (!String.isBlank(dateTimeStr))
                    ? DateTime.valueOf(dateTimeStr.replace('T', ' '))
                    : null;
    }
	/**
    * @author      Vikas Sharma
    * @date        2019-09-12
    * @description To get the specific field Info from list of cases based on ID
    */
    public static List<String> getCaseFielValue(Id caseId, String fieldName,  List<Case> cases) {
        
        for (Case cs : cases)
        {
            if (cs.Id == caseId)
            {
                return (''+cs.get(fieldName)).split(';');
            }
            
        }
        return new List<String>();
    }
    
    /**
    * @author      Vikas Sharma
    * @date        2019-09-12
    * @description to get the specific template names associated with configurations
    */
    public static List<String> getTemplateNames(Communication_Configuration__c currentConfig, 
                                                List<Case> cases, 
                                                Map<Id, List<Language_Config__c>> languageConfigWithIds,
                                                String templateType, Case currentCase) 
    {
        List<String> templateInfo = new List<String>();
        for(Id languageConfigId : languageConfigWithIds.keySet())
        {
            
            for (Language_Config__c langConfig : languageConfigWithIds.get(languageConfigId))
            {
                if (langConfig.Communication_Configuration__c == currentConfig.Id)
                {
                    for (Case cs : cases)
                    {
                        if (cs.Id == currentCase.Id)
                        {
                            // check the language qualifier
                            if (''+ cs.get(langConfig.Language_Qualifier__c) == 'true')
                            {

                                if (templateType == 'EMAIL')
                                {
                                  templateInfo.add(langConfig.Email_Template__c);
                                }
                                if (templateType == 'SMS')
                                {
                                  templateInfo.add(langConfig.SMS_Template__r.Message__c);
                                }
                                
                            }
                        }
                    }
                }	    
            }
            
        }
        return templateInfo;
 	}
    
    /**
    * @author      Vikas Sharma
    * @date        2019-09-12
    * @description  to add the Account Info related to Account Id
    */
    public static void addAccountMapWithAccountId(Map<String, Account> accountMapwithId, 
                                                  String accId,
                                                  Account acc)
    {
        accountMapwithId.put(accId, acc);
    }

    /**
    * @description retrieve claim notif config by name map
    * @author      Kejia Hu
    * @date        24/09/2019                     
    */
    public static final Map<String, String> CLAIM_NOTIF_CONFIG_BY_NAME {
        get {
            if(null == CLAIM_NOTIF_CONFIG_BY_NAME) {
                CLAIM_NOTIF_CONFIG_BY_NAME = new Map<String, String>();
                Claim_Notification_Config__mdt[] elementsForMappings = [
                    SELECT DeveloperName, Value__c FROM Claim_Notification_Config__mdt];
                for(Claim_Notification_Config__mdt element : elementsForMappings) {
                    CLAIM_NOTIF_CONFIG_BY_NAME.put(element.DeveloperName, element.Value__c);
                }
            }
            return CLAIM_NOTIF_CONFIG_BY_NAME;
        }
        set;
    }

    /**
    * @description retrieve Omni_Implementation_Date__c
    * @author      Kejia Hu
    * @date        17/10/2019                     
    */
    public static final DateTime OMNI_IMPLEMENTATION_DATE {
        get {
            if(null == OMNI_IMPLEMENTATION_DATE) {
                OMNI_IMPLEMENTATION_DATE = [SELECT DeveloperName, Implementation_Date__c 
                                                FROM OMNI_Implementation_Date__mdt][0].Implementation_Date__c;
            }
            return OMNI_IMPLEMENTATION_DATE;
        }
        set;
    }

    /**
    * @description remove all non-digits from given string. Used to remove any non number characters in phone numbers
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
    public static String removeNonDigitsFromString(String dirtyString){
        return dirtyString.replaceAll('\\D','');
    }

    /**
    * @description Multiplication table for Verhoeff algorithm
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
    // The multiplication table
    private static List<List<Integer>> multiplicationTable = new List<List<Integer>>
    {
        new Integer[]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9},  
        new Integer[]{1, 2, 3, 4, 0, 6, 7, 8, 9, 5}, 
        new Integer[]{2, 3, 4, 0, 1, 7, 8, 9, 5, 6}, 
        new Integer[]{3, 4, 0, 1, 2, 8, 9, 5, 6, 7}, 
        new Integer[]{4, 0, 1, 2, 3, 9, 5, 6, 7, 8}, 
        new Integer[]{5, 9, 8, 7, 6, 0, 4, 3, 2, 1}, 
        new Integer[]{6, 5, 9, 8, 7, 1, 0, 4, 3, 2}, 
        new Integer[]{7, 6, 5, 9, 8, 2, 1, 0, 4, 3}, 
        new Integer[]{8, 7, 6, 5, 9, 3, 2, 1, 0, 4}, 
        new Integer[]{9, 8, 7, 6, 5, 4, 3, 2, 1, 0}
    };
	
    /**
    * @description Permutation table for Verhoeff algorithm
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
    private static List<List<Integer>> permutationTable = new List<List<Integer>>
    {
        new Integer[]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, 
        new Integer[]{1, 5, 7, 6, 2, 8, 3, 0, 9, 4}, 
        new Integer[]{5, 8, 0, 3, 7, 9, 6, 1, 4, 2}, 
        new Integer[]{8, 9, 1, 6, 0, 4, 3, 5, 2, 7}, 
        new Integer[]{9, 4, 5, 3, 1, 2, 6, 8, 7, 0}, 
        new Integer[]{4, 2, 8, 6, 5, 7, 3, 9, 0, 1}, 
        new Integer[]{2, 7, 9, 3, 8, 0, 6, 4, 1, 5}, 
        new Integer[]{7, 0, 4, 6, 9, 1, 3, 2, 5, 8}
    };
	
    /**
    * @description Inverse table for Verhoeff algorithm
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
    private static List<Integer> inv = new List<Integer>{0, 4, 3, 2, 1, 5, 6, 7, 8, 9};
	
    /**
    * @description Validate that string is a valid claim number
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
	public static boolean isValidClaimNumber(String claimNumber){
        if(!claimNumber.isNumeric() || claimNumber.length() != 10){
            return false;
        }
        //move check number to the end of the strig
        String numberWithCheckAsLast = swapCheckNumber(claimNumber);
        return validateVerhoeff(numberWithCheckAsLast);
	}

    /**
    * @description Validate that an entered number is Verhoeff compliant
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
	private static boolean validateVerhoeff(String numberToValidate){
        Integer c = 0;
        Integer[] myArray = stringToReversedIntArray(numberToValidate);
    
        for (Integer i = 0; i < myArray.size(); i++){
            c = multiplicationTable[c][permutationTable[(math.mod(i,8))][myArray[i]]];
        }
		return (c == 0);
	}
	
    /**
    * @description Move check number from the beginning to the end of the string
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
	private static String swapCheckNumber(String originalNumber){
        String leftMostNumber = originalNumber.left(1);
        String baseNumber = originalNumber.mid(1, originalNumber.length()-1);
        return baseNumber+leftMostNumber;
    }

	/**
    * @description Turn string number to reversed array to calculate Verhoeff
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
	private static Integer[] stringToReversedIntArray(String num){
		
		Integer[] myArray = new Integer[num.length()];
		for(Integer i = 0; i < num.length(); i++)
		{
			myArray[i] = Integer.valueOf(num.substring(i, i + 1));					
		}
		
		myArray = reverse(myArray);
		return myArray;
	}
	
	/**
    * @description Validate that an entered number is Verhoeff compliant
    * @author      Damian Kazior
    * @date        08/01/2019                     
    */
	private static Integer[] reverse(integer[] myArray)
	{
		Integer[] reversed = new Integer[myArray.size()];
		for(Integer i = 0; i < myArray.size() ; i++)
		{
			reversed[i] = myArray[myArray.size() - (i + 1)];			
		}		
		return reversed;
	}
    
}