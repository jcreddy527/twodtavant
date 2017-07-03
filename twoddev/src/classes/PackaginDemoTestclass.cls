/**********************************************************************
 Name:  PackaginDemoTestclass
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for PackaginDemoTest
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP           
***********************************************************************/
@isTest
private class PackaginDemoTestclass{

 private static List<account> accList;
    private static Warranty_Product__c wpParent ;
    private static Warranty_Product__c wpModel;
    private static Warranty_Product__c wpItem;
    private static Warranty_Product__c wpItem1;
    private static Warranty_Product__c wpItem2;
    private static Warranty_Product__c wpItem3;
    private static Warranty_Code__c warrantyCode;
    private static Warranty_Code__c warrantyCode1;
    private static Warranty_Code__c warrantyCode2;
    private static Warranty_Code__c warrantyCode3;
    private static FaultCode_Mapper__c faultMapperCode;
    private static List<Payment_Definitions__c> paymentDefList;
    private static Policy_Definition__c pd;
    private static List<Claim__c> claimList;
    private static List<Claim__c> fieldModificationClaimList;
    private static String FieldModificationId ;
    private static String ClaimTemplateID;
    private static String warrantyCodeRecordTypeId;
    private static String warrantyCodeRecordTypeId1;
    private static Service_Campaign__c serviceCampaign;
    private static Inventory__c  invParent;
    private static Inventory__c  invParent1;
    private static Inventory__c  invParent2;
    private static Campaign_Members__c campaignMembers;
    private static Rates_Details__c tempRateDetail;
    private static WOD__c defaultRateWod;
    private static List<WOD__c> claimFields;
    private static List<Claim_Part__c> claimPartsList;
    private static List<Claim_Part__c> FieldModificationclaimPartsList;
    private static List<Claim_Service_Information__c> claimserviceInfoList;
    private static List<Claim_Service_Information__c> claimserviceInfoList1;
    private static WOD__c tempCustomSetting;
    private static WOD__c tempCustomSettingPrice;
    private static Warranty_Product_Pricebook__c warrantyPrice;
  static testmethod void TestPackaginDemoTest(){
                CustomSettingsUtilityTest.init();
           
                Test.startTest();  
             //creating and inserting the warranty product
                Warranty_Product__c testwarrantyProductrecords = TestutilityRecoveryClaim.createWarrantyProductRecords();
                
             
                    
            /*creating and inserting the removed part    
                list<Removed_Claim_Part__c> testRemovedClaimPartsRecords = TestutilityRecoveryClaim.createremovedclaimpartsRecords();
                insert testRemovedClaimPartsRecords ;
          
                
           //creating and inserting the supplier product 
                list<Supplier_Product__c> testSupplierProductRecords = TestutilityRecoveryClaim.createsupplierproductRecords();
                 insert testSupplierProductRecords ;
                
            //Creating and inserting The Supplier Contract
                Supplier_Contract__c testSupplierContract = TestutilityRecoveryClaim.createsuppliercontractRecords();
               insert testSupplierContract ;
                
           //Creating and inserting the supplier Contract Lineitems 
                
               list<Supplier_Contract_Item__c> testSupplierContractLineitems =  TestutilityRecoveryClaim.createcontractlineitems();       
                insert testSupplierContractLineitems ;
                
            list<Supplier_Contract_Item__c> testsuppliercontractrecords = TestutilityRecoveryClaim.createcontractlineitems();
                 insert testsuppliercontractrecords;
         */
            //creating the claim 
                //claim__c claimrecord =  TestutilityRecoveryClaim.createClaimTestRecords();
             
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
        
        //Insert warranty product
        //Create warranty product data
        wpParent = TestUtility.createWarrantyProduct('Beetel', 'Beetel', 'Product', '', '','',null);
        insert wpParent;
        wpModel = TestUtility.createWarrantyProduct('BeetelModel', 'BeetelModel', 'Model', '', '','', wpParent.Id);
        insert wpModel;
        wpItem = TestUtility.createWarrantyProduct('BeetelItem', 'BeetelItem', 'Item', 'Machine', 'Serialized','Miles', wpParent.Id);
        insert wpItem;
        wpItem1 = TestUtility.createWarrantyProduct('BeetelItem1', 'BeetelItem1', 'Item', 'Machine', 'Non-Serialized','Miles', wpParent.Id);
        insert wpItem1;
        wpItem2 = TestUtility.createWarrantyProduct('BeetelItem2', 'BeetelItem2', 'Item', 'Machine', 'Non-Serialized','Miles', wpParent.Id);
        insert wpItem2;
        wpItem3 = TestUtility.createWarrantyProduct('BeetelItem3', 'BeetelItem3', 'Item', 'Machine', 'Non-Serialized','Miles', wpParent.Id);
        insert wpItem3;
        
        //insert warrantyPricebook
        warrantyPrice = TestUtility.createWarrantyPricebook();
        warrantyPrice.Name = 'Test PriceBook';
        warrantyPrice.Warranty_Product__c =wpItem.Id;
        warrantyPrice.Country__c =TestCountryList[1].Id;
        insert warrantyPrice;
        if(warrantyPrice.Id != null){
         System.assertEquals('Test PriceBook',warrantyPrice.Name);
         }
        
        //insert warranty code
        warrantyCodeRecordTypeId = RecordTypeUtils.getRecordTypeId('Fault_Code',Warranty_Code__c.sObjectType); 
        warrantyCode = TestUtility.createWarrantyCode('TestWarrantyCode',wpItem.Id,warrantyCodeRecordTypeId);
        insert warrantyCode ;
        
        //insert fault code mappers
        faultMapperCode = TestUtility.createFaultCodeMapper('TestFaultCode',warrantyCode.Id,wpItem.Id);
        insert faultMapperCode ;
        
        //Insert payment definitions
        paymentDefList = TestUtility.createPaymentDefinitionsTestRecords();
        paymentDefList[0].Status__c = 'Active';
        insert paymentDefList[0];
        
        //Insert policy Definition data        
        pd = TestUtility.createPolicyDefinition('beetelpolicy', paymentDefList[0].Id,100);
        insert pd;
        
        tempCustomSetting=WOD__c.getValues('Default Rate');
       //Create Rate details data 
        tempRateDetail = TestUtility.createRateDetail();
        tempRateDetail.Dealer__c = accList[0].Id;
        tempRateDetail.Status__c = 'Active';
        tempRateDetail.Active_From__c = System.today()-6;
        tempRateDetail.Active_Until__c = System.today()+6;
        tempRateDetail.LaborRate__c = 12;
        tempRateDetail.TravelByDistanceRate__c = 12;

        insert tempRateDetail;
        if(tempCustomSetting==null){
            if(CrudUtil.isWODCreateable()){
                tempCustomSetting = new WOD__c();
                tempCustomSetting.Trigger_Value__c = tempRateDetail.id;
                tempCustomSetting.name = 'Default Rate';
                insert tempCustomSetting;
            }
        }
        
        if(tempCustomSettingPrice==null){           
                tempCustomSettingPrice = new WOD__c();
                tempCustomSettingPrice.Trigger_Value__c = warrantyPrice.id;
                tempCustomSettingPrice.name = 'Default Price';
                insert tempCustomSettingPrice;
        } 
        
        
        //get the claim record types
        FieldModificationId = RecordTypeUtils.getRecordTypeId('Field_Modification',Claim__c.sObjectType); 
        ClaimTemplateID = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);
        
        //Insert calimTemplate records
         claimList = TestUtility.createClaimTestRecords();
         claimList[0].RecordTypeId               = ClaimTemplateID;
         claimList[0].Causal_Part_Number__c      = wpItem.Id;
         claimList[0].Fault_Code__c              = warrantyCode.Id;
         claimList[0].Fault_found__c             = 'Alignment';
         claimList[0].Caused_by__c               ='Incorrect Setup';
         claimList[0].Total_Labor_Cost__c        = 16.00;
         claimList[0].Claim_Status__c            = 'Draft';
         claimList[0].Date_of_Failure__c         = System.today()-6;
         claimList[0].Date_of_Repair__c          = System.today()-2;
         claimList[0].In_Approval_Process__c     = false;
         claimList[0].Rate__c                    = tempRateDetail.Id;
         claimList[0].Account__c                 = accList[0].Id;
         //claimList[0].Is_Eligible_for_Appeal__c  = true;
         claimList[0].Claim_Status__c            ='Submitted';
         insert claimList[0]; 
         if(claimList[0].Id != null){
         System.assertEquals('Alignment',claimList[0].Fault_found__c);
         }
                
        Removed_Claim_Part__c testremovedpart = new Removed_Claim_Part__c();
        testremovedpart.Name = 'TestPartRem';
        testremovedpart.Claim__c = claimList[0].Id;
        testremovedpart.Warranty_Product__c = wpItem.id;
        testremovedpart.Quantity__c = 10;
        
        insert testremovedpart;
        
        //supplier product
        Supplier_Product__c testsupplierProduct = new Supplier_Product__c();
        testsupplierProduct.Name = 'BeetelItem';
        testsupplierProduct.Product__c = wpItem.id;
        //testsupplierProduct.Supplier_Account__c = '001j0000007HE1L';
        testsupplierProduct.Supplier_Account__c = accList[0].id;
        testsupplierProduct.Manufacuture_Date_del__c = System.today();
        insert testsupplierProduct;
    
        //supplier product 2
        Supplier_Product__c testsupplierProduct2 = new Supplier_Product__c();
        testsupplierProduct2.Name = 'BeetelItem';
        testsupplierProduct2.Product__c = wpItem.id;
        //testsupplierProduct.Supplier_Account__c = '001j0000007HE1L';
        testsupplierProduct2.Supplier_Account__c = accList[0].id;
        testsupplierProduct2.OEM_Purchase_Date_del__c = System.today();
        insert testsupplierProduct2;
    
        //supplier contract
        Supplier_Contract__c testSupplierContract = new Supplier_Contract__c();
        testSupplierContract.Name = 'TestSupplierContract';
        testSupplierContract.Is_Collateral_Applicable__c = True;
        testSupplierContract.Supplier_Account__c = accList[0].id;
        testSupplierContract.Valid_From__c = System.today()-10;
        testSupplierContract.Valid_To__c = System.today()+10;
        testSupplierContract.Months_Covered__c = 24;
        testSupplierContract.Validity_Date_Type__c = 'Manufacturing Date';
        insert testSupplierContract; 
        
        //supplier contract 2
        Supplier_Contract__c testSupplierContract2 = new Supplier_Contract__c();
        testSupplierContract2.Name = 'TestSupplierContract2';
        testSupplierContract2.Is_Collateral_Applicable__c = True;
        testSupplierContract2.Supplier_Account__c = accList[0].id;
        testSupplierContract2.Valid_From__c = System.today()-10;
        testSupplierContract2.Valid_To__c = System.today()+10;
        testSupplierContract2.Months_Covered__c = 24;
        testSupplierContract2.Validity_Date_Type__c = 'Purchase Date';
        insert testSupplierContract2;       
        
        //supplier contract item
        Supplier_Contract_Item__c testContractlineitem2 = new Supplier_Contract_Item__c();
        testContractlineitem2.Name = 'TestSupplierContractLineItems';
        testContractlineitem2.Supplier_Contract__c = testSupplierContract.id;
        testContractlineitem2.Supplier_Product__c = testsupplierProduct.id;
        insert testContractlineitem2;
        
        //supplier contract item 2
        Supplier_Contract_Item__c testContractlineitem = new Supplier_Contract_Item__c();
        testContractlineitem.Name = 'TestSupplierContractLineItems';
        testContractlineitem.Supplier_Contract__c = testSupplierContract2.id;
        testContractlineitem.Supplier_Product__c = testsupplierProduct2.id;
        insert testContractlineitem;
           
        //Refering the Claim page 
        /*Removed_Claim_Part__c testremovedpart1 = new Removed_Claim_Part__c();
            testremovedpart1.Name = 'TestPartRem';
            testremovedpart1.Claim__c = claimrecord.id;
            testremovedpart1.Warranty_Product__c = testwarrantyProductrecords.id;
            testremovedpart1.Quantity__c = 10;
           
        insert testremovedpart1;*/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(claimList[0]);
        //RecoveryClaimpageCtrl controller = new RecoveryClaimpageCtrl(sc);
            
        PackaginDemoTest PackaginDemoTest1 = new PackaginDemoTest(sc);
        //TEST 1 : Test for getCausalPartdetails
        PackaginDemoTest1.getCausalPartdetails();
        
        //TEST 2 : Test for getRemovedPartdetails
        PackaginDemoTest1.getRemovedPartdetails();
        
        //TEST 3 : Test for SearchContractForParts
        PackaginDemoTest1.SearchContractForParts();
        
        //TEST 4 : Test for ShowCreatedClaim
        PackaginDemoTest.WarrantyProductWrapperClass temp = new PackaginDemoTest.WarrantyProductWrapperClass();
        list<PackaginDemoTest.WarrantyProductWrapperClass> wrapperList = new list<PackaginDemoTest.WarrantyProductWrapperClass>();
        temp.WarrantyProductName = 'wp';
        temp.ContractName = 'testSupplierContract2';
        temp.IsPartReturnRequired = false;
        temp.SupplierAccountName = accList[0].Id;
        temp.SupplierProductId = testsupplierProduct2.id;
        temp.SupplierProductName = 'test';
        temp.WarrantyProductId = wpItem.id;
        temp.PartType ='Causal';
        temp.isSelected = true;
        temp.IsCollateralApplicable = true;
        wrapperList.add(temp);
        //list<PackaginDemoTest1.ContractInfo> mainList = new list<PackaginDemoTest.WarrantyProductWrapperClass>();
        PackaginDemoTest1.ContractInfo = new list<PackaginDemoTest.WarrantyProductWrapperClass>();
        PackaginDemoTest1.ContractInfo = wrapperList;
        //mainList.equals(wrapperList);
        //insert PackaginDemoTest1.ContractInfo[0];
        /*for(PackaginDemoTest.WarrantyProductWrapperClass temp : PackaginDemoTest1.ContractInfo ){
            
            temp.isSelected = true;
        }
        */
        PackaginDemoTest1.mapObj = new Map<String,List<PackaginDemoTest.WarrantyProductWrapperClass>>();
        PackaginDemoTest1.mapObj.put('BeetelItem',PackaginDemoTest1.ContractInfo);
        PackaginDemoTest1.ShowCreatedClaim();
            
  }



}