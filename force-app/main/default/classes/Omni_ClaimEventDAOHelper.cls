/**
* @description DAO related to Claim Event process
* @author      Kejia Hu
* @date        06/08/2019                     
*/
public with sharing class Omni_ClaimEventDAOHelper {

    public static List<PolicyBranch__c> policyBranches;
    public static List<InjuredPartyRole__c> injuredPartyRoles;
    public static List<LossCause__c> lossCauses;
    public static List<TypeOfLoss__c> typesOfLoss;
    public static List<State__c> states;
    public static List<ContactRole__c> contactRoles;
    public static List<PolicyIssuingGroup__c> policyIssuingGroups;
    public static List<Country__c> countries;
    public static List<ExposureType__c> exposureTypes;
    public static List<ClaimExposureStatus__c> exposureStatus;

    /**
    * @description retrieve OrgWideEmailAddress by email address map
    * @author      Kejia Hu
    * @date        19/02/2020                     
    */
    public static Map<String, OrgWideEmailAddress> orgWideEmailAddressByEmail {
        get{
            if (null == orgWideEmailAddressByEmail) {
                orgWideEmailAddressByEmail = new Map<String, OrgWideEmailAddress>();
                for (OrgWideEmailAddress orgEmail : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                    orgWideEmailAddressByEmail.put(orgEmail.Address, orgEmail);
                }
            }
            return orgWideEmailAddressByEmail;
        }
        set;
    }

    /**
    * @description retrieve Claim Exposure Status by TypeCode map
    * @author      Kejia Hu
    * @date        02/12/2019                     
    */
    public static Map<String, ClaimExposureStatus__c> exposureStatusByCode {
        get{
            if (null == exposureStatusByCode) {
                exposureStatusByCode = new Map<String, ClaimExposureStatus__c>();
                if (null == exposureStatus) {
                    exposureStatus = [SELECT Id, TypeCode__c, Description__c, L_EN_CA__c, L_FR_CA__c FROM ClaimExposureStatus__c];
                }
                for (ClaimExposureStatus__c es : exposureStatus) {
                    exposureStatusByCode.put(es.TypeCode__c, es);
                }
            }
            return exposureStatusByCode;
        }
        set;
    }

    /**
    * @description retrieve Claim Exposure Status by Id map
    * @author      Kejia Hu
    * @date        02/12/2019                     
    */
    public static Map<String, ClaimExposureStatus__c> exposureStatusById {
        get{
            if (null == exposureStatusById) {
                exposureStatusById = new Map<String, ClaimExposureStatus__c>();
                if (null == exposureStatus) {
                    exposureStatus = [SELECT Id, TypeCode__c, Description__c, L_EN_CA__c, L_FR_CA__c FROM ClaimExposureStatus__c];
                }
                for (ClaimExposureStatus__c es : exposureStatus) {
                    exposureStatusById.put(es.Id, es);
                }
            }
            return exposureStatusById;
        }
        set;
    }

	/**
    * @description retrieve EmailMessage from set of Ids
    * @author      Kejia Hu
    * @date        18/09/2019                     
    */
    public static List<EmailMessage> getEmailMessages(Set<Id> idSet) {
        return [SELECT Id, Subject, RelatedToId, ParentId, Claim__c, Exposure__c 
                    FROM EmailMessage 
                    WHERE Id IN :idSet];
    }

    /**
    * @description Exposure_Type__c by Name Map
    * @author      Kejia Hu
    * @date        06/08/2019                     
    */
    public static Map<String, ExposureType__c> exposureTypeByName {
        get{
            if (null == exposureTypeByName) {
                exposureTypeByName = new Map<String, ExposureType__c>();
                for (ExposureType__c ep :  [SELECT TypeCode__c, Description__c 
                                            FROM ExposureType__c]) {
                    exposureTypeByName.put(ep.TypeCode__c, ep);
                }
            }
            return exposureTypeByName;
        }
        set;
    }

    /**
    * @description Case Exposure record type Ids by Exposure_Type__c.Code__c Map
    * @author      Kejia Hu
    * @date        06/08/2019                     
    */
    public static Map<String, String> exposureRecordTypeIdByTypeCode {
        get {
            if (null == exposureRecordTypeIdByTypeCode) {
                exposureRecordTypeIdByTypeCode = new Map<String, String>();
                for (String oneType : exposureTypeByName.keySet()) {
                    switch on oneType {
                        when 'benefits' {
                            exposureRecordTypeIdByTypeCode.put(oneType, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                oneType.capitalize()).getRecordTypeId());
                        }	
                        when 'BodilyInjury' {
                            exposureRecordTypeIdByTypeCode.put(oneType, Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                oneType).getRecordTypeId());
                        }
                        when else {
                            exposureRecordTypeIdByTypeCode.put(oneType, Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE);
                        }
                    }
                }
            }
            return exposureRecordTypeIdByTypeCode;
        }
        set;
    }

    /**
    * @description retrieve Type of Loss Id by Type Code map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, String> TYPE_LOSS_ID_BY_CODE {
        get{
            if (null == TYPE_LOSS_ID_BY_CODE) {
                TYPE_LOSS_ID_BY_CODE = new Map<String, String>();
                if (null == typesOfLoss) {
                    typesOfLoss = [SELECT Id, TypeCode__c, Description__c, L_EN_CA__c, L_FR_CA__c FROM TypeOfLoss__c];
                }
                for (TypeOfLoss__c tl : typesOfLoss) {
                    TYPE_LOSS_ID_BY_CODE.put(tl.TypeCode__c, tl.Id);
                }
            }
            return TYPE_LOSS_ID_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve Type of Loss by Id map
    * @author      Kejia Hu
    * @date        12/11/2019                     
    */
    public static final Map<String, TypeOfLoss__c> TYPE_LOSS_BY_ID {
        get{
            if (null == TYPE_LOSS_BY_ID) {
                TYPE_LOSS_BY_ID = new Map<String, TypeOfLoss__c>();
                if (null == typesOfLoss) {
                    typesOfLoss = [SELECT Id, TypeCode__c, Description__c, L_EN_CA__c, L_FR_CA__c FROM TypeOfLoss__c];
                }
                for (TypeOfLoss__c tl : typesOfLoss) {
                    TYPE_LOSS_BY_ID.put(tl.Id, tl);
                }
            }
            return TYPE_LOSS_BY_ID;
        }
        set;
    }

    /**
    * @description retrieve Loss Cause Id by Type Code map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, String> LOSS_CAUSE_ID_BY_CODE {
        get{
            if (null == LOSS_CAUSE_ID_BY_CODE) {
                LOSS_CAUSE_ID_BY_CODE = new Map<String, String>();
                if (null == lossCauses) {
                    lossCauses = [SELECT Id, TypeCode__c, Description__c, L_EN_CA__c, L_FR_CA__c FROM LossCause__c];
                }
                for (LossCause__c lc : lossCauses) {
                    LOSS_CAUSE_ID_BY_CODE.put(lc.TypeCode__c, lc.Id);
                }
            }
            return LOSS_CAUSE_ID_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve Loss Cause by Id map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, LossCause__c> LOSS_CAUSE_BY_ID {
        get{
            if (null == LOSS_CAUSE_BY_ID) {
                LOSS_CAUSE_BY_ID = new Map<String, LossCause__c>();
                if (null == lossCauses) {
                    lossCauses = [SELECT Id, TypeCode__c, Description__c, L_EN_CA__c, L_FR_CA__c FROM LossCause__c];
                }
                for (LossCause__c lc : lossCauses) {
                    LOSS_CAUSE_BY_ID.put(lc.Id, lc);
                }
            }
            return LOSS_CAUSE_BY_ID;
        }
        set;
    }

    /**
    * @description retrieve Country by Type Code map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, Country__c> COUNTRY_BY_CODE {
        get{
            if (null == COUNTRY_BY_CODE) {
                COUNTRY_BY_CODE = new Map<String, Country__c>();
                if (null == countries) {
                    countries = [SELECT Id, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM Country__c];
                }
                for (Country__c country : countries) {
                    COUNTRY_BY_CODE.put(country.TypeCode__c, country);
                }
            }
            return COUNTRY_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve Country by Id map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, Country__c> COUNTRY_BY_ID {
        get{
            if (null == COUNTRY_BY_ID) {
                COUNTRY_BY_ID = new Map<String, Country__c>();
                if (null == countries) {
                    countries = [SELECT Id, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM Country__c];
                }
                for (Country__c country : countries) {
                    COUNTRY_BY_ID.put(country.Id, country);
                }
            }
            return COUNTRY_BY_ID;
        }
        set;
    }

    /**
    * @description retrieve State by Type Code map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, State__c> STATE_BY_CODE {
        get{
            if (null == STATE_BY_CODE) {
                STATE_BY_CODE = new Map<String, State__c>();
                if (null == states) {
                    states = [SELECT Id, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM State__c];
                }
                for (State__c state : states) {
                    STATE_BY_CODE.put(state.TypeCode__c, state);
                }
            }
            return STATE_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve State by Id map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, State__c> STATE_BY_ID {
        get{
            if (null == STATE_BY_ID) {
                STATE_BY_ID = new Map<String, State__c>();
                if (null == states) {
                    states = [SELECT Id, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM State__c];
                }
                for (State__c state : states) {
                    STATE_BY_ID.put(state.Id, state);
                }
            }
            return STATE_BY_ID;
        }
        set;
    }

    /**
    * @description retrieve Name Prefix by Type Code map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, NamePrefix__c> NAME_PREFIX_BY_CODE {
        get{
            if (null == NAME_PREFIX_BY_CODE) {
                NAME_PREFIX_BY_CODE = new Map<String, NamePrefix__c>();
                for (NamePrefix__c prefix : [SELECT Id, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM NamePrefix__c]) {
                    NAME_PREFIX_BY_CODE.put(prefix.TypeCode__c, prefix);
                }
            }
            return NAME_PREFIX_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve Name Suffix by Type Code map
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public static final Map<String, NameSuffix__c> NAME_SUFFIX_BY_CODE {
        get{
            if (null == NAME_SUFFIX_BY_CODE) {
                NAME_SUFFIX_BY_CODE = new Map<String, NameSuffix__c>();
                for (NameSuffix__c suffix : [SELECT Id, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM NameSuffix__c]) {
                    NAME_SUFFIX_BY_CODE.put(suffix.TypeCode__c, suffix);
                }
            }
            return NAME_SUFFIX_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve role nature by Type Code map
    * @author      Kejia Hu
    * @date        13/08/2019                     
    */
    public static final Map<String, ContactRole__c> ROLE_NATURE_BY_CODE {
        get{
            if (null == ROLE_NATURE_BY_CODE) {
                ROLE_NATURE_BY_CODE = new Map<String, ContactRole__c>();
                if (null == contactRoles) {
                    contactRoles = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM ContactRole__c];
                }
                for (ContactRole__c rn : contactRoles) {
                    ROLE_NATURE_BY_CODE.put(rn.TypeCode__c, rn);
                }
            }
            return ROLE_NATURE_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve injured party role Id by Type Code map
    * @author      Kejia Hu
    * @date        06/09/2019                     
    */
    public static final Map<String, String> INJURED_ROLE_ID_BY_CODE {
        get{
            if (null == INJURED_ROLE_ID_BY_CODE) {
                INJURED_ROLE_ID_BY_CODE = new Map<String, String>();
                if (null == injuredPartyRoles) {
                    injuredPartyRoles = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c, Description__c FROM InjuredPartyRole__c];
                }
                for (InjuredPartyRole__c ir : injuredPartyRoles) {
                    INJURED_ROLE_ID_BY_CODE.put(ir.TypeCode__c, ir.Id);
                }
            }
            return INJURED_ROLE_ID_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve injured party role by Id map
    * @author      Kejia Hu
    * @date        12/11/2019                     
    */
    public static final Map<String, InjuredPartyRole__c> INJURED_ROLE_BY_ID {
        get{
            if (null == INJURED_ROLE_BY_ID) {
                INJURED_ROLE_BY_ID = new Map<String, InjuredPartyRole__c>();
                if (null == injuredPartyRoles) {
                    injuredPartyRoles = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c, Description__c FROM InjuredPartyRole__c];
                }
                for (InjuredPartyRole__c ir : injuredPartyRoles) {
                    INJURED_ROLE_BY_ID.put(ir.Id, ir);
                }
            }
            return INJURED_ROLE_BY_ID;
        }
        set;
    }

    /**
    * @description retrieve Policy Issuing Group Id by Type Code map
    * @author      Kejia Hu
    * @date        06/09/2019                     
    */
    public static final Map<String, String> POLICY_ISSUING_GROUP_ID_BY_CODE {
        get{
            if (null == POLICY_ISSUING_GROUP_ID_BY_CODE) {
                POLICY_ISSUING_GROUP_ID_BY_CODE = new Map<String, String>();
                if (null == policyIssuingGroups) {
                    policyIssuingGroups = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c, Business_Name_EN_CA__c, Business_Name_FR_CA__c FROM PolicyIssuingGroup__c];
                }
                for (PolicyIssuingGroup__c ig : policyIssuingGroups) {
                    POLICY_ISSUING_GROUP_ID_BY_CODE.put(ig.TypeCode__c, ig.Id);
                }
            }
            return POLICY_ISSUING_GROUP_ID_BY_CODE;
        }
        set;
    }

    /**
    * @description retrieve Policy Issuing Group by Id map
    * @author      Kejia Hu
    * @date        12/11/2019                     
    */
    public static final Map<String, PolicyIssuingGroup__c> POLICY_ISSUING_GROUP_BY_ID {
        get{
            if (null == POLICY_ISSUING_GROUP_BY_ID) {
                POLICY_ISSUING_GROUP_BY_ID = new Map<String, PolicyIssuingGroup__c>();
                if (null == policyIssuingGroups) {
                    policyIssuingGroups = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c, Business_Name_EN_CA__c, Business_Name_FR_CA__c FROM PolicyIssuingGroup__c];
                }
                for (PolicyIssuingGroup__c ig : policyIssuingGroups) {
                    POLICY_ISSUING_GROUP_BY_ID.put(ig.Id, ig);
                }
            }
            return POLICY_ISSUING_GROUP_BY_ID;
        }
        set;
    }

    /**
    * @description retrieve Policy Branch Id by Type Code map
    * @author      Kejia Hu
    * @date        06/09/2019                     
    */
    public static final Map<String, String> POLICY_BRANCH_ID_BY_CODE {
        get{
            if (null == POLICY_BRANCH_ID_BY_CODE) {
                POLICY_BRANCH_ID_BY_CODE = new Map<String, String>();
                if (null == policyBranches) {
                    policyBranches = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM PolicyBranch__c];
                }
                for (PolicyBranch__c pb : policyBranches) {
                    POLICY_BRANCH_ID_BY_CODE.put(pb.TypeCode__c, pb.Id);
                }
            }
            return POLICY_BRANCH_ID_BY_CODE;
        }
        set;
    }
	
	    /**
    * @description retrieve role nature by Id map
    * @author      Vikas Sharma
    * @date        13/08/2019                     
    */
    public static final Map<String, ContactRole__c> ROLE_NATURE_BY_ID {
        get{
            if (null == ROLE_NATURE_BY_ID) {
                ROLE_NATURE_BY_ID = new Map<String, ContactRole__c>();
                if (null == contactRoles) {
                    contactRoles = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM ContactRole__c];
                }
                for (ContactRole__c rn : contactRoles) {
                    ROLE_NATURE_BY_ID.put(rn.Id, rn);
                }
            }
            return ROLE_NATURE_BY_ID;
        }
        set;
    }
  
    /**
    * @description retrieve Exposure Type by Id map
    * @author      Vikas Sharma
    * @date        13/08/2019                     
    */
    public static final Map<String, ExposureType__c> EXPOSURE_TYPE_BY_ID  {
        get{
            if (null == EXPOSURE_TYPE_BY_ID) {
                EXPOSURE_TYPE_BY_ID = new Map<String, ExposureType__c>();
                if (null == exposureTypes) {
                    exposureTypes = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM ExposureType__c];
                }
                for (ExposureType__c rn : exposureTypes) {
                    EXPOSURE_TYPE_BY_ID.put(rn.Id, rn);
                }
            }
            return EXPOSURE_TYPE_BY_ID;
        }
        set;
    }

    /**
    * @description retrieve Policy Branch Id by Type Code map
    * @author      Kejia Hu
    * @date        06/09/2019                     
    */
    public static final Map<Id, PolicyBranch__c> POLICY_BRANCH_BY_ID {
        get{
            if (null == POLICY_BRANCH_BY_Id) {
                POLICY_BRANCH_BY_Id = new Map<Id, PolicyBranch__c>();
                if (null == policyBranches) {
                    policyBranches = [SELECT Id, Name, TypeCode__c, L_EN_CA__c, L_FR_CA__c FROM PolicyBranch__c];
                }
                for (PolicyBranch__c pb : policyBranches) {
                    POLICY_BRANCH_BY_Id.put(pb.Id, pb);
                }
            }
            return POLICY_BRANCH_BY_Id;
        }
        set;
    }
}