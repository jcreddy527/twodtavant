/*********************************************************************************************
Name:  ClaimFinancialController
Copyright © 2016  Tavant Technology Inc
==============================================================================================
==============================================================================================
Purpose:  Claim Financials - Populate the Claim values and reflect changes in Claim Financials                                                  
-------                                                             
==============================================================================================
Without Sharing Reason - This class is used create claim Financial data. Claim Financial object CRUD access provided only warranty admin. 
Claim Financial data need to be create if dealer create/update/delete claim data. 
==============================================================================================
History                                                            
-------                                                            
VERSION   AUTHOR             DATE            DETAIL                         FEATURES/CSR/TTP
1.0       Chethan Sharma L   07/10/2016      INITIAL DEVELOPMENT            
**********************************************************************************************/

global with sharing class ClaimFinancialController{
    Set<Id> ClaimIds = new Set<Id>();   
    List<String> customSettingVal = new List<String>();
    List<String> PrefixVals = new List<String>(); 
                     
    global static string NameSpace = SystemUtils.getNameSpace();
    
    private static boolean run = true;
    
    // Set containing all Cost Category fields
    Set<String>  costCatFieldSet;
    
    // Suffix cost categories
    public static String claimSuffix = '_Cost__c';
    
    public List<Claim__c> cliamsList;
    public List<Claim_Financial__c> cliamFinancialsList;
        
    // String Variable for cost categories
    String costCategoryFields='';     
    
    // Class variable
    private static ClaimFinancialController instance = null;
    
    /***********************************************************************************************
    PURPOSE: Private Constructor used to restrict object instantiation of this controller class   
    ************************************************************************************************/
    private ClaimFinancialController() {
        // Exists only to defeat instantiation.
    } 
    
    
    /***********************************************************************************************
    PURPOSE: Method used to Create Single instance of this controller class                                              
    PARAMETERS: N/A
    RETURNS: Single instance of ClaimFinancialController class
    THROWS [EXCEPTIONS]: N/A  
    ************************************************************************************************/
    public static ClaimFinancialController getInstance() {
       if (instance == null) {
            instance = new ClaimFinancialController();
        }
        return instance;
    }
    
    /***********************************************************************************************
    PURPOSE: Method used to Upsert Claim-Financials on Insert/Update of Claim__c object                                               
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ************************************************************************************************/
    public void claimFinanceOnUpsert(List<Claim__c> claimFinList){
        
        // Get all 'CustomSettings' records
        //List<WOD__c> customSettingsList = WOD__c.getall().values();
        
        // Iterate through the 'CustomSettings' records list of WOD__c object
        /* ************************************************************************************************
            Search for 'All Payment Configurations' Name in the list of 'CustomSettings' records. 
            Get all the Values(i.e in 'CustomSettings'-'All Payment Configurations' record and Split Values
        ************************************************************************************************ */
        
        WOD__c paymentConfig = WOD__c.getValues('All Payment Configurations');
        customSettingVal = paymentConfig.Trigger_Value__c.split(',');
        //Added by Kishore for adding parts to claim financial list
        customSettingVal.add('Parts');
        
        WOD__c prefixConfig = WOD__c.getValues('All Prefix Configurations');
        PrefixVals = prefixConfig.Trigger_Value__c.split(',');
        
        costCatFieldSet = new Set<String>();
    
        for(String costCategory: customSettingVal){ 
            for(String prefix: PrefixVals){
                costCategoryFields=NameSpace+prefix + costCategory + claimSuffix ;
                // Add appended cost category values to list
                costCatFieldSet.add(costCategoryFields);
            }                                          
        }
        
        // Add Parts to List
        /*costCatFieldSet.add(NameSpace+'Total_Parts_Cost__c');
        costCatFieldSet.add(NameSpace+'Final_Parts_Cost__c');
        costCatFieldSet.add(NameSpace+'Approved_Parts_Cost__c');
        costCatFieldSet.add(NameSpace+'Percent_Parts_Cost__c'); */
        
        // Get all Claim-Id's and Add to List
        for(Claim__c claimrecord : claimFinList){
            ClaimIds.add(claimrecord.id);
        } 
        
        // Creating a Query String dynamically
        String selectQuery = 'Select ';
        
        for(String query : costCatFieldSet) {
           selectQuery+= query+','; 
        }
        
        selectQuery = selectQuery.removeEnd(',');
        selectQuery+= ' FROM '+NameSpace+'claim__c WHERE Id IN:ClaimIds';
        List<Claim__c> claimsList = database.query(selectQuery);
        
        cliamFinancialsList = new List<Claim_Financial__c>();
        
        
        // Iterate through Claim-Id and add corresponding Claim financial Objects to Claim              
        for(claim__c claim : claimsList)
        {
        
            for(String individualCostCat: customSettingVal){
                Claim_Financial__c claimfinancial = new Claim_Financial__c();
                if (Schema.sObjectType.Claim_Financial__c.fields.Name.isCreateable() ){
                   claimfinancial.Name = individualCostCat;
                }
                //the below if statement added by siva
                if (Schema.sObjectType.Claim_Financial__c.fields.Cost_Category_Type__c.isCreateable() ){
                   claimfinancial.Cost_Category_Type__c = individualCostCat;
                }
                if (Schema.sObjectType.Claim_Financial__c.fields.Total_Amount__c.isCreateable()){
                    claimfinancial.Total_Amount__c = (Decimal)claim.get(NameSpace+'Total_'+ individualCostCat + claimSuffix);
                }
                if (Schema.sObjectType.Claim_Financial__c.fields.Final_Amount__c.isCreateable() ){
                    claimfinancial.Final_Amount__c = (Decimal)claim.get(NameSpace+'Final_'+ individualCostCat + claimSuffix);
                }
                if (Schema.sObjectType.Claim_Financial__c.fields.Percent_Amount__c.isCreateable()){
                    claimfinancial.Percent_Amount__c = (Decimal)claim.get(NameSpace+'Percent_'+ individualCostCat + claimSuffix);
                }
                if (Schema.sObjectType.Claim_Financial__c.fields.Approved_Amount__c.isCreateable() ){
                    claimfinancial.Approved_Amount__c = (Decimal)claim.get(NameSpace+'Approved_'+ individualCostCat + claimSuffix);
                }
                if (Schema.sObjectType.Claim_Financial__c.fields.Claim__c.isCreateable()){
                    claimfinancial.Claim__c = claim.Id;
                }
                if (Schema.sObjectType.Claim_Financial__c.fields.Payment_Type__c.isCreateable()){
                    claimfinancial.Payment_Type__c = claimfinancial.Name + claimfinancial.Claim__c;
                }
                
                cliamFinancialsList.add(claimfinancial);
            }
        
                        
        }
        
        if(!cliamFinancialsList.isEmpty()) {
            try{
                if(Schema.sObjectType.Claim_Financial__c.isCreateable() && Schema.sObjectType.Claim_Financial__c.isCreateable()){  
                    //Added by Siva for setting static variable
                    ClaimFinancialControllerHelper.firstRun = false;
                    upsert cliamFinancialsList Payment_Type__c;
                }
              } 
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
            
    }
    
    
    /***********************************************************************************************
    PURPOSE: Method used to Delete Claim-Financials on Deleting of Claim__c object                                               
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ************************************************************************************************/
    public void claimFinancialsDelete(Set<Id> claimFinDelete)
    {
        List<Claim_Financial__c> claimFinancials = [SELECT Claim__c FROM Claim_Financial__c WHERE Claim__c IN:claimFinDelete];
          if (Schema.sObjectType.Claim_Financial__c.isDeletable()) {
                //Added by Siva for setting static variable
                ClaimFinancialControllerHelper.firstRun = false;
                delete claimFinancials;
           }
            
          
    }
    
}