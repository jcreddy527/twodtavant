/********************************************************************************
 Name:  InventoryChangeStockToRetailTestClass
 Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: 
This class contains unit tests for validating the behaviour of
InventoryChangesStocktoRetailTestClass.
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          10/19/2016     INITIAL DEVELOPMENT            
**********************************************************************************/
@isTest(seeAllData = false)
private class InventoryChangeStockToRetailTest{
    
    //Varibale declaration
    private static List<account> accList;
    private static Payment_Definitions__c paymentDef;
    private static Payment_Definitions__c paymentDef1;
    private static Warranty_Product__c wpParent ;
    private static Warranty_Product__c wpModel;
    private static Warranty_Product__c wpItem;
    private static Policy_Definition__c pd;
    private static Policy_Definition__c pd1;
    private static Policy_Applicability_Term__c pat;
    private static Policy_Applicability_Term__c pat1;
    private static Inventory__c  invParent;
    private static Inventory__c  invParent1;
    private static Inventory__c  invImplements;
    private static Inventory__c  invImplements1;
    private static Warranty_Registration__c wr;
    private static Warranty_Coverages__c wc;
    private static WOD__c wod;
    
    //method to prepare test data
    private static void init(){
        
        //inseting custom settings data
        CustomSettingsUtilityTest.init();
        //Insert test Country
        list<Country__c> TestCountryList = new list<Country__c>();
        TestCountryList.add(new Country__c(Name = 'India',Currency_Code__c = 'INR'));
        TestCountryList.add(new Country__c(Name = 'USA',Currency_Code__c = 'Dollar'));
        TestCountryList.add(new Country__c(Name = 'Japan',Currency_Code__c = 'Yen'));
        insert TestCountryList;
        
        //Create account data
        accList = new List<account>();        
        accList = TestUtility.createAccountTestRecords();
        if(CrudUtil.isAccountCreateable()){ 
            accList[0].Country__c = TestCountryList[0].Id;
            insert accList[0];
        } 
        
        //Create Payment definition data
        paymentDef = new Payment_Definitions__c();
        paymentDef.Name = 'TestTavantPaymentDef';
        paymentDef.Status__c = 'Active';
        insert paymentDef ;
        
        paymentDef1 = new Payment_Definitions__c();
        paymentDef1.Name = 'TestTavantPaymentDef12';
        paymentDef1.Status__c = 'Active';
        insert paymentDef1 ;
        
        //Create warranty product data
        wpParent = TestUtility.createWarrantyProduct('Beetel', 'Beetel', 'Product', '', '','',null);
        insert wpParent;
        wpModel = TestUtility.createWarrantyProduct('BeetelModel', 'BeetelModel', 'Model', '', '','', wpParent.Id);
        insert wpModel;
        wpItem = TestUtility.createWarrantyProduct('BeetelItem', 'BeetelItem', 'Item', 'Machine', 'Serialized','Miles', wpParent.Id);
        insert wpItem;
        
        //Create policy Definition data
        pd = TestUtility.createPolicyDefinition('beetelpolicy', paymentDef.Id,100);
        insert pd;
        
        pd1 = TestUtility.createPolicyDefinition('beetelpolicy12', paymentDef1.Id,150);
        pd1.Is_Policy_Optional__c = true;
        insert pd1;
        
        //Create payment Applicablility Items data
        pat  = TestUtility.createPolicyApplicabilityTerm(pd.Id,'beetelpolicy',wpItem.Id);
        insert pat;
        pat1  = TestUtility.createPolicyApplicabilityTerm(pd1.Id,'beetelpolicy',wpItem.Id);
        insert pat1;
        
        //Create Inventory data 
        invParent = TestUtility.createInventory('Beetel','Beetel123','Warrantable','Stock',accList[0].Id, wpItem.Id,null);
        insert invParent;
        invParent1 = TestUtility.createInventory('Beetel','Beetel1234','Warrantable','Stock',accList[0].Id, wpItem.Id,null);
        insert invParent1;
        invImplements = TestUtility.createInventory('Beetel','Beetel12345','Warrantable','Stock',accList[0].Id, wpItem.Id,invParent.Id);
        insert invImplements ;
        invImplements1 = TestUtility.createInventory('Beetel','Beetel12346','Warrantable','Stock',accList[0].Id, wpItem.Id,invParent1.Id);
        insert invImplements1 ;
        
        //Create warranty registration data
        wr = TestUtility.createWarrantyRegistration('TestWarranty',accList[0].Id, invParent.Id ,'Registered');
        insert wr;
        
        //Create warrantycoverages data
        wc = TestUtility.createWarrantyCoverages(wr.Id, pd.Id);
        insert wc;
        
            
        
    }
    
    //Method to validate InventoryChangeStockToRetail class.
    static testMethod void inventoryChangeTest(){
        init();
        
        system.assertNotEquals(invParent,null);
        //Insert custom settings dtaa
        wod = new WOD__c();
        wod.Name = 'InvBatchSize';
        wod.Trigger_Value__c = '5';
        insert wod;
        
        Test.startTest();
        invParent.Type__c = 'Retail';
        invParent.Install_Date__c = date.today();
        invParent.Customer__c = accList[0].Id;
        update invParent;
        Test.stopTest();
    }
    
    //Method to create exception scenarios for InventoryChangeStockToRetail class.
    static testMethod void inventoryChangeTest1(){
        init();
        
        //Insert custom settings dtaa
        wod = new WOD__c();
        wod.Name = 'InvBatchSize';
        wod.Trigger_Value__c = '5';
        insert wod;
        
        invParent.Type__c = 'Stock';              
        update invParent;
        
        //delete one policy
        delete pd1;
        
        Test.startTest();
        invParent.Type__c = 'Retail';       
        invParent.Customer__c = accList[0].Id;
        update invParent;
        Test.stopTest();
    }
    
    //Method to create exception scenarios for InventoryChangeStockToRetail class.
    static testMethod void inventoryChangeTest2(){
        init();       

        Test.startTest();
        invParent.Type__c = 'Retail';
        invParent.Install_Date__c = date.today();
        invParent.Customer__c = accList[0].Id;
        update invParent;
        Test.stopTest();
    }    
    
}