/**
* @Description: Controller for Omni_ClaimSearch lightning component
* @Author:      Damian Kazior, PwC
* @Date:        12/01/2020
*/
public with sharing class Omni_Aura_CustomSearchController {

    public static final String RECORD_TYPE_ID_CLAIM         = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claim').getRecordTypeId();
    public static final String RECORD_TYPE_ID_OTH_EXPOSURE  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OtherExposure').getRecordTypeId();
    public static final String RECORD_TYPE_ID_BI            = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BodilyInjury').getRecordTypeId();
    public static final String RECORD_TYPE_ID_BENEFITS      = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Benefits').getRecordTypeId();
    public static final List<String> exposureRecordTypeIds  = new List<String>{RECORD_TYPE_ID_OTH_EXPOSURE, RECORD_TYPE_ID_BI, RECORD_TYPE_ID_BENEFITS};

    /**
    * @Description: Search for claims or exposures by passed keywords
    * @Author:      Damian Kazior, PwC
    * @Date:        12/01/2020
    */
    @AuraEnabled  
    public static Omni_AuraResponse fetchLookUpValues(String searchKeyWord) {

        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        try{
            String searchKey = searchKeyWord + '%';
            //query not in the selector since it must enforce sharing settings
            Map<Id, Case> claims = new Map<Id, Case>(
                            [SELECT Id, ClaimNumber__c from Case 
                            WHERE ClaimNumber__c LIKE :searchKey AND RecordTypeId =: RECORD_TYPE_ID_CLAIM AND Retired__c = False  
                            Order By CreatedDate DESC limit 3]);
 
            List<Case> exposures = new List<Case>();
            if(claims.size() >0){ 
                 //query must enfore sharing rules to hide AB/Bi exposures
                exposures = [SELECT Id, ExposureType__r.Name, RecordType.Name, CaseNumber 
                            FROM Case 
                            WHERE ClaimForExposure__c IN :claims.keyset() and RecordtypeId IN:exposureRecordTypeIds];
            } 
            auraResponse.dataList.addAll(createResultSet(claims.values(), exposures));

        }catch(Exception e){
            ApplicationLogHandler.addExceptionLog('Omni_Aura_CustomSearchController', e, null);
            auraResponse.success = false;
            auraResponse.message = e.getMessage();
        }
        return auraResponse; 
    }

    /**
    * @Description: Create custom resultset for claims and exposures
    * @Author:      Damian Kazior, PwC
    * @Date:        12/01/2020
    */
    public static List<CaseSearchResultWrapper> createResultSet(List<Case> claims, List<Case> exposures){
        List<CaseSearchResultWrapper> results = new List<CaseSearchResultWrapper>();
        //generate Calim number suggestions
        for (Case claim: claims) {
            results.add(new CaseSearchResultWrapper(  
                claim.Id, 
                'Claim: ' + claim.ClaimNumber__c)
            ); 
        }
        //generate Exposure suggestions
        for (Case exposure: exposures) {
                results.add(new CaseSearchResultWrapper(
                exposure.Id, 
                exposure.RecordType.Name + ' (' + exposure.ExposureType__r.Name + '): '+exposure.CaseNumber)
            ); 
        }
        return results;
    }

    /**
    * @Description: Wrapper for results returned to the lightning component
    * @Author:      Damian Kazior, PwC
    * @Date:        12/01/2020
    */
    public class CaseSearchResultWrapper{
        @AuraEnabled public String CaseId;
        @AuraEnabled public String Name;	

        public CaseSearchResultWrapper(String id, String name){
            this.CaseId = id;
            this.Name = name;
        }
    }  
}