/********************************************************************************
 Name:  InitializeTestData
 Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: 
Class is used to create data for test classes.
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          10/19/2016     INITIAL DEVELOPMENT            
**********************************************************************************/
@isTest
global class InitializeTestData{
    global static string NameSpace;
  static{
    NameSpace = SystemUtils.getNameSpace();
    system.debug('---NameSpace-'+NameSpace);
  } 
   /******************************************************************
   * Purpose : Method to create warranty product data. 
   *******************************************************************/
   public static Warranty_Product__c createWarrantyProduct(String pCode, String pName, String type, String itemType, String trackType, String UOM, Id parentId){
       CustomSettingsUtilityTest.init();
       System.assertNotEquals(null,pName);
       Warranty_Product__c wp = new Warranty_Product__c();
       wp.name                = pCode;
       wp.Product_Name__c     = pName;
       wp.Type__c             = type;
       wp.Item_Type__c        = itemType;
       wp.Track_Type__c       = trackType;
       wp.Units_of_Measure__c = UOM;
       wp.Parent_Product__c   = parentId;
       return wp;
   }
   
   
    
   /******************************************************************
   * Purpose : Method to create inventory data.
   *******************************************************************/
   public static Inventory__c createInventory(String invName, String serialNumber, String assetType, String type, Id accountId, Id itemId, Id invId){
       CustomSettingsUtilityTest.init();
       System.assertNotEquals(null,assetType);
       Inventory__c  inv = new Inventory__c ();
       inv.Name             = invName;
       inv.Serial_Number__c = serialNumber;
       inv.Asset_Type__c    = assetType;
       inv.Type__c          = type;
       inv.Account__c       = accountId;
       inv.Item__c          = itemId;
       inv.Inventory__c     = invId;
       return inv;
   }
   
   
   /******************************************************************
   * Purpose : Method to create Warranty Registration data.
   *******************************************************************/
   public static Warranty_Registration__c createWarrantyRegistration(String wName, Id accountId, Id invId, String status){
       CustomSettingsUtilityTest.init();
       System.assertNotEquals(null,wName);
       Warranty_Registration__c wr = new Warranty_Registration__c();
       wr.name                    = wName;
       wr.Account__c              = accountId;
       wr.Customer__c             = accountId;
       wr.Inventory__c            = invId;
       wr.Status__c               = status;
       wr.Registration_Date__c    = date.today();             
       return wr;
   }
   
   /******************************************************************
   * Purpose : Method to create Warranty coverages data.
   *******************************************************************/
   public static Warranty_Coverages__c createWarrantyCoverages(Id WRId, Id PDID){
       CustomSettingsUtilityTest.init();
       System.assertNotEquals(null,WRId);
       Warranty_Coverages__c wc = new Warranty_Coverages__c();
       wc.Warranty_Registration__c  = WRId;
       wc.Policy_Definition__c      = PDID;
       wc.Warranty_Start_Date__c    = date.today();
       wc.Warranty_End_Date__c      = date.today();
       return wc;      
   }
   
   /******************************************************************
   * Purpose : Method to create policy definition data.
   *******************************************************************/
   public static Policy_Definition__c createPolicyDefinition(String pdName, Id paymentDefId, Integer Priority){
       CustomSettingsUtilityTest.init();
       System.assertNotEquals(null,paymentDefId);
       Policy_Definition__c pd = new Policy_Definition__c();
       pd.Name                   = pdName;
       pd.Active_From__c         = date.today();
       pd.Type__c                = 'Standard';
       pd.Active_Until__c        = date.today();
       pd.Priority__c            = Priority;
       pd.Status__c              = 'Active';
       pd.Payment_Definition__c  = paymentDefId;
       pd.Months_Covered__c      = 12;      
       return pd;
   }
   
   /******************************************************************
   * Purpose : Method to create Policy Applicability Terms data.
   *******************************************************************/
   public static Policy_Applicability_Term__c createPolicyApplicabilityTerm(Id pdID,String pdName,String applicabilityValue){
       CustomSettingsUtilityTest.init();
       System.assertNotEquals(null,pdID);
       Policy_Applicability_Term__c pat = new Policy_Applicability_Term__c();
       pat.Applicability_Term_Type__c = 'Referred by ID';
       pat.Applicability_SubType__c   = NameSpace+'Warranty_Product__c';
       pat.Policy_Definition__c       =  pdID;
       pat.Applicability_Label__c     =  pdName;
       pat.Applicability_Value__c = applicabilityValue;
       return pat;      
   }
}