/**
* @description Helper class for CaseTriggerHandler
*              This class is retired, logic now is done in PE mapping directly
* @author      Kejia Hu
* @date        16/10/2019                     
*/
public with sharing class CaseTriggerHandlerHelper {

    /**
    * @description retrieve Set of Case Id from role list
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Case populateRoleWithReference(Case role, Case roleWithRef, User u) {
    //     role.Additional_Insured__c = (null!=roleWithRef.ClaimForRole__c) 
    //                                     ? roleWithRef.ClaimForRole__r.Additional_Insured__c
    //                                     : null;
    //     if( null != u ) {
    //         role.Adjuster_Address_Line1__c = u.Street;
    //         role.Adjuster_City__c = u.City;
    //         role.Adjuster_Postal_Code__c = u.PostalCode;
    //         role.Adjuster_Title_1_FR__c = u.Title_1_FR__c;
    //         role.Adjuster_Title_2_FR__c = u.Title_2_FR__c;
    //         role.Adjustor_Company_Name__c = u.CompanyName;
    //         role.Adjustor_Email_Address__c = u.Email;
    //         role.Adjustor_Fax_Number__c = u.Fax;
    //         role.Adjustor_Name__c = u.Name;
    //         role.Adjustor_Phone__c = u.Phone;
    //         role.Adjustor_Province__c = u.State;
    //         role.Adjustor_Title1__c = u.Title_1__c;
    //         role.Adjustor_Title2__c = u.Title_2__c;
    //         role.Adjustor_Address__c = u.Street + ', ' + u.City + ', ' +u.State + ', ' + u.PostalCode;
    //     }
    //     role.InjuriesInvolved__c = roleWithRef.ClaimForRole__r.InjuriesInvolved__c;
    //     role.AppraisalQualifier__c = roleWithRef.ClaimForRole__r.AppraisalQualifier__c;
    //     role.AppraisalTaskStatus__c = roleWithRef.ClaimForRole__r.AppraisalTaskStatus__c;
    //     role.Appraisal_Appointment_Date__c = roleWithRef.ClaimForRole__r.Appraisal_Appointment_Date__c;
    //     role.Appraisal_Appointment_Time__c = roleWithRef.ClaimForRole__r.Appraisal_Appointment_Time__c;
    //     role.AppraiserPartyName_for_Role__c = roleWithRef.ClaimForRole__r.AppraiserParty__r.Name;
    //     role.Broker_Branch_EN__c = roleWithRef.ClaimForRole__r.PolicyBranch__r.L_EN_CA__c;
    //     role.Broker_Branch_FR__c = roleWithRef.ClaimForRole__r.PolicyBranch__r.L_FR_CA__c;
    //     role.Broker_Name__c = roleWithRef.ClaimForRole__r.AgentParty__r.Name;
    //     role.Cellular_Phone_Number__c = roleWithRef.PartyAccount__r.Phone;
    //     role.Cheque_Issued_Amount_for_Role__c = roleWithRef.ExposureForRole__r.LastPaymentTransaction__r.Amount__c;
    //     role.Cheque_Issued_Date_EN__c = roleWithRef.ExposureForRole__r.LastPaymentTransaction__r.EffectiveDateEN__c;
    //     role.Cheque_Issued_Date_FR__c = roleWithRef.ExposureForRole__r.LastPaymentTransaction__r.EffectiveDateFR__c;
    //     role.Cheque_Payee_for_Role__c = roleWithRef.ExposureForRole__r.LastPaymentTransaction__r.NameOnInstrument__c;
    //     role.ClaimContractEffectiveDate__c = roleWithRef.ClaimForRole__r.ClaimContractEffectiveDate__c;
    //     role.ClaimLOBGroup__c = roleWithRef.ClaimForRole__r.ClaimLOBGroup__c;
    //     role.ClaimNumber__c = roleWithRef.ClaimForRole__r.ClaimNumber__c;
    //     role.Claim_LOB__c = roleWithRef.ClaimForRole__r.Claim_LOB__c;
    //     role.ClientPIN__c = roleWithRef.ClaimForRole__r.ClientPIN__c;
    //     role.CoverageInQuestion__c = roleWithRef.ClaimForRole__r.NonCasualtyCoverageInQuestion__c;
    //     role.CoverageVehicleMake_for_Role__c = roleWithRef.ClaimForRole__r.AssignedForCoverageVehicleId__r.Make__c;
    //     role.CoverageVehicleModel_for_Role__c = roleWithRef.ClaimForRole__r.AssignedForCoverageVehicleId__r.Model__c;
    //     role.CoverageVehicleVIN_for_Role__c = roleWithRef.ClaimForRole__r.AssignedForCoverageVehicleId__r.SerialNumber__c;
    //     role.CoverageVehicleYear_for_Role__c = roleWithRef.ClaimForRole__r.AssignedForCoverageVehicleId__r.ModelYear__c;
    //     role.DateOfLoss__c = roleWithRef.ClaimForRole__r.DateOfLoss__c;
    //     role.DeductibleAmount__c = roleWithRef.ClaimForRole__r.DeductibleAmount__c;
    //     role.DeductibleAmountCurrencyCode__c = roleWithRef.ClaimForRole__r.DeductibleAmountCurrencyCode__c;
    //     role.Driver_Name__c = (String.isBlank(roleWithRef.ClaimForRole__r.AssignedDriverParty__c))
    //                             ? null
    //                             : roleWithRef.ClaimForRole__r.AssignedDriverParty__r.FirstName + ' ' + roleWithRef.ClaimForRole__r.AssignedDriverParty__r.LastName;
    //     role.Email_Address_for_Role__c = roleWithRef.PartyContact__r.Email;
    //     role.ExposureName_EN_for_Role__c = roleWithRef.ExposureForRole__r.ExposureType__r.L_EN_CA__c;
    //     role.ExposureName_FR_for_Role__c = roleWithRef.ExposureForRole__r.ExposureType__r.L_FR_CA__c;
    //     role.Exposure_Number_Order__c = roleWithRef.ExposureForRole__r.Exposure_Number_Order__c;
    //     role.Exposure_Type__c = (String.isBlank(roleWithRef.ExposureForRole__r.ExposureType__c))
    //                                 ? null
    //                                 : roleWithRef.ExposureForRole__r.ExposureType__r.L_EN_CA__c + ' ' + roleWithRef.ExposureForRole__r.ExposureType__r.L_FR_CA__c;
    //     role.Exposure_Type_for_Role__c = roleWithRef.ExposureForRole__r.ExposureType__r.TypeCode__c;
    //     role.ExposureIdForRole__c = roleWithRef.ExposureForRole__r.ExposureId__c;
    //     role.Fax_Number__c = roleWithRef.PartyAccount__r.Fax;
    //     role.IncidentDateReported__c = roleWithRef.ClaimForRole__r.IncidentDateReported__c;
    //     role.InformationSensitivity__c = roleWithRef.ClaimForRole__r.InformationSensitivity__c;
    //     role.Initial_Gross_Estimate_Amount__c = roleWithRef.ClaimForRole__r.Initial_Gross_Estimate_Amount__c;
    //     role.Initial_Gross_Estimate_Currency__c = roleWithRef.ClaimForRole__r.Initial_Gross_Estimate_Currency__c;
    //     role.InjuredPartyRoleDescriptionEN__c = roleWithRef.ClaimForRole__r.InjuredPartyRole__r.L_EN_CA__c;
    //     role.InjuredPartyRoleDescription__c = roleWithRef.ClaimForRole__r.InjuredPartyRole__r.Description__c;
    //     role.InjuredPartyTypeCode__c = roleWithRef.ClaimForRole__r.InjuredPartyRole__r.TypeCode__c;
    //     role.InsuredProbableFaultPercentage__c = roleWithRef.ClaimForRole__r.InsuredProbableFaultPercentage__c;
    //     role.Insured_First_Name__c = roleWithRef.ClaimForRole__r.InsuredParty__r.FirstName;
    //     role.Insured_Last_Name__c = roleWithRef.ClaimForRole__r.InsuredParty__r.LastName;
    //     role.Language_Preference__c = roleWithRef.PartyAccount__r.Language__c;
    //     role.LiabilityConfirmed__c = roleWithRef.ClaimForRole__r.LiabilityConfirmed__c;
    //     role.LossCauseTypeCode__c = roleWithRef.ClaimForRole__r.LossCause__r.TypeCode__c;
    //     role.LossLocation__c = clearAddressField( 
    //                            getCleanFieldValue(roleWithRef.ClaimForRole__r.IncidentAddressLine__c) + getCleanFieldValue(roleWithRef.ClaimForRole__r.IncidentCity__c)+
    //                            getCleanFieldValue(roleWithRef.ClaimForRole__r.IncidentProvince__c) +  getCleanFieldValue(roleWithRef.ClaimForRole__r.IncidentPostalCode__c) +
    //                            getCleanFieldValue(roleWithRef.ClaimForRole__r.IncidentCountry__c));
    //     role.LossType_TypeCode__c = roleWithRef.ClaimForRole__r.TypeOfLoss__r.TypeCode__c;
    //     role.Loss_Cause_Description__c = roleWithRef.ClaimForRole__r.LossCause__r.Description__c;
    //     role.Loss_Cause_EN__c = roleWithRef.ClaimForRole__r.LossCause__r.L_EN_CA__c;
    //     role.Loss_Cause_FR__c = roleWithRef.ClaimForRole__r.LossCause__r.L_FR_CA__c;
    //     role.Loss_Cause__c = (String.isBlank(roleWithRef.ClaimForRole__r.LossCause__c))
    //                             ? null
    //                             : roleWithRef.ClaimForRole__r.LossCause__r.L_EN_CA__c + ' ' + roleWithRef.ClaimForRole__r.LossCause__r.L_FR_CA__c;
    //     role.Loss_Type_Description__c = roleWithRef.ClaimForRole__r.TypeOfLoss__r.Description__c;
    //     role.Loss_Type_EN_for_Role__c = roleWithRef.ClaimForRole__r.TypeOfLoss__r.L_EN_CA__c;
    //     role.Loss_Type_FR_for_Role__c = roleWithRef.ClaimForRole__r.TypeOfLoss__r.L_FR_CA__c;
    //     role.Loss_Type__c = (String.isBlank(roleWithRef.ClaimForRole__r.TypeOfLoss__c))
    //                             ? null
    //                             : roleWithRef.ClaimForRole__r.TypeOfLoss__r.L_EN_CA__c + '/' + roleWithRef.ClaimForRole__r.TypeOfLoss__r.L_FR_CA__c;
    //     role.Main_Contact_Address_for_Role__c = roleWithRef.ClaimForRole__r.Account.PersonMailingStreet;
    //     role.Main_Contact_City_for_Role__c = roleWithRef.ClaimForRole__r.Account.PersonMailingCity;
    //     role.Main_Contact_First_Name_for_Role__c = roleWithRef.ClaimForRole__r.Account.FirstName;
    //     role.Main_Contact_Last_Name_for_Role__c = roleWithRef.ClaimForRole__r.Account.LastName;
    //     role.Main_Contact_Postal_for_Role__c = roleWithRef.ClaimForRole__r.Account.PersonMailingPostalCode;
    //     role.Main_Contact_Province_for_Role__c = roleWithRef.ClaimForRole__r.Account.State__r.L_EN_CA__c;
    //     role.Main_Contact_Province_for_Role_FR__c = roleWithRef.ClaimForRole__r.Account.State__r.L_FR_CA__c;
    //     role.Nature_of_Role__c = (String.isBlank(roleWithRef.RoleNature__c))
    //                                 ? null
    //                                 : roleWithRef.RoleNature__r.L_EN_CA__c + '/' + roleWithRef.RoleNature__r.L_FR_CA__c;
    //     role.PIGBusinessNameEN__c = roleWithRef.ClaimForRole__r.Policy_Issuing_Group__r.Business_Name_EN_CA__c;
    //     role.PIGBusinessNameFR__c = roleWithRef.ClaimForRole__r.Policy_Issuing_Group__r.Business_Name_FR_CA__c;
    //     role.PIG_EN__c = roleWithRef.ClaimForRole__r.Policy_Issuing_Group__r.L_EN_CA__c;
    //     role.PIG_FR__c = roleWithRef.ClaimForRole__r.Policy_Issuing_Group__r.L_FR_CA__c;
    //     role.PIG_TypeCode__c = roleWithRef.ClaimForRole__r.Policy_Issuing_Group__r.TypeCode__c;
    //     role.Party_Address_Line__c = roleWithRef.PartyContact__r.MailingStreet;
    //     role.Party_City__c = roleWithRef.PartyContact__r.MailingCity;
    //     role.Party_First_Name__c = roleWithRef.PartyAccount__r.FirstName;
    //     role.Party_Last_Name__c = roleWithRef.PartyContact__r.LastName;
    //     role.Party_Postal_Code__c = roleWithRef.PartyContact__r.MailingPostalCode;
    //     role.Party_Province_FR__c = roleWithRef.PartyAccount__r.State__r.L_FR_CA__c;
    //     role.Party_Province__c = roleWithRef.PartyAccount__r.State__r.L_EN_CA__c;
    //     role.PolicyNumber__c = roleWithRef.ClaimForRole__r.PolicyNumber__c;
    //     role.PolicyUnderwritingGroupForRole__c = roleWithRef.ClaimForRole__r.UnderwritingCompany__c;
    //     role.Policy_Holder_First_Last_Name__c = (String.isBlank(roleWithRef.ClaimForRole__r.InsuredParty__c))
    //                                                 ? null
    //                                                 : roleWithRef.ClaimForRole__r.InsuredParty__r.FirstName + ' ' + roleWithRef.ClaimForRole__r.InsuredParty__r.LastName;
    //     role.ProvinceOfIssuanceId__c = roleWithRef.ClaimForRole__r.ProvinceOfIssuance__r.TypeCode__c;
    //     role.RentalCompany_Name_for_Role__c = roleWithRef.ClaimForRole__r.RenterParty__r.Name;
    //     role.Rental_Address_for_Role__c = roleWithRef.ClaimForRole__r.RenterParty__r.BillingStreet;
    //     role.Rental_City_for_Role__c = roleWithRef.ClaimForRole__r.RenterParty__r.BillingCity;
    //     role.Rental_Company_Country_FR__c = roleWithRef.ClaimForRole__r.RenterParty__r.Country__r.L_FR_CA__c;
    //     role.Rental_Company_Country__c = roleWithRef.ClaimForRole__r.RenterParty__r.Country__r.L_EN_CA__c;
    //     role.Rental_Limit__c = roleWithRef.ClaimForRole__r.Rental_Limit__c;
    //     if (!String.isBlank(roleWithRef.ClaimForRole__r.RenterParty__c)) {
    //         role.Rental_Location_Phone__c = (String.isBlank(roleWithRef.ClaimForRole__r.RenterParty__r.Extension__c))
    //                                             ? roleWithRef.ClaimForRole__r.RenterParty__r.Phone
    //                                             : roleWithRef.ClaimForRole__r.RenterParty__r.Phone + ' x' + roleWithRef.ClaimForRole__r.RenterParty__r.Extension__c;
    //     }
    //     role.Rental_PostalCode_for_Role__c = roleWithRef.ClaimForRole__r.RenterParty__r.BillingPostalCode;
    //     role.Rental_Province_for_Role_FR__c = roleWithRef.ClaimForRole__r.RenterParty__r.State__r.L_FR_CA__c;
    //     role.Rental_Province_for_Role__c = roleWithRef.ClaimForRole__r.RenterParty__r.State__r.L_EN_CA__c;
    //     role.Repair_Shop_City_for_Role__c = roleWithRef.ClaimForRole__r.DamageRepairParty__r.BillingCity;
    //     role.Repair_Shop_Vendor_Name_for_Role__c = roleWithRef.ClaimForRole__r.DamageRepairParty__r.Name;
    //     role.Repairshop_Address_for_Role__c = roleWithRef.ClaimForRole__r.DamageRepairParty__r.BillingStreet;
    //     role.Repairshop_PostalCode_for_Role__c = roleWithRef.ClaimForRole__r.DamageRepairParty__r.BillingPostalCode;
    //     role.Repairshop_Province_for_Role_FR__c = roleWithRef.ClaimForRole__r.DamageRepairParty__r.State__r.L_FR_CA__c;
    //     role.Repairshop_Province_for_Role__c = roleWithRef.ClaimForRole__r.DamageRepairParty__r.State__r.L_EN_CA__c;
    //     if (!String.isBlank(roleWithRef.ClaimForRole__r.DamageRepairParty__c)) {
    //         role.Repairshop_Workphone_for_Role__c = (String.isBlank(roleWithRef.ClaimForRole__r.DamageRepairParty__r.Extension__c))
    //                                                     ? roleWithRef.ClaimForRole__r.DamageRepairParty__r.Phone
    //                                                     : roleWithRef.ClaimForRole__r.DamageRepairParty__r.Phone + ' x' + roleWithRef.ClaimForRole__r.DamageRepairParty__r.Extension__c;
    //     }
    //     role.RoleName_EN__c = roleWithRef.RoleNature__r.L_EN_CA__c;
    //     role.RoleName_FR__c = roleWithRef.RoleNature__r.L_FR_CA__c;
    //     role.SellingChannelDistributorNumber__c = roleWithRef.ClaimForRole__r.SellingChannelDistributorNumber__c;
    //     role.TotalLoss__c = roleWithRef.ClaimForRole__r.TotalLoss__c;
    //     role.VehicleMake_for_Role__c = roleWithRef.ClaimForRole__r.LossVehicle__r.Make__c;
    //     role.VehicleModel_for_Role__c = roleWithRef.ClaimForRole__r.LossVehicle__r.Model__c;
    //     role.VehicleYear_for_Role__c = roleWithRef.ClaimForRole__r.LossVehicle__r.ModelYear__c;
    //     role.Vendor_Address_for_Role__c = roleWithRef.ClaimForRole__r.AppraiserParty__r.BillingStreet;
    //     role.Vendor_City_for_Role__c = roleWithRef.ClaimForRole__r.AppraiserParty__r.BillingCity;
    //     role.Vendor_Name_for_Role__c = roleWithRef.ClaimForRole__r.AppraiserParty__r.Name;
    //     role.Vendor_Postal_Code_for_Role__c = roleWithRef.ClaimForRole__r.AppraiserParty__r.BillingPostalCode;
    //     role.Vendor_Province_for_Role_FR__c = roleWithRef.ClaimForRole__r.AppraiserParty__r.State__r.L_FR_CA__c;
    //     role.Vendor_Province_for_Role__c = roleWithRef.ClaimForRole__r.AppraiserParty__r.State__r.L_EN_CA__c;
    //     if (!String.isBlank(roleWithRef.ClaimForRole__r.AppraiserParty__c)) {
    //         role.Vendor_WorkPhone_for_Role__c = (String.isBlank(roleWithRef.ClaimForRole__r.AppraiserParty__r.Extension__c))
    //                                                 ? roleWithRef.ClaimForRole__r.AppraiserParty__r.Phone
    //                                                 : roleWithRef.ClaimForRole__r.AppraiserParty__r.Phone + ' x' + roleWithRef.ClaimForRole__r.AppraiserParty__r.Extension__c;
    //     }
    //     role.VirtualAppraisal__c = roleWithRef.ClaimForRole__r.VirtualAppraisal__c;
    //     role.WithoutPrejudice__c = (String.isBlank(roleWithRef.ClaimForRole__c))
    //                                     ? false
    //                                     : roleWithRef.ClaimForRole__r.NonCasualtyWithoutPrejudice__c;
    //     return role;
    // }

    /**
    * @description Make sure that address does not contain any null values in case when these are missing from the payload
    * @author      Damian Kazior
    * @date        31/10/2019                     
    */
    // private static String getCleanFieldValue(String fieldValue){
    //     if(fieldValue == null){
    //         return '';
    //     }else{
    //         return fieldValue+', ';
    //     }
    // }

    /**
    * @description remove any trailing commas from address field in case of missing fields
    * @author      Damian Kazior
    * @date        31/10/2019                     
    */
    // private static String clearAddressField(String address){
     
    //     if(address.endsWith(', ')){
    //         address = address.trim().removeEnd(','); 
    //     }
    //     return address;
    // }

    /**
    * @description retrieve Set of Case Id from role list
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Case populateRoleWithReferenceBeforeInsert(Case role, Case claim, Case exposure, User u, Account partyAcc, Contact partyContact) {
    //     role.Additional_Insured__c = claim.Additional_Insured__c;
    //     if( null != u ) {
    //         role.Adjuster_Address_Line1__c  = (u.Street == null) ? '' : u.Street;
    //         role.Adjuster_City__c           = (u.City == null) ? '' : u.City;
    //         role.Adjuster_Postal_Code__c    = (u.PostalCode == null) ? '' : u.PostalCode;
    //         role.Adjuster_Title_1_FR__c     = (u.Title_1_FR__c == null) ? '' : u.Title_1_FR__c;
    //         role.Adjuster_Title_2_FR__c     = (u.Title_2_FR__c == null) ? '' : u.Title_2_FR__c;
    //         role.Adjustor_Company_Name__c   = (u.CompanyName == null) ? '' : u.CompanyName;
    //         role.Adjustor_Email_Address__c  = u.Email;
    //         role.Adjustor_Fax_Number__c     = (u.Fax == null) ? '' : u.Fax;
    //         role.Adjustor_Name__c           = u.Name;
    //         role.Adjustor_Phone__c          = (u.Phone == null) ? '' : u.Phone;
    //         role.Adjustor_Province__c       = (u.State == null) ? '' : u.State;
    //         role.Adjustor_Title1__c         = (u.Title_1__c == null) ? '' : u.Title_1__c;
    //         role.Adjustor_Title2__c         = (u.Title_2__c == null) ? '' : u.Title_2__c;
    //         role.Adjustor_Address__c        = (u.Street == null ? '' : u.Street + ', ') +
    //                                           (u.City == null ? '' : u.City + ', ') +
    //                                           (u.State == null ? '' : u.State + ', ')  + 
    //                                           (u.PostalCode == null ? '' : u.PostalCode);
    //     }
    //     role.InjuriesInvolved__c = claim.InjuriesInvolved__c;
    //     role.AppraisalQualifier__c = claim.AppraisalQualifier__c;
    //     role.AppraisalTaskStatus__c = claim.AppraisalTaskStatus__c;
    //     role.Appraisal_Appointment_Date__c = claim.Appraisal_Appointment_Date__c;
    //     role.Appraisal_Appointment_Time__c = claim.Appraisal_Appointment_Time__c;
    //     role.AppraiserPartyName_for_Role__c = claim.AppraiserParty__r.Name;
    //     role.Broker_Branch_EN__c = claim.PolicyBranch__r.L_EN_CA__c;
    //     role.Broker_Branch_FR__c = claim.PolicyBranch__r.L_FR_CA__c;
    //     role.Broker_Name__c = claim.AgentParty__r.Name;
    //     role.Cellular_Phone_Number__c = partyAcc.Phone;
    //     if (null != exposure) {
    //         role.Cheque_Issued_Amount_for_Role__c = exposure.LastPaymentTransaction__r.Amount__c;
    //         role.Cheque_Issued_Date_EN__c = exposure.LastPaymentTransaction__r.EffectiveDateEN__c;
    //         role.Cheque_Issued_Date_FR__c = exposure.LastPaymentTransaction__r.EffectiveDateFR__c;
    //         role.Cheque_Payee_for_Role__c = exposure.LastPaymentTransaction__r.NameOnInstrument__c;
    //         role.ExposureName_EN_for_Role__c = exposure.ExposureType__r.L_EN_CA__c;
    //         role.ExposureName_FR_for_Role__c = exposure.ExposureType__r.L_FR_CA__c;
    //         role.Exposure_Number_Order__c = exposure.Exposure_Number_Order__c;
    //         role.Exposure_Type__c = (String.isBlank(exposure.ExposureType__c))
    //                                     ? null
    //                                     : exposure.ExposureType__r.L_EN_CA__c + ' ' + exposure.ExposureType__r.L_FR_CA__c;
    //         role.Exposure_Type_for_Role__c = exposure.ExposureType__r.TypeCode__c;
    //         role.ExposureIdForRole__c = exposure.ExposureId__c;
    //     }
    //     role.ClaimContractEffectiveDate__c = claim.ClaimContractEffectiveDate__c;
    //     role.ClaimLOBGroup__c = claim.ClaimLOBGroup__c;
    //     role.ClaimNumber__c = claim.ClaimNumber__c;
    //     role.Claim_LOB__c = claim.Claim_LOB__c;
    //     role.ClientPIN__c = claim.ClientPIN__c;
    //     role.CoverageInQuestion__c = claim.NonCasualtyCoverageInQuestion__c;
    //     role.CoverageVehicleMake_for_Role__c = claim.AssignedForCoverageVehicleId__r.Make__c;
    //     role.CoverageVehicleModel_for_Role__c = claim.AssignedForCoverageVehicleId__r.Model__c;
    //     role.CoverageVehicleVIN_for_Role__c = claim.AssignedForCoverageVehicleId__r.SerialNumber__c;
    //     role.CoverageVehicleYear_for_Role__c = claim.AssignedForCoverageVehicleId__r.ModelYear__c;
    //     role.DateOfLoss__c = claim.DateOfLoss__c;
    //     role.DeductibleAmount__c = claim.DeductibleAmount__c;
    //     role.DeductibleAmountCurrencyCode__c = claim.DeductibleAmountCurrencyCode__c;
    //     role.Driver_Name__c = (String.isBlank(claim.AssignedDriverParty__c))
    //                             ? null
    //                             : claim.AssignedDriverParty__r.FirstName + ' ' + claim.AssignedDriverParty__r.LastName;
    //     role.Email_Address_for_Role__c = partyContact.Email;
    //     role.Fax_Number__c = partyAcc.Fax;
    //     role.IncidentDateReported__c = claim.IncidentDateReported__c;
    //     role.InformationSensitivity__c = claim.InformationSensitivity__c;
    //     role.Initial_Gross_Estimate_Amount__c = claim.Initial_Gross_Estimate_Amount__c;
    //     role.Initial_Gross_Estimate_Currency__c = claim.Initial_Gross_Estimate_Currency__c;
    //     role.InjuredPartyRoleDescriptionEN__c = claim.InjuredPartyRole__r.L_EN_CA__c;
    //     role.InjuredPartyRoleDescription__c = claim.InjuredPartyRole__r.Description__c;
    //     role.InjuredPartyTypeCode__c = claim.InjuredPartyRole__r.TypeCode__c;
    //     role.InsuredProbableFaultPercentage__c = claim.InsuredProbableFaultPercentage__c;
    //     role.Insured_First_Name__c = claim.InsuredParty__r.FirstName;
    //     role.Insured_Last_Name__c = claim.InsuredParty__r.LastName;
    //     role.Language_Preference__c = partyAcc.Language__c;
    //     role.LiabilityConfirmed__c = claim.LiabilityConfirmed__c;
    //     role.LossCauseTypeCode__c = claim.LossCause__r.TypeCode__c;
    //     role.LossLocation__c = clearAddressField(
    //                            getCleanFieldValue(claim.IncidentAddressLine__c) + getCleanFieldValue(claim.IncidentCity__c) + 
    //                            getCleanFieldValue(claim.IncidentProvince__c) + getCleanFieldValue(claim.IncidentPostalCode__c) +  
    //                            getCleanFieldValue(claim.IncidentCountry__c));
    //     role.LossType_TypeCode__c = claim.TypeOfLoss__r.TypeCode__c;
    //     role.Loss_Cause_Description__c = claim.LossCause__r.Description__c;
    //     role.Loss_Cause_EN__c = claim.LossCause__r.L_EN_CA__c;
    //     role.Loss_Cause_FR__c = claim.LossCause__r.L_FR_CA__c;
    //     role.Loss_Cause__c = (String.isBlank(claim.LossCause__c))
    //                             ? null
    //                             : claim.LossCause__r.L_EN_CA__c + ' ' + claim.LossCause__r.L_FR_CA__c;
    //     role.Loss_Type_Description__c = claim.TypeOfLoss__r.Description__c;
    //     role.Loss_Type_EN_for_Role__c = claim.TypeOfLoss__r.L_EN_CA__c;
    //     role.Loss_Type_FR_for_Role__c = claim.TypeOfLoss__r.L_FR_CA__c;
    //     role.Loss_Type__c = (String.isBlank(claim.TypeOfLoss__c))
    //                             ? null
    //                             : claim.TypeOfLoss__r.L_EN_CA__c + '/' + claim.TypeOfLoss__r.L_FR_CA__c;
    //     role.Main_Contact_Address_for_Role__c = claim.Account.PersonMailingStreet;
    //     role.Main_Contact_City_for_Role__c = claim.Account.PersonMailingCity;
    //     role.Main_Contact_First_Name_for_Role__c = claim.Account.FirstName;
    //     role.Main_Contact_Last_Name_for_Role__c = claim.Account.LastName;
    //     role.Main_Contact_Postal_for_Role__c = claim.Account.PersonMailingPostalCode;
    //     role.Main_Contact_Province_for_Role__c = claim.Account.State__r.L_EN_CA__c;
    //     role.Main_Contact_Province_for_Role_FR__c = claim.Account.State__r.L_FR_CA__c;
    //     role.Nature_of_Role__c = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_ID.get(role.RoleNature__c).L_EN_CA__c 
    //                             + '/' + Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_ID.get(role.RoleNature__c).L_FR_CA__c;
    //     role.PIGBusinessNameEN__c = claim.Policy_Issuing_Group__r.Business_Name_EN_CA__c;
    //     role.PIGBusinessNameFR__c = claim.Policy_Issuing_Group__r.Business_Name_FR_CA__c;
    //     role.PIG_EN__c = claim.Policy_Issuing_Group__r.L_EN_CA__c;
    //     role.PIG_FR__c = claim.Policy_Issuing_Group__r.L_FR_CA__c;
    //     role.PIG_TypeCode__c = claim.Policy_Issuing_Group__r.TypeCode__c;
    //     role.Party_Address_Line__c = partyContact.MailingStreet;
    //     role.Party_City__c = partyContact.MailingCity;
    //     role.Party_First_Name__c = partyAcc.FirstName;
    //     role.Party_Last_Name__c = partyContact.LastName;
    //     role.Party_Postal_Code__c = partyContact.MailingPostalCode;
    //     role.Party_Province_FR__c = partyAcc.State__r.L_FR_CA__c;
    //     role.Party_Province__c = partyAcc.State__r.L_EN_CA__c;
    //     role.PolicyNumber__c = claim.PolicyNumber__c;
    //     role.PolicyUnderwritingGroupForRole__c = claim.UnderwritingCompany__c;
    //     role.Policy_Holder_First_Last_Name__c = (String.isBlank(claim.InsuredParty__c))
    //                                                 ? null
    //                                                 : claim.InsuredParty__r.FirstName + ' ' + claim.InsuredParty__r.LastName;
    //     role.ProvinceOfIssuanceId__c = claim.ProvinceOfIssuance__r.TypeCode__c;
    //     role.RentalCompany_Name_for_Role__c = claim.RenterParty__r.Name;
    //     role.Rental_Address_for_Role__c = claim.RenterParty__r.BillingStreet;
    //     role.Rental_City_for_Role__c = claim.RenterParty__r.BillingCity;
    //     role.Rental_Company_Country_FR__c = claim.RenterParty__r.Country__r.L_FR_CA__c;
    //     role.Rental_Company_Country__c = claim.RenterParty__r.Country__r.L_EN_CA__c;
    //     role.Rental_Limit__c = claim.Rental_Limit__c;
    //     if (!String.isBlank(claim.RenterParty__c)) {
    //         role.Rental_Location_Phone__c = (String.isBlank(claim.RenterParty__r.Extension__c))
    //                                             ? claim.RenterParty__r.Phone
    //                                             : claim.RenterParty__r.Phone + ' x' + claim.RenterParty__r.Extension__c;
    //     }
    //     role.Rental_PostalCode_for_Role__c = claim.RenterParty__r.BillingPostalCode;
    //     role.Rental_Province_for_Role_FR__c = claim.RenterParty__r.State__r.L_FR_CA__c;
    //     role.Rental_Province_for_Role__c = claim.RenterParty__r.State__r.L_EN_CA__c;
    //     role.Repair_Shop_City_for_Role__c = claim.DamageRepairParty__r.BillingCity;
    //     role.Repair_Shop_Vendor_Name_for_Role__c = claim.DamageRepairParty__r.Name;
    //     role.Repairshop_Address_for_Role__c = claim.DamageRepairParty__r.BillingStreet;
    //     role.Repairshop_PostalCode_for_Role__c = claim.DamageRepairParty__r.BillingPostalCode;
    //     role.Repairshop_Province_for_Role_FR__c = claim.DamageRepairParty__r.State__r.L_FR_CA__c;
    //     role.Repairshop_Province_for_Role__c = claim.DamageRepairParty__r.State__r.L_EN_CA__c;
    //     if (!String.isBlank(claim.DamageRepairParty__c)) {
    //         role.Repairshop_Workphone_for_Role__c = (String.isBlank(claim.DamageRepairParty__r.Extension__c))
    //                                                     ? claim.DamageRepairParty__r.Phone
    //                                                     : claim.DamageRepairParty__r.Phone + ' x' + claim.DamageRepairParty__r.Extension__c;
    //     }
    //     role.RoleName_EN__c = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_ID.get(role.RoleNature__c).L_EN_CA__c;
    //     role.RoleName_FR__c = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_ID.get(role.RoleNature__c).L_FR_CA__c;
    //     role.SellingChannelDistributorNumber__c = claim.SellingChannelDistributorNumber__c;
    //     role.TotalLoss__c = claim.TotalLoss__c;
    //     role.VehicleMake_for_Role__c = claim.LossVehicle__r.Make__c;
    //     role.VehicleModel_for_Role__c = claim.LossVehicle__r.Model__c;
    //     role.VehicleYear_for_Role__c = claim.LossVehicle__r.ModelYear__c;
    //     role.Vendor_Address_for_Role__c = claim.AppraiserParty__r.BillingStreet;
    //     role.Vendor_City_for_Role__c = claim.AppraiserParty__r.BillingCity;
    //     role.Vendor_Name_for_Role__c = claim.AppraiserParty__r.Name;
    //     role.Vendor_Postal_Code_for_Role__c = claim.AppraiserParty__r.BillingPostalCode;
    //     role.Vendor_Province_for_Role_FR__c = claim.AppraiserParty__r.State__r.L_FR_CA__c;
    //     role.Vendor_Province_for_Role__c = claim.AppraiserParty__r.State__r.L_EN_CA__c;
    //     if (!String.isBlank(claim.AppraiserParty__c)) {
    //         role.Vendor_WorkPhone_for_Role__c = (String.isBlank(claim.AppraiserParty__r.Extension__c))
    //                                                 ? claim.AppraiserParty__r.Phone
    //                                                 : claim.AppraiserParty__r.Phone + ' x' + claim.AppraiserParty__r.Extension__c;
    //     }
    //     role.VirtualAppraisal__c = claim.VirtualAppraisal__c;
    //     role.WithoutPrejudice__c = (null == claim)
    //                                     ? false
    //                                     : claim.NonCasualtyWithoutPrejudice__c;
    //     return role;
    // }
    
    /**
    * @description retrieve Set of Case Id from role list
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Set<Id> getRoleIdSetFromRoles(List<Case> roles) {
    //     Set<Id> roleIdSet = new Set<Id>();
    //     for (Case role : roles) {
    //         roleIdSet.add(role.Id);
    //         if (null != role.ClaimForRole__c) {
    //             roleIdSet.add(role.ClaimForRole__c);
    //         }
    //         if (null != role.ExposureForRole__c) {
    //             roleIdSet.add(role.ExposureForRole__c);
    //         }
    //     }
    //     return roleIdSet;
    // }

    /**
    * @description retrieve Set of Account Id from role list
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Set<Id> getPartyAccIdSetFromRoles(List<Case> roles) {
    //     Set<Id> partyAccountIdSet = new Set<Id>();
    //     for (Case role : roles) {
    //         if (null != role.PartyAccount__c) {
    //             partyAccountIdSet.add(role.PartyAccount__c);
    //         }
    //     }
    //     return partyAccountIdSet;
    // }

    /**
    * @description retrieve Set of Contact Id from role list
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Set<Id> getPartyContactIdSetFromRoles(List<Case> roles) {
    //     Set<Id> partyContactIdSet = new Set<Id>();
    //     for (Case role : roles) {
    //         if (null != role.PartyContact__c) {
    //             partyContactIdSet.add(role.PartyContact__c);
    //         }
    //     }
    //     return partyContactIdSet;
    // }

    /**
    * @description retrieve Set of reference Case Id from role list
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Set<Id> getRefIdSetFromRoles(List<Case> roles) {
    //     Set<Id> roleIdSet = new Set<Id>();
    //     for (Case role : roles) {
    //         if (null != role.ClaimForRole__c) {
    //             roleIdSet.add(role.ClaimForRole__c);
    //         }
    //         if (null != role.ExposureForRole__c) {
    //             roleIdSet.add(role.ExposureForRole__c);
    //         }
    //     }
    //     return roleIdSet;
    // }
    
    /**
    * @description retrieve Set of User Id from role list
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Set<Id> getUserIdSetFromRoles(List<Case> roles) {
    //     Set<Id> userIdSet = new Set<Id>();
    //     for (Case role : roles) {
    //         userIdSet.add(role.OwnerId);
    //     }
    //     return userIdSet;
    // }

    /**
    * @description check if case is a role 
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static List<Case> retrieveRolesFromCases(List<Case> cases) {
    //     List<Case> roles = new List<Case>();
    //     for (Case oneCase : cases) {
    //         if (isRole(oneCase)) {
    //             roles.add(oneCase);
    //         }
    //     }
    //     return roles;
    // }

    /**
    * @description check if case is a role 
    * @author      Kejia Hu
    * @date        16/10/2019                     
    */
    // public static Boolean isRole(Case caseToCheck) {
    //     return  (caseToCheck.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
    //                 Omni_ClaimNotificationConstant.CLAIM_ROLE_RECORD_TYPE_NAME).getRecordTypeId())
    //         ||  (caseToCheck.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
    //                 Omni_ClaimNotificationConstant.EXPOSURE_ROLE_RECORD_TYPE_NAME).getRecordTypeId())
    //         ||  (caseToCheck.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
    //                 Omni_ClaimNotificationConstant.SHADOW_ROLE_RECORD_TYPE_NAME).getRecordTypeId());
    // } 
}