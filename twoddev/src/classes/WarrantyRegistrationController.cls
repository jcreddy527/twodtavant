/**********************************************************************
 Name:  WarrantyRegistrationController 
 Copyright � 2016  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:  To create Warranty Registration and Warranty Coverages from Inventory
                                                      
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Mounika        14/06/2016      INITIAL DEVELOPMENT            
***********************************************************************/

public without sharing class WarrantyRegistrationController {
    public static Warranty_Registration__c newWarrantyRegistration;
    public static InventoryManager inventoryManagerObj;
    public static list<Response> lstResponse ;

    
    public WarrantyRegistrationController(){
        Id WRId = ApexPages.currentPage().getParameters().get('WRId');
        system.debug('----WRId----'+WRId);
    }
    /*******************************************************************
    PURPOSE:   To get Custom Setting value which is used for Enable/Disable Multiple Inventory Registration.                                                   
    PARAMETERS: 
    RETURNS:Boolean
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    @AuraEnabled
    public static Boolean isMultipleWarrantyRegistration()
    {
        WOD__c tempCustomSetting = WOD__c.getValues('Multiple Warranty Registration');
        if(tempCustomSetting != null)
            return tempCustomSetting.isTriggered__c;
        else
            return false;
    }
    
    /*******************************************************************
    PURPOSE:   To get Custom Setting value which is used for Enable/Disable Multiple Inventory Registration.                                                   
    PARAMETERS: 
    RETURNS:Boolean
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    @AuraEnabled
    public static list<String> usageTypeRetrun()
    {
        //
        List<String> options = new List<String>();
       Schema.DescribeFieldResult fieldResult = Warranty_Registration__c.Usage_Type__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple){
          options.add(f.getValue());
       }       
        return options;
    }
    
    
    /*******************************************************************
    PURPOSE:   To get all Policy Definitions                                                   
    PARAMETERS: boolean flag "isWRCreated" , Inventory__c type of object "CurrentInventory" , String Variable "CurrentInventoryDetails" 
    RETURNS:List of PolicyDefinitionWrapper
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    @AuraEnabled
    public static list<Response> createWarrantyRegistration(boolean isWRCreated,Inventory__c CurrentInventory,
                                                            string CurrentInventoryDetails, String InstDate, 
                                                            Id WRId, String WRUsageType, Id InventoryCustomer)
    {
        lstResponse = new list<Response>();
        system.debug('InstDate-----------'+InstDate);
        system.debug('WRID-----------'+WRId);
                
        List<String> lstDate = InstDate.split('/');
        Date InstallDate = date.newinstance(Integer.valueOf(lstDate[2]),Integer.valueOf(lstDate[1]),Integer.valueOf(lstDate[0]));
        CurrentInventory.Customer__c = InventoryCustomer;
        CurrentInventory.Install_Date__c = InstallDate;
        system.debug('----------InstallDate---------'+InstallDate);
        system.debug('----------CurrentInventory---------'+CurrentInventory);        
         //Creating Warranty Registration Record
        //if(isWRCreated == false) 
         if(WRId != null){
            system.debug('===========WRId======='+WRId);
            newWarrantyRegistration  = [select Account__c,Customer__c,Group__c,Inventory__c,Maximum_Unit__c,Registration_Comments__c,Registration_Date__c,Status__c,Usage_Type__c,Warranty_End_Date__c,Warranty_Product__c,Warranty_Start_Date__c,Id FROM Warranty_Registration__c Where Id= :WRId];
         }else{
           system.debug('============InstallDate==cwr======='+InstallDate);
           newWarrantyRegistration = frameWarrantyRegistration(CurrentInventory, CurrentInventoryDetails,WRUsageType);
         }
     
        if(newWarrantyRegistration != null)
        {
            system.debug('-------------new wr'+newWarrantyRegistration);
            if(true){
                Database.upsertResult WRInsertion = database.upsert(newWarrantyRegistration,false);
            if (WRInsertion.isSuccess()) 
            {
                isWRCreated = true;
                System.debug('Successfully inserted Warranty Registration. Warranty Registration ID: ' + WRInsertion.getId());
            }
            else 
            {
                for(Database.Error err : WRInsertion.getErrors()) 
                {
                    System.debug('The following error has occurred while inserting WR.'+err);
                    //PageUtils.addError(err.getMessage());
                    lstResponse.add(new Response(err.getMessage(),null,null));
                    return lstResponse;                    
                }
            }
            
            lstResponse.add(new Response(null,newWarrantyRegistration,null));
            return lstResponse;                    
            }else{
                    //ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                    lstResponse.add(new Response(string.valueOf(CrudUtil.INSUFFICIENT_ACCESS),null,null));
                    return lstResponse;
            }
        }else
            return null;
    }
    public static Warranty_Registration__c frameWarrantyRegistration(Inventory__c CurrentInventory,string CurrentInventoryDetails,String WRUsageType){
         newWarrantyRegistration = new Warranty_Registration__c();
        //Date registrationDate = date.today();
        Date registrationDate = CurrentInventory.Install_Date__c;
        if (Schema.sObjectType.Warranty_Registration__c.fields.Usage_Type__c.isCreateable()){
            newWarrantyRegistration.Usage_Type__c = WRUsageType;
            system.debug('-----newWarrantyRegistration.Usage_Type__c----'+newWarrantyRegistration.Usage_Type__c);
        }
        
        if (Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isCreateable()){
            newWarrantyRegistration.Account__c = CurrentInventory.Account__c;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Inventory__c.isCreateable() ){
            newWarrantyRegistration.Inventory__c = CurrentInventory.Id;
        }
        system.debug('---Registration_Date__c----');
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isCreateable()){
            newWarrantyRegistration.Registration_Date__c = registrationDate; //CurrentInventory.Install_Date__c;
        }
        system.debug('---Registration_Date__c----'+newWarrantyRegistration.Registration_Date__c);
        if (Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isCreateable()){
            newWarrantyRegistration.Status__c = Label.In_Progress;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isCreateable()){
            newWarrantyRegistration.Registration_Comments__c = CurrentInventoryDetails;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Customer__c.isCreateable()){
          
            newWarrantyRegistration.Customer__c= CurrentInventory.Customer__c;
        }
        return newWarrantyRegistration;
    }
    
      /*******************************************************************
    PURPOSE:   To fetch applicable Policy                                                  
    PARAMETERS: N/A
    RETURNS: list<PolicyDefinitionWrapper>
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    @AuraEnabled
    public static list<Response> fetchPolicyDefinitionsMngr(Boolean isDeleted,Warranty_Registration__c newWR,Boolean preowned,String inventoryId,String regType){
        lstResponse = new list<Response>();
        system.debug('---------- inside fetchpolicy'+newWR);
        
         list<PolicyDefinitionWrapper> tempPolicyDefinitionWrapperList = new list<PolicyDefinitionWrapper>();

        //Fetching all Policy Definitions using the Warranty Registration Record
        WarrantyRegisterManager objWarrantyRegisterManager=new WarrantyRegisterManager();
        list<Policy_Definition__c> PolicyDefinitionList = new list<Policy_Definition__c>();
        set<Id> existingPDId = new Set<Id>();
        //list<Policy_Definition__c> PolicyDefinitionList = objWarrantyRegisterManager.doSearch(newWR);
        //system.debug('PolicyDefinitionList----->'+PolicyDefinitionList);
        //system.debug('newWR.Inventory__c is ----->'+newWR.Inventory__c);
        if(newWR!= Null) {
         existingPDId = objWarrantyRegisterManager.findExistingPolicies(newWR.Inventory__c);
         system.debug('existingPDId is ----->'+existingPDId);
        }
       
        if(preowned == true && regType == 'Standard') {
            List<Warranty_Registration__c>  wrList = [SELECT Id,Name,(select Id,Name,Policy_Definition__c from Warranty_Coverages__r WHERE Is_Active__c = false) FROM Warranty_Registration__c WHERE Inventory__c =:inventoryId ];
            Set<String> PdIds =  new Set<String>();
            System.debug('----++++-----'+wrList + ' :::: ' + wrList[0].Warranty_Coverages__r.size());
            if(wrList.size()>0 && wrList[0].Warranty_Coverages__r.size()>0) {
                for(Warranty_Coverages__c wc : wrList[0].Warranty_Coverages__r) {
                
                    pdIds.add(wc.Policy_Definition__c);
                }
           }
            if(pdIds.size()>0) {
                PolicyDefinitionList  =[SELECT Id,Priority__c,Type__c,Active_From__c,Sub_Type__c,Active_Until__c,Transferable__c,Months_Covered__c,Status__c,Name,Is_Policy_Optional__c FROM Policy_Definition__c WHERE Type__c ='Standard' AND Id IN : pdIds];
            }
         }
         
         else {
         
            PolicyDefinitionList = objWarrantyRegisterManager.doSearch(newWR);
         }
        
        
        if(PolicyDefinitionList != null && PolicyDefinitionList.size() > 0)
        {    
            system.debug('---- inside policy def------');
            for(Policy_Definition__c objPD : PolicyDefinitionList)
            {
                system.debug('---- inside policy def---for loop---'+existingPDId.size());
                system.debug('---- inside policy def---for loop---'+objPD.Id);
                system.debug('existingPDId is ----->'+existingPDId);
                
                if(preowned == true && regType == 'Standard') {
                    
                      PolicyDefinitionWrapper tempPDW = new PolicyDefinitionWrapper(objPD);
                      if(!objPD.Is_Policy_Optional__c)
                      {
                        system.debug('---- Is_Policy_Optional__c----');
                        tempPDW.isDisabled = true;
                        tempPDW.selected = true;
                      }
                      tempPolicyDefinitionWrapperList.add(tempPDW);
                      
                }

                else if((existingPDId == null || existingPDId.size() == 0) || (existingPDId != null && existingPDId.size() > 0 && !existingPDId.contains(objPD.Id)))
                {
                    system.debug('---- existingPDId----');
                    PolicyDefinitionWrapper tempPDW = new PolicyDefinitionWrapper(objPD);
                    if(!objPD.Is_Policy_Optional__c)
                    {
                        system.debug('---- Is_Policy_Optional__c----');
                        tempPDW.isDisabled = true;
                        tempPDW.selected = true;
                    }
                    system.debug('---- tempPolicyDefinitionWrapperList-in for loop---'+tempPolicyDefinitionWrapperList);
                    tempPolicyDefinitionWrapperList.add(tempPDW);
                    system.debug('&&&&&list');
                    system.debug(tempPolicyDefinitionWrapperList.size());
                }
            }
        }
       if(newWr != null) {
        Warranty_Registration__c tmpWR = new Warranty_Registration__c(Id = newWR.Id);
          //if(CrudUtil.isWRDeletable()){
                 if(!isDeleted && tmpWR!=null && tmpWR.id!=null)
                {
                    isDeleted = true;
                    delete tmpWR;
                }
            else{
                //ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                lstResponse.add(new Response(string.valueOf(CrudUtil.INSUFFICIENT_ACCESS),null,null));
                return lstResponse;

            }
        system.debug('newWR is ---->>>'+newWR);
        system.debug('tempPolicyDefinitionWrapperList is ---->>>'+tempPolicyDefinitionWrapperList);
        
        }
        lstResponse.add(new Response(null,null,tempPolicyDefinitionWrapperList));
        return lstResponse;
    }
    
     /*******************************************************************
    PURPOSE:   To update Warranty Registration and Insert Warranty Coverage Records based on the user's selection                                                   
    PARAMETERS: N/A
    RETURNS: void
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    @AuraEnabled
    public static list<Response> registerInventory(string PolicyDefinitionList ,String CurrentInventoryDetails,Inventory__c CurrentInventory, String InstDate, Id WRID,String WRUsageType,Id InventoryCustomer,String coverageEndDate)    {
        system.debug('WRUsageType-----------'+WRUsageType);
        system.debug('InstDate-----------'+InstDate);
        system.debug('InventoryCustomer-----------'+InventoryCustomer);
        system.debug('CurrentInventory-----------'+CurrentInventory);
        List<String> lstDate = InstDate.split('/');
        Date InstallDate = date.newinstance(Integer.valueOf(lstDate[2]),Integer.valueOf(lstDate[1]),Integer.valueOf(lstDate[0]));
        
        CurrentInventory.Customer__c = InventoryCustomer;
        CurrentInventory.Install_Date__c = InstallDate;
        
        system.debug('----WRId----'+WRId);
        if(WRId != null){
            system.debug('===========WRId======='+WRId);
            newWarrantyRegistration  = [select Account__c,Customer__c,Group__c,Inventory__c,Maximum_Unit__c,Registration_Comments__c,Registration_Date__c,Status__c,Usage_Type__c,Warranty_End_Date__c,Warranty_Product__c,Warranty_Start_Date__c,Id FROM Warranty_Registration__c Where Id= :WRId];
            system.debug('============newWarrantyRegistration========'+newWarrantyRegistration);
         }else{
           system.debug('============InstallDate==cwr======='+InstallDate);
           newWarrantyRegistration = frameWarrantyRegistration(CurrentInventory, CurrentInventoryDetails,WRUsageType);
         }
         
        
        system.debug('---------- inside registerInventory'+newWarrantyRegistration);
        system.debug('---------- list of policies'+PolicyDefinitionList);
        
        //List<PolicyDefinitionWrapper> PolicyDefinitionList = (List<PolicyDefinitionWrapper>)JSON.deserializeUntyped(PolicyDefinitionWrapperList);
        List<PolicyDefinitionWrapper> PolicyDefinitionWrapperList =  (List<PolicyDefinitionWrapper>)System.JSON.deserialize(PolicyDefinitionList, List<PolicyDefinitionWrapper>.class);

            
        system.debug('-----------PolicyDefinitionList--------'+PolicyDefinitionWrapperList);        
       if(InventoryCustomer != Null){  
            try{
               system.debug('---------- inside CurrentInventory reg'+CurrentInventory);  
            CurrentInventory.Customer__c = InventoryCustomer;
            CurrentInventory.Install_Date__c = InstallDate;
            CurrentInventory.Type__c='Retail';
            upsert CurrentInventory;
            }
            catch(DMLException e){
             System.debug('The following exception has occurred: ' + e.getMessage());
                lstResponse.add(new Response(e.getMessage(),null,null));
                return lstResponse;
            }
        }
        
        //inventoryManagerObj.registerInventoryMngr(PolicyDefinitionList,CurrentInventoryDetails,CurrentInventory);
        
        //Inventory manager registerInventoryMngr code
        
        system.debug('inside registerInventoryMngr');
        //checking for all selected Policy Definitions
        list<Policy_Definition__c> selectedPolicyDefinitions = new list<Policy_Definition__c>();
        //system.debug('+++AAAA+++'+selectedPolicyDefinitions);
         if(PolicyDefinitionWrapperList != null && PolicyDefinitionWrapperList.size() > 0) 
         {
            system.debug('+++AAAA+++'+selectedPolicyDefinitions);

            for(PolicyDefinitionWrapper objPD : PolicyDefinitionWrapperList) 
            {
                system.debug('----------objPD-----'+objPD);
                if(objPD.selected != null && objPD.selected)
                {
                    selectedPolicyDefinitions.add(objPD.ObjPolicyDefinition);
                }
            }
             system.debug('-selectedPolicyDefinitions---------'+selectedPolicyDefinitions);
        }
        
        system.debug('newWarrantyRegistration is ------>>>>'+newWarrantyRegistration);
        Warranty_Registration__c newWR = null;
        
        if(WRId != null){
                newWR = newWarrantyRegistration;
        }else{
            newWR = newWarrantyRegistration.clone(false, true); 
        }
        
        if(true){
            Database.upsertResult WRInsertion = database.upsert(newWR,false);
        
            if (WRInsertion.isSuccess()) 
            {
                System.debug('Successfully inserted Warranty Registration. Warranty Registration ID: ' + WRInsertion.getId());
            }
            else 
            {
                for(Database.Error err : WRInsertion.getErrors()) 
                {
                    System.debug('The following error has occurred while inserting WR.'+err);
                    //PageUtils.addError(err.getMessage());
                    lstResponse.add(new Response(err.getMessage(),null,null));
                    return lstResponse;
                }
            }
        }
        else{
                //ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                lstResponse.add(new Response(string.valueOf(CrudUtil.INSUFFICIENT_ACCESS),null,null));
                return lstResponse;
        }
        
        //Creating Warranty Registration Record
        //if (Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isUpdateable()){
            newWR.Status__c = 'Registered';
        //}
        //if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isUpdateable()){
            newWR.Registration_Comments__c = CurrentInventoryDetails;
        //}
        boolean isSuccess = false;
        
        system.debug('newWR is---->>>'+newWR);
        
       
            Database.SaveResult WRUpdation = database.update(newWR,false);
       
            if(WRUpdation.isSuccess()) {
                isSuccess = true;
                System.debug('Successfully updated Warranty Registration. Warranty Registration ID: ' + WRUpdation.getId());
                
            }else{
                for(Database.Error err : WRUpdation.getErrors()){
                    System.debug('The following error has occurred while updating WR.'+err);
                    //PageUtils.addError(err.getMessage());  
                    lstResponse.add(new Response(err.getMessage(),null,null));
                    return lstResponse;
                }
            }
                 
       //Creating Warranty Coverage Record after the successful creation of warranty Registration Records
       if(isSuccess){
            list<Warranty_Coverages__c> WarrantyCoverageList = new list<Warranty_Coverages__c>();
         
            
            for(Policy_Definition__c objPD : selectedPolicyDefinitions)
            {
                Warranty_Coverages__c newWarrantyCoverage = new Warranty_Coverages__c(); 
                 
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Policy_Definition__c.isCreateable())               
                    newWarrantyCoverage.Policy_Definition__c = objPD.Id;   
                    
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Registration__c.isCreateable())             
                    newWarrantyCoverage.Warranty_Registration__c = newWR.Id;
                
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Is_Active__c.isCreateable()){
                    newWarrantyCoverage.Is_Active__c = true;
                }
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Start_Date__c.isCreateable()){ 
                    newWarrantyCoverage.Warranty_Start_Date__c = CurrentInventory.Install_Date__c;  //newWR.Registration_Date__c;
                
                }
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_End_Date__c.isCreateable()){ 
                    
                    system.debug('coverageEndDate');
                    system.debug(coverageEndDate);   
                        
                    
                    if(objPD.Type__c == 'Goodwill' && coverageEndDate!=null && coverageEndDate!=''){
                        newWarrantyCoverage.Warranty_End_Date__c = Date.parse(coverageEndDate);
                    }else{
                        newWarrantyCoverage.Warranty_End_Date__c = CurrentInventory.Install_Date__c.addMonths(Integer.valueOf(objPD.Months_Covered__c != null ?objPD.Months_Covered__c:0));
                        newWarrantyCoverage.Warranty_End_Date__c = newWarrantyCoverage.Warranty_End_Date__c.addDays(-1);
                    }    
                    
                
                
                }
                WarrantyCoverageList.add(newWarrantyCoverage);
            }
            
            
            if(CrudUtil.isWCCreateable()){
                system.debug('-WarrantyCoverageList---------'+WarrantyCoverageList);
                Database.SaveResult[] WCInsertionList = database.insert(WarrantyCoverageList,false);
                
                for(Database.SaveResult sr : WCInsertionList){
                    if (sr.isSuccess()){
                    System.debug('Successfully inserted Warranty coverage. Warranty coverage ID: ' + sr.getId());
                    }else{
                        for(Database.Error err : sr.getErrors()) 
                        {
                            System.debug('The following error has occurred while inserting WC.'+err);
                            //PageUtils.addError(err.getMessage());
                            lstResponse.add(new Response(err.getMessage(),null,null));
                            return lstResponse;  
                        }
                    }
                }
                return null;
            }else{
                //ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                lstResponse.add(new Response(string.valueOf(CrudUtil.INSUFFICIENT_ACCESS),null,null));
                return lstResponse;
            }
        }else
            return null;
        
      
    }  
    
    @AuraEnabled
    public static list<fieldset> fieldstodisplay(){
    
    List<Schema.FieldSetMember> lstInventoryFieldSet = readFieldSet('BasicInventoryDetails','Inventory__c'); 
    List<fieldset> lstFieldSet = new list<fieldset>();
    if(!lstInventoryFieldSet.isEmpty()){
   
        for(Schema.FieldSetMember f : lstInventoryFieldSet) {
            system.debug('-------------------------type'+f.getType());
            string type = ''+f.getType();
            string apiname = f.getFieldPath();
            String referenceName = '';
            if(type == 'REFERENCE')
            {
                Schema.DescribeFieldResult fresult = Schema.getGlobalDescribe().get('Inventory__c').getDescribe().Fields.getMap().get(apiname).getDescribe();
                system.debug('--------------fresult-----'+fresult);
                referenceName = fresult.getRelationshipName();
                system.debug('--------------referenceName -----'+referenceName );
                referenceName +='.Name';
            }
            lstFieldSet.add(new fieldset(f.getLabel(),f.getFieldPath(),type,referenceName));
        }
    }
    system.debug('--------------------------------'+lstFieldSet );
    return lstFieldSet ;
    }
   
    @AuraEnabled
    public static list<fieldset> policydefFields(){
         List<Schema.FieldSetMember> lstInventoryFieldSet = readFieldSet('Policy_Definition_fieldset_for_WR','Policy_Definition__c'); 
    List<fieldset> lstFieldSet = new list<fieldset>();
    if(!lstInventoryFieldSet.isEmpty()){
   
        for(Schema.FieldSetMember f : lstInventoryFieldSet) {
            system.debug('-------------------------type'+f.getType());
            string type = ''+f.getType();
            string apiname = f.getFieldPath();
            String referenceName = '';
            if(type == 'REFERENCE')
            {
                Schema.DescribeFieldResult fresult = Schema.getGlobalDescribe().get('Policy_Definition__c').getDescribe().Fields.getMap().get(apiname).getDescribe();
                system.debug('--------------fresult-----'+fresult);
                referenceName = fresult.getRelationshipName();
                system.debug('--------------referenceName -----'+referenceName );
                referenceName +='.Name';
            }
            lstFieldSet.add(new fieldset(f.getLabel(),f.getFieldPath(),type,referenceName));
        }
    }
    system.debug('--------------------------------'+lstFieldSet );
    return lstFieldSet ;
    }
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        return fieldSetObj.getFields(); 
    }
    
    @AuraEnabled
    public static Object getMaxMonthsCovered(String warrantyRegistrationId){

        AggregateResult[] groupedResults = [select MAX(Months_Covered_Till_Day__c) from Warranty_Coverages__c where Warranty_Registration__c=:warrantyRegistrationId];
        Object maximumMonthsCoveredTillDate = groupedResults[0].get('expr0');
        return maximumMonthsCoveredTillDate;

    }
    
    @AuraEnabled
    public static String getInitialData(String invId){
        Account accObj = null;
        Inventory__c invObj = [Select Id, Name, Account__c, Item__c,De_Registration_Date__c, Customer__c, Serial_Number__c,Model_Number__c, Item__r.Parent_Product__r.Name,Units_Run__c, Install_Date__c,Type__c from Inventory__c where Id =: invId];
        
        if(String.isNotBlank(invObj.Customer__c)){
            accObj = [SELECT Id,Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode,Country__r.Name,Phone,Website,Email__c FROM Account Where Id=: invObj.Customer__c];
        }
        
        return System.JSON.serialize(new InitDataSet(invObj, accObj, usageTypeRetrun(), fieldstodisplay(), policydefFields()));
    }
      
   @AuraEnabled
    public static String getAllCoveragesRealtedtoInventory(String invId){
        
            Warranty_Registration__c  wr = [SELECT Id,Name,(select Id,Name,Policy_Definition__c,Policy_Definition__r.Name,Is_Active__c,Warranty_End_Date__c from Warranty_Coverages__r WHERE Is_Active__c = false) FROM Warranty_Registration__c WHERE Inventory__c =:invId];
            List<Warranty_Coverages__c> coveragesList =  new List<Warranty_Coverages__c>();
            coveragesList.addAll(wr.Warranty_Coverages__r);
            return JSON.serialize(coveragesList);
    }
    
    
    @AuraEnabled
    public static Boolean updateCoverages( String  coveragesList,String currentInventory,String customerId){
        Boolean successFlag = true;
        try {
          
            List<Warranty_Coverages__c> wc =   (List<Warranty_Coverages__c>)System.JSON.deserialize(coveragesList, List<Warranty_Coverages__c>.class);
            Inventory__c  Inv = (Inventory__c)System.JSON.deserialize(currentInventory,Inventory__c.class);
            Inv.Type__c ='Retail';
            Inv.Customer__c= customerId;
            update wc;
            update Inv;
        }
        catch(Exception e) {
            System.debug(e.getMessage()+'Error Occured-------');
            successFlag = false;
            
        }
        return successFlag ;
    }
    
    
    //Get the fields from custom setting
    @AuraEnabled
     Public static boolean EnableExtendedRegistrationLogic(){        
        WOD__c enableExtendedSetting = WOD__c.getInstance(label.Enable_Extended_Registration_Logic);
        Boolean enableExtended = enableExtendedSetting.isTriggered__c;
        return enableExtended;
    }
    
    public class InitDataSet{
        @AuraEnabled
        public Inventory__c invObj;
        @AuraEnabled
        public Account accObj;
        @AuraEnabled
        public list<String> usageTypeOptions;
        @AuraEnabled
        public list<fieldset> invFieldSetList;
        @AuraEnabled
        public list<fieldset> policyFieldSetList;
        
        public InitDataSet(Inventory__c invObj, Account accObj, list<String> usageTypeOptions, list<fieldset> invFieldSetList, list<fieldset> policyFieldSetList){
            this.invObj = invObj;
            this.accObj = accObj;
            this.usageTypeOptions = usageTypeOptions;
            this.invFieldSetList = invFieldSetList;
            this.policyFieldSetList = policyFieldSetList;
        }
    }
    
    public class fieldset{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String RelationShipName;

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public fieldset(String labelvalue, String apiNamevalue, String datatype, String referenceName ) {
            label = labelvalue;
            apiName = apiNamevalue;
            type = datatype;
            RelationShipName = referenceName ;
        }
    }
    public class Response{
        @AuraEnabled
        public String error;
        @AuraEnabled
        public Warranty_Registration__c WarrantyRegistration;
        @AuraEnabled
        public List<PolicyDefinitionWrapper>  PolicyDefWrapper;

        public Response(String strError, Warranty_Registration__c wr, List<PolicyDefinitionWrapper> pdWrapper) {
            error = strError;
            WarrantyRegistration = wr;
            PolicyDefWrapper = pdWrapper;
            
        }
    }
    
    
}