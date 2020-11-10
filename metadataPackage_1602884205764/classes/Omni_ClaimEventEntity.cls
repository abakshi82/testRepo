/**
* @description OM-98 model for Claim events related payload
* @author      Kejia Hu
* @date        01/08/2019                     
*/
public with sharing class Omni_ClaimEventEntity {

    public String eventId;
    public String transactionId;
    public String eventName;
    public String eventTime;
    public String eventTrackingNumber;
    public String eventVersion;
    public String claimId;
    public String claimNumber;
    public String dateOfLoss;
    public String typeOfLoss;
    public String causeOfLoss;
    public Double insuredProbableFaultPercentage;
    public String incidentDescription;
    public Boolean liabilityConfirmed;
    public String policyNumber;
    public String policyIssuingGroup;
    public String assignedUserId;
    public Double deductibleAmount;
    public String deductibleAmountCurrencyCode;
    public String incidentAddressLine;
    public String incidentPostalCode;
    public String incidentProvince;
    public String incidentCity;
    public String incidentCountry;
    public String appraiserPartyId;
    public String damageRepairPartyId;
    //Owner userId for unassigned Account records
    public String defaultOwnerId;
    //Queue for unassigned Case/Transaction/Vehicle records
    public String defaultQueueAsOwner;
    public String lossVehicleId;
    public String provinceOfIssuanceId;
    public String branchReferenceNumber;
    public String claimNumberReplaced;
    public String claimLOBGroup;
    public String claimLOB;
    public String underwritingCompanyNumber;
    public String sellingChannelDistributorNumber;
    public String sellingChannelDistributionChannel;
    public Date claimContractEffectiveDate;
    public Date claimContractExpiryDate;
    public String appraisalTaskStatus;
    public Date appraisalAppointmentDate;
    public String appraisalAppointmentTime;
    public String initialGrossEstimateCurrency;
    public Double initialGrossEstimateAmount;
    public String rentalContractStatus;
    public String rentalCompanyPartyId;
    public String rentalLimit;
    public Boolean injuriesInvolved;
    public Boolean virtualAppraisal;
    public String clientPIN;
    public String incidentDateReported;
    public String totalLoss;
    public String assignedVehicleId;
    public String assignedDriverPartyId;
    public String informationSensitivity;
    public Boolean incidentReportOnly;
    public Boolean manuallyEnteredPolicy;
    public String conversionOrigin;
    public String claimStatus;
    public String claimClosedDate;
    public String appraisalQualifier;
    public String assignedLossDriverId;
    public String injuredParty;
    public Date claimOriginEffectiveDate;
    public String primaryAdjuster;
    public Boolean nonCasualtyWithoutPrejudice;
    public Boolean nonCasualtyCoverageInQuestion;
    public String insuredPartyId;
    public Double rentalNumberOfAuthorizedDays;
    public String agentPartyId;
    public String lastOpenedNonBIExposureId;
    public String claimOpenedDate;
    public String claimReopenedDate;
    public Double totalIndemnity;
    public Double totalRecovery;
    public Double QCLNClaimExpVehicleChapAPaid;
    public Double QCLNClaimExpVehicleChapBPaid;
    public Double NLPClaimSectionAPaidThirdParty;
    public String insuredIncDriverPartyId;
    public String insuredIncCustodianPartyId;
    public String QCLNExposureId;
    public String NLPLExposureId;
    public String policeReportNumber;
    public String vehicleLocationNote;
    public Boolean sendAutoPropertySurvey;

    public List<ClaimExposure> claimExposures;
    public List<FinancialTransaction> financialTransactions;
    public List<PartyItem> party;
    public List<PartyRole> partyRoles;
    public List<DrivingLicense> drivingLicenses;
    public List<Address> addresses;
    public List<Email> emails;
    public List<Phone> phones;
    public List<Vehicle> vehicles;

    public Omni_ClaimEventEntity(SObject claimEvent) {
        this.eventId = (String) claimEvent.get('EventId__c');
        this.transactionId = (String) claimEvent.get('TransactionID__c');
        this.eventName = (String) claimEvent.get('EventName__c');
        this.eventTime = (String) claimEvent.get('EventTime__c');
        this.eventTrackingNumber = (String) claimEvent.get('EventTrackingNumber__c');
        this.eventVersion = (String) claimEvent.get('EventVersion__c');
        this.claimId = (String) claimEvent.get('ClaimId__c');
        this.claimNumber = (String) claimEvent.get('ClaimNumber__c');
        this.dateOfLoss = (String) claimEvent.get('DateOfLoss__c');
        this.typeOfLoss =(String) claimEvent.get('TypeOfLoss__c');
        this.causeOfLoss = (String) claimEvent.get('CauseOfLoss__c');
        this.insuredProbableFaultPercentage = (Double) claimEvent.get('InsuredProbableFaultPercentage__c');
        this.incidentDescription = (String) claimEvent.get('IncidentDescription__c');
        this.liabilityConfirmed = (Boolean) claimEvent.get('LiabilityConfirmed__c');
        this.policyNumber = (String) claimEvent.get('PolicyNumber__c');
        this.policyIssuingGroup = (String) claimEvent.get('PolicyIssuingGroup__c');
        this.assignedUserId = (String) claimEvent.get('AssignedUserId__c');
        this.deductibleAmount = (Double) claimEvent.get('ClaimDeductibleAmount__c');
        this.deductibleAmountCurrencyCode = (String) claimEvent.get('ClaimDeductibleAmountCurrencyCode__c');
        this.incidentAddressLine = (String) claimEvent.get('IncidentAddressLine__c');
        this.incidentPostalCode = (String) claimEvent.get('IncidentPostalCode__c');
        this.incidentProvince = (String) claimEvent.get('IncidentProvince__c');
        this.incidentCity = (String) claimEvent.get('IncidentCity__c');
        this.incidentCountry = (String) claimEvent.get('IncidentCountry__c');
        this.appraiserPartyId = (String) claimEvent.get('AppraiserPartyId__c');
        this.damageRepairPartyId = (String) claimEvent.get('DamageRepairPartyId__c');
        this.rentalCompanyPartyId = (String) claimEvent.get('RentalCompanyPartyId__c');
        this.defaultOwnerId = System.Label.Omni_DefaultOwnerId;
        this.defaultQueueAsOwner = Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('DefaultOwnerIdForUnassigned');
        this.lossVehicleId = (String) claimEvent.get('LossVehicleId__c');
        this.provinceOfIssuanceId = (String) claimEvent.get('ProvinceOfIssuanceId__c');
        this.injuredParty = (String) claimEvent.get('InjuredParty__c');
        this.branchReferenceNumber = (String) claimEvent.get('BranchReferenceNumber__c');
        this.claimNumberReplaced = (String) claimEvent.get('ClaimNumberReplaced__c');
        this.claimLOBGroup = (String) claimEvent.get('ClaimLOBGroup__c');
        this.claimLOB = (String) claimEvent.get('ClaimLOB__c');
        this.underwritingCompanyNumber = (String) claimEvent.get('UnderwritingCompanyNumber__c');
        this.sellingChannelDistributorNumber = (String) claimEvent.get('SellingChannelDistributorNumber__c');
        this.sellingChannelDistributionChannel = (String) claimEvent.get('SellingChannelDistributionChannel__c');
        this.claimContractEffectiveDate = (Date) claimEvent.get('ClaimContractEffectiveDate__c');
        this.claimContractExpiryDate = (Date) claimEvent.get('ClaimContractExpiryDate__c');
        this.appraisalTaskStatus = (String) claimEvent.get('AppraisalTaskStatus__c');
        this.appraisalAppointmentDate = (Date) claimEvent.get('AppraisalAppointmentDate__c');
        this.appraisalAppointmentTime = (String) claimEvent.get('AppraisalAppointmentTime__c');
        this.initialGrossEstimateCurrency = (String) claimEvent.get('InitialGrossEstimateCurrency__c');
        this.initialGrossEstimateAmount = (Double) claimEvent.get('InitialGrossEstimateAmount__c');
        this.rentalContractStatus = (String) claimEvent.get('RentalContractStatus__c');
        this.rentalLimit = (String) claimEvent.get('RentalLimit__c');
        this.injuriesInvolved = (Boolean) claimEvent.get('InjuriesInvolved__c');
        this.virtualAppraisal = (Boolean) claimEvent.get('VirtualAppraisal__c');
        this.clientPIN = (String) claimEvent.get('ClientPIN__c');
        this.incidentDateReported = (String) claimEvent.get('IncidentDateReported__c');
        this.totalLoss = (String) claimEvent.get('TotalLoss__c');
        this.assignedVehicleId = (String) claimEvent.get('AssignedVehicleId__c');
        this.assignedDriverPartyId = (String) claimEvent.get('AssignedDriverPartyId__c');
        this.informationSensitivity = (String) claimEvent.get('InformationSensitivity__c');
        this.incidentReportOnly = (Boolean) claimEvent.get('IncidentReportOnly__c');
        this.manuallyEnteredPolicy = (Boolean) claimEvent.get('ManuallyEnteredPolicy__c');
        this.conversionOrigin = (String) claimEvent.get('ConversionOrigin__c');
        this.claimStatus = (String) claimEvent.get('ClaimStatus__c');
        this.claimClosedDate = (String) claimEvent.get('ClaimClosedDate__c');
        this.appraisalQualifier = (String) claimEvent.get('AppraisalQualifier__c');
        this.assignedLossDriverId = (String) claimEvent.get('AssignedLossDriverId__c');
        this.injuredParty = (String) claimEvent.get('InjuredParty__c');
        this.claimOriginEffectiveDate = (Date) claimEvent.get('ClaimOriginEffectiveDate__c');
        this.primaryAdjuster = (String) claimEvent.get('PrimaryAdjuster__c');
        this.nonCasualtyWithoutPrejudice = (Boolean) claimEvent.get('NonCasualtyWithoutPrejudice__c');
        this.nonCasualtyCoverageInQuestion = (Boolean) claimEvent.get('NonCasualtyCoverageInQuestion__c');
        this.insuredPartyId = (String) claimEvent.get('InsuredPartyId__c');
        this.rentalNumberOfAuthorizedDays = (Double) claimEvent.get('RentalNumberOfAuthorizedDays__c');
        this.agentPartyId = (String) claimEvent.get('AgentPartyId__c');
        this.lastOpenedNonBIExposureId = (String) claimEvent.get('LastOpenedNonBIExposureId__c');
        this.claimOpenedDate = (String) claimEvent.get('ClaimOpenedDate__c');
        this.claimReopenedDate = (String) claimEvent.get('ClaimReopenedDate__c');
        this.totalIndemnity = (Double) claimEvent.get('TotalIndemnity__c');
        this.totalRecovery = (Double) claimEvent.get('TotalRecovery__c');
        this.QCLNClaimExpVehicleChapAPaid = (Double) claimEvent.get('QCLNClaimExpVehicleChapAPaid__c');
        this.QCLNClaimExpVehicleChapBPaid = (Double) claimEvent.get('QCLNClaimExpVehicleChapBPaid__c');
        this.NLPClaimSectionAPaidThirdParty = (Double) claimEvent.get('NLPClaimSectionAPaidThirdParty__c');
        this.insuredIncDriverPartyId = (String) claimEvent.get('InsuredIncDriverPartyId__c');
        this.insuredIncCustodianPartyId = (String) claimEvent.get('InsuredIncCustodianPartyId__c');
        this.QCLNExposureId = (String) claimEvent.get('QCLNExposureId__c');
        this.NLPLExposureId = (String) claimEvent.get('NLPLExposureId__c');
        this.policeReportNumber = (String) claimEvent.get('PoliceReportNumber__c');
        this.vehicleLocationNote = (String) claimEvent.get('VehicleLocationNote__c');
        this.sendAutoPropertySurvey = (Boolean) claimEvent.get('SendAutoPropertySurvey__c');

        String claimExposuresString = (String) claimEvent.get('ClaimExposures__c');
        if (!String.isBlank(claimExposuresString)) {
            this.claimExposures = (List<ClaimExposure>) JSON.deserialize(
                                    claimExposuresString, List<ClaimExposure>.class);
        }
        String partyString = (String) claimEvent.get('Party__c');
        if (!String.isBlank(partyString)) {
            this.party = (List<PartyItem>) JSON.deserialize(
                            partyString, List<PartyItem>.class);
        }
        String financialTransactionsString = (String) claimEvent.get('FinancialTransactions__c');
        if(!String.isBlank(financialTransactionsString)) {
            this.financialTransactions = (List<FinancialTransaction>) JSON.deserialize(
                                    financialTransactionsString, List<FinancialTransaction>.class);
        }
        String partyRolesString = (String) claimEvent.get('PartyRoles__c');
        if (!String.isBlank(partyRolesString)) {
            this.partyRoles = (List<PartyRole>) JSON.deserialize(
                                partyRolesString, List<PartyRole>.class);
        }
        String addressesString = (String) claimEvent.get('Addresses__c');
        if (!String.isBlank(addressesString)) {
            this.addresses = (List<Address>) JSON.deserialize(
                                addressesString, List<Address>.class);
        }
        String emailsString = (String) claimEvent.get('Emails__c');
        if (!String.isBlank(emailsString)) {
            this.emails = (List<Email>) JSON.deserialize(
                                emailsString, List<Email>.class);
        }
        String phonesString = (String) claimEvent.get('Phones__c');
        if (!String.isBlank(phonesString)) {
            this.phones = (List<Phone>) JSON.deserialize(
                                phonesString, List<Phone>.class);
        }
        String vehiclesString = (String) claimEvent.get('Vehicles__c');
        if (!String.isBlank(vehiclesString)) {
            this.vehicles = (List<Vehicle>) JSON.deserialize(
                                vehiclesString, List<Vehicle>.class);
        }
        String drivingLicensesString = (String) claimEvent.get('DrivingLicenses__c');
        if(!String.isBlank(drivingLicensesString)) {
            this.drivingLicenses = (List<DrivingLicense>) JSON.deserialize(
                                        drivingLicensesString, List<DrivingLicense>.class);
        }
    }

    /**
    * @description get all exposure Id
    * @author      Kejia Hu
    * @date        02/08/2019                     
    */
    public List<String> getAllExposureIds() {
        List<String> exposureIds = new List<String>();
        if (!this.claimExposures.isEmpty()) {
            for (ClaimExposure ce : this.claimExposures) {
                exposureIds.add(ce.claimExposureId);
            }
        }
        return exposureIds;
    }

    /**
    * @description OM-925 Generate AccountByPartyId map Claim Notification platform Event
    * @author      Kejia Hu
    * @date        02/08/2019                     
    */
    public Map<String, Account> generateAccountByPartyId() {
        Map<String, Account> accPartyByKey = new Map<String, Account>();
        for (PartyItem item: this.party) {
            Account acc = generateAccountFromPartyItem(item);
            accPartyByKey.put(acc.PartyId__c, acc);
        }
        return accPartyByKey;
    }

    /**
    * @description OM-925 Generate account instance from Claim Notification platform Event PartyItem
    * @author      Kejia Hu
    * @date        02/08/2019                     
    */
    private Account generateAccountFromPartyItem(PartyItem partyItemInst){
    	Address partyAddress = this.getAddress(partyItemInst.partyId);
        DrivingLicense drivingLicense = this.getDrivingLicense(partyItemInst.partyId);
        Account acct = ('IN' == partyItemInst.partyType)
                        ? new Account(
                                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.PERSON_ACCT_RECORD_TYPE_NAME).getRecordTypeId(),
                                FirstName = partyItemInst.personFirstName,
                                LastName = partyItemInst.personLastName,
                                MiddleName = partyItemInst.personMiddleName,
                                Language__c = partyItemInst.Language,
                                Retired__c = partyItemInst.retired,
                                Prefix__c = (Omni_ClaimEventDAOHelper.NAME_PREFIX_BY_CODE.containsKey(partyItemInst.personTitle)) 
                                                ? Omni_ClaimEventDAOHelper.NAME_PREFIX_BY_CODE.get(partyItemInst.personTitle).Id
                                                : null,
                                Suffix__c = (Omni_ClaimEventDAOHelper.NAME_SUFFIX_BY_CODE.containsKey(partyItemInst.personSuffix))
                                                ? Omni_ClaimEventDAOHelper.NAME_SUFFIX_BY_CODE.get(partyItemInst.personSuffix).Id
                                                : null,
                                PartyId__c = partyItemInst.partyId,
                                PersonBirthdate = String.isBlank(partyItemInst.personBirthDate) ? null : Date.valueOf(partyItemInst.personBirthDate),
                                PersonEmail = getEmail(partyItemInst.partyId),
                                Phone = (null != getCellPhone(partyItemInst.partyId))
                                            ? getCellPhone(partyItemInst.partyId).phoneNumber
                                            : null,
                                Fax = (null != getFax(partyItemInst.partyId))
                                        ? getFax(partyItemInst.partyId).phoneNumber
                                        : null,
                                DrivingLicenseNumber__c = (null != drivingLicense)
                                                            ? drivingLicense.drivingLicenseNumber
                                                            : null,
                                DrivingLicensePlaceOfIssue__c = (null != drivingLicense)
                                                                    ? drivingLicense.drivingLicensePlaceOfIssue
                                                                    : null,
                                OwnerId = (String.isBlank(this.assignedUserId) || !Omni_UserSelector.USER_ID_BY_GWCC_ID.containsKey(this.assignedUserId)) 
                                            ? Omni_UserSelector.USER_ID_BY_GWCC_ID.get(defaultOwnerId)
                                            : Omni_UserSelector.USER_ID_BY_GWCC_ID.get(this.assignedUserId),
                                PersonMailingStreet = (null != partyAddress) ? partyAddress.addressLine : '',
                                PersonMailingCity = (null != partyAddress) ? partyAddress.city : '',
                                PersonMailingPostalCode = (null != partyAddress) ? partyAddress.postalCode : '',
                                PersonMailingState = (null != partyAddress && !String.isBlank(partyAddress.province))
                                                        ? ( ('E' == partyItemInst.Language) 
                                                                ? Omni_ClaimEventDAOHelper.STATE_BY_CODE.get(partyAddress.province).L_EN_CA__c
                                                                : Omni_ClaimEventDAOHelper.STATE_BY_CODE.get(partyAddress.province).L_FR_CA__c)
                                                        : '',
                                PersonMailingCountry = (null != partyAddress && !String.isBlank(partyAddress.country)) 
                                                        ? ( ('E' == partyItemInst.Language) 
                                                                ? Omni_ClaimEventDAOHelper.COUNTRY_BY_CODE.get(partyAddress.country).L_EN_CA__c
                                                                : Omni_ClaimEventDAOHelper.COUNTRY_BY_CODE.get(partyAddress.country).L_FR_CA__c)
                                                        : '',
                                State__c = (null != partyAddress && !String.isBlank(partyAddress.province))
                                                ? Omni_ClaimEventDAOHelper.STATE_BY_CODE.get(partyAddress.province).Id
                                                : null,
                                Country__c = (null != partyAddress && !String.isBlank(partyAddress.country))
                                                ? Omni_ClaimEventDAOHelper.COUNTRY_BY_CODE.get(partyAddress.country).Id
                                                : null
                            )
                        : new Account(
                                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(
                                                Omni_ClaimEventConstant.BIZ_ACCT_RECORD_TYPE_NAME).getRecordTypeId(),
                                Name = (!String.isBlank(partyItemInst.organisationName)) 
                                            ? partyItemInst.organisationName
                                            : 'NA',
                                PartyId__c = partyItemInst.partyId,
                                Retired__c = partyItemInst.retired,
                                OwnerId = (String.isBlank(this.assignedUserId) || !Omni_UserSelector.USER_ID_BY_GWCC_ID.containsKey(this.assignedUserId)) 
                                            ? Omni_UserSelector.USER_ID_BY_GWCC_ID.get(defaultOwnerId) 
                                            : Omni_UserSelector.USER_ID_BY_GWCC_ID.get(this.assignedUserId),
                            	Language__c = partyItemInst.Language,
                                Phone = (null != getBusinessPhone(partyItemInst.partyId))
                                            ? getBusinessPhone(partyItemInst.partyId).phoneNumber
                                            : null,
                                Extension__c = (null != getBusinessPhone(partyItemInst.partyId))
                                                    ? getBusinessPhone(partyItemInst.partyId).extensionNumber
                                                    : null,
                                Fax = (null != getFax(partyItemInst.partyId))
                                        ? getFax(partyItemInst.partyId).phoneNumber
                                        : null,
                                BillingStreet = (null != partyAddress) ? partyAddress.addressLine : '',
                                BillingCity = (null != partyAddress) ? partyAddress.city : '',
                                BillingPostalCode = (null != partyAddress) ? partyAddress.postalCode : '',
                                BillingState = (null != partyAddress && !String.isBlank(partyAddress.province)) 
                                                    ? ( ('E' == partyItemInst.Language) 
                                                            ? Omni_ClaimEventDAOHelper.STATE_BY_CODE.get(partyAddress.province).L_EN_CA__c
                                                            : Omni_ClaimEventDAOHelper.STATE_BY_CODE.get(partyAddress.province).L_FR_CA__c)
                                                    : '',
                                BillingCountry = (null != partyAddress && !String.isBlank(partyAddress.country)) 
                                                    ? ( ('E' == partyItemInst.Language) 
                                                            ? Omni_ClaimEventDAOHelper.COUNTRY_BY_CODE.get(partyAddress.country).L_EN_CA__c
                                                            : Omni_ClaimEventDAOHelper.COUNTRY_BY_CODE.get(partyAddress.country).L_FR_CA__c)
                                                    : '',
                                State__c = (null != partyAddress && !String.isBlank(partyAddress.province))
                                                ? Omni_ClaimEventDAOHelper.STATE_BY_CODE.get(partyAddress.province).Id
                                                : null,
                                Country__c = (null != partyAddress && !String.isBlank(partyAddress.country))
                                                ? Omni_ClaimEventDAOHelper.COUNTRY_BY_CODE.get(partyAddress.country).Id
                                                : null
                            );
        return acct;
    }

    /**
    * @description OM-925 Generate AddressByType map from Addresses
    * @author      Kejia Hu
    * @date        07/08/2019                     
    */
    private Map<String, Address> getAddressByType(List<Address> addresses) {
        Map<String, Address> addressByType = new Map<String, Address>();
        for (Address add : addresses) { 
            addressByType.put(add.addressType, add);
        }
        return addressByType;
    }

    /**
    * @description OM-925 Generate account instance from Claim Notification platform Event PartyItem
    * @author      Kejia Hu
    * @date        07/08/2019                     
    */
    private Map<String, List<Address>> getAddressesByPartyId() {
        Map<String, List<Address>> addressesByPartyId = new Map<String, List<Address>>();
        for(Address add : this.addresses) {
            if (addressesByPartyId.containsKey(add.partyId)) {
                addressesByPartyId.get(add.partyId).add(add);
            } else {
                addressesByPartyId.put(add.partyId, new List<Address>{add});
            }
        }
        return addressesByPartyId;
    }

    public Map<String, Contact> generateContactByPartyId(Map<String, Account> acctsByKey) {
        Map<String, Contact> contactByPartyId = new Map<String, Contact>();
        for (PartyItem onepartyItem : this.party) {
            if ('CY' == onepartyItem.partyType) {
                contactByPartyId.put(onepartyItem.partyId, generateContact(onepartyItem, acctsByKey.get(onepartyItem.partyId)));    
            }
        }
        return contactByPartyId;
    }


    /**
    * @description OM-925 Generate contact instance from Claim Notification platform Event PartyItem and an account
    * @author      Kejia Hu
    * @date        02/08/2019                     
    */
    private Contact generateContact(PartyItem item, Account acct){
        return new Contact(
            LastName = (!String.isBlank(item.organisationName)) 
                            ? item.organisationName
                            : 'NA',
            Email = getEmail(item.partyId),
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(
                                Omni_ClaimEventConstant.CLAIM_CONTACT_RECORD_TYPE).getRecordTypeId(),
            Phone = acct.phone,
            Fax = acct.Fax,
            PartyId__c = item.partyId,
            AccountId = acct.Id,
            MailingStreet = acct.BillingStreet,
            MailingCity = acct.BillingCity,
            MailingState = acct.BillingState,
            MailingPostalCode = acct.BillingPostalCode,
            MailingCountry = acct.BillingCountry);
    }

    /**
    * @description OM-925 Generate Claim instance from Claim Notification platform Event and account
    * @author      Kejia Hu
    * @date        02/08/2019                     
    */
    public Map<String, Case> generateClaimByClaimId(Map<String, Account> accountByPartyId, Map<String, Contact> contactByPartyId, 
                                                        Map<String, Vehicle__c> vehicleById) {
        User claimOwner = new User(UserId__c = this.assignedUserId);
        String mainContactPartyId = getMainContactPartyId();
        Contact contClaim = (contactByPartyId.containsKey(mainContactPartyId)) ? contactByPartyId.get(mainContactPartyId) : null;
        //Add 5 hours to appointment time, if exceeded 24h then add one day to appointment date
        String appointmentTime;
        Date appointmentDate;
        if (!String.isBlank(this.appraisalAppointmentTime)) {
            appointmentTime = this.appraisalAppointmentTime;
            String mins = appointmentTime.substringAfter(':');
            Integer hours = Integer.valueOf(appointmentTime.substringBefore(':')) + 5;
            if (hours>24) {
                hours = hours - 24;
                appointmentDate = this.appraisalAppointmentDate.addDays(1);
            } else {
                appointmentDate = this.appraisalAppointmentDate;
            }
            appointmentTime = (String.valueOf(hours).length()==1) 
                                ? '0' + hours + ':' + mins
                                : hours + ':' + mins;                                                   
        }
        Case claim =  new Case(
                        EventName__c = this.eventName,
                        ClaimNumber__c = this.claimNumber, 
                        ClaimId__c = this.claimId,
                        RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM,
                        Origin = 'Web',
                        UnderWritingCompany__c = this.underwritingCompanyNumber,
                        DeductibleAmount__c = this.deductibleAmount,
                        DeductibleAmountCurrencyCode__c = this.deductibleAmountCurrencyCode,
                        IncidentDescription__c = this.incidentDescription,
                        LiabilityConfirmed__c = this.liabilityConfirmed,
                        PolicyNumber__c = this.policyNumber,
                        InsuredProbableFaultPercentage__c = this.insuredProbableFaultPercentage,
                        OwnerId = (String.isBlank(this.assignedUserId) || !Omni_UserSelector.USER_ID_BY_GWCC_ID.containsKey(this.assignedUserId)) 
                                    ? defaultQueueAsOwner 
                                    : Omni_UserSelector.USER_ID_BY_GWCC_ID.get(this.assignedUserId),
                        AccountId = (accountByPartyId.containsKey(mainContactPartyId)) 
                                        ? accountByPartyId.get(mainContactPartyId).Id
                                        : null,
                        ContactId = (null != contClaim) ? contClaim.Id : null, 
                        DateOfLoss__c = Utility.getDateTime(this.dateOfLoss),
                        SellingChannelDistributorNumber__c = this.sellingChannelDistributorNumber,
                        SellingChannelDistributionChannel__c = this.sellingChannelDistributionChannel,
                        AppraisalTaskStatus__c = this.appraisalTaskStatus,
                        ClaimNumberReplaced__c = this.claimNumberReplaced,
                        ClaimLOBGroup__c = this.claimLOBGroup,
                        Claim_LOB__c = this.claimLOB,
                        ClaimContractEffectiveDate__c = this.claimContractEffectiveDate,
                        ClaimContractExpiryDate__c = this.claimContractExpiryDate,
                        Appraisal_Appointment_Date__c = appointmentDate,
                        Appraisal_Appointment_Time__c = appointmentTime,
                        Initial_Gross_Estimate_Amount__c = this.initialGrossEstimateAmount,
                        Initial_Gross_Estimate_Currency__c = this.initialGrossEstimateCurrency,
                        RentalContractStatus__c = this.rentalContractStatus,
                        Rental_Limit__c = this.rentalLimit,
                        InjuriesInvolved__c = this.injuriesInvolved,
                        VirtualAppraisal__c = this.virtualAppraisal,
                        ClientPIN__c = this.clientPIN,
                        IncidentDateReported__c = Utility.getDateTime(this.incidentDateReported),
                        TotalLoss__c = this.totalLoss,
                        InformationSensitivity__c = this.informationSensitivity,
                        IncidentReportOnly__c = this.incidentReportOnly,
                        ManuallyEnteredPolicy__c = this.manuallyEnteredPolicy,
                        ConversionOrigin__c = this.conversionOrigin,
                        ClaimStatus__c = this.claimStatus,
                        ClaimClosedDate__c = Utility.getDateTime(this.claimClosedDate),
                        AppraisalQualifier__c = this.appraisalQualifier,
                        AssignedLossDriverId__c = this.assignedLossDriverId,
                        ClaimOriginEffectiveDate__c = this.claimOriginEffectiveDate,
                        PrimaryAdjuster__c = this.primaryAdjuster,
                        NonCasualtyWithoutPrejudice__c = this.nonCasualtyWithoutPrejudice,
                        NonCasualtyCoverageInQuestion__c = this.nonCasualtyCoverageInQuestion,
                        RentalNumberOfAuthorizedDays__c = this.rentalNumberOfAuthorizedDays,
                        LastOpenExposureId__c = this.lastOpenedNonBIExposureId,
                        ClaimOpenedDate__c = Utility.getDateTime(this.claimOpenedDate),
                        ClaimReopenedDate__c = Utility.getDateTime(this.claimReopenedDate),
                        TotalIndemnity__c = this.totalIndemnity,
                        TotalRecovery__c = this.totalRecovery,
                        QCLNClaimExpVehicleChapAPaid__c = this.QCLNClaimExpVehicleChapAPaid,
                        QCLNClaimExpVehicleChapBPaid__c = this.QCLNClaimExpVehicleChapBPaid,
                        NLPClaimSectionAPaidThirdParty__c = this.NLPClaimSectionAPaidThirdParty,
                        PoliceReportNumber__c = this.policeReportNumber,
                        VehicleLocationNote__c = this.vehicleLocationNote,
                        TypeOfLoss__c = (!String.isBlank(this.typeOfLoss) && Omni_ClaimEventDAOHelper.TYPE_LOSS_ID_BY_CODE.containsKey(this.typeOfLoss)) 
                                            ? Omni_ClaimEventDAOHelper.TYPE_LOSS_ID_BY_CODE.get(this.typeOfLoss)
                                            : null,
                        LossCause__c = (!String.isBlank(this.causeOfLoss) && Omni_ClaimEventDAOHelper.LOSS_CAUSE_ID_BY_CODE.containsKey(this.causeOfLoss)) 
                                            ? Omni_ClaimEventDAOHelper.LOSS_CAUSE_ID_BY_CODE.get(this.causeOfLoss)
                                            : null,
                        InjuredPartyRole__c = (!String.isBlank(this.injuredParty) && Omni_ClaimEventDAOHelper.INJURED_ROLE_ID_BY_CODE.containsKey(this.injuredParty))
                                                ? Omni_ClaimEventDAOHelper.INJURED_ROLE_ID_BY_CODE.get(this.injuredParty)
                                                : null,
                        Policy_Issuing_Group__c = (!String.isBlank(this.policyIssuingGroup) && Omni_ClaimEventDAOHelper.POLICY_ISSUING_GROUP_ID_BY_CODE.containsKey(this.policyIssuingGroup))
                                                    ? Omni_ClaimEventDAOHelper.POLICY_ISSUING_GROUP_ID_BY_CODE.get(this.policyIssuingGroup)
                                                    : null,
                        PolicyBranch__c	= (!String.isBlank(this.branchReferenceNumber) && Omni_ClaimEventDAOHelper.POLICY_BRANCH_ID_BY_CODE.containsKey(this.branchReferenceNumber))
                                                ? Omni_ClaimEventDAOHelper.POLICY_BRANCH_ID_BY_CODE.get(this.branchReferenceNumber)
                                                : null,
                        AppraiserParty__c = (!String.isBlank(this.appraiserPartyId) && accountByPartyId.containsKey(this.appraiserPartyId))
                                                ? accountByPartyId.get(this.appraiserPartyId).Id
                                                : null,
                        DamageRepairParty__c = (!String.isBlank(this.damageRepairPartyId) && accountByPartyId.containsKey(this.damageRepairPartyId))
                                                    ? accountByPartyId.get(this.damageRepairPartyId).Id
                                                    : null,
                        RenterParty__c = (!String.isBlank(this.rentalCompanyPartyId) && accountByPartyId.containsKey(this.rentalCompanyPartyId))
                                            ? accountByPartyId.get(this.rentalCompanyPartyId).Id
                                            : null,
                        InsuredParty__c = (!String.isBlank(this.insuredPartyId) && accountByPartyId.containsKey(this.insuredPartyId))
                                            ? accountByPartyId.get(this.insuredPartyId).Id
                                            : null,
                        AgentParty__c = (!String.isBlank(this.agentPartyId) && accountByPartyId.containsKey(this.agentPartyId))
                                            ? accountByPartyId.get(this.agentPartyId).Id
                                            : null,
                        IncidentDriver__c = (!String.isBlank(this.InsuredIncDriverPartyId) && accountByPartyId.containsKey(this.InsuredIncDriverPartyId))
                                            ? accountByPartyId.get(this.InsuredIncDriverPartyId).Id
                                            : null,
                        InsuredCustodian__c = (!String.isBlank(this.insuredIncCustodianPartyId) && accountByPartyId.containsKey(this.insuredIncCustodianPartyId))
                                            ? accountByPartyId.get(this.insuredIncCustodianPartyId).Id
                                            : null,
                        IncidentAddressLine__c = this.incidentAddressLine,
                        IncidentPostalCode__c = this.incidentPostalCode,
                        IncidentCity__c = this.incidentCity,
                        IncidentProvince__c = this.incidentProvince,
                        IncidentCountry__c = this.incidentCountry,
                        LossVehicle__c = (!String.isBlank(this.lossVehicleId) && vehicleById.containsKey(this.lossVehicleId)) 
                                            ? vehicleById.get(this.lossVehicleId).Id
                                            : null,
                        AssignedForCoverageVehicleId__c = (!String.isBlank(this.assignedVehicleId) && vehicleById.containsKey(this.assignedVehicleId)) 
                                                            ? vehicleById.get(this.assignedVehicleId).Id
                                                            : null,
                        AssignedDriverParty__c = (!String.isBlank(this.assignedDriverPartyId) && accountByPartyId.containsKey(this.assignedDriverPartyId))
                                                ? accountByPartyId.get(this.assignedDriverPartyId).Id
                                                : null,
                        ProvinceOfIssuance__c = (!String.isBlank(this.provinceOfIssuanceId) && Omni_ClaimEventDAOHelper.STATE_BY_CODE.containsKey(this.provinceOfIssuanceId))
                                                    ? Omni_ClaimEventDAOHelper.STATE_BY_CODE.get(this.provinceOfIssuanceId).Id
                                                    : null,
                        AssignedUserId__c = this.assignedUserId
                        );
        if (Utility.SURVEY_SWITCH_BY_KEY.get('SurveyMapping').IsEnabled__c) {
            claim.SendAutoPropertySurvey__c = this.sendAutoPropertySurvey;
        }
        return new Map<String, Case>{
                        claim.ClaimId__c => claim};
    }

    /**
    * @description OM-925 Generate vehicles from Claim platform Event
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    public Map<String, Vehicle__c> generateVehicleById(){
        Map<String, Vehicle__c> vehicleByIdToReturn = new Map<String, Vehicle__c>();
        if (!this.vehicles.isEmpty()) {
            for (Vehicle v : this.vehicles) {
                vehicleByIdToReturn.put(v.vehicleId, new Vehicle__c(
                    OwnerId = (String.isBlank(this.assignedUserId) || !Omni_UserSelector.USER_ID_BY_GWCC_ID.containsKey(this.assignedUserId)) 
                                ? defaultQueueAsOwner 
                                : Omni_UserSelector.USER_ID_BY_GWCC_ID.get(this.assignedUserId),
                    VehicleId__c = v.vehicleId,
                    Make__c = v.make,
                    Model__c = v.model,
                    ModelYear__c = v.modelYear,
                    Name = v.make + ' ' + v.model + ' ' + v.modelYear,
                    SerialNumber__c = v.serialNumber,
                    LicensePlate__c = v.licensePlate,
                    LicensePlateProvinceId__c = v.licensePlateProvinceId));
            }
        }
        return vehicleByIdToReturn;
    }

    /**
    * @description OM-925 Generate Exposure records from Claim platform Event
    * @author      Kejia Hu
    * @date        06/08/2019                     
    */
    public Map<String, Case> generateExposureByExposureId(Case claim, Map<String, Account> accountByPartyId) {
        Map<String, Case> exposuresByKey = new Map<String, Case>();
        for (ClaimExposure ce : this.claimExposures) {
            Case oneExp = generateExposureFromClaimExposure(ce, claim, accountByPartyId);
            exposuresByKey.put(ce.claimExposureId, oneExp);
        }
        return exposuresByKey;
    }

    /**
    * @description OM-925 Generate Exposure instance from Claim platform Event ClaimExposure
    * @author      Kejia Hu
    * @date        06/08/2019                     
    */
    public Case generateExposureFromClaimExposure(ClaimExposure claimExposure, Case claim, Map<String, Account> accountByPartyId) {
        //Case-Exposure RecordType API names need to match Expousre_Type__c.Code__c
        Case exposure = new Case(
                            RecordTypeId = Omni_ClaimEventDAOHelper.exposureRecordTypeIdByTypeCode.get(
                                            claimExposure.exposureType),
                            Origin = 'Web',
            				ExposureType__c = (Omni_ClaimEventDAOHelper.exposureTypeByName.containsKey(claimExposure.exposureType))
                                                ? Omni_ClaimEventDAOHelper.exposureTypeByName.get(claimExposure.exposureType).Id
                                                : null,
                            ClaimForExposure__c = claim.Id,
                            ClaimNumber__c = claim.ClaimNumber__c,
                            Retired__c = claimExposure.retired,
                            OwnerId = (null == claimExposure.assignedUserId || !Omni_UserSelector.USER_ID_BY_GWCC_ID.containsKey(claimExposure.assignedUserId)) 
                                        ? defaultQueueAsOwner 
                                        : Omni_UserSelector.USER_ID_BY_GWCC_ID.get(claimExposure.assignedUserId),
                            ExposureId__c = claimExposure.claimExposureId,
                            ApplicableDeductibleAmount__c = (!String.isBlank(claimExposure.applicableDeductibleAmount))
                                                                ? Decimal.valueOf(claimExposure.applicableDeductibleAmount)
                                                                : null,
                            ApplicableDeductibleCurrencyCode__c = claimExposure.applicableDeductibleCurrencyCode,
                            ReferenceNumber__c = claimExposure.referenceNumber,
                            CoverageInQuestion__c = claimExposure.coverageInQuestion,
                            WithoutPrejudice__c = claimExposure.withoutPrejudice,
                            RiskUnitReferenceNumber__c = claimExposure.riskUnitReferenceNumber,
                            ChevronStatus__c = (String.isBlank(claimExposure.chevronStatus)) ? 'opened' : claimExposure.chevronStatus,
                            ClaimExposureClosedDate__c = Utility.getDateTime(claimExposure.claimExposureClosedDate),
                            ClaimExposureOpenedDate__c = Utility.getDateTime(claimExposure.claimExposureOpenedDate),
                            ClaimExposureReOpenedDate__c = Utility.getDateTime(claimExposure.claimExposureReOpenedDate),
                            LossPartyRole__c = (Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_CODE.containsKey(claimExposure.lossPartyRole))
                                                ? Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_CODE.get(claimExposure.lossPartyRole).Id
                                                : null,
                            ClaimExposureStatus__c = (Omni_ClaimEventDAOHelper.exposureStatusByCode.containsKey(claimExposure.claimExposureStatus))
                                                        ? Omni_ClaimEventDAOHelper.exposureStatusByCode.get(claimExposure.claimExposureStatus).Id
                                                        : null,
                            Claimant__c = (!String.isBlank(claimExposure.claimantPartyId) && accountByPartyId.containsKey(claimExposure.claimantPartyId))
                                                ? accountByPartyId.get(claimExposure.claimantPartyId).Id
                                                : null,
                            ExpClaimantDOB__c = (!String.isBlank(claimExposure.claimantPartyId) && accountByPartyId.containsKey(claimExposure.claimantPartyId))
                                                    ? accountByPartyId.get(claimExposure.claimantPartyId).PersonBirthdate
                                                    : null,
                            AssignedUserId__c = claimExposure.assignedUserId);
        //Populate InformationSensitivity for Other Exposure from claim
        exposure.InformationSensitivity__c = (exposure.RecordTypeId == Omni_ClaimEventConstant.RECORD_TYPE_ID_OTH_EXPOSURE)
                                                ? claim.InformationSensitivity__c
                                                : null;
        if (Utility.SURVEY_SWITCH_BY_KEY.get('SurveyMapping').IsEnabled__c) {
            exposure.SendAccidentBenefitsSurvey__c = (null == claimExposure.sendAccidentBenefitsSurvey) ? false : claimExposure.sendAccidentBenefitsSurvey;

        }
        return exposure;
    }

    /**
    * @description OM-925 Generate Transaction records from Claim platform Event
    * @author      Kejia Hu
    * @date        05/09/2019                     
    */
    public Map<String, Transaction__c> generateTransactionByTransId(Map<String, Case> exposureByExposureId) {
        Map<String, Transaction__c> transactionByKey = new Map<String, Transaction__c>();
        if (!this.financialTransactions.isEmpty()) {
            for (FinancialTransaction ft : this.financialTransactions) {
                Transaction__c oneTrans = generateTransFromFinancialTrans(ft, exposureByExposureId.get(ft.claimExposureId));
                transactionByKey.put(ft.financialTransactionId, oneTrans);
            }
        }
        return transactionByKey;
    }

    /**
    * @description OM-925 Generate Transaction instance from Claim platform Event FinancialTransaction
    * @author      Kejia Hu
    * @date        06/09/2019                     
    */
    private Transaction__c generateTransFromFinancialTrans(FinancialTransaction fTrans, Case exposure) {
        Transaction__c trans = new Transaction__c(
                                    Exposure__c = exposure.Id,
                                    OwnerId = exposure.OwnerId,
                                    Amount__c = (!String.isBlank(fTrans.amount))
                                                    ? Decimal.valueOf(fTrans.amount)
                                                    : null,
                                    AmountOnInstrument__c = (!String.isBlank(fTrans.amountOnInstrument))
                                                    ? Decimal.valueOf(fTrans.amountOnInstrument)
                                                    : null,
                                    AmountBreakdownCategory__c = fTrans.amountBreakdownCategory,
                                    AmountCurrencyCode__c = fTrans.amountCurrencyCode,
                                    AmountOnInstrumentCurrencyCode__c = fTrans.amountOnInstrumentCurrencyCode,
                                    EffectiveDate__c = Utility.getDateTime(fTrans.instrumentEffectiveDate),
                                    NameOnInstrument__c = fTrans.nameOnInstrument,
                                    Retired__c = fTrans.retired,
                                    Status__c = fTrans.status,
                                    Transaction_Id__c = fTrans.financialTransactionId,
                                    TransactionType__c = fTrans.transactionType,
                                    CostTypeCategory__c = fTrans.costTypeCategory,
                                    InstrumentStatus__c = fTrans.instrumentStatus,
                                    TransactionStatus__c = fTrans.transactionStatus,
                                    TransactionEventDate__c = Utility.getDateTime(fTrans.transactionEventDate)
        );
        return trans;
    }

    /**
    * @description OM-925 populate last financial transaction on exposures
    * @author      Kejia Hu
    * @date        06/09/2019                     
    */
    public Map<String, Case> populateExposureLastTransaction(Map<String, Case> exposureByExposureId, 
        Map<String, Transaction__c> transactionById) {
            for (ClaimExposure ce : this.claimExposures) {
                if (!String.isBlank(ce.lastPaymentFinancialTransactionId) 
                    && transactionById.containsKey(ce.lastPaymentFinancialTransactionId)) {
                        Case exposureToProcess = exposureByExposureId.get(ce.claimExposureId);
                        exposureToProcess.LastPaymentTransaction__c = transactionById.get(ce.lastPaymentFinancialTransactionId).Id;
                } else if (String.isBlank(ce.lastPaymentFinancialTransactionId)) {
                        exposureByExposureId.get(ce.claimExposureId).LastPaymentTransaction__c = null;
                }
            }
        return exposureByExposureId;
    }

    /**
    * @description OM-925 Generate Role records from PartyRoles of Platform Event, accounts, claim and exposures
    * @author      Kejia Hu
    * @date        06/08/2019                     
    */
    public Map<String, Case> generateRoleByPartyRoleId(Map<String, Account> accountByPartyId, Case claim,
                                        Map<String, Case> exposureByExposureId, Map<String, Contact> contactByPartyId,
                                        Map<String, Contact> contactByAccountId, Map<String, Vehicle__c> vehicleById,
                                        Map<String, Transaction__c> transactionById) {
        Map<String, Case> rolesByKey = new Map<String, Case>();
        Map<String, String> contactIdByAccountId;
        for (PartyRole pcr : this.partyRoles) {
            Case role = (String.isBlank(pcr.claimExposureId)) 
                            ? generateClaimRoleFromPartyRole(pcr, accountByPartyId, claim, exposureByExposureId, contactByPartyId, contactByAccountId, vehicleById)
                            : generateExposureRoleFromPartyRole(pcr, accountByPartyId, claim, exposureByExposureId, contactByPartyId, contactByAccountId, vehicleById, transactionById);
            rolesByKey.put(pcr.partyRoleId,role);
        }
        return rolesByKey;
    }

    /**
    * @description OM-925 genereate Claim Role record from one PartyRole of Platform Event, accounts, claim and exposures
    * @author      Kejia Hu
    * @date        06/08/2019                     
    */
    public Case generateClaimRoleFromPartyRole(PartyRole partyRole, Map<String, Account> accountByPartyId, Case claim, 
                                                Map<String, Case> exposureByExposureId, Map<String, Contact> contactByPartyId, 
                                                Map<String, Contact> contactByAccountId, Map<String, Vehicle__c> vehicleById) {
        Case role = generateBaseRole(partyRole, accountByPartyId, claim, exposureByExposureId, contactByPartyId, contactByAccountId, vehicleById);
        role.RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_CLAIM_ROLE;
        role.OwnerId = claim.OwnerId;
        User u = Omni_UserSelector.USER_BY_ID.get(claim.OwnerId);
        if (u != null) {
            role.Adjuster_Address_Line1__c  = (u.Street == null) ? '' : u.Street;
            role.Adjuster_City__c           = (u.City == null) ? '' : u.City;
            role.Adjuster_Postal_Code__c    = (u.PostalCode == null) ? '' : u.PostalCode;
            role.Adjuster_Title_1_FR__c     = (u.Title_1_FR__c == null) ? '' : u.Title_1_FR__c;
            role.Adjuster_Title_2_FR__c     = (u.Title_2_FR__c == null) ? '' : u.Title_2_FR__c;
            role.Adjustor_Company_Name__c   = (u.CompanyName == null) ? '' : u.CompanyName;
            role.Adjustor_Email_Address__c  = u.Email;
            role.Adjustor_Fax_Number__c     = (u.Fax == null) ? '' : u.Fax;
            role.Adjustor_Name__c           = u.Name;
            role.Adjustor_Phone__c          = (u.Phone == null) ? '' : u.Phone;
            role.Adjustor_Province__c       = (u.State == null) ? '' : u.State;
            role.Adjustor_Title1__c         = (u.Title_1__c == null) ? '' : u.Title_1__c;
            role.Adjustor_Title2__c         = (u.Title_2__c == null) ? '' : u.Title_2__c;
            role.Adjustor_Address__c        = (u.Street == null ? '' : u.Street + ', ') +
                                                (u.City == null ? '' : u.City + ', ') +
                                                (u.State == null ? '' : u.State + ', ')  + 
                                                (u.PostalCode == null ? '' : u.PostalCode);
        }
        return role;
    }

    /**
    * @description OM-925 genereate Exposure Role record from one PartyRole of Platform Event, accounts, claim and exposures
    * @author      Kejia Hu
    * @date        06/08/2019                    
    */
    public Case generateExposureRoleFromPartyRole(PartyRole partyRole, Map<String, Account> accountByPartyId, Case claim,
                                                    Map<String, Case> exposureByExposureId, Map<String, Contact> contactByPartyId,
                                                    Map<String, Contact> contactByAccountId,Map<String, Vehicle__c> vehicleById,
                                                    Map<String, Transaction__c> transactionById) {                                               
        Map<String, Account> accountBySFId = new Map<String, Account>();
        accountBySFId.putAll(accountByPartyId.values());
        Case exposureForRole = exposureByExposureId.get(partyRole.claimExposureId);
        Map<String, Transaction__c> transactionBySFId = new Map<String, Transaction__c>();
        transactionBySFId.putAll(transactionById.values());
        Transaction__c lastPaymentTransaction  = transactionBySFId.get(exposureForRole.LastPaymentTransaction__c);
        ExposureType__c exposureType = Omni_ClaimEventDAOHelper.EXPOSURE_TYPE_BY_ID.get(exposureForRole.ExposureType__c);
        ClaimExposureStatus__c exposureStatus = Omni_ClaimEventDAOHelper.exposureStatusById.get(exposureForRole.ClaimExposureStatus__c);
        Case role = generateBaseRole(partyRole, accountByPartyId, claim, exposureByExposureId, contactByPartyId, contactByAccountId, vehicleById);
        Account claimantParty = accountBySFId.get(exposureForRole.Claimant__c);
        role.RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE;
        role.ExposureForRole__c = exposureForRole.Id;
        role.OwnerId = exposureForRole.OwnerId;
        User u = Omni_UserSelector.USER_BY_ID.get(role.OwnerId);
        if (u != null) {
            role.Adjuster_Address_Line1__c  = (u.Street == null) ? '' : u.Street;
            role.Adjuster_City__c           = (u.City == null) ? '' : u.City;
            role.Adjuster_Postal_Code__c    = (u.PostalCode == null) ? '' : u.PostalCode;
            role.Adjuster_Title_1_FR__c     = (u.Title_1_FR__c == null) ? '' : u.Title_1_FR__c;
            role.Adjuster_Title_2_FR__c     = (u.Title_2_FR__c == null) ? '' : u.Title_2_FR__c;
            role.Adjustor_Company_Name__c   = (u.CompanyName == null) ? '' : u.CompanyName;
            role.Adjustor_Email_Address__c  = u.Email;
            role.Adjustor_Fax_Number__c     = (u.Fax == null) ? '' : u.Fax;
            role.Adjustor_Name__c           = u.Name;
            role.Adjustor_Phone__c          = (u.Phone == null) ? '' : u.Phone;
            role.Adjustor_Province__c       = (u.State == null) ? '' : u.State;
            role.Adjustor_Title1__c         = (u.Title_1__c == null) ? '' : u.Title_1__c;
            role.Adjustor_Title2__c         = (u.Title_2__c == null) ? '' : u.Title_2__c;
            role.Adjustor_Address__c        = (u.Street == null ? '' : u.Street + ', ') +
                                                (u.City == null ? '' : u.City + ', ') +
                                                (u.State == null ? '' : u.State + ', ')  + 
                                                (u.PostalCode == null ? '' : u.PostalCode);
        }
        if (null != lastPaymentTransaction) {
            role.Cheque_Issued_Amount_for_Role__c = lastPaymentTransaction.AmountOnInstrument__c;
            role.Cheque_Issued_Amount_for_Role_Str__c = Utility.getStringValWithScale(lastPaymentTransaction.AmountOnInstrument__c, 2);
            role.Cheque_Issued_Date_EN__c = (null!=lastPaymentTransaction.EffectiveDate__c) 
                                                ? lastPaymentTransaction.EffectiveDate__c.format('MM/dd/yyyy')
                                                : null;
            role.Cheque_Issued_Date_FR__c = (null!=lastPaymentTransaction.EffectiveDate__c)
                                                ? lastPaymentTransaction.EffectiveDate__c.format('dd/MM/yyyy')
                                                : null;
            role.Cheque_Payee_for_Role__c = lastPaymentTransaction.NameOnInstrument__c;
        }
        if (null != claimantParty) {
            role.ClaimantFirstName__c = (!String.isBlank(claimantParty.LastName)) 
                                                ? claimantParty.FirstName 
                                                : claimantParty.Name;
            role.ClaimantLastName__c = claimantParty.LastName;
        }
        role.ExposureName_EN_for_Role__c = exposureType.L_EN_CA__c;
        role.ExposureName_FR_for_Role__c = exposureType.L_FR_CA__c;
        role.Exposure_Type__c = exposureType.L_EN_CA__c + ' ' + exposureType.L_FR_CA__c;
        role.Exposure_Type_for_Role__c = exposureType.TypeCode__c;
        role.Exposure_Number_Order__c = exposureForRole.Exposure_Number_Order__c;
        role.ExposureIdForRole__c = exposureForRole.ExposureId__c;
        role.RiskUnitReferenceNumber__c = exposureForRole.RiskUnitReferenceNumber__c;
        role.ClaimExposureStatusEN__c = exposureStatus.L_EN_CA__c;
        role.ClaimExposureStatusFR__c = exposureStatus.L_FR_CA__c;
        if (null != claim.IncidentDriver__c && accountBySFId.containsKey(claim.IncidentDriver__c)) {
            role.IncidentDriverExposureId__c = (partyRole.partyId == accountBySFId.get(claim.IncidentDriver__c).PartyId__c
                                                && partyRole.claimExposureId == role.QCLNExposureExId__c) 
                                                    ? partyRole.claimExposureId
                                                    : null;
        }
        return role;
    }

    /**
    * @description OM-925 genereate Role record claim related information from one PartyRole of Platform Event, accounts, claim and exposures
    * @author      Kejia Hu
    * @date        12/11/2019                    
    */
    public Case generateBaseRole(PartyRole partyRole, Map<String, Account> accountByPartyId, Case claim, 
                                 Map<String, Case> exposureByExposureId, Map<String, Contact> contactByPartyId, 
                                 Map<String, Contact> contactByAccountId, Map<String, Vehicle__c> vehicleById){
        Map<String, Account> accountBySFId = new Map<String, Account>();
        accountBySFId.putAll(accountByPartyId.values());
        Map<String, Case> exposureBySFId = new Map<String, Case>();
        exposureBySFId.putAll(exposureByExposureId.values());
        Map<String, Vehicle__c> vehicleBySFId = new Map<String, Vehicle__c>();
        vehicleBySFId.putAll(vehicleById.values());
        Vehicle__c assignedForCoverageVehicle = vehicleBySFId.get(claim.AssignedForCoverageVehicleId__c);
        Account partyAccount = (accountByPartyId.containsKey(partyRole.partyId)) 
                                    ? accountByPartyId.get(partyRole.partyId)
                                    : null;
        Contact partyContact = (accountByPartyId.containsKey(partyRole.partyId))
                                    ? (contactByPartyId.containsKey(partyRole.partyId))
                                        ? contactByPartyId.get(partyRole.partyId)
                                        : contactByAccountId.get(accountByPartyId.get(partyRole.partyId).Id)
                                    : null;
        LossCause__c lossCause = Omni_ClaimEventDAOHelper.LOSS_CAUSE_BY_ID.get(claim.LossCause__c);
        TypeOfLoss__c typeOfLoss = Omni_ClaimEventDAOHelper.TYPE_LOSS_BY_ID.get(claim.TypeOfLoss__c);
        Account mainContact = accountBySFId.get(claim.AccountId);
        PolicyIssuingGroup__c policyIssuingGroup = Omni_ClaimEventDAOHelper.POLICY_ISSUING_GROUP_BY_ID.get(claim.Policy_Issuing_Group__c);
        Account renterParty = accountBySFId.get(claim.RenterParty__c);
        Account damageRepairParty = accountBySFId.get(claim.DamageRepairParty__c);
        Vehicle__c lossVehicle = vehicleBySFId.get(claim.LossVehicle__c);
        Account appraiserParty = accountBySFId.get(claim.AppraiserParty__c);
        Account driverParty = accountBySFId.get(claim.IncidentDriver__c);
        Account custodianParty = accountBySFId.get(claim.InsuredCustodian__c);
        Case QCLNExposure = exposureBySFId.get(claim.QCLNExposure__c);
        Case NLPLExposure = exposureBySFId.get(claim.NLPLExposure__c);
        
        Case baseRole = new Case();
        baseRole.Origin = 'Web';
        baseRole.Omni_Implementation_Date__c = Utility.OMNI_IMPLEMENTATION_DATE;
        baseRole.RoleId__c = partyRole.partyRoleId;
        baseRole.ClaimForRole__c = claim.Id;
        baseRole.Retired__c = partyRole.retired;
        baseRole.Preferred_Channel_Type__c = partyRole.preferredChannelType;
        baseRole.RoleNature__c = (Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_CODE.containsKey(partyRole.nature))
                                        ? Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_CODE.get(partyRole.nature).Id
                                        : null;
        baseRole.Nature_of_Role__c = Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_CODE.get(partyRole.nature).L_EN_CA__c 
                                    + '/' + Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_CODE.get(partyRole.nature).L_FR_CA__c;
        if (null != partyAccount) {
            baseRole.RolePartyId__c = partyAccount.PartyId__c;
            baseRole.PartyAccount__c = partyAccount.Id;
            baseRole.Fax_Number__c = partyAccount.Fax;
            baseRole.Language_Preference__c = partyAccount.Language__c;
            baseRole.DriversLicenceNumber__c = partyAccount.DrivingLicenseNumber__c;
            baseRole.Party_Province_FR__c = (Omni_ClaimEventDAOHelper.STATE_BY_ID.containsKey(partyAccount.State__c)) 
                                                ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(partyAccount.State__c).L_FR_CA__c
                                                : null;
            baseRole.Party_Province__c = (Omni_ClaimEventDAOHelper.STATE_BY_ID.containsKey(partyAccount.State__c)) 
                                                ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(partyAccount.State__c).L_EN_CA__c
                                                : null;
        }
        //For person account, need to query to get contact Id from the person account Id
        if (null != partyContact) {
            baseRole.PartyContact__c = partyContact.Id;
            baseRole.Email_Address_for_Role__c = partyContact.Email;
            baseRole.Party_Address_Line__c = partyContact.MailingStreet;
            baseRole.Party_City__c = partyContact.MailingCity;
            baseRole.Party_First_Name__c = partyContact.FirstName;
            baseRole.Party_Last_Name__c = partyContact.LastName;
            baseRole.Party_Postal_Code__c = partyContact.MailingPostalCode;
        }
        baseRole.Additional_Insured__c = claim.Additional_Insured__c;
        baseRole.InjuriesInvolved__c = claim.InjuriesInvolved__c;
        baseRole.AppraisalQualifier__c = claim.AppraisalQualifier__c;
        baseRole.AppraisalTaskStatus__c = claim.AppraisalTaskStatus__c;
        baseRole.Appraisal_Appointment_Date__c = claim.Appraisal_Appointment_Date__c;
        baseRole.Appraisal_Appointment_Time__c = claim.Appraisal_Appointment_Time__c;
        baseRole.AppraiserPartyName_for_Role__c = (accountBySFId.containsKey(claim.AppraiserParty__c)) 
                                                        ? accountBySFId.get(claim.AppraiserParty__c).Name 
                                                        : null;
        baseRole.Broker_Branch_EN__c = (Omni_ClaimEventDAOHelper.POLICY_BRANCH_BY_ID.containsKey(claim.PolicyBranch__c)) 
                                            ? Omni_ClaimEventDAOHelper.POLICY_BRANCH_BY_ID.get(claim.PolicyBranch__c).L_EN_CA__c
                                            : null;
        baseRole.Broker_Branch_FR__c = (Omni_ClaimEventDAOHelper.POLICY_BRANCH_BY_ID.containsKey(claim.PolicyBranch__c)) 
                                            ? Omni_ClaimEventDAOHelper.POLICY_BRANCH_BY_ID.get(claim.PolicyBranch__c).L_FR_CA__c
                                            : null;
        baseRole.Broker_Name__c = (accountBySFId.containsKey(claim.AgentParty__c)) ? accountBySFId.get(claim.AgentParty__c).Name : null;
        baseRole.Cellular_Phone_Number__c = (accountByPartyId.containsKey(partyRole.partyId)) 
                                                ? accountByPartyId.get(partyRole.partyId).Phone
                                                : null;
        baseRole.ClaimContractEffectiveDate__c = claim.ClaimContractEffectiveDate__c;
        baseRole.ClaimLOBGroup__c = claim.ClaimLOBGroup__c;
        baseRole.ClaimNumber__c = claim.ClaimNumber__c;
        baseRole.Claim_LOB__c = claim.Claim_LOB__c;
        baseRole.ClientPIN__c = claim.ClientPIN__c;
        baseRole.NonCasualtyWithoutPrejudice__c = claim.NonCasualtyWithoutPrejudice__c;
        baseRole.NonCasualtyCoverageInQuestion__c = claim.NonCasualtyCoverageInQuestion__c;
        if (null != assignedForCoverageVehicle) {
            baseRole.CoverageVehicleMake_for_Role__c = assignedForCoverageVehicle.Make__c;
            baseRole.CoverageVehicleModel_for_Role__c = assignedForCoverageVehicle.Model__c;
            baseRole.CoverageVehicleVIN_for_Role__c = assignedForCoverageVehicle.SerialNumber__c;
            baseRole.CoverageVehicleYear_for_Role__c = assignedForCoverageVehicle.ModelYear__c;
            baseRole.CoverageVehicleLicensePlate__c = assignedForCoverageVehicle.LicensePlate__c;
            baseRole.AssignedVehicleLicensePlateProvince__c = assignedForCoverageVehicle.LicensePlateProvinceId__c;
        }
        baseRole.DateOfLoss__c = claim.DateOfLoss__c;
        baseRole.DeductibleAmount__c = claim.DeductibleAmount__c;
        baseRole.DeductibleAmountStr__c = Utility.getStringValWithScale(claim.DeductibleAmount__c, 2);
        baseRole.DeductibleAmountCurrencyCode__c = claim.DeductibleAmountCurrencyCode__c;
        baseRole.Driver_Name__c = (String.isBlank(claim.AssignedDriverParty__c))
                                        ? null
                                        : accountBySFId.get(claim.AssignedDriverParty__c).FirstName 
                                            + ' ' + accountBySFId.get(claim.AssignedDriverParty__c).LastName;
        baseRole.IncidentDateReported__c = claim.IncidentDateReported__c;
        baseRole.InformationSensitivity__c = claim.InformationSensitivity__c;
        baseRole.Initial_Gross_Estimate_Amount__c = claim.Initial_Gross_Estimate_Amount__c;
        baseRole.Initial_Gross_Estimate_Amount_Str__c = Utility.getStringValWithScale(claim.Initial_Gross_Estimate_Amount__c, 2);
        baseRole.Initial_Gross_Estimate_Currency__c = claim.Initial_Gross_Estimate_Currency__c;
        baseRole.InsuredProbableFaultPercentage__c = claim.InsuredProbableFaultPercentage__c;
        baseRole.ClaimOpenedDate__c = claim.ClaimOpenedDate__c;
        baseRole.ClaimReopenedDate__c = claim.ClaimReopenedDate__c;
        baseRole.TotalIndemnity__c = claim.TotalIndemnity__c;
        baseRole.TotalRecovery__c = claim.TotalRecovery__c;
        baseRole.ClaimNumberReplaced__c = claim.ClaimNumberReplaced__c;
        baseRole.QCLNClaimExpVehicleChapAPaid__c = claim.QCLNClaimExpVehicleChapAPaid__c;
        baseRole.QCLNClaimExpVehicleChapAPaidStr__c = Utility.getStringValWithScale(claim.QCLNClaimExpVehicleChapAPaid__c, 2);
        baseRole.QCLNClaimExpVehicleChapBPaid__c = claim.QCLNClaimExpVehicleChapBPaid__c;
        baseRole.QCLNClaimExpVehicleChapBPaidStr__c = Utility.getStringValWithScale(claim.QCLNClaimExpVehicleChapBPaid__c, 2);
        baseRole.NLPClaimSectionAPaidThirdParty__c = claim.NLPClaimSectionAPaidThirdParty__c;
        baseRole.NLPClaimSectionAPaidThirdPartyStr__c = Utility.getStringValWithScale(claim.NLPClaimSectionAPaidThirdParty__c, 2);
        baseRole.QCLNExposureExId__c = (null != QCLNExposure) ? QCLNExposure.ExposureId__c : null;
        baseRole.NLPLExposureExId__c = (null != NLPLExposure) ? NLPLExposure.ExposureId__c : null;
        baseRole.PoliceReportNumber__c = claim.PoliceReportNumber__c;
        baseRole.VehicleLocationNote__c = claim.VehicleLocationNote__c;
        baseRole.InjuredPartyRoleDescriptionEN__c = (Omni_ClaimEventDAOHelper.INJURED_ROLE_BY_ID.containsKey(claim.InjuredPartyRole__c)) 
                                                        ? Omni_ClaimEventDAOHelper.INJURED_ROLE_BY_ID.get(claim.InjuredPartyRole__c).L_EN_CA__c
                                                        : null;
        baseRole.InjuredPartyRoleDescription__c = (Omni_ClaimEventDAOHelper.INJURED_ROLE_BY_ID.containsKey(claim.InjuredPartyRole__c)) 
                                                        ? Omni_ClaimEventDAOHelper.INJURED_ROLE_BY_ID.get(claim.InjuredPartyRole__c).Description__c
                                                        : null;
        baseRole.InjuredPartyTypeCode__c = (Omni_ClaimEventDAOHelper.INJURED_ROLE_BY_ID.containsKey(claim.InjuredPartyRole__c)) 
                                                ? Omni_ClaimEventDAOHelper.INJURED_ROLE_BY_ID.get(claim.InjuredPartyRole__c).TypeCode__c
                                                : null;
        baseRole.Insured_First_Name__c = (null!=claim.InsuredParty__c) 
                                            ? (!String.isBlank(accountBySFId.get(claim.InsuredParty__c).LastName)) 
                                                ? accountBySFId.get(claim.InsuredParty__c).FirstName 
                                                : accountBySFId.get(claim.InsuredParty__c).Name
                                            : null;
        baseRole.Insured_Last_Name__c = (null!=claim.InsuredParty__c) ? accountBySFId.get(claim.InsuredParty__c).LastName : null;
        baseRole.LiabilityConfirmed__c = claim.LiabilityConfirmed__c;
        if (null != lossCause) {
            baseRole.LossCauseTypeCode__c = lossCause.TypeCode__c;
            baseRole.Loss_Cause_Description__c = lossCause.Description__c;
            baseRole.Loss_Cause_EN__c = lossCause.L_EN_CA__c;
            baseRole.Loss_Cause_FR__c = lossCause.L_FR_CA__c;
            baseRole.Loss_Cause__c = lossCause.L_EN_CA__c + '/' + lossCause.L_FR_CA__c;
        }
        baseRole.LossLocation__c = clearAddressField(
                                        getCleanFieldValue(claim.IncidentAddressLine__c) + getCleanFieldValue(claim.IncidentCity__c) + 
                                        getCleanFieldValue(claim.IncidentProvince__c) + getCleanFieldValue(claim.IncidentPostalCode__c) +  
                                        getCleanFieldValue(claim.IncidentCountry__c));
        if (null != typeOfLoss) {
            baseRole.LossType_TypeCode__c = typeOfLoss.TypeCode__c;
            baseRole.Loss_Type_Description__c = typeOfLoss.Description__c;
            baseRole.Loss_Type_EN_for_Role__c = typeOfLoss.L_EN_CA__c;
            baseRole.Loss_Type_FR_for_Role__c = typeOfLoss.L_FR_CA__c;
            baseRole.Loss_Type__c = typeOfLoss.L_EN_CA__c + '/' + typeOfLoss.L_FR_CA__c;
        }
        if (null != mainContact) {
            baseRole.Main_Contact_Address_for_Role__c = mainContact.PersonMailingStreet;
            baseRole.Main_Contact_City_for_Role__c = mainContact.PersonMailingCity;
            baseRole.Main_Contact_First_Name_for_Role__c = mainContact.FirstName;
            baseRole.Main_Contact_Last_Name_for_Role__c = mainContact.LastName;
            baseRole.Main_Contact_Postal_for_Role__c = mainContact.PersonMailingPostalCode;
            baseRole.Main_Contact_Province_for_Role__c = (!String.isBlank(mainContact.State__c)) 
                                                                ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(mainContact.State__c).L_EN_CA__c
                                                                : null;
            baseRole.Main_Contact_Province_for_Role_FR__c = (!String.isBlank(mainContact.State__c)) 
                                                                ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(mainContact.State__c).L_FR_CA__c
                                                                : null;
        }
        if (null != policyIssuingGroup) {
            baseRole.PIGBusinessNameEN__c = policyIssuingGroup.Business_Name_EN_CA__c;
            baseRole.PIGBusinessNameFR__c = policyIssuingGroup.Business_Name_FR_CA__c;
            baseRole.PIG_EN__c = policyIssuingGroup.L_EN_CA__c;
            baseRole.PIG_FR__c = policyIssuingGroup.L_FR_CA__c;
            baseRole.PIG_TypeCode__c = policyIssuingGroup.TypeCode__c;
        }
        baseRole.PolicyNumber__c = claim.PolicyNumber__c;
        baseRole.PolicyUnderwritingGroupForRole__c = claim.UnderwritingCompany__c;
        baseRole.Policy_Holder_First_Last_Name__c = (String.isBlank(claim.InsuredParty__c))
                                                        ? null
                                                        : accountBySFId.get(claim.InsuredParty__c).FirstName + ' ' + accountBySFId.get(claim.InsuredParty__c).LastName;
        baseRole.ProvinceOfIssuanceId__c = (!String.isBlank(claim.ProvinceOfIssuance__c)) 
                                                ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(claim.ProvinceOfIssuance__c).TypeCode__c
                                                : null;
        baseRole.Rental_Limit__c = claim.Rental_Limit__c;
        if (null != renterParty) {
            baseRole.RentalCompany_Name_for_Role__c = renterParty.Name;
            baseRole.Rental_Address_for_Role__c = renterParty.BillingStreet;
            baseRole.Rental_City_for_Role__c = renterParty.BillingCity;
            baseRole.Rental_Company_Country_FR__c = (!String.isBlank(renterParty.Country__c)) 
                                                        ? Omni_ClaimEventDAOHelper.COUNTRY_BY_ID.get(renterParty.Country__c).L_FR_CA__c
                                                        : null;
            baseRole.Rental_Company_Country__c = (!String.isBlank(renterParty.Country__c)) 
                                                        ? Omni_ClaimEventDAOHelper.COUNTRY_BY_ID.get(renterParty.Country__c).L_EN_CA__c
                                                        : null;
            baseRole.Rental_Location_Phone__c = (String.isBlank(renterParty.Extension__c))
                                                    ? renterParty.Phone
                                                    : renterParty.Phone + ' x' + renterParty.Extension__c;
            baseRole.Rental_PostalCode_for_Role__c = renterParty.BillingPostalCode;
            baseRole.Rental_Province_for_Role_FR__c = (!String.isBlank(renterParty.State__c)) 
                                                            ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(renterParty.State__c).L_FR_CA__c
                                                            : null;
            baseRole.Rental_Province_for_Role__c = (!String.isBlank(renterParty.State__c)) 
                                                            ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(renterParty.State__c).L_EN_CA__c
                                                            : null;
        }
        if (null != damageRepairParty) {
            baseRole.Repair_Shop_City_for_Role__c = damageRepairParty.BillingCity;
            baseRole.Repair_Shop_Vendor_Name_for_Role__c = damageRepairParty.Name;
            baseRole.Repairshop_Address_for_Role__c = damageRepairParty.BillingStreet;
            baseRole.Repairshop_PostalCode_for_Role__c = damageRepairParty.BillingPostalCode;
            baseRole.Repairshop_Province_for_Role_FR__c = (!String.isBlank(damageRepairParty.State__c)) 
                                                            ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(damageRepairParty.State__c).L_FR_CA__c
                                                            : null;
            baseRole.Repairshop_Province_for_Role__c = (!String.isBlank(damageRepairParty.State__c)) 
                                                            ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(damageRepairParty.State__c).L_EN_CA__c
                                                            : null;
            baseRole.Repairshop_Workphone_for_Role__c = (String.isBlank(damageRepairParty.Extension__c))
                                                        ? damageRepairParty.Phone
                                                        : damageRepairParty.Phone + ' x' + damageRepairParty.Extension__c;
        }
        baseRole.RoleName_EN__c = Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_ID.get(baseRole.RoleNature__c).L_EN_CA__c;
        baseRole.RoleName_FR__c = Omni_ClaimEventDAOHelper.ROLE_NATURE_BY_ID.get(baseRole.RoleNature__c).L_FR_CA__c;
        baseRole.SellingChannelDistributorNumber__c = claim.SellingChannelDistributorNumber__c;
        baseRole.TotalLoss__c = claim.TotalLoss__c;
        if (null != lossVehicle) {
            baseRole.VehicleMake_for_Role__c = lossVehicle.Make__c;
            baseRole.VehicleModel_for_Role__c = lossVehicle.Model__c;
            baseRole.VehicleYear_for_Role__c = lossVehicle.ModelYear__c;
            baseRole.LossVehicleLicensePlate__c = lossVehicle.LicensePlate__c;
        }
        if (null != appraiserParty) {
            baseRole.Vendor_Address_for_Role__c = appraiserParty.BillingStreet;
            baseRole.Vendor_City_for_Role__c = appraiserParty.BillingCity;
            baseRole.Vendor_Name_for_Role__c = appraiserParty.Name;
            baseRole.Vendor_Postal_Code_for_Role__c = appraiserParty.BillingPostalCode;
            baseRole.Vendor_Province_for_Role_FR__c = (!String.isBlank(appraiserParty.State__c)) 
                                                        ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(appraiserParty.State__c).L_FR_CA__c
                                                        : null;
            baseRole.Vendor_Province_for_Role__c = (!String.isBlank(appraiserParty.State__c)) 
                                                        ? Omni_ClaimEventDAOHelper.STATE_BY_ID.get(appraiserParty.State__c).L_EN_CA__c
                                                        : null;
            baseRole.Vendor_WorkPhone_for_Role__c = (String.isBlank(appraiserParty.Extension__c))
                                                    ? appraiserParty.Phone
                                                    : appraiserParty.Phone + ' x' + appraiserParty.Extension__c;
            baseRole.VirtualAppraisal__c = claim.VirtualAppraisal__c;
        }
        if (null != driverParty) {
            baseRole.IncidentDriverEmailAddress__c = getEmail(driverParty.PartyId__c);
            baseRole.IncidentDriverPartyId__c = driverParty.PartyId__c;
        }
        if (null != custodianParty) {
            baseRole.InsuredCustodianPartyId__c = custodianParty.PartyId__c;
            baseRole.VehicleIncidentCustodianIN__C = custodianParty.Name;
        }
        return baseRole;                                              
    }

    /**
    * @description Make sure that address does not contain any null values in case when these are missing from the payload
    * @author      Damian Kazior
    * @date        31/10/2019                     
    */
    private static String getCleanFieldValue(String fieldValue){
        if(fieldValue == null){
            return '';
        }else{
            return fieldValue+', ';
        }
    }

    /**
    * @description remove any trailing commas from address field in case of missing fields
    * @author      Damian Kazior
    * @date        31/10/2019                     
    */
    private static String clearAddressField(String address){
     
        if(address.endsWith(', ')){
            address = address.trim().removeEnd(','); 
        }
        return address;
    }

    /**
    * @description OM-925 get Driving License information from platform event based on party Id
    * @author      Kejia Hu
    * @date        09/09/2019                     
    */
    private DrivingLicense getDrivingLicense(String partyId) {
        DrivingLicense lis;
        for (DrivingLicense l : this.DrivingLicenses) {
            if (partyId == l.partyId) {
                lis = l;
                break;
            }
        }
        return lis;
    }

    /**
    * @description OM-925 get address from platform event based on party Id
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    private Address getAddress(String partyId) {
        Address add;
        if (null != this.addresses) {
            for (Address a : this.addresses) {
                //Temporary diable isPreferred check unti CC fix the bug
                if (partyId == a.partyId) {
                //if (partyId == a.partyId && a.preferred) {
                    add = a;
                    break;
                }
            }
        }
        return add;
    }

    /**
    * @description OM-925 get email address from platform event based on party Id
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    private String getEmail(String partyId) {
        String emailToReturn;
        if (null != this.emails) {
            for (Email e : this.emails) {
                if (partyId == e.partyId && e.preferred) {
                    emailToReturn = e.electronicAddress;
                    break;
                }
            }
        }
        return emailToReturn;
    }

    /**
    * @description OM-925 get main cntact partyId from platform event
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    private String getMainContactPartyId() {
        String mailContactPartyId;
        for (PartyRole pr : this.partyRoles) {
            if (Omni_ClaimEventConstant.MAIN_CONTACT_VAL == pr.nature) {
                mailContactPartyId = pr.partyId;
                break;
            }
        }
        return mailContactPartyId;
    }

    /**
    * @description OM-925 get cell phone from platform event based on party Id
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    private Phone getCellPhone(String partyId) {
        Phone phoneToReturn;
        if (null != this.phones) {
            for (Phone p : this.phones) {
                if (partyId == p.partyId 
                    //&& p.preferred 
                    && p.phoneType == Omni_ClaimEventConstant.CELL_PHONE_TYPE_CODE) {
                    phoneToReturn = p;
                }
            }
        }
        return phoneToReturn;
    }

    /**
    * @description OM-925 get business phone from platform event based on party Id
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    private Phone getBusinessPhone(String partyId) {
        Phone phoneToReturn;
        if (null != this.phones) {
            for (Phone p : this.phones) {
                if (partyId == p.partyId 
                    && p.preferred 
                    && p.phoneType == Omni_ClaimEventConstant.BUSINESS_PHONE_TYPE_CODE) {
                    phoneToReturn = p;
                }
            }
        }
        return phoneToReturn;
    }
    
    /**
    * @description OM-925 get fax from platform event based on party Id
    * @author      Kejia Hu
    * @date        12/08/2019                     
    */
    private Phone getFax(String partyId) {
        Phone phoneToReturn;
        if (null != this.phones) {
            for (Phone p : this.phones) {
                if (partyId == p.partyId 
                    && p.preferred 
                    && p.phoneType == Omni_ClaimEventConstant.FAX_TYPE_CODE) {
                    phoneToReturn = p;
                }
            }
        }
        return phoneToReturn;
    }
	
	/**
    * @description OM-925 get address from platform event based on party Id
    * @author      Vikas Sharma
    * @date        21/08/2019
    */
    public List<Communication_Configuration__c> generateConfigurations(Map<String, List<Communication_Configuration__c>> eventNamesToConfigurations) 
    {
        
        List<Communication_Configuration__c> listToReturn = new List<Communication_Configuration__c>();
        
        if (eventNamesToConfigurations != null && eventNamesToConfigurations.get(eventName) != null)
        {
            return eventNamesToConfigurations.get(eventName);
        }
        return null;
        
    }
    
    private class ClaimExposure {
        String claimExposureId;
        String exposureType;
        Boolean retired;
        String assignedUserId;
        String applicableDeductibleCurrencyCode;
        String applicableDeductibleAmount;
        String referenceNumber;
        String lastPaymentFinancialTransactionId;
        Boolean coverageInQuestion;
        Boolean withoutPrejudice;
        String riskUnitReferenceNumber;
        String lossPartyRole;
        String claimExposureStatus;
        String claimExposureClosedDate;
        String claimExposureOpenedDate;
        String claimExposureReOpenedDate;
        String claimSubCoverage;
        String claimCoverage;
        Double totalIndemnity;
        String claimantPartyId;
        String hoExaminerUserId;
        String chevronStatus;
        Boolean sendAccidentBenefitsSurvey;
	}

    private class DrivingLicense {
        String partyId;
        String drivingLicenseNumber;
        String drivingLicensePlaceOfIssue;
    }

    private class FinancialTransaction {
        String claimExposureId;
        String financialTransactionId;
        Boolean retired;
        String transactionType; 
        String status;
        String instrumentEffectiveDate;
        String nameOnInstrument;
        String amount;
        String amountCurrencyCode;
        String amountOnInstrument;
        String amountOnInstrumentCurrencyCode;
        String amountBreakdownCategory;
        String instrumentStatus;
        String costTypeCategory;
        String transactionStatus;
        String transactionEventDate;
    }
    
    private class PartyItem {
        String partyId;
        String personFirstName;
        String personLastName;
        String personMiddleName;
        String personTitle;
        String personSuffix;
        String organisationName;
        String partyType;
        String language;
        Boolean retired;
        String personBirthDate;
	}

    private class PartyRole {
        String partyRoleId;
        String partyId;
        String claimExposureId;
        String nature;
        String preferredChannelType;
        Boolean retired;
    }

    private class Address {
        String addressType;
        String partyId;
        String addressLine;
        String postalCode;
        String province;
        String county;
        String city;
        String country;
        Boolean preferred;
    }

    private class Email {
        String partyId;
        String electronicAddress;
        Boolean preferred;
    }

    private class Phone {
        String partyId;
        String phoneType;
        String phoneNumber;
        String extensionNumber;
        Boolean preferred;
    }

    private class Vehicle {
        String vehicleId;
        String make;
        String model;
        String modelYear;
        String serialNumber;
        String licensePlate;
        String licensePlateProvinceId;
    }
}