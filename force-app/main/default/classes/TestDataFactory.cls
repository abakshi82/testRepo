@isTest
public class TestDataFactory {

    public static FINAL Integer TEST_SIZE_SMALL = 5;
    public static FINAL Integer TEST_SIZE_LARGE = 10;

    public static List<Application_Log__c> createExceptionIntegrationAppLogs(Integer numForEach){
        List<Application_Log__c> appLogs = new List<Application_Log__c>();
        for (Integer i=0 ; i<numForEach ; i++) {
            appLogs.add(new Application_Log__c(Category__c='Exception'));
            appLogs.add(new Application_Log__c(Category__c='Integration'));
        }
        insert appLogs;
        return appLogs;
    }

    /**
    * @Description: Create Email Case 
    * @Author:      Kejia hu
    * @Date:        30/01/2020
    */
    public static Case createEmailCase() {
        Account acc = createPersonAccounts(1, true)[0];
        Case c = new Case();
        c.RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_EMAIL_CASE;
        c.Origin = 'Email';
        c.AccountId = acc.Id;
        c.ContactId = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id].PersonContactId;
        c.ClaimNumber__c = generateRandomString(8);
        insert c;
        return c;
    }

    /**
    * @Description: Create Communication Configuration for a channel
    * @Author:      Kejia hu
    * @Date:        02/10/2019
    */
    public static Communication_Configuration__c createCommConfigForChannel(String channel) {
        Communication_Configuration__c config = new Communication_Configuration__c();
        config.Name = 'Test Config';
        config.Communication_Type__c = channel;
        insert config;
        return config;
    }

    /**
    * @Description: Create exposure roles
    * @Author:      Kejia hu
    * @Date:        02/10/2019
    */
    public static List<Case> createExposureRoles(List<Case> exposures) {
        List<Case> exposureRoles = new List<Case>();
        createContactTypeRole();
        for (Case exposure : exposures) {
            exposureRoles.add(createExposureRole(exposure));
        }
        insert exposureRoles;
        return exposureRoles;
    }

    /**
    * @Description: Create a exposure role
    * @Author:      Kejia hu
    * @Date:        02/10/2019
    */
    public static Case createExposureRole(Case exposure) {
        Case role = new Case();
        role.RecordTypeId = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_EXPO_ROLE;
        role.ClaimForRole__c = exposure.ClaimForExposure__c;
        role.ExposureForRole__c = exposure.Id;
        role.Origin = 'Web';
		role.Email_Address_for_Role__c = 'test@test.com';
        role.PartyAccount__c = exposure.AccountId;
        role.PartyContact__c = exposure.ContactId;
        role.RoleNature__c = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_CODE.get('driver').Id;
        return role;
    }

    /**
    * @Description: Create shadow roles
    * @Author:      Kejia hu
    * @Date:        24/09/2019
    */
    public static List<Case> createOtherExposures(Integer numToCreate) {
        Case claim = createClaim();
        List<ExposureType__c> types = createExposureTypes();
        List<Case> otherExposures = new List<Case>();
        String typeId = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_OTH_EXPOSURE;
        for(Integer i=0; i<numToCreate; i++){
            Case c = new Case();
            c.RecordTypeId = typeId;
            c.ClaimForExposure__c = claim.Id;
            c.Origin = 'Web';
            c.ExposureType__c = types[2].Id;
            c.AccountId = claim.AccountId;
            c.ContactId = claim.ContactId;
            otherExposures.add(c);
        }
        insert otherExposures;
        return otherExposures;
    }

    /**
    * @Description: Create shadow roles
    * @Author:      Kejia hu
    * @Date:        24/09/2019
    */
    public static List<Case> createShadowRoles(Integer numToCreate) {
        Case claim = createClaim();
        createContactTypeRole();
        List<Case> shadowRoles = new List<Case>();
        List<Case> otherExposures = createOtherExposures(1);
        String shadowRecordTypeId = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_SHADOW_ROLE;
        for(Integer i=0; i<numToCreate; i++){
            Case c = new Case();
            c.RecordTypeId = shadowRecordTypeId;
            c.ClaimForRole__c = claim.Id;
            c.Origin = 'Web';
            c.ExposureForRole__c = otherExposures[0].Id;
            c.PartyAccount__c = otherExposures[0].AccountId;
            c.PartyContact__c = otherExposures[0].ContactId;
            c.RoleNature__c = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_CODE.get('driver').Id;
            shadowRoles.add(c);
        }
        insert shadowRoles;
        return shadowRoles;
    }

    /**
    * @Description: Create a claim role
    * @Author:      Kejia hu
    * @Date:        30/09/2019
    */
    public static Case createClaimRole() {
        Case claim = createClaim();
        createContactTypeRole();
        Account acc = createPersonAccounts(1, true)[0];
        claim.AccountId = acc.Id;
        update claim;
        Case role = new Case();
        role.RecordTypeId = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM_ROLE;
        role.ClaimForRole__c = claim.Id;
        role.Origin = 'Web';
        role.PartyAccount__c = claim.AccountId;
        role.PartyContact__c = claim.ContactId;
        role.RoleNature__c = Omni_ClaimNotificationDAOHelper.ROLE_NATURE_BY_CODE.get('driver').Id;
        role.PartyAccount__c = acc.Id;
        insert role;
        return role;
    }

    /**
    * @Description: Create case 
    * @Author:      Kejia hu
    * @Date:        24/09/2019
    */
    public static Case createClaim() {
        Account acc = createPersonAccounts(1, true)[0];
        Case c = new Case();
        c.RecordTypeId = Omni_ClaimNotificationConstant.RECORD_TYPE_ID_CLAIM;
        c.LiabilityConfirmed__c = true;
        c.Origin = 'Web';
        c.AccountId = acc.Id;
        c.ContactId = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id].PersonContactId;
        c.ClaimNumber__c = generateRandomString(8);
        insert c;
        return c;
    }
    
    /**
    * @Description: Create an email template
    * @Author:      Kejia Hu
    * @Date:        04/11/2019
    */
    public static EmailTemplate createEmailTemplate() {
        EmailTemplate template = new EmailTemplate();
        template.isActive = true;
        template.Name = 'Tempalte For Test';
        template.DeveloperName = 'Template_For_Test';
        template.TemplateType = 'text';
        template.FolderId = UserInfo.getUserId();
        insert template;
        return template;
    }

    /**
    * @Description: Generate random string for given length. 
    * @Author:      Damian Kazior, PwC
    * @Date:         05/07/2019
    */
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr;  
    }

    /**
    * @Description: Generate random number for given length. 
    * @Author:      Damian Kazior, PwC
    * @Date:         05/07/2019
    */
    public static String generateRandomNumber(Integer len) {
        final String chars = '123456789';
        String randStr = '';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr;  
    }
	
	/**
    * @Description: Generate random string with spaces. 
    * @Author:      Damian Kazior, PwC
    * @Date:        10/09/2019
    */
    public static String generateRandomStringWithSpaces(Integer totalLength, Integer eachWordLength) {
        String randomStringWithSpaces = ''; 
         while (randomStringWithSpaces.length()+eachWordLength <= totalLength) {
            randomStringWithSpaces += generateRandomString(eachWordLength);
            if( (randomStringWithSpaces.length() + eachWordLength + 1) <= totalLength){
                randomStringWithSpaces += ' ';
            }
        }
        return randomStringWithSpaces;  
    }
	
        /**
    * @Description: Generate random string with spaces. 
    * @Author:      Damian Kazior, PwC
    * @Date:        10/09/2019
    */
    public static List<String> generateSMSTemplates(Integer numberOfTemplates) {
        String randomTemplate = '{!Case.PIG_EN__c } claim #{!Case.ClaimNumber__c }: Track your claim at 	{!Case.ClientCenterLink_EN__c}, Thank you for choosing {!Case.PIG_EN__c }. For your records your claim # is {!Case.ClaimNumber__c }.'; 
        List<String> templates = new List<String>();
        for(Integer k=0; k<numberOfTemplates; k++){
            templates.add(randomTemplate+generateRandomString(10));
        }
        return templates;
    }
    
    /**
    * @Description: Generate file from base64 payload 
    * @Author:      Damian Kazior, PwC
    * @Date:        23/08/2019
    */
    public static ContentVersion generateFile(String base64, String fileName, Boolean isInsert) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        if(isInsert){
            try {
                insert cv;
            } catch(DMLException e) {
                System.debug(e);
                return null;
            }
        }
        return cv;
    }

    /**
    * @Description: Generate cases
    * @Author:      Damian Kazior, PwC
    * @Date:        23/08/2019
    */
    public static List<Case> createCases(Integer numberOfCases, Boolean isInsert) {
        List<Case> cases = new List<Case>();
        for(Integer k=0; k<numberOfCases; k++){
            cases.add(new Case(
                PolicyIssuingGroup__c = 'BELAIR',
                ClaimNumber__c        = generateRandomString(8)
            ));
        }
        if(isInsert){
            insert cases;
        }
        return cases;
    }

    /**
    * @Description: Generate Application log
    * @Author:      Damian Kazior, PwC
    * @Date:        23/08/2019
    */
    public static List<Application_Log__c> createApplicationLogs(Integer numberOfLogs, Boolean isInsert) {
        List<Application_Log__c> aplogs = new List<Application_Log__c>();
        for(Integer k=0; k<numberOfLogs; k++){
            aplogs.add(new Application_Log__c());
        }
        if(isInsert){
            insert aplogs;
        }
        return aplogs;
    }

    /**
    * @Description: Generate LiveMessages
    * @Author:      Damian Kazior, PwC
    * @Date:        23/08/2019
    */
    public static List<LiveMessage__c> createLiveMessages(Integer numberOfLiveMessages, Boolean isInsert, Case cas) {
        List<LiveMessage__c> livemessages = new List<LiveMessage__c>();
        List<Application_Log__c> appLogs = TestDataFactory.createApplicationLogs(numberOfLiveMessages, true);
        for(Integer k=0; k<numberOfLiveMessages; k++){
            livemessages.add(new LiveMessage__c( 
                Case__c          = cas.Id,
                Message_Text__c  = new List<String>(generateSMSTemplates(1))[0],
                Phone_Number__c  = '123456879',
                Recipient_First_Name__c = generateRandomString(8),
                Recipient_Last_Name__c  = generateRandomString(8),
                Parent_Integration_Log__c = appLogs[k].Id
            ));
        }
        if(isInsert){
            insert livemessages;
        }
        return livemessages;
    }


    /**
    * @Description: Generate person accounts
    * @Author:      Damian Kazior, PwC
    * @Date:        23/08/2019
    */
    public static List<Account> createPersonAccounts(Integer numberOfAccounts, Boolean isInsert) {
        List<Account> accounts = new List<Account>();
        for(Integer k=0; k<numberOfAccounts; k++){
            accounts.add(new Account(
                RecordTypeId      = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
                LastName          = generateRandomString(10),
                Phone             = '123456879',
                PersonEmail       = 'TestEmail' + k + '@intact.net'
                ));
        }
        if(isInsert){
            insert accounts;
        }
        return accounts;
    }

    /**
    * @Description: Generate email templates. 
    * @Author:      Damian Kazior, PwC
    * @Date:        05/07/2019
    */ 
    public static List<EmailTemplate> generateEmailTemplates(Integer amount, String folderName, boolean isInsert) {
        List<EmailTemplate> emailTemaples = new List<EmailTemplate>();
        Folder folder = [SELECT Id FROM Folder WHERE Name =: folderName];
        for(Integer k=0; k<amount; k++){
            emailTemaples.add(new EmailTemplate(
                isActive        = true,
                Name            = generateRandomString(5),
                DeveloperName   = generateRandomString(5),
                TemplateType    = 'text',
                FolderId        = folder.Id
            ));
        }
        if(isInsert){
            insert emailTemaples;
        }
        return emailTemaples;
    }

    /**
    * @Description: Create a user with given profile
    * @Author:      Kejia Hu
    * @Date:        07/08/2019
    */
    public static User createrUserWithProfile(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName]; 
        User u = new User(
                        Alias = generateRandomString(5), Email=generateRandomString(5)+'@'+'intact.net', 
                        EmailEncodingKey='UTF-8', FirstName = 'Testing', LastName='User', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/New_York', 
                        UserName=generateRandomString(5)+'@'+generateRandomString(3)+'.com', UserId__c = 'testu@intact.net');
        insert u;
        return u;
    }

    /**
    * @Description: Create a case and a FeedItem
    * @Author:      Kejia Hu
    * @Date:        03/09/2019
    */
    public static FeedItem createFeedItem(){
        Case c = new Case();
        insert c; 
        FeedItem fi = new FeedItem(Body = 'Testing FeedItem', ParentId = c.Id);
        insert fi;
        return fi;
    }

    /**
    * @Description: Create ClaimExposureStatus
    * @Author:      Kejia Hu
    * @Date:        02/12/2019
    */
    public static List<ClaimExposureStatus__c> createExposureStatus() {
        List<ClaimExposureStatus__c> exposureStatus = new List<ClaimExposureStatus__c>();
        exposureStatus.add(new ClaimExposureStatus__c(
            Name = 'Open',
            TypeCode__c = 'OP',
            Description__c = 'Opened',
            L_EN_CA__c = 'Open',
            L_FR_CA__c = 'Ouvrir',
            Retired__c = '0'));
        exposureStatus.add(new ClaimExposureStatus__c(
            Name = 'Closed',
            TypeCode__c = 'CL',
            Description__c = 'Closed',
            L_EN_CA__c = 'Closed',
            L_FR_CA__c = 'Fermee',
            Retired__c = '0'));
        insert exposureStatus;
        return exposureStatus;
    }

    /**
    * @Description: Create Exposure Types
    * @Author:      Kejia Hu
    * @Date:        07/08/2019
    */
    public static List<ExposureType__c> createExposureTypes() {
        List<ExposureType__c> exposureTypes = new List<ExposureType__c>();
        exposureTypes.add(new ExposureType__c(
            Name = 'Benefits - Medical/Disability',
            TypeCode__c = 'benefits',
            Description__c = 'Medical or Disability Benefits',
            Retired__c = '0'));
        exposureTypes.add(new ExposureType__c(
            Name = 'Bodily Injury',
            TypeCode__c = 'BodilyInjury',
            Description__c = 'Bodily Injury',
            Retired__c = '0'));
        exposureTypes.add(new ExposureType__c(
            Name = 'AutoDamage',
            TypeCode__c = 'AutoDamage',
            Description__c = 'Auto Damage',
            Retired__c = '0'));
        insert exposureTypes;
        return exposureTypes;
    } 

    /**
    * @Description: Create Claim Notification Payload 
    * @Author:      Damian Kazior
    * @Date:        16/08/2019
    */
    public static Claim_Notification__e createCalimNotificationPayload(String transactionId) { 
        return new Claim_Notification__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create comment Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        06/02/2020
    */
    public static SObject createCommonClaimEventPayload(String transactionId, String claimNumber, String eventType) { 
        SObject oneObj;
        if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_1) {
            oneObj = new ClaimEvent_1__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_2) {
            oneObj = new ClaimEvent_2__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_3) {
            oneObj = new ClaimEvent_3__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_4) {
            oneObj = new ClaimEvent_4__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_5) {
            oneObj = new ClaimEvent_5__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_6) {
            oneObj = new ClaimEvent_6__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_7) {
            oneObj = new ClaimEvent_7__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_8) {
            oneObj = new ClaimEvent_8__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_9) {
            oneObj = new ClaimEvent_9__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_10) {
            oneObj = new ClaimEvent_10__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_11) {
            oneObj = new ClaimEvent_11__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_12) {
            oneObj = new ClaimEvent_12__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_13) {
            oneObj = new ClaimEvent_13__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_14) {
            oneObj = new ClaimEvent_14__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_15) {
            oneObj = new ClaimEvent_15__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_16) {
            oneObj = new ClaimEvent_16__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_17) {
            oneObj = new ClaimEvent_17__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_18) {
            oneObj = new ClaimEvent_18__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_19) {
            oneObj = new ClaimEvent_19__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_20) {
            oneObj = new ClaimEvent_20__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_BACKUP) {
            oneObj = new ClaimEvent_Backup__e();
        } else if (eventType == Omni_ClaimEventConstant.NAME_CLAIM_EVENT_DISPATCH) {
            oneObj = new ClaimEvent_Dispatcher__e();
        }
        
        oneObj.put('EventId__c','110000030');
        oneObj.put('TransactionID__c',transactionId);
        oneObj.put('EventName__c','Comm1-EN');
        oneObj.put('EventTime__c','2019-08-07T15:04:14-04:00');
        oneObj.put('EventTrackingNumber__c','GWCC-b4099c4c-caf1-4488-a33c-7929a998073f');
        oneObj.put('EventVersion__c','1.0');
        oneObj.put('ClaimId__c','110000031');
        oneObj.put('ClaimNumber__c',claimNumber);
        oneObj.put('DateOfLoss__c','2017-10-18T05:00:00-04:00');
        oneObj.put('TypeOfLoss__c','C2');
        oneObj.put('CauseOfLoss__c','fire');
        oneObj.put('InsuredProbableFaultPercentage__c',100);
        oneObj.put('IncidentDescription__c','Omni Payload Sampler');
        oneObj.put('LiabilityConfirmed__c',true);
        oneObj.put('PolicyNumber__c','AA1000829');
        oneObj.put('PolicyIssuingGroup__c','intact');
        oneObj.put('AssignedUserId__c','testu@intact.net');
        oneObj.put('ClaimDeductibleAmount__c',100);
        oneObj.put('ClaimDeductibleAmountCurrencyCode__c','CAN');
        oneObj.put('IncidentAddressLine__c','2020 Robert-Bourrasa');
        oneObj.put('IncidentPostalCode__c','J1J 0J0');
        oneObj.put('IncidentProvince__c','QC');
        oneObj.put('IncidentCity__c','Montreal');
        oneObj.put('IncidentCountry__c','CAN');
        oneObj.put('AppraiserPartyId__c','LC1:15005');
        oneObj.put('DamageRepairPartyId__c','LC1:15005');
        oneObj.put('RentalCompanyPartyId__c','LC1:15005');
        oneObj.put('LossVehicleId__c','veh1');
        oneObj.put('ProvinceOfIssuanceId__c','QC');
        oneObj.put('InjuredParty__c','LC1:15005');
        oneObj.put('BranchReferenceNumber__c','74');
        oneObj.put('ClaimNumberReplaced__c','9999999');
        oneObj.put('ClaimLOBGroup__c','P');
        oneObj.put('ClaimLOB__c','AUP');
        oneObj.put('UnderwritingCompanyNumber__c','1');
        oneObj.put('SellingChannelDistributorNumber__c','1104');
        oneObj.put('SellingChannelDistributionChannel__c','B');
        oneObj.put('ClaimContractEffectiveDate__c',Date.today());
        oneObj.put('ClaimContractExpiryDate__c',Date.today());
        oneObj.put('AppraisalTaskStatus__c','A');
        oneObj.put('AppraisalAppointmentDate__c',Date.today());
        oneObj.put('AppraisalAppointmentTime__c','06:59:00');
        oneObj.put('InitialGrossEstimateCurrency__c','CAN');
        oneObj.put('InitialGrossEstimateAmount__c',100.69);
        oneObj.put('RentalContractStatus__c','1');
        oneObj.put('RentalLimit__c','500');
        oneObj.put('InjuriesInvolved__c',true);
        oneObj.put('VirtualAppraisal__c',false);
        oneObj.put('ClientPIN__c','e1209dcb');
        oneObj.put('IncidentDateReported__c','2017-10-21T05:00:00-04:00');
        oneObj.put('TotalLoss__c','TOT');
        oneObj.put('AssignedVehicleId__c','veh1');
        oneObj.put('AssignedDriverPartyId__c','LC1:15005');
        oneObj.put('InformationSensitivity__c','EMP');
        oneObj.put('IncidentReportOnly__c',true);
        oneObj.put('ManuallyEnteredPolicy__c',true);
        oneObj.put('ConversionOrigin__c','axa');
        oneObj.put('ClaimStatus__c','draft');
        oneObj.put('ClaimClosedDate__c','2019-09-06T05:00:00-04:00');
        oneObj.put('AppraisalQualifier__c','REL');
        oneObj.put('AssignedLossDriverId__c','1');
        oneObj.put('InjuredParty__c','cyclist');
        oneObj.put('ClaimOriginEffectiveDate__c',Date.today().addDays(-30));
        oneObj.put('PrimaryAdjuster__c','hprice');
        oneObj.put('NonCasualtyWithoutPrejudice__c',false);
        oneObj.put('NonCasualtyCoverageInQuestion__c',false);
        oneObj.put('InsuredPartyId__c','LC1:15005');
        oneObj.put('RentalNumberOfAuthorizedDays__c',31);
        oneObj.put('AgentPartyId__c','');
        String claimExposures = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005","chevronStatus":"opened","sendAccidentBenefitsSurvey":false},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005","sendAccidentBenefitsSurvey":false},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null,"chevronStatus":"estimate","sendAccidentBenefitsSurvey":true}]';
        oneObj.put('ClaimExposures__c',claimExposures);
        String party = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]';
        oneObj.put('Party__c',party);
        String financialTransactions = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]';
        oneObj.put('FinancialTransactions__c',financialTransactions);
        String partyRoles = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"insured"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]';
        oneObj.put('PartyRoles__c',partyRoles);
        String addresses = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]';
        oneObj.put('Addresses__c',addresses);
        String emails = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]';
        oneObj.put('Emails__c',emails);
        String phones = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]';
        oneObj.put('Phones__c',phones);
        String vehicles = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]';
        oneObj.put('Vehicles__c',vehicles);
        String drivingLicenses = '[{"partyId ":"LC1:15003","drivingLicenseNumber":"","drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]';
        oneObj.put('DrivingLicenses__c',drivingLicenses);
        oneObj.put('ClaimExposuresCount__c',10);
        oneObj.put('FinancialTransactionsCount__c',10);
        oneObj.put('PartyCount__c',10);
        oneObj.put('PartyRolesCount__c',10);
        oneObj.put('LastOpenedNonBIExposureId__c','LC1:1401');
        oneObj.put('ClaimOpenedDate__c','2019-10-18T05:00:00-04:00');
        oneObj.put('ClaimReopenedDate__c','2019-12-18T05:00:00-04:00');
        oneObj.put('TotalIndemnity__c',100);
        oneObj.put('TotalRecovery__c',150);
        oneObj.put('QCLNClaimExpVehicleChapAPaid__c',50);
        oneObj.put('QCLNClaimExpVehicleChapBPaid__c',30);
        oneObj.put('NLPClaimSectionAPaidThirdParty__c',20);
        oneObj.put('InsuredIncDriverPartyId__c','LC1:15005');
        oneObj.put('InsuredIncCustodianPartyId__c','LC1:15005');
        oneObj.put('QCLNExposureId__c','LC1:1401');
        oneObj.put('NLPLExposureId__c','LC1:1401');
        oneObj.put('PoliceReportNumber__c','11111111');
        oneObj.put('VehicleLocationNote__c','Test');
        oneObj.put('SendAutoPropertySurvey__c',true);
        return oneObj;
    }

    /**
    * @Description: Create Claim Event Dispacher Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_Dispatcher__e createClaimEventDispatcherPayload(String transactionId, String claimNumber) { 
        return new ClaimEvent_Dispatcher__e(EventId__c = '1565204654811',
                                            TransactionId__c = transactionId,
                                            EventName__c = 'Comm1-EN', 
                                            EventTime__c = '2019-08-07T15:04:14-04:00',
                                            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
                                            EventVersion__c = '1.0',
                                            ClaimId__c = '110000030',
                                            ClaimNumber__c = claimNumber,
                                            AssignedUserId__c = 'testu@intact.net');
    }

    /**
    * @Description: Create Claim Event 1 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_1__e createClaimEvent1Payload(String transactionId) { 
        return new ClaimEvent_1__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000031',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 2 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_2__e createClaimEvent2Payload(String transactionId) { 
        return new ClaimEvent_2__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000032',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 3 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_3__e createClaimEvent3Payload(String transactionId) { 
        return new ClaimEvent_3__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000033',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 1 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_4__e createClaimEvent4Payload(String transactionId) { 
        return new ClaimEvent_4__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000034',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 5 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_5__e createClaimEvent5Payload(String transactionId) { 
        return new ClaimEvent_5__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000035',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 6 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_6__e createClaimEvent6Payload(String transactionId) { 
        return new ClaimEvent_6__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000036',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 7 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_7__e createClaimEvent7Payload(String transactionId) { 
        return new ClaimEvent_7__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000037',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 8 Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_8__e createClaimEvent8Payload(String transactionId) { 
        return new ClaimEvent_8__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000038',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 9 Payload 
    * @Author:      Kejia Hu
    * @Date:        09/12/2019
    */
    public static ClaimEvent_9__e createClaimEvent9Payload(String transactionId) { 
        return new ClaimEvent_9__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000039',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event 10 Payload 
    * @Author:      Kejia Hu
    * @Date:        09/12/2019
    */
    public static ClaimEvent_10__e createClaimEvent10Payload(String transactionId) { 
        return new ClaimEvent_10__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_11__e createClaimEvent11Payload(String transactionId) { 
        return new ClaimEvent_11__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_12__e createClaimEvent12Payload(String transactionId) { 
        return new ClaimEvent_12__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_13__e createClaimEvent13Payload(String transactionId) { 
        return new ClaimEvent_13__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_14__e createClaimEvent14Payload(String transactionId) { 
        return new ClaimEvent_14__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_15__e createClaimEvent15Payload(String transactionId) { 
        return new ClaimEvent_15__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_16__e createClaimEvent16Payload(String transactionId) { 
        return new ClaimEvent_16__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_17__e createClaimEvent17Payload(String transactionId) { 
        return new ClaimEvent_17__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_18__e createClaimEvent18Payload(String transactionId) { 
        return new ClaimEvent_18__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_19__e createClaimEvent19Payload(String transactionId) { 
        return new ClaimEvent_19__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Payload 
    * @Author:      Kejia Hu
    * @Date:        20/12/2019
    */
    public static ClaimEvent_20__e createClaimEvent20Payload(String transactionId) { 
        return new ClaimEvent_20__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000030',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Claim Event Backup Payload 
    * @Author:      Kejia Hu
    * @Date:        04/12/2019
    */
    public static ClaimEvent_Backup__e createClaimEventBackupPayload(String transactionId) { 
        return new ClaimEvent_Backup__e(
            EventId__c = '1565204654811',
            TransactionId__c = transactionId,
            EventName__c = 'Comm1-EN', 
            EventTime__c = '2019-08-07T15:04:14-04:00',
            EventTrackingNumber__c = 'GWCC-b4099c4c-caf1-4488-a33c-7929a998073f',
            EventVersion__c = '1.0',
            ClaimId__c = '110000030',
            ClaimNumber__c = '110000031',
            DateOfLoss__c = '2017-10-18T05:00:00-04:00',
            TypeOfLoss__c = 'C2',
            CauseOfLoss__c = 'fire',
            InsuredProbableFaultPercentage__c = 100,
            IncidentDescription__c = 'Omni Payload Sampler',
            LiabilityConfirmed__c = true,
            PolicyNumber__c = 'AA1000829',
            PolicyIssuingGroup__c = '',
            UnderWritingCompanyNumber__c = '010',
            AssignedUserId__c = 'testu@intact.net',
            ClaimDeductibleAmount__c = 100,
            ClaimDeductibleAmountCurrencyCode__c = 'CAN',
            IncidentAddressLine__c = '2020 Robert-Bourrasa',
            IncidentPostalCode__c = 'J1J 0J0',
            IncidentProvince__c = 'QC',
            IncidentCity__c = 'Montreal',
            IncidentCountry__c = 'CAN',
            AppraiserPartyId__c = 'LC1:15005',
            DamageRepairPartyId__c = 'LC1:15005',
            RentalCompanyPartyId__c = 'LC1:15005',
            LossVehicleId__c = 'veh1',
            ClaimContractEffectiveDate__c = Date.today(),
            ClaimContractExpiryDate__c = Date.today(),
            AppraisalAppointmentDate__c = Date.today(),
            AppraisalAppointmentTime__c = '06:59:00',
            IncidentDateReported__c = '2017-10-21T05:00:00-04:00',
            TotalLoss__c = 'TOT',
            InformationSensitivity__c = 'EMP',
            IncidentReportOnly__c = true,
            ManuallyEnteredPolicy__c = true,
            ConversionOrigin__c = 'axa',
            ClaimStatus__c = 'draft',
            ClaimClosedDate__c = '2019-09-06T05:00:00-04:00',
            AppraisalQualifier__c = 'REL',
            AssignedLossDriverId__c = '1',
            InjuredParty__c = 'cyclist',
            BranchReferenceNumber__c = '74',
            ClaimOriginEffectiveDate__c = Date.today().addDays(-30),
            PrimaryAdjuster__c = 'hprice',
            RentalNumberOfAuthorizedDays__c = 31,
            NonCasualtyWithoutPrejudice__c = false,
            NonCasualtyCoverageInQuestion__c = false,
            InsuredPartyId__c = 'LC1:15005',
            LastOpenedNonBIExposureId__c = '"LC1:1401',
            ClaimExposuresCount__c = 10,
            FinancialTransactionsCount__c = 10,
            PartyCount__c = 10,
            PartyRolesCount__c = 10,
            ClaimOpenedDate__c = '2019-10-18T05:00:00-04:00',
            ClaimReopenedDate__c = '2019-12-18T05:00:00-04:00',
            TotalIndemnity__c = 100,
            TotalRecovery__c = 150,
            QCLNClaimExpVehicleChapAPaid__c = 50,
            QCLNClaimExpVehicleChapBPaid__c = 30,
            NLPClaimSectionAPaidThirdParty__c = 20,
            InsuredIncDriverPartyId__c = 'LC1:15005',
            InsuredIncCustodianPartyId__c = 'LC1:15005',
            QCLNExposureId__c = 'LC1:1401',
            NLPLExposureId__c = 'LC1:1401',
            Addresses__c = '[{"partyId":"PROD:18","addressLine":"Apt 701 4122 Antibes Drive","postalCode":"L4J8X1","province":null,"city":"Vaughan","country":"CA","preferred":true},{"partyId":"PROD:19","addressLine":"Apt 11 123 Ford Yoork Blvd.","postalCode":"M2R3M8","province":null,"city":"Toronto","country":"CA","preferred":true}]',
            ClaimExposures__c = '[{"claimExposureId":"LC1:1401","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType":"AutoDamage","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"123","lossPartyRole":"CommunicationContact","claimExposureStatus":"OP","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1402","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":"300","assignedUserId":"testu@intact.net","exposureType": "BodilyInjury","coverageInQuestion":false,"withoutPrejudice":false,"claimExposureStatus":"CL","claimantPartyId":"LC1:15005"},{"claimExposureId":"LC1:1301","retired":false,"applicableDeductibleCurrencyCode":"USD","applicableDeductibleAmount":300,"assignedUserId":"testu@intact.net","exposureType": "benefits","coverageInQuestion":false,"withoutPrejudice":false,"riskUnitReferenceNumber":"456","claimExposureStatus":"OP","claimantPartyId":null}]',
            PartyRoles__c = '[{"partyRoleId":"LC1:5001","partyId":"LC1:15005","claimExposureId":null,"retired":false,"nature":"CommunicationContact"},{"partyRoleId":"LC1:2803","partyId":"LC1:15005","claimExposureId":"LC1:1301","retired":false,"nature":"driver"},{"partyRoleId":"LC1:2805","partyId":"LC1:15003","claimExposureId":"LC1:1401","retired":false,"nature":"maincontact"}]',
            Party__c = '[{"partyId":"LC1:15005","language":"E","retired":false,"partyType":"IN","personFirstName":"Joseph","personLastName":"Baxfield","personMiddleName":"Henry","personTitle":"mr","personBirthDate":"1934-06-22","personGender":"M","personSuffix":"jr","personName":"Joseph Baxfield Sr."},{"partyId":"LC1:15003","language":"E","retired":false,"partyType":"CY","organisationName":"Joseph Baxfield Corp."}]',
	        Phones__c = '[{"partyId":"LC1:15005","phoneNumber":"4167280934","extentionNumber":"1234","phoneType":"CP","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"FX","preferred": true},{"partyId":"LC1:15003","phoneNumber":"4166213499","extentionNumber":"123","phoneType":"BP","preferred": true}]',
	        Emails__c = '[{"partyId":"LC1:15005","type":"EMAIL","electronicAddress":"omni@gmail.com","preferred": true},{"partyId":"LC1:15003","type":"EMAIL","electronicAddress":"Test@gmail.com","preferred": true}]',		
	        Vehicles__c = '[{"vehicleId":"veh1","make":"NISSAN","model":"ALTIMA","modelYear":"2017"}]',
            DrivingLicenses__c = '[{"partyId ":"LC1:15003"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15004"  , "drivingLicenseNumber":"", "drivingLicensePlaceOfIssue":"" },{"partyId":"LC1:15005" ,"drivingLicenseNumber":"1228900", "drivingLicensePlaceOfIssue":"BC" }]',
            FinancialTransactions__c = '[{"claimExposureId":"LC1:1401"  ,"financialTransactionId":"PROD:1059" , "retired":false,"transactionType":"claimrecovery" , "status":"ISD", "instrumentEffectiveDate":"2019-05-07T18:25:43+01:00", "nameOnInstrument":"Emma Frost", "amount":"200","amountCurrencyCode":"CAN","amountBreakdownCategory":""},{"claimExposureId":"LC1:1402","financialTransactionId":"PROD:1058","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-01-07T18:25:43+01:00", "nameOnInstrument":"Silver Fox and Magneto", "amount":"100","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"},{"claimExposureId":"LC1:1301","financialTransactionId":"PROD:1060","retired":false,"transactionType":"payment","status":"ISD", "instrumentEffectiveDate":"2019-07-07T18:25:43+01:00","nameOnInstrument":"Kayla Silverfox","amount":"300","amountCurrencyCode":"CAN","amountBreakdownCategory":"Total"}]');
    }

    /**
    * @Description: Create Communication Configuration  
    * @Author:      Vikas Sharma
    * @Date:        23/09/2019
    */
    public static List<Communication_Configuration__c> createCommunicationConfiguration(integer noOfRecords,
                                                                                       boolean isInsert,
                                                                                       String communicationType,
                                                                                       String roleCode) {
                                                                                      
        	/*Communication_Configuration__c configurations = new Communication_Configuration__c (
                												Communication_Type__c = 'Email',
                												EventName__c = 'Comm1-EN',
                												Role__c = 'CommunicationContact'
                
            	);
              */                                                                             
                                                                                           
			List<Communication_Configuration__c> configsToReturn = new List<Communication_Configuration__c>();
                for (integer i = 0 ; i<=noOfRecords ; i++)
            {
                configsToReturn.add( new Communication_Configuration__c (  Communication_Type__c = communicationType,
                                                                            Active__c = true,
                    														EventName__c = 'Comm1-EN',
                															Role__c = roleCode,
                                                                            SMS_Subject_EN__c=  'TEST SUB ENG',
                                                                            SMS_Subject_FR__c = ' TEST SUB FR',
                                                                         	Eligibility_Criteria__c = 'Is_Language_English__c',
                                                                         	Exposure_Type__c  = 'AutoDamage',
                                                                         	Fax_Subject_EN__c= '',
                                                                         	Fax_Subject_FR__c='',
                                                                         	Print_Subject_EN__c = '',
                                                                         	Print_Subject_FR__c = ''	
                														));
            }
			if(isInsert)                                                                                          
        	insert configsToReturn;
                                                                                           
           return  configsToReturn; 
    }
    
    /**
    * @Description: Create Communication Configuration  
    * @Author:      Vikas Sharma
    * @Date:        23/09/2019
    */
    public static void createContactTypeRole() { 
        List<ContactRole__c> contactRole = new List<ContactRole__c>();
        contactRole.add(new ContactRole__c(TypeCode__c = 'CommunicationContact',
                                                            Description__c = 'CommunicationContact',
                                                            Retired__c = '0'));
        contactRole.add(new ContactRole__c(TypeCode__c = 'driver',
                												Description__c = 'driver',
                												Retired__c = '0'));
        contactRole.add(new ContactRole__c(TypeCode__c = 'maincontact',
                												Description__c = 'maincontact',
                												Retired__c = '0'));
        contactRole.add(new ContactRole__c(TypeCode__c = 'insured',
                												Description__c = 'insured',
                												Retired__c = '0'));
        insert contactRole;
           
    }

    /**
    * @Description: Create PolicyIssuingGroup__c
    * @Author:      Kejia Hu
    * @Date:        27/02/2020
    */
    public static void createPolicyIssuingGroup() { 
        List<PolicyIssuingGroup__c> piGroup = new List<PolicyIssuingGroup__c>();
        piGroup.add(new PolicyIssuingGroup__c(TypeCode__c = 'belair',
                                                            Description__c = 'belair',
                                                            Retired__c = '0'));
        piGroup.add(new PolicyIssuingGroup__c(TypeCode__c = 'intact',
                												Description__c = 'intact',
                												Retired__c = '0'));
        piGroup.add(new PolicyIssuingGroup__c(TypeCode__c = 'jevco',
                												Description__c = 'jevco',
                												Retired__c = '0'));
        piGroup.add(new PolicyIssuingGroup__c(TypeCode__c = 'nordic',
                												Description__c = 'nordic',
                												Retired__c = '0'));
        insert piGroup;
           
    }
    
   /**
    * @Description: Create SMS Templates based on Configurations  
    * 				First Creates Language configurations and then SMS templates	
    * @Author:      Vikas Sharma
    * @Date:        23/09/2019
    */
    public static void createSMSTemplate(List<Communication_Configuration__c> commConfigs, String templateName	) { 
        
           SMS_Template__c smsTemplate = new SMS_Template__c(
               													Name = 'Current State (Property) - Vendor Notification-EN',
               													Message__c = '{!Case.PIG_EN__c } claim #{!Case.ClaimNumber__c }. Vendor: {!Case. Vendor_Name_for_Role__c} {!Case.Vendor_WorkPhone_for_Role__c}, {!Case.Vendor_Address_for_Role__c}, {!Case.Vendor_City_for_Role__c}, {!Case.Vendor_Postal_Code_for_Role__c}.',
																Type__c = 'Broker'
           );
        
        insert smsTemplate;
        	
        
       	List<Language_Config__c> languageConfig = new List<Language_Config__c>();
        for(Communication_Configuration__c commConfig : commConfigs )
        {
       			languageConfig.add(new Language_Config__c (Communication_Configuration__c = commConfig.Id,
                                                         Language_Qualifier__c = 'Is_Language_English__c',
                                                           Email_Template__c = templateName,
                                                            Active__c = true,
															SMS_Template__c = smsTemplate.Id));     
        }
        
        insert languageConfig;
    }

    /**
    * @Description: Generate EmailMessage records
    * @Author:      Damian Kazior, PwC
    * @Date:        23/01/2020
    */
    public static List<EmailMessage> createEmailMessages(Integer numberOfEmailMessages, Case relatedCase, Boolean isIncoming) {
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for(Integer k=0; k<numberOfEmailMessages; k++){
            emailMessages.add(
                new EmailMessage(
                    fromAddress = generateRandomString(5)+'@'+'intact.net', 
                    Incoming    = isIncoming, 
                    toAddress   = generateRandomString(5)+'@'+'intact.net', 
                    subject     = 'Test email', 
                    textBody    = generateRandomString(5), 
                    parentId    = relatedCase.Id
                )
            );
        }
        return emailMessages;
    }

    /**
    * @Description: Generate tasks
    * @Author:      Damian Kazior, PwC
    * @Date:        23/01/2020
    */
    public static List<Task> createTasks(Integer numberOfTasks, Case relatedCase, Boolean isInsert) {
        List<Task> tasks = new List<Task>();
        for(Integer k=0; k<numberOfTasks; k++){
            tasks.add(
                 new Task(description   = generateRandomString(5),
                    priority            = 'high',
                    status              = 'new',
                    subject             = generateRandomString(5),
                    IsReminderSet       = true,
                    reminderDateTime    = DateTime.now(),
                    ActivityDate        = Date.today(),
                    OwnerId             = relatedCase.ownerId,
                    whatId              = relatedCase.Id    
                )
            );
        }
        return tasks;
    }

    /**
    * @Description: Generate pulse survey results
    * @Author:      Damian Kazior, PwC 
    * @Date:        23/01/2020 
    */
    public static List<Pulse_Survey_Result__c> createPulseSurveyResult(Integer numberOfSurveys, Case relatedCase, String score, Boolean isInsert) {
        List<Pulse_Survey_Result__c> surveyResults = new List<Pulse_Survey_Result__c>();
        for(Integer k=0; k<numberOfSurveys; k++){
            surveyResults.add(
                 new Pulse_Survey_Result__c(
                    Case__c         = relatedCase.Id,
                    Comments__c     = generateRandomString(20),          
                    Score__c        = score
                )
            );
        }
        if(isInsert){
            insert surveyResults;
        }
        return surveyResults;
    }
    
	/**
    * @Description: Generate ECM Endpoints Config
    * @Author:      Luis Merinero, PwC 
    * @Date:        5/03/2020 
    */
    public static void createECMConfiguration() {
		Ecm_Ingest__c ecmIngest = new Ecm_Ingest__c();
        ecmIngest.Endpoint__c = 'https://test.test.com';
        ecmIngest.Name = 'Test Ingest';
        ecmIngest.Oauth_ClientId__c = 'ABC123';
        ecmIngest.Oauth_Scope__c = 'c360doc/write';
        ecmIngest.Oauth_Secret__c = '123ABC';
        ecmIngest.Oauth_Token_Url__c = 'https://test.test.com/oauth20/token';
        insert ecmIngest;
        
		Ecm_Composition__c ecmComposition = new Ecm_Composition__c();
        ecmComposition.Endpoint__c = 'https://test.test.com';
        ecmComposition.Name = 'Test Composition';
        ecmComposition.Oauth_ClientId__c = 'ABC123';
        ecmComposition.Oauth_Scope__c = 'c360doc/write';
        ecmComposition.Oauth_Secret__c = '123ABC';
        ecmComposition.Oauth_Token_Url__c = 'https://test.test.com/oauth20/token';
        insert ecmComposition;
    }
    
	/**
    * @Description: Generates Mock response
    * @Author:      Luis Merinero, PwC 
    * @Date:        5/03/2020 
    */
   	public static ServiceMock createServiceMock(Integer code, String body) {
		ServiceMock mock = new ServiceMock();
        mock.responseBodyAsString = body;
        mock.code = code;
        mock.status = 'SUCCESS';
        return mock;
    }
    
    public class ServiceMock implements HttpCalloutMock {
        String responseBodyAsString {get; set;}
        String status {get; set;}
        boolean success {get; set;}
        Integer code {get; set;}
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseBodyAsString);
            response.setStatusCode(code);
            response.setStatus(status);
            return response;
        }
    }
    
    public static File_Metadata__c SaveFileMetadata(Case claim){
		File_Metadata__c fMeta = new File_Metadata__c();
        fMeta.Claim_Number__c = '12345';
		fMeta.Policy_Number__c = '12345';
		fMeta.Claimant_Name__c = 'John Smith';
		fMeta.Case__c = claim.id;
		fMeta.Insure_Name__c = 'John Smith';
        fMeta.Date_of_Loss__c = System.now();
		fMeta.Claim_Sub_Type__c = 'GENERAL';
		fMeta.Claim_Reported_Date__c = System.now();
		fMeta.Date_received__c = System.now();
		fMeta.Document_Status__c = 'ASG';
        fMeta.Line_of_Business__c = 'Claims';
		fMeta.Document_Title__c = 'Test File';
		fMeta.Region_Code__c = 'CENT';
        fMeta.File_Mime_Type__c = 'JPG';
        fMeta.File_Size__c = 100000;
		fMeta.Exposure_Number__c = '12345';
		fMeta.MessageId__c = '12345';
		fMeta.Reference_Id__c = '0684c0000000jZxAAI';
		fMeta.Unique_Id__c = '12345-0684c0000000jZxAAI';
        insert fMeta;
        return fMeta;
	}

    public static MessagingSession createMessagingSessionForEndUser(MessagingEndUser msgUser, Boolean isInsert){
        MessagingChannel msgChannel = Omni_MessagingChannelSelector.getMessagingChannelByName(Omni_SMSConstant.MESSAGING_CHANNEL_NAME);

        MessagingSession msgSession = new MessagingSession(
            AgentType = 'Agent',
            MessagingEndUserId = msgUser.Id,
            MessagingChannelId = msgChannel.Id,
            Status             = 'New'
        );
        if(isInsert){
            insert msgSession;
        }
        return msgSession;
    }

    public static void createConversationEntriesForMessagingSession(MessagingSession msgSession, Integer amount){
        List<ConversationEntry> convEntries = new List<ConversationEntry>();
        for(Integer k=1; k<amount+1; k++){
            convEntries.add(new ConversationEntry(
                ActorType = 'Agent', 
                ConversationId=msgSession.Id, 
                EntryType = 'Text', 
                Message = generateRandomString(5), 
                Seq=k, 
                EntryTime=DateTime.now()
            ));
        }
        insert convEntries;
    }


    public static MessagingEndUser createMessagingEndUser(Boolean isInsert){
        MessagingChannel msgChannel = Omni_MessagingChannelSelector.getMessagingChannelByName(Omni_SMSConstant.MESSAGING_CHANNEL_NAME);

        String phoneNumber = TestDataFactory.generateRandomNumber(8);
        MessagingEndUser msgUser = new MessagingEndUser( 
            MessageType     = Omni_SMSConstant.MESSAGING_USER_TYPE,
            MessagingChannelId   = msgChannel.Id,
            MessagingPlatformKey = phoneNumber,
            Name                 = phoneNumber,
            IsOptedOut           = false
        );
        if(isInsert){
            insert msgUser;
        }
        return msgUser;       
    }
}