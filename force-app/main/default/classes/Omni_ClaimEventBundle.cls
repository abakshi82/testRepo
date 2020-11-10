/**
* @description class contains records that related to one Claim event
* @author      Kejia Hu
* @date        01/08/2019                    
*/
public with sharing class Omni_ClaimEventBundle {

    public String eventId;
    public User ajuster;
    public Application_Log__c integrationLog;
    public Map<String, Case> claimByClaimId;
    public Map<String, Case> exposureByExposureId;
    public Map<String, Case> roleByPartyRoleId;
    public Map<String,Account> accountByPartyId;
    public Map<String, Contact> contactByPartyId;
    public Map<String, Vehicle__c> vehicleById;
    public Map<String, Transaction__c> transactionById;
    public Omni_ClaimEventEntity eventEntity;
    public List<Messaging.SingleEmailMessage> emailsToSend;
    public Map<Case, Set<Communication_Configuration__c>> rolesByConfigurations; // To get the roles and Configurations to check the elig criteria
    public List<Communication_Configuration__c> configurations;
    public Map<Case, String> claimsToSendEmails; // Map to hold claims with template name to send emails.
    public Map<Case, List<Communication_Configuration__c>> finalListToSendEmail = new Map<Case, List<Communication_Configuration__c>>(); // Final list to send emails. 
    public Map<Case, List<Communication_Configuration__c>> rolesAfterProcessingLanguage = new Map<Case, List<Communication_Configuration__c>>(); // Final list to send emails.
    public List<Case> existingShadowRoles;

    public Omni_ClaimEventBundle(Omni_ClaimEventEntity eventEntity) {
        this.eventId = eventEntity.eventId;
        this.eventEntity = eventEntity;
        this.accountByPartyId = eventEntity.generateAccountByPartyId();
    }

    /**
    * @description get all exposure Ids
    * @author      Kejia Hu
    * @date        14/02/2020                     
    */
    public List<String> getAllExposureIdsFromEventEntity(){
        return this.eventEntity.getAllExposureIds();
    }

    /**
    * @description Set Exposure lookups on claim
    * @author      Kejia Hu
    * @date        06/12/2019                     
    */
    public void setExposureLookupsForClaim() {
        if (!String.isBlank(eventEntity.QCLNExposureId) && this.exposureByExposureId.containsKey(eventEntity.QCLNExposureId)) {
                claimByClaimId.get(eventEntity.claimId).QCLNExposure__c = exposureByExposureId.get(eventEntity.QCLNExposureId).Id;
        }
        if (!String.isBlank(eventEntity.NLPLExposureId) && this.exposureByExposureId.containsKey(eventEntity.NLPLExposureId)) {
                claimByClaimId.get(eventEntity.claimId).NLPLExposure__c = exposureByExposureId.get(eventEntity.NLPLExposureId).Id;
        }
    }
    
    /**
    * @description OM-925 claimByClaimId setter
    * @author      Kejia Hu
    * @date        11/08/2019                     
    */
    public void setClaimByClaimId() {
        this.claimByClaimId = eventEntity.generateClaimByClaimId(this.accountByPartyId, this.contactByPartyId, this.vehicleById);
    }
    
    /**
    * @description OM-925 vehicles setter
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public void setVehicleById() {
        this.vehicleById = this.eventEntity.generateVehicleById();
    }
    
    /**
    * @description OM-925 exposureByExposureId setter
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public void setExposureByExposureId() {
        this.exposureByExposureId = this.eventEntity.generateExposureByExposureId(this.claimByClaimId.get(eventEntity.claimId), this.accountByPartyId);
    }
    
    /**
    * @description OM-925 transactionById setter
    * @author      Kejia Hu
    * @date        06/09/2019                     
    */
    public void setTransactionById() {
        this.transactionById = this.eventEntity.generateTransactionByTransId(this.exposureByExposureId);
    }
    
    /**
    * @description OM-925 populate last financial transaction on exposures
    * @author      Kejia Hu
    * @date        06/09/2019                    
    */
    public void populateExposuresLastTransaction() {
        this.exposureByExposureId = this.eventEntity.populateExposureLastTransaction(
            this.exposureByExposureId, this.transactionById);
    }
    
    /**
    * @description OM-925 roleByPartyRoleId setter
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public void setRoleByPartyRoleId(Map<String, Contact> contactByAccountId) {
        this.roleByPartyRoleId = this.eventEntity.generateRoleByPartyRoleId(
            this.accountByPartyId,
            this.claimByClaimId.get(eventEntity.claimId), 
            this.exposureByExposureId,
            this.contactByPartyId,
            contactByAccountId,
            this.vehicleById,
            this.transactionById);
    }
    
    /**
    * @description OM-925 to generate the communication configuration
    * @author      Vikas Sharma
    * @date        08/21/2019                     	
    */
    
    public void generateConfigurations(List<Communication_Configuration__c> configs,
                                       Map<String, ContactRole__c> idWithContactRolesMap,
                                       Map<String, ExposureType__c> idWithExposureTypeMap, 
                                       Map<String, String> sfIdsWithCC, Map<String, ExposureType__c> typeCodeToExposures)
    {
        this.configurations = configs;
        generateRolesAndConfigurations(idWithContactRolesMap,idWithExposureTypeMap,sfIdsWithCC, typeCodeToExposures);
        
    }
    
    /**
    * @description OM-925 to generate the roles and corresponding Communication Configurations associated
    * @author      Vikas Sharma
    * @date        08/21/2019                     
    */
    public void generateRolesAndConfigurations(Map<String, ContactRole__c> idWithContactRolesMap,
                                               Map<String, ExposureType__c> idWithExposureTypeMap,
                                               Map<String, String> sfIdsWithCC,
                                               Map<String, ExposureType__c> typeCodeToExposures)
    {
        
        boolean createShadowRole = false;
        rolesByConfigurations = new Map<Case, Set<Communication_Configuration__c>>();
        
        Map<Case, Set<Communication_Configuration__c>> shadowRolesToCreate = new Map<Case, Set<Communication_Configuration__c>>();
        // Another copy of ShadowRoles
        Map<String, Set<Communication_Configuration__c>> shadowRolesWithRoleIdExpId = new Map<String, Set<Communication_Configuration__c>>();
        
        Map<String, Transaction__c> transactionBySFId = new Map<String, Transaction__c>();
        if(null != transactionById) {
            transactionBySFId.putAll(transactionById.values());
        }
        Map<String, Set<String>> processedExposureTypes = new Map<String, Set<String>>();
        
        for (Communication_Configuration__c config : configurations)
        {
            for (String partyRoleId : roleByPartyRoleId.keySet())
            { 
                Case cs =  roleByPartyRoleId.get(partyRoleId);
                
                if (config.Role__c != null){
                    List<String> lstRoles = config.Role__c.split(';');
                    List<String> lstExposureTypes = new List<String>();
                    if (config.Exposure_Type__c != null){
                        lstExposureTypes = config.Exposure_Type__c.split(';');
                    }
                    for (String role : lstRoles){
                        
                        if (role == idWithContactRolesMap.get(cs.RoleNature__c).TypeCode__c){
                            
                            //processedExposureTypes = new Map<String, Set<String>>();
                            
                            if (lstExposureTypes.size() > 0){
                                
                                //exposureByExposureId DOESNT CONTAIN CURRENT EXPOSURE
                                
                                for (String expType : lstExposureTypes)
                                {
                                    for (String exposureId : exposureByExposureId.keySet())
                                    {
                                        if (typeCodeToExposures != null && 
                                            typeCodeToExposures.get(expType) != null &&
                                            exposureByExposureId.get(exposureId).ExposureType__c == typeCodeToExposures.get(expType).Id
                                           )
                                        {
                                            if (typeCodeToExposures.get(expType).TypeCode__c == expType)
                                            {
                                                // Adding current role to the configurations
                                                
                                                if (config.Explicit__c){
                                                    
                                                    if(cs.ExposureForRole__c == null)
                                                    {
                                                        //ignore
                                                    }
                                                    else
                                                    {
                                                        if (rolesByConfigurations.get(cs) == null){
                                                            rolesByConfigurations.put(cs,new Set<Communication_Configuration__c>{config});
                                                        }
                                                        else
                                                        {
                                                            rolesByConfigurations.get(cs).add(config);
                                                        }
                                                        
                                                    }
                                                }
                                                else{
                                                    if ( cs.ExposureForRole__c == null)
                                                    {
                                                        boolean toProcessFurther = true;
                                                if (processedExposureTypes.get(cs.Id+exposureId) != null){
                                                    
                                                    if ( processedExposureTypes.get(cs.Id+exposureId) != null &&  processedExposureTypes.get(cs.Id+exposureId).contains(expType)){
                                                        toProcessFurther = false;
                                                        
                                                    }
                                                }
                                                        if (toProcessFurther){	
                                                            if(processedExposureTypes.get(cs.Id+exposureId) == null){
                                                                processedExposureTypes.put(cs.Id+exposureId,new Set<String>{expType});
                                                            }
                                                            else{
                                                                processedExposureTypes.get(cs.Id+exposureId).add(expType);
                                                            }
                                                            // To generate the Random Role Key
                                                            Case cloneCase = cs.clone();
                                                            //String tempRecordId = cs.RoleId__c + Utility.generateRandomChar(8) + DateTime.now().getTime();
                                                            //cloneCase.RoleId__c = tempRecordId;
                                                            cloneCase.ExposureForRole__c = exposureByExposureId.get(exposureId).Id;
                                                            cloneCase.OriginRoleForShadow__c = cs.Id;
                                                            cloneCase.Id = null;
                                                            cloneCase.RecordTypeId = Omni_ClaimEventConstant.RECORD_TYPE_ID_SHADOW_ROLE;
                                                            Case exposureForRole = exposureByExposureId.get(exposureId);
                                                            cloneCase.OwnerId = exposureForRole.OwnerId;
                                                            cloneCase.Exposure_Number_Order__c = exposureForRole.Exposure_Number_Order__c;
                                                            cloneCase.ExposureIdForRole__c = exposureForRole.ExposureId__c;
                                                            cloneCase.ExposureName_EN_for_Role__c = idWithExposureTypeMap.get(exposureForRole.ExposureType__c).L_EN_CA__c;
                                                            cloneCase.ExposureName_FR_for_Role__c = idWithExposureTypeMap.get(exposureForRole.ExposureType__c).L_FR_CA__c;
                                                            cloneCase.Exposure_Type__c = idWithExposureTypeMap.get(exposureForRole.ExposureType__c).L_EN_CA__c + ' ' + idWithExposureTypeMap.get(exposureForRole.ExposureType__c).L_FR_CA__c;
                                                            cloneCase.Exposure_Type_for_Role__c = idWithExposureTypeMap.get(exposureForRole.ExposureType__c).TypeCode__c;
                                                            if (null != exposureForRole.LastPaymentTransaction__c) {
                                                                Transaction__c lastPaymentTransaction  = transactionBySFId.get(exposureForRole.LastPaymentTransaction__c);
                                                                cloneCase.Cheque_Issued_Amount_for_Role__c = lastPaymentTransaction.AmountOnInstrument__c;
                                                                cloneCase.Cheque_Issued_Amount_for_Role_Str__c = Utility.getStringValWithScale(lastPaymentTransaction.AmountOnInstrument__c, 2);
                                                                cloneCase.Cheque_Issued_Date_EN__c = (null!=lastPaymentTransaction.EffectiveDate__c) 
                                                                    ? lastPaymentTransaction.EffectiveDate__c.format('MM/dd/yyyy')
                                                                    : null;
                                                                cloneCase.Cheque_Issued_Date_FR__c = (null!=lastPaymentTransaction.EffectiveDate__c)
                                                                    ? lastPaymentTransaction.EffectiveDate__c.format('dd/MM/yyyy')
                                                                    : null;
                                                                cloneCase.Cheque_Payee_for_Role__c = lastPaymentTransaction.NameOnInstrument__c;
                                                            }
                                                            if(shadowRolesToCreate.get(cloneCase) == null){
                                                                shadowRolesToCreate.put(cloneCase,new Set<Communication_Configuration__c>{config});
                                                                shadowRolesWithRoleIdExpId.put(cloneCase.RoleId__c+cloneCase.ExposureIdForRole__c, new Set<Communication_Configuration__c>{config});
                                                            }
                                                            else{
                                                                shadowRolesToCreate.get(cloneCase).add(config);
                                                                shadowRolesWithRoleIdExpId.get(cloneCase.RoleId__c+cloneCase.ExposureIdForRole__c).add(config);
                                                            }
                                                        }
                                                        else{
                                                            if (shadowRolesWithRoleIdExpId.get(cs.RoleId__c+exposureId) == null){
                                                                shadowRolesWithRoleIdExpId.put(cs.RoleId__c+exposureId,new Set<Communication_Configuration__c>{config});
                                                            }
                                                            else
                                                            {
                                                                shadowRolesWithRoleIdExpId.get(cs.RoleId__c+exposureId).add(config);
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    else
                                                    {
                                                        if (rolesByConfigurations.get(cs) == null){
                                                            rolesByConfigurations.put(cs,new Set<Communication_Configuration__c>{config});
                                                        }
                                                        else
                                                        {
                                                            rolesByConfigurations.get(cs).add(config);
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            else
                                            {
                                                
                                            }
                                        }	
                                        
                                    }
                                }
                                
                            }
                            // Else if no exposure added
                            else
                            {
                                if (rolesByConfigurations.get(cs) == null){
                                    rolesByConfigurations.put(cs,new Set<Communication_Configuration__c>{config});
                                }
                                else
                                {
                                    rolesByConfigurations.get(cs).add(config);
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
        if (shadowRolesToCreate.size() > 0){
            addShadowRoles(shadowRolesToCreate, shadowRolesWithRoleIdExpId);
        }
    }
    
    public void addShadowRoles(Map<Case, Set<Communication_Configuration__c>> shadowRolesToCreate, Map<String, 
                               Set<Communication_Configuration__c>> shadowRolesWithRoleIdExpId)
    {
        List<Case> toInsert = new List<Case>();
        Map<Communication_Configuration__c, Set<String>> trackOfCommWithOriginalRole = new Map<Communication_Configuration__c, Set<String>>();
        Map<String, String> mapRoleIds = new Map<String, String>();
        for (Case cs : shadowRolesToCreate.keySet())
        {
            //If shadow role exists, transform the composite shadow role Id back to role Id
            String existingShadowRoleId = getRoleIdForExistingShadowRole(cs);
            Boolean isExistingShadowRole = !String.isBlank(existingShadowRoleId);
            if (isExistingShadowRole) {
                cs.RoleId__c = existingShadowRoleId.substring(0, existingShadowRoleId.length()-21);
            }

            for(Communication_Configuration__c cConfig : shadowRolesWithRoleIdExpId.get(cs.RoleId__c+cs.ExposureIdForRole__c))
            {
                if (trackOfCommWithOriginalRole.get(cConfig) == null)
                {
                    trackOfCommWithOriginalRole.put(cConfig,  new Set<String>{cs.RoleId__c});
                }
                else{
                    trackOfCommWithOriginalRole.get(cConfig).add(cs.RoleId__c);
                }
            }
            
            
            for (Communication_Configuration__c crConfig:shadowRolesToCreate.get(cs))
            {
                
                
                if (trackOfCommWithOriginalRole.get(crConfig) == null)
                {
                    trackOfCommWithOriginalRole.put(crConfig,  new Set<String>{cs.RoleId__c});
                }
                else{
                    trackOfCommWithOriginalRole.get(crConfig).add(cs.RoleId__c);
                }
            }

            String tempRecordId;
            if (isExistingShadowRole) {
                tempRecordId = existingShadowRoleId;
            } else {
                tempRecordId = cs.RoleId__c + Utility.generateRandomChar(8) + DateTime.now().getTime();
            }
            mapRoleIds.put(tempRecordId,cs.RoleId__c);
            
            cs.RoleId__c = tempRecordId;

            toInsert.add(cs);
        }
        upsert toInsert RoleId__c;
        
        for(Case csWithId : toInsert)
        {
            for (Communication_Configuration__c originalConfig : trackOfCommWithOriginalRole.keySet())
            {
                for (String originalRole : trackOfCommWithOriginalRole.get(originalConfig))
                {
                    if (originalRole == mapRoleIds.get(csWithId.RoleId__c))    
                    {
                        if (rolesByConfigurations.get(csWithId) == null){
                            rolesByConfigurations.put(csWithId,new Set<Communication_Configuration__c>{originalConfig});
                            
                        }
                        else
                        {
                            rolesByConfigurations.get(csWithId).add(originalConfig);
                        }
                    }
                }
            }
            
            
        }
        
        
    }

    /**
    * @description get existing role
    * @author      Kejia Hu
    * @date        04/05/2020                     
    */
    public String getRoleIdForExistingShadowRole(Case cloneRole) {
        String roleId;
        if (existingShadowRoles != null && !existingShadowRoles.isEmpty()) {
            for (Case existingShadowRole : existingShadowRoles) {
                if (isEquivalent(cloneRole, existingShadowRole)) {
                    roleId = existingShadowRole.RoleId__c;
                }
            }
        }
        return roleId;
    }

    /**
    * @description get existing role
    * @author      Kejia Hu
    * @date        04/05/2020                     
    */
    public Boolean isEquivalent(Case cloneRole, Case existingRole) {
        return (cloneRole.ExposureForRole__c == existingRole.ExposureForRole__c
                && cloneRole.OriginRoleForShadow__c == existingRole.OriginRoleForShadow__c
                && cloneRole.RoleNature__c == existingRole.RoleNature__c);
    }
    
    /**
    * @description OM-925 contactByPartyId setter
    * @author      Kejia Hu
    * @date        08/08/2019                     
    */
    public void setContactByPartyId() {
        this.contactByPartyId = this.eventEntity.generateContactByPartyId(this.accountByPartyId);
    }
}