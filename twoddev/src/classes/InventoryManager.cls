/**********************************************************************
 Name:  InventoryManager
 Copyright ? 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:  Manager Class to create Warranty Registration and Warranty Coverages from Inventory
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Abhishek        17/11/2014      INITIAL DEVELOPMENT   
2.0 -    Susmita         19/08/2015       Added null check for WR in Cancel method
***********************************************************************/

global with sharing class InventoryManager{

    Warranty_Registration__c newWarrantyRegistration;
    list<PolicyDefinitionWrapper> tempPolicyDefinitionWrapperList= new list<PolicyDefinitionWrapper>();
    boolean isDeleted = false;
    /*******************************************************************
    PURPOSE:   To get all Policy Definitions                                                   
    PARAMETERS: boolean flag "isWRCreated" , Inventory__c type of object "CurrentInventory" , String Variable "CurrentInventoryDetails" 
    RETURNS:List of PolicyDefinitionWrapper
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
   
    global boolean createWarrantyRegistration(boolean isWRCreated,Inventory__c CurrentInventory,string CurrentInventoryDetails)
    {
        //Date registrationDate = Date.Today();
        Date registrationDate = CurrentInventory.Install_Date__c;
        tempPolicyDefinitionWrapperList= new list<PolicyDefinitionWrapper>();
        isDeleted = false;
         //Creating Warranty Registration Record
        //if(isWRCreated == false) 
        {
            newWarrantyRegistration = new Warranty_Registration__c();
        }        
        
        if (Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isUpdateable()){
            newWarrantyRegistration.Account__c = CurrentInventory.Account__c;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Inventory__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Inventory__c.isUpdateable()){
            newWarrantyRegistration.Inventory__c = CurrentInventory.Id;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isUpdateable()){
        newWarrantyRegistration.Registration_Date__c = registrationDate;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isUpdateable()){
            newWarrantyRegistration.Status__c = Label.In_Progress;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isUpdateable()){
            newWarrantyRegistration.Registration_Comments__c = CurrentInventoryDetails;
        }
        
              if (Schema.sObjectType.Warranty_Registration__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Customer__c.isUpdateable()){
          
            newWarrantyRegistration.Customer__c= CurrentInventory.Customer__c;
        }
        
        
  
        
        if(CrudUtil.isWRUpsertable()){
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
                PageUtils.addError(err.getMessage());
                return null;                    
            }
        }
        
        return isWRCreated;
        }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
        }
    }
    
    /*******************************************************************
    PURPOSE:   To fetch applicable Policy                                                  
    PARAMETERS: N/A
    RETURNS: list<PolicyDefinitionWrapper>
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    global list<PolicyDefinitionWrapper> fetchPolicyDefinitionsMngr(){
        tempPolicyDefinitionWrapperList= new list<PolicyDefinitionWrapper>();
        
        //Fetching all Policy Definitions using the Warranty Registration Record
        WarrantyRegisterManager objWarrantyRegisterManager=new WarrantyRegisterManager();
        list<Policy_Definition__c> PolicyDefinitionList = objWarrantyRegisterManager.doSearch(newWarrantyRegistration);
        system.debug('newWarrantyRegistration.Inventory__c is ----->'+newWarrantyRegistration.Inventory__c);
        set<Id> existingPDId = objWarrantyRegisterManager.findExistingPolicies(newWarrantyRegistration.Inventory__c);
        system.debug('existingPDId is ----->'+existingPDId);
        if(PolicyDefinitionList != null && PolicyDefinitionList.size() > 0) 
        {
            for(Policy_Definition__c objPD : PolicyDefinitionList) 
            {
                If((existingPDId == null || existingPDId.size() == 0) || (existingPDId != null && existingPDId.size() > 0 && !existingPDId.contains(objPD.Id)))
                {
                    PolicyDefinitionWrapper tempPDW = new PolicyDefinitionWrapper(objPD);
                    if(!objPD.Is_Policy_Optional__c) 
                    {
                        tempPDW.isDisabled = true;
                        tempPDW.selected = true;
                    }
                    tempPolicyDefinitionWrapperList.add(tempPDW);
                }
            }
        }
        
        Warranty_Registration__c tmpWR = new Warranty_Registration__c(Id = newWarrantyRegistration.Id);
        if(CrudUtil.isWRDeletable()){
                 if(!isDeleted && tmpWR!=null && tmpWR.id!=null )
                {
                    isDeleted = true;
                    delete tmpWR;
                }
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
            }
        system.debug('newWarrantyRegistration is ---->>>'+newWarrantyRegistration);
        return tempPolicyDefinitionWrapperList;
    }


    /*******************************************************************
    PURPOSE:   To update Warranty Registration and to insert Warranty Coverage Records based on the user's selection                                                   
    PARAMETERS: List of PolicyDefinitionWrapper "PolicyDefinitionWrapperList ",String Variable "CurrentInventoryDetails" , Inventory__c type of Object "CurrentInventory"
    RETURNS: Pagereference
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    
    global PageReference registerInventoryMngr(list<PolicyDefinitionWrapper> PolicyDefinitionWrapperList , String CurrentInventoryDetails , Inventory__c CurrentInventory ){
    
        system.debug('inside registerInventoryMngr');
        //checking for all selected Policy Definitions
        list<Policy_Definition__c> selectedPolicyDefinitions = new list<Policy_Definition__c>();
        
         if(PolicyDefinitionWrapperList != null && PolicyDefinitionWrapperList.size() > 0) 
         {
         
            for(PolicyDefinitionWrapper objPD : PolicyDefinitionWrapperList) 
            {
                system.debug('----------objPD-----'+objPD);
                if(objPD.selected) 
                {
                    selectedPolicyDefinitions.add(objPD.ObjPolicyDefinition);
                }
            }
        }
        system.debug('----------selectedPolicyDefinitions-----'+selectedPolicyDefinitions);
        if(selectedPolicyDefinitions == null || selectedPolicyDefinitions.size() == 0) 
        {
        
            PageUtils.addError(Label.Warranty_Registration_Validation_Message);
            return null;
            
        }
        
        system.debug('newWarrantyRegistration is ------>>>>'+newWarrantyRegistration);
        Warranty_Registration__c newWR = newWarrantyRegistration.clone(false, true);
        
        if(CrudUtil.isWRUpsertable()){
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
                    PageUtils.addError(err.getMessage());
                    return null;                    
                }
            }
        }
        else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
        }
        
        //Creating Warranty Registration Record
        if (Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isUpdateable()){
            newWR.Status__c = 'Registered';
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isUpdateable()){
            newWR.Registration_Comments__c = CurrentInventoryDetails;
        }
        boolean isSuccess = false;
        
        system.debug('newWR is---->>>'+newWR);
        
        if(CrudUtil.isWRupdateable()){
            Database.SaveResult WRUpdation = database.update(newWR,false);
       
            if(WRUpdation.isSuccess()) {
                isSuccess = true;
                System.debug('Successfully updated Warranty Registration. Warranty Registration ID: ' + WRUpdation.getId());
                
            }else{
                for(Database.Error err : WRUpdation.getErrors()){
                    System.debug('The following error has occurred while updating WR.'+err);
                    PageUtils.addError(err.getMessage());  
                    return null;
                }
            }
        }
        
                 
       //Creating Warranty Coverage Record after the successful creation of warranty Registration Records
       if(isSuccess){
            list<Warranty_Coverages__c> WarrantyCoverageList = new list<Warranty_Coverages__c>();
         
            
            for(Policy_Definition__c objPD : selectedPolicyDefinitions)
            {
                Warranty_Coverages__c newWarrantyCoverage = new Warranty_Coverages__c(); 
                 
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Policy_Definition__c.isCreateable()){               
                    newWarrantyCoverage.Policy_Definition__c = objPD.Id;   
                }
                    
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Registration__c.isCreateable()) {            
                    newWarrantyCoverage.Warranty_Registration__c = newWR.Id;
                }
                
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Is_Active__c.isCreateable()){
                    newWarrantyCoverage.Is_Active__c = true; 
                }
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Start_Date__c.isCreateable()){ 
                    newWarrantyCoverage.Warranty_Start_Date__c = CurrentInventory.Install_Date__c;
                
                }
                if (Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_End_Date__c.isCreateable()){ 
                    newWarrantyCoverage.Warranty_End_Date__c = CurrentInventory.Install_Date__c.addMonths(Integer.valueOf(objPD.Months_Covered__c != null ?objPD.Months_Covered__c:0));
                    newWarrantyCoverage.Warranty_End_Date__c = newWarrantyCoverage.Warranty_End_Date__c.addDays(-1);
                }
                WarrantyCoverageList.add(newWarrantyCoverage);
            }
            
            
            if(CrudUtil.isWCCreateable()){
                system.debug('---WarrantyCoverageList----'+WarrantyCoverageList);
                Database.SaveResult[] WCInsertionList = database.insert(WarrantyCoverageList,false);
                
                for(Database.SaveResult sr : WCInsertionList){
                    if (sr.isSuccess()){
                    System.debug('Successfully inserted Warranty coverage. Warranty coverage ID: ' + sr.getId());
                    }else{
                        for(Database.Error err : sr.getErrors()) 
                        {
                            System.debug('The following error has occurred while inserting WC.'+err);
                            PageUtils.addError(err.getMessage());  
                            return null;                  
                        }
                    }
                }
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
            }
        }
        
        return cancel(CurrentInventory,false);
    
    }
    
    /*******************************************************************
    PURPOSE:   To do registration without warranty                                                     
    PARAMETERS: boolean flag "isWRCreated" , Inventory__c type of object "CurrentInventory" , String Variable "CurrentInventoryDetails" 
    RETURNS:List of PolicyDefinitionWrapper
    THROWS [EXCEPTIONS]: N/A  
    *******************************************************************
   
    global PageReference registerWOWarranty(Inventory__c CurrentInventory,string CurrentInventoryDetails)
    {
        PageReference pageRef = null;
        
        Warranty_Registration__c newWarrantyRegistration1 = new Warranty_Registration__c();
        
        if (Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isUpdateable()){
            newWarrantyRegistration1.Account__c = CurrentInventory.Account__c;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Inventory__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Inventory__c.isUpdateable()){
            newWarrantyRegistration1.Inventory__c = CurrentInventory.Id;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isUpdateable()){
            newWarrantyRegistration1.Registration_Date__c = CurrentInventory.Install_Date__c;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isUpdateable()){
            newWarrantyRegistration1.Status__c = Label.In_Progress;
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isUpdateable()){
            newWarrantyRegistration1.Registration_Comments__c = CurrentInventoryDetails;
        }
        
        if(CrudUtil.isWRUpsertable()){
        Database.upsertResult WRInsertion = database.upsert(newWarrantyRegistration1,false);
        
        if (WRInsertion.isSuccess()) 
        {
            System.debug('Successfully inserted Warranty Registration. Warranty Registration ID: ' + WRInsertion.getId());
        }
        else 
        {
            for(Database.Error err : WRInsertion.getErrors()) 
            {
                System.debug('The following error has occurred while inserting WR.'+err);
                PageUtils.addError(err.getMessage());
                return null;                    
            }
        }
        
        if (Schema.sObjectType.Warranty_Registration__c.fields.Status__c.isUpdateable()){
            newWarrantyRegistration1.Status__c = 'Registered';
        }
        if (Schema.sObjectType.Warranty_Registration__c.fields.Registration_Comments__c.isUpdateable()){
            newWarrantyRegistration1.Registration_Comments__c = CurrentInventoryDetails;
        }
        
        if(CrudUtil.isWRupdateable()){
            Database.SaveResult WRUpdation = database.update(newWarrantyRegistration1,false);
       
            if(WRUpdation.isSuccess()) {
                System.debug('Successfully updated Warranty Registration. Warranty Registration ID: ' + WRUpdation.getId());
                if(CurrentInventory.id != null){
                    pageRef =  new ApexPages.StandardController(CurrentInventory).view();
                    pageRef.setRedirect(true);
                }
            }else{
                for(Database.Error err : WRUpdation.getErrors()){
                    System.debug('The following error has occurred while updating WR.'+err);
                    PageUtils.addError(err.getMessage());  
                    return null;
                }
            }
        }
        
        
        return pageRef;
        }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
        }
    }*/
    
    /*******************************************************************
    Purpose:     To redirect to the inventory records                                                    
    Parameters: Inventory__c type of object "CurrentInventory"
    Returns:Pagereference
    Throws [Exceptions]:                                                          
    ********************************************************************/ 
    global PageReference Cancel(Inventory__c CurrentInventory,boolean isDelete){
        system.debug('# -> Cancel');
        PageReference pageRef = null;
        if(isDelete == true && newWarrantyRegistration != null && newWarrantyRegistration.id!=null && isDeleted == false)
        {
            if(CrudUtil.isWRDeletable()){
                delete newWarrantyRegistration;
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
            }
        }
        
        if(CurrentInventory.id != null){
            //pageRef = new PageReference('/'+CurrentInventory.Id);
            pageRef =  new ApexPages.StandardController(CurrentInventory).view();
            pageRef.setRedirect(true);
        }
        system.debug('# <- Cancel');
        return pageRef;
    }


}