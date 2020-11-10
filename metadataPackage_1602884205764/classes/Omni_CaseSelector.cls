/**
* @Description: Selctor for Case sObject
* @Author:      Kejia Hu
* @Date:        17/09/2019
*/
public without sharing class Omni_CaseSelector {
    /**
    * @Description retrieve case records for EOC surveys
    * @Author      Kejia Hu
    * @Date        08/05/2020                     
    */
    public static Map<String, Case> getRoleByRoleId(Set<Id> ids) {
        Map<String, Case> roleByRoleId = new Map<String, Case>();
        List<Case> roles = [SELECT Id, RoleId__c, PIG_EN__c, PIG_Logo_EN__c, ClaimNumber__c, Adjustor_Name__c, Broker_Name__c, Claim_LOB__c, PIG_Name_EN__c, 
                                Party_Name__c, Party_Address_Line__c, Party_City__c, Party_Province__c, Party_Postal_Code__c, LiabilityConfirmed__c, 
                                ProvinceOfIssuanceId__c, PIG_FR__c, PIG_Logo_FR__c, PIG_Name_FR__c, ClaimForRole__c, ExposureForRole__c, PartyContact__c, 
                                PartyContact__r.FirstName, PartyContact__r.LastName, PartyContact__r.Email, PartyAccount__c, RoleNature__c
                            FROM Case
                            WHERE Id IN :ids];
        if (!roles.isEmpty()) {
            for (Case role : roles) {
                roleByRoleId.put(role.RoleId__c, role);
            }
        }
        return roleByRoleId;
    }

    /**
    * @Description retrieve shadow roles by claim Ids
    * @Author      Kejia Hu
    * @Date        04/05/2020                     
    */
    public static Map<String, List<Case>> getShadowRolesByClaimId(Set<String> claimIds) {
        Map<String, List<Case>> shadowRolesByClaimId = new Map<String, List<Case>>();
        List<Case> shadowRoles = [SELECT Id, ClaimForRole__c, OriginRoleForShadow__c, OwnerId, ExposureForRole__c, 
                                    ClaimForRole__r.ClaimId__c, RoleId__c, RoleNature__c 
                                  FROM Case
                                  WHERE ClaimForRole__r.ClaimId__c IN :claimIds
                                  AND RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE];
        if (!shadowRoles.isEmpty()) {
            for (Case oneRole : shadowRoles) {
                if (shadowRolesByClaimId.containsKey(oneRole.ClaimForRole__r.ClaimId__c)) {
                    shadowRolesByClaimId.get(oneRole.ClaimForRole__r.ClaimId__c).add(oneRole);
                } else {
                    shadowRolesByClaimId.put(oneRole.ClaimForRole__r.ClaimId__c, new List<Case>{oneRole});
                }
            }
        }
        return shadowRolesByClaimId;
    }
    
    /**
    * @Description retrieve case records with minimum information
    * @Author      Kejia Hu
    * @Date        30/01/2020                     
    */
    public static Map<String, Case> getMinCaseInfo(Set<Id> ids) {
        return new Map<String, Case>([SELECT Id, ExposureType__c, ClaimForExposure__c, RecordTypeId, OwnerId, ClaimNumber__c FROM Case WHERE Id IN :ids]);
    }

    /**
    * @Description retrieve Claim/Exposure records for the given DEA address
    * @Author      Kejia Hu
    * @Date        30/01/2020                     
    */
    public static Map<String, Case> getMasterCasesFromDEAAddresses(Set<String> addresses) {   
        Map<String, Case> masterCaseByDEAKey = new Map<String, Case>();
        String deaSuffix = Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('DEA_Email_Address_Domain');
        Set<String> claimNumbers = getClaimNumberFromDEAAddresses(addresses);
        List<Case> cases = [SELECT Id, ClaimNumber__c, ClaimForRole__c, ExposureForRole__c, PartyAccount__c, PartyContact__c, 
                                    RecordTypeId, RoleNature__r.Name, ExposureForRole__r.ExposureType__c,
                                    OriginRoleForShadow__c, ClaimForExposure__c, ExposureType__c, OwnerId, ReferenceNumber__c,
                                    (SELECT Id, ClaimNumber__c, ClaimForRole__c, ExposureForRole__c, PartyAccount__c, PartyContact__c, 
                                        RecordTypeId, RoleNature__r.Name, ExposureForRole__r.ExposureType__c,
                                        OriginRoleForShadow__c, ClaimForExposure__c, ExposureType__c, OwnerId, ReferenceNumber__c 
                                     FROM ExposuresByClaim__r
                                    )  
                                FROM Case
                                WHERE ClaimNumber__c IN :claimNumbers
                                AND Retired__c = False 
                                AND RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM
                            ];
        
        if (!cases.isEmpty()) {
            for (Case c : cases) {
                masterCaseByDEAKey.put((c.ClaimNumber__c + deaSuffix).toUpperCase(), c);
                String claimNumberOnClaim = c.ClaimNumber__c;
                if (null!= c.ExposuresByClaim__r || !c.ExposuresByClaim__r.isEmpty()) {
                    for (Case exposure : c.ExposuresByClaim__r) {
                        if (exposure.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS) {
                            masterCaseByDEAKey.put((claimNumberOnClaim + '-ab' + exposure.ReferenceNumber__c + deaSuffix).toUpperCase(), exposure);
                        }
                        if (exposure.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_BI) {
                            masterCaseByDEAKey.put((claimNumberOnClaim + '-bi' + exposure.ReferenceNumber__c + deaSuffix).toUpperCase(), exposure);
                        }
                    }
                }
            }
        }
        return masterCaseByDEAKey;
    }

    /**
    * @Description retrieve claim numbers from the given DEA address
    * @Author      Kejia Hu
    * @Date        16/04/2020                     
    */
    public static Set<String> getClaimNumberFromDEAAddresses(Set<String> addresses) {
        Set<String> claimNumbers = new Set<String>();
        for (String address : addresses) {
            if (address.substringBefore('@').contains('-')) {
                claimNumbers.add(address.substringBefore('-'));
            } else {
                claimNumbers.add(address.substringBefore('@'));
            }
        }
        return claimNumbers;

    }

    /**
    * @Description retrieve Role, Email Case, Claim (Case) and Exposure (Cases) records from Case records Ids Set
    * @Author      Kejia Hu
    * @Date        21/01/2020                     
    */
    public static Map<String, Case> getRoleClaimExpoEmailByIdFromCaseIds(Set<String> caseIds) {
        Map<String, Case> roleClaimExpoEmailById = new Map<String, Case>();
        List<Case> roleClaimExpoEmailCases =  [SELECT Id, ClaimForRole__c, ExposureForRole__c, PartyAccount__c, PartyContact__c, 
                                    RecordTypeId, RoleNature__r.Name, ExposureForRole__r.ExposureType__c,
                                    OriginRoleForShadow__c, ClaimForExposure__c, ExposureType__c, OwnerId
                             FROM Case 
                             WHERE Id IN :caseIds 
                             AND (RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE 
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_ADHOC_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_BI
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EMAIL_CASE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM
                                 )
                             FOR UPDATE
                            ];
        if(!roleClaimExpoEmailCases.isEmpty()) {
            for(Case roleOrClaimOrExpoOrEmail : roleClaimExpoEmailCases) {
                roleClaimExpoEmailById.put(roleOrClaimOrExpoOrEmail.Id, roleOrClaimOrExpoOrEmail);
            }
        }
        return roleClaimExpoEmailById;
    }

    /**
    * @Description retrieve Role, Email Case and Exposure (Cases) records from Case records Ids Set
    * @Author      Kejia Hu
    * @Date        21/01/2020                     
    */
    public static Map<String, Case> getRoleExpoEmailByIdFromCaseIds(Set<String> caseIds) {
        Map<String, Case> roleExpoEmailById = new Map<String, Case>();
        List<Case> roleExpoEmails =  [SELECT Id, ClaimForRole__c, ExposureForRole__c, PartyAccount__c, PartyContact__c, 
                                    RecordTypeId, RoleNature__r.Name, ExposureForRole__r.ExposureType__c,
                                    OriginRoleForShadow__c, ClaimForExposure__c, ExposureType__c, OwnerId
                             FROM Case 
                             WHERE Id IN :caseIds 
                             AND (RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE 
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_ADHOC_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_BI
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_BENEFITS
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EMAIL_CASE
                                 )
                             FOR UPDATE
                            ];
        if(!roleExpoEmails.isEmpty()) {
            for(Case roleOrExpoOrEmail : roleExpoEmails) {
                roleExpoEmailById.put(roleOrExpoOrEmail.Id, roleOrExpoOrEmail);
            }
        }
        return roleExpoEmailById;
    }
    
    /**
    * @description retrieve Role (Case) record from Case records Ids Set
    * @author      Kejia Hu
    * @date        17/09/2019                     
    */
    public static Map<String, Case> getRoleByIdFromCaseIds(Set<String> caseIds) {
        Map<String, Case> roleById = new Map<String, Case>();
        List<Case> roles =  [SELECT Id, ClaimForRole__c, ExposureForRole__c, PartyAccount__c, PartyContact__c, 
                                    RecordTypeId, RoleNature__r.Name, ExposureForRole__r.ExposureType__c,
                                    OriginRoleForShadow__c
                             FROM Case 
                             WHERE Id IN :caseIds 
                             AND (RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE 
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_ADHOC_ROLE
                                 )
                             FOR UPDATE
                            ];
        if(!roles.isEmpty()) {
            for(Case role : roles) {
                roleById.put(role.Id, role);
            }
        }
        return roleById;
    }

    /**
    * @description retrieve Role (Case) records and Email Case reocrds from Ids Set
    * @author      Kejia Hu
    * @date        27/01/2020                     
    */
    public static Map<Id, Case> getRoleEmailCaseByIdFromCaseIds(Set<String> caseIds) {
        return new Map<Id, Case>(
                            [SELECT Id, ClaimForRole__c, ExposureForRole__c, PartyAccount__c, PartyContact__c, 
                                    RecordTypeId, RoleNature__r.Name, ExposureForRole__r.ExposureType__c,
                                    OriginRoleForShadow__c
                             FROM Case 
                             WHERE Id IN :caseIds 
                             AND (RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE 
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE
                                  OR RecordTypeId = :Omni_ClaimEventConstant.RECORD_TYPE_ID_EMAIL_CASE
                                 )
                             FOR UPDATE
                            ]
        );
    }

     /**
    * @description Retrieve case informations by Ids
    * @author      Damian Kazior
    * @date        14/09/2019                     
    */
    public static Map<Id, Case> getCaseById(List<String> caseIds) {
        Map<Id, Case> cases = new Map<Id, Case>([SELECT ExposureType__c, DEAForRole__c, Party_First_Name__c, Party_Last_Name__c, OwnerId, Owner.isActive
                                                            FROM Case 
                                                            WHERE Id IN:caseIds
                                                            FOR UPDATE]);
        return cases;                                                        
    }

    /**
    * @description Retrieve minimum case informations by Ids
    * @author      Kejia Hu
    * @date        23/01/2020                     
    */
    public static Map<Id, Case> getCaseByIdForMerge(List<String> caseIds) {
        Map<Id, Case> cases = new Map<Id, Case>([SELECT ExposureType__c, RecordTypeId, ClaimForExposure__c
                                                            FROM Case 
                                                            WHERE Id IN:caseIds
                                                            FOR UPDATE]);
        return cases;                                                        
    }

    /**
    * @description Retrieve case details informations by Ids, including user/claim/exposure reference values
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    public static Map<Id, Case> getCaseDetailsById(Set<Id> caseIds) {
        Map<Id, Case> cases = new Map<Id, Case>([
                                SELECT ClaimForRole__r.Additional_Insured__c, ClaimForRole__r.AppraisalQualifier__c, ClaimForRole__r.AppraisalTaskStatus__c 
                                    , ClaimForRole__r.Appraisal_Appointment_Date__c, ClaimForRole__r.Appraisal_Appointment_Time__c, ClaimForRole__r.InjuriesInvolved__c
                                    , ClaimForRole__r.PolicyBranch__r.L_EN_CA__c, ClaimForRole__r.PolicyBranch__r.L_FR_CA__c, ClaimForRole__r.AgentParty__r.Name
                                    , ClaimForRole__r.ClaimContractEffectiveDate__c, ClaimForRole__r.ClaimLOBGroup__c 
                                    , ClaimForRole__r.ClaimNumber__c, ClaimForRole__r.Claim_LOB__c, ClaimForRole__r.ClientPIN__c, ClaimForRole__r.NonCasualtyCoverageInQuestion__c
                                    , ClaimForRole__r.AssignedForCoverageVehicleId__r.Make__c, ClaimForRole__r.AssignedForCoverageVehicleId__r.Model__c
                                    , ClaimForRole__r.AssignedForCoverageVehicleId__r.SerialNumber__c, ClaimForRole__r.AssignedForCoverageVehicleId__r.ModelYear__c, ClaimForRole__r.DateOfLoss__c
                                    , ClaimForRole__r.DeductibleAmount__c, ClaimForRole__r.DeductibleAmountCurrencyCode__c, ClaimForRole__r.AssignedDriverParty__r.FirstName
                                    , ClaimForRole__r.AssignedDriverParty__r.LastName, ClaimForRole__r.IncidentDateReported__c, ClaimForRole__r.InformationSensitivity__c
                                    , ClaimForRole__r.Initial_Gross_Estimate_Amount__c, ClaimForRole__r.Initial_Gross_Estimate_Currency__c
                                    , ClaimForRole__r.InjuredPartyRole__r.L_EN_CA__c, ClaimForRole__r.InjuredPartyRole__r.Description__c
                                    , ClaimForRole__r.InjuredPartyRole__r.TypeCode__c, ClaimForRole__r.InsuredProbableFaultPercentage__c
                                    , ClaimForRole__r.InsuredParty__r.FirstName, ClaimForRole__r.InsuredParty__r.LastName, ClaimForRole__r.LiabilityConfirmed__c
                                    , ClaimForRole__r.LossCause__r.TypeCode__c, ClaimForRole__r.IncidentAddressLine__c, ClaimForRole__r.IncidentCity__c, ClaimForRole__r.IncidentProvince__c  
                                    , ClaimForRole__r.IncidentPostalCode__c, ClaimForRole__r.IncidentCountry__c
                                    , ClaimForRole__r.TypeOfLoss__r.TypeCode__c, ClaimForRole__r.LossCause__r.Description__c, ClaimForRole__r.LossCause__r.L_EN_CA__c
                                    , ClaimForRole__r.LossCause__r.L_FR_CA__c, ClaimForRole__r.TypeOfLoss__r.Description__c, ClaimForRole__r.TypeOfLoss__r.L_EN_CA__c
                                    , ClaimForRole__r.TypeOfLoss__r.L_FR_CA__c, ClaimForRole__r.Account.PersonMailingStreet, ClaimForRole__r.Account.PersonMailingCity
                                    , ClaimForRole__r.Account.FirstName, ClaimForRole__r.Account.LastName, ClaimForRole__r.Account.PersonMailingPostalCode
                                    , ClaimForRole__r.Account.State__r.L_EN_CA__c, ClaimForRole__r.Account.State__r.L_FR_CA__c, ClaimForRole__r.Policy_Issuing_Group__r.Business_Name_EN_CA__c
                                    , ClaimForRole__r.Policy_Issuing_Group__r.Business_Name_FR_CA__c, ClaimForRole__r.Policy_Issuing_Group__r.L_EN_CA__c
                                    , ClaimForRole__r.Policy_Issuing_Group__r.L_FR_CA__c, ClaimForRole__r.Policy_Issuing_Group__r.TypeCode__c, ClaimForRole__r.PolicyNumber__c
                                    , ClaimForRole__r.UnderwritingCompany__c, ClaimForRole__r.ProvinceOfIssuance__r.TypeCode__c, ClaimForRole__r.RenterParty__r.Name
                                    , ClaimForRole__r.RenterParty__r.BillingStreet, ClaimForRole__r.RenterParty__r.BillingCity, ClaimForRole__r.RenterParty__r.Country__r.L_FR_CA__c
                                    , ClaimForRole__r.RenterParty__r.Country__r.L_EN_CA__c, ClaimForRole__r.RenterParty__r.Extension__c, ClaimForRole__r.RenterParty__r.Phone
                                    , ClaimForRole__r.RenterParty__r.BillingPostalCode, ClaimForRole__r.RenterParty__r.State__r.L_FR_CA__c, ClaimForRole__r.RenterParty__r.State__r.L_EN_CA__c
                                    , ClaimForRole__r.Rental_Limit__c, ClaimForRole__r.DamageRepairParty__r.BillingCity, ClaimForRole__r.DamageRepairParty__r.Name
                                    , ClaimForRole__r.DamageRepairParty__r.BillingStreet, ClaimForRole__r.DamageRepairParty__r.BillingPostalCode, ClaimForRole__r.DamageRepairParty__r.State__r.L_FR_CA__c
                                    , ClaimForRole__r.DamageRepairParty__r.State__r.L_EN_CA__c, ClaimForRole__r.DamageRepairParty__r.Phone, ClaimForRole__r.DamageRepairParty__r.Extension__c
                                    , ClaimForRole__r.SellingChannelDistributorNumber__c, ClaimForRole__r.TotalLoss__c, ClaimForRole__r.VirtualAppraisal__c, ClaimForRole__r.NonCasualtyWithoutPrejudice__c  
                                    , ClaimForRole__r.LossVehicle__r.Make__c, ClaimForRole__r.LossVehicle__r.Model__c, ClaimForRole__r.LossVehicle__r.ModelYear__c
                                    , ClaimForRole__r.AppraiserParty__r.BillingStreet, ClaimForRole__r.AppraiserParty__r.BillingCity, ClaimForRole__r.AppraiserParty__r.Name
                                    , ClaimForRole__r.AppraiserParty__r.BillingPostalCode, ClaimForRole__r.AppraiserParty__r.State__r.L_FR_CA__c, ClaimForRole__r.AppraiserParty__r.State__r.L_EN_CA__c
                                    , ClaimForRole__r.AppraiserParty__r.Phone, ClaimForRole__r.AppraiserParty__r.Extension__c
                                    , ExposureForRole__r.LastPaymentTransaction__r.Amount__c, ExposureForRole__r.LastPaymentTransaction__r.EffectiveDateEN__c 
                                    , ExposureForRole__r.LastPaymentTransaction__r.EffectiveDateFR__c, ExposureForRole__r.LastPaymentTransaction__r.NameOnInstrument__c
                                    , ExposureForRole__r.ExposureType__r.L_EN_CA__c, ExposureForRole__r.ExposureType__r.L_FR_CA__c, ExposureForRole__r.Exposure_Number_Order__c
                                    , ExposureForRole__r.ExposureType__r.TypeCode__c, ExposureForRole__r.ExposureId__c
                                    , PartyAccount__r.Name, PartyAccount__r.Phone, PartyAccount__r.Fax, PartyAccount__r.Language__c, PartyAccount__r.FirstName
                                    , PartyAccount__r.State__r.L_FR_CA__c, PartyAccount__r.State__r.L_EN_CA__c 
                                    , PartyContact__r.LastName, PartyContact__r.MailingPostalCode, PartyContact__r.Email, PartyContact__r.MailingStreet, PartyContact__r.MailingCity 
                                    , RoleNature__r.L_EN_CA__c, RoleNature__r.L_FR_CA__c, RoleId__c 
                                FROM Case 
                                WHERE Id IN:caseIds]);
        return cases;                                                        
    }

    /**
    * @description Retrieve Claim Exposure details informations by Ids
    * @date        16/10/2019                     
    */
    public static Map<Id, Case> getClaimExpoDetailsById(Set<Id> caseIds) {
        Map<Id, Case> cases = new Map<Id, Case>([
                                SELECT Additional_Insured__c, AppraisalQualifier__c, AppraisalTaskStatus__c 
                                    , Appraisal_Appointment_Date__c, Appraisal_Appointment_Time__c, InjuriesInvolved__c
                                    , PolicyBranch__r.L_EN_CA__c, PolicyBranch__r.L_FR_CA__c, AgentParty__r.Name
                                    , ClaimContractEffectiveDate__c, ClaimLOBGroup__c 
                                    , ClaimNumber__c, Claim_LOB__c, ClientPIN__c, NonCasualtyCoverageInQuestion__c
                                    , AssignedForCoverageVehicleId__r.Make__c, AssignedForCoverageVehicleId__r.Model__c
                                    , AssignedForCoverageVehicleId__r.SerialNumber__c, AssignedForCoverageVehicleId__r.ModelYear__c, DateOfLoss__c
                                    , DeductibleAmount__c, DeductibleAmountCurrencyCode__c, AssignedDriverParty__r.FirstName
                                    , AssignedDriverParty__r.LastName, IncidentDateReported__c, InformationSensitivity__c
                                    , Initial_Gross_Estimate_Amount__c, Initial_Gross_Estimate_Currency__c
                                    , InjuredPartyRole__r.L_EN_CA__c, InjuredPartyRole__r.Description__c
                                    , InjuredPartyRole__r.TypeCode__c, InsuredProbableFaultPercentage__c
                                    , InsuredParty__r.FirstName, InsuredParty__r.LastName, LiabilityConfirmed__c
                                    , LossCause__r.TypeCode__c, IncidentAddressLine__c, IncidentCity__c, IncidentProvince__c  
                                    , IncidentPostalCode__c, IncidentCountry__c
                                    , TypeOfLoss__r.TypeCode__c, LossCause__r.Description__c, LossCause__r.L_EN_CA__c
                                    , LossCause__r.L_FR_CA__c, TypeOfLoss__r.Description__c, TypeOfLoss__r.L_EN_CA__c
                                    , TypeOfLoss__r.L_FR_CA__c, Account.PersonMailingStreet, Account.PersonMailingCity
                                    , Account.FirstName, Account.LastName, Account.PersonMailingPostalCode
                                    , Account.State__r.L_EN_CA__c, Account.State__r.L_FR_CA__c, Policy_Issuing_Group__r.Business_Name_EN_CA__c
                                    , Policy_Issuing_Group__r.Business_Name_FR_CA__c, Policy_Issuing_Group__r.L_EN_CA__c
                                    , Policy_Issuing_Group__r.L_FR_CA__c, Policy_Issuing_Group__r.TypeCode__c, PolicyNumber__c
                                    , UnderwritingCompany__c, ProvinceOfIssuance__r.TypeCode__c, RenterParty__r.Name
                                    , RenterParty__r.BillingStreet, RenterParty__r.BillingCity, RenterParty__r.Country__r.L_FR_CA__c
                                    , RenterParty__r.Country__r.L_EN_CA__c, RenterParty__r.Extension__c, RenterParty__r.Phone
                                    , RenterParty__r.BillingPostalCode, RenterParty__r.State__r.L_FR_CA__c, RenterParty__r.State__r.L_EN_CA__c
                                    , Rental_Limit__c, DamageRepairParty__r.BillingCity, DamageRepairParty__r.Name
                                    , DamageRepairParty__r.BillingStreet, DamageRepairParty__r.BillingPostalCode, DamageRepairParty__r.State__r.L_FR_CA__c
                                    , DamageRepairParty__r.State__r.L_EN_CA__c, DamageRepairParty__r.Phone, DamageRepairParty__r.Extension__c
                                    , SellingChannelDistributorNumber__c, TotalLoss__c, VirtualAppraisal__c, NonCasualtyWithoutPrejudice__c  
                                    , LossVehicle__r.Make__c, LossVehicle__r.Model__c, LossVehicle__r.ModelYear__c
                                    , AppraiserParty__r.BillingStreet, AppraiserParty__r.BillingCity, AppraiserParty__r.Name
                                    , AppraiserParty__r.BillingPostalCode, AppraiserParty__r.State__r.L_FR_CA__c, AppraiserParty__r.State__r.L_EN_CA__c
                                    , AppraiserParty__r.Phone, AppraiserParty__r.Extension__c
                                    , LastPaymentTransaction__r.Amount__c, LastPaymentTransaction__r.EffectiveDateEN__c 
                                    , LastPaymentTransaction__r.EffectiveDateFR__c, LastPaymentTransaction__r.NameOnInstrument__c
                                    , ExposureType__r.L_EN_CA__c, ExposureType__r.L_FR_CA__c, Exposure_Number_Order__c
                                    , ExposureType__r.TypeCode__c
                                    , ExposureId__c
                                    , RoleNature__r.L_EN_CA__c, RoleNature__r.L_FR_CA__c, RoleId__c 
                                FROM Case 
                                WHERE Id IN:caseIds]);
        return cases;                                                        
    }
    
     /**
    * @description Find claim by partial claim number
    * @author      Damian Kazior
    * @date        20/12/2019                     
    */
    public static Map<Id, Case> getClaimsByPartialKey(String partialKey, String recordTypeId){
        Map<Id, Case> claims = new Map<Id, Case>(
            [SELECT Id, ClaimNumber__c from Case 
            WHERE ClaimNumber__c LIKE :partialKey AND RecordTypeId =: recordTypeId AND Retired__c = False 
            Order By CreatedDate DESC limit 3]);
        return claims;
    }

    /**
    * @description Retrieve Exposures related to multiple Claims
    * @author      Damian Kazior
    * @date        20/12/2019                     
    */  
    public static List<Case> getExposuresFromClaims(Set<Id> claimIds, List<String> exposuresRTIds){
        return [SELECT Id, ExposureType__r.Name, RecordType.Name, CaseNumber 
                FROM Case 
                WHERE ClaimForExposure__c IN :claimIds and RecordtypeId IN:exposuresRTIds];
    }

    /**
    * @description Retrieve Exposures related to multiple Claims
    * @author      Damian Kazior
    * @date        20/12/2019                     
    */   
    public static Map<Id, Case> getCasesByIds(Set<Id> caseIds){
        return new Map<Id, Case>([SELECT Id, ClaimNumber__c, CaseNumber, ownerId, owner.isActive, Tasks_Status__c, RecordType.DeveloperName, RecordTypeId, ExposureType__c, 
                                         ClaimForExposure__c, AssignedUserId__c, Claim_LOB__c, ClaimForExposure__r.Claim_LOB__c, ClaimForExposure__r.ClaimNumber__c, ProvinceOfIssuance__r.TypeCode__c, 
                                         ClaimForExposure__r.ProvinceOfIssuance__r.TypeCode__c, ClaimantFirstName__c, ClaimantLastName__c, Insured_First_Name__c, Insured_Last_Name__c,
                                         ClaimForExposure__r.Insured_First_Name__c, ClaimForExposure__r.Insured_Last_Name__c,
                                         ExposureType__r.L_EN_CA__c, ExposureType__r.L_FR_CA__c, InsuredParty__r.Name, ClaimForExposure__r.InsuredParty__r.Name, Claimant__r.Name
                FROM Case 
                WHERE Id IN :caseIds]); 
    }

    /**
    * @description Retrieve Exposures related to multiple Claims
    * @author      Damian Kazior
    * @date        20/12/2019                     
    */  
    public static List<Case> getParentCasesByRoles(List<Id> roles){
        return [SELECT Id, RecordTypeId, OwnerId, ClaimForRole__c, ClaimForExposure__r.OwnerId, ExposureForRole__r.OwnerId
                FROM Case
                WHERE Id IN:roles]; 
    }

    /**
    * @description Retrieve Exposures related to multiple Claims
    * @author      Damian Kazior
    * @date        20/12/2019                     
    */  
    public static List<Case> getCaseAccountInformationById(Id caseId){
        return [SELECT PartyAccount__c, PartyAccount__r.Phone FROM Case WHERE Id = : caseId]; 
    }
    
	/**
	* @description Retrieve Adhoc Shadow Role Cases related to the exposure
    * @author      Luis Merinero
    * @date        30/01/2020                    
    */
    public static List<Case> getAdhocRoleByExposureAndOriginRole(String roleId, String exposureId){
        String ADHOC_ROLE_RT_ID = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_ADHOC_ROLE;
        return [SELECT id FROM Case 
                WHERE recordTypeId = :ADHOC_ROLE_RT_ID 
                AND ExposureForRole__c = :exposureId
                AND OriginRoleForShadow__c = :roleId];
    }
}