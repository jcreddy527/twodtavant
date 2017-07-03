/**********************************************************************
 Name:  genericAuraControllerTest 
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for GenericCrudController
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    sainath 28/09/2016      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class genericAuraControllerTest {

 static testmethod void TestgenericAuraController(){
         // CustomSettingsUtilityTest.init();
      
        
        list<Account> tempAccountRecordsList = TestUtility.createAccountTestRecords();
        if(CrudUtil.isAccountCreateable()){ 
            upsert tempAccountRecordsList[0];
        } 
        
        WOD__c tempCustomSetting=WOD__c.getValues('Default Rate');
        //Rates_Details__c tempRateDetail = TestUtility.createRateDetail();
        //tempRateDetail.Dealer__c = tempAccountRecordsList[0].id;
        //insert tempRateDetail;
        if(tempCustomSetting==null){
            if(CrudUtil.isWODCreateable()){
                tempCustomSetting = new WOD__c();
                //tempCustomSetting.Trigger_Value__c = tempRateDetail.id;
                tempCustomSetting.name = 'Default Rate';
                insert tempCustomSetting;
            }
        }
        
        WOD__c objDefPolicySetting1 = new WOD__c(Name = 'All Payment Configurations',Trigger_Value__c='Labor');
        insert objDefPolicySetting1;
        
        WOD__c objDefPolicySetting2 = new WOD__c(Name = 'Enable changeCustomerName',isTriggered__c=true);
        insert objDefPolicySetting2;
        
        //Insert test Warranty Product
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        TestWarrantyProduct.Item_Type__c = 'Machine';
        TestWarrantyProduct.Type__c = 'Item';
        TestWarrantyProduct.Track_Type__c = 'Serialized';
        if(CrudUtil.isWarrantyProductCreateable()){ 
            insert TestWarrantyProduct;
        }
        //Insert test Warranty Product
        Warranty_Product__c TestWarrantyProduct1 = TestUtility.createWarrantyProduct();
        TestWarrantyProduct1.Item_Type__c = 'Machine';
        TestWarrantyProduct1.Type__c = 'Item';
        TestWarrantyProduct1.Track_Type__c = 'Non-Serialized';
        if(CrudUtil.isWarrantyProductCreateable()){ 
            insert TestWarrantyProduct1;
        }
        
        list<Inventory__c> invList = TestUtility.createInventoryTestRecords();
        invList[0].Account__c=tempAccountRecordsList[0].Id;
        invList[0].Item__c = TestWarrantyProduct.id;
        insert invList[0];
        
        list<Warranty_Registration__c> tempWarrantyRegistrationRecordsList = TestUtility.createWarrantyRegistrationTestRecords();
        tempWarrantyRegistrationRecordsList[0].Account__c = tempAccountRecordsList[0].id;
        tempWarrantyRegistrationRecordsList[0].Inventory__c = invList[0].id;
        If(CrudUtil.isWRCreateable())
            insert tempWarrantyRegistrationRecordsList[0];
        
        
        system.assertNotEquals(null,tempWarrantyRegistrationRecordsList[0]);
    
          
          /***############## TEST 1 : Test for generatePicklistValues #################****/
          /*List<String> PickListValues = genericAuraController.generatePicklistValues('Caused_by__c','account');
          Boolean TestString = false;
          for(String pickLists: PickListValues ){
           TestString  =pickLists.contains('Assembly');
          }*/
          
         
          /***############## TEST 2 : Test for getRelatedInventories #################****/
          List<String> RelatedInventoriesIds = genericAuraController.getRelatedInventories(String.valueOf(invList[0].id),'');
          System.assertNotEquals(null,RelatedInventoriesIds);
          
      
          /***############## TEST 3 : Test for getclaimPrefix #################****/
          String ReturnedResultMeta = genericAuraController.getFieldMetaData('Account','Name');
          System.assertNotEquals(null,ReturnedResultMeta);
          
          genericAuraController.ReadSObjects('select id from Inventory__c');
           
           List<sObject> obj= genericAuraController.findSObjectsBySOQL('select id from Inventory__c');
            genericAuraController.modifyAnysObject( obj[0], 'Name', 'Mamta' );
             //genericAuraController.selectDealerAccount();
            genericAuraController.generateGroups('Test');
          genericAuraController.createSObject(tempAccountRecordsList[0]);
          genericAuraController.upsertSObject(tempAccountRecordsList[0]);
            
    }
    
    
    static testmethod void TestgenericAuraControllerParam(){
        list<Policy_Definition__c> tempPolicyDefinitionRecordsList = TestUtility.createPolicyDefinitionTestRecords();
        If(CrudUtil.isPolicyDefinitionCreatable())
        {
            //tempPolicyDefinitionRecordsList[0].Payment_Definition__c = TestPDlist[0].Id;
            insert tempPolicyDefinitionRecordsList[0];
        }
        genericAuraController.fieldSummary fieldSummary = new genericAuraController.fieldSummary();
         genericAuraController.getFieldsInfo('Account');
        genericAuraController.findSObjectsBySOQL('select id from Inventory__c');
        genericAuraController.findSObjectsBySOSL('FIND \'mamta*\' IN ALL FIELDS RETURNING Account (Id, Name), Contact, Opportunity, Lead');
        genericAuraController.checkSystemAdmin();
        genericAuraController.findPolicyDef();
         list<Account> tempAccountRecordsList = TestUtility.createAccountTestRecords();
        if(CrudUtil.isAccountCreateable()){ 
            upsert tempAccountRecordsList[0];
        } 
        
        genericAuraController.deleteSObject(tempAccountRecordsList);
         
        
    }
    
    static testMethod void unitTest2(){
     test.starttest();
        String ClaimTemplateID;
        List<Claim__c> claimList;
        
        WOD__c  wod = new WOD__c();
        wod.Name = 'Enable MasterRecoveryClaim';
        wod.isTriggered__c = true;
        insert wod;
        
        WOD__c  wod1 = new WOD__c();
        wod1.Name = 'Enable OnPolicyChange';
        wod1.isTriggered__c = false;
        insert wod1;
        
        WOD__c objDefPolicySetting2 = new WOD__c(Name = 'Enable changeCustomerName',isTriggered__c=true);
        insert objDefPolicySetting2;
        
         //Insert test Country
        list<Country__c> TestCountryList = new list<Country__c>();
        TestCountryList.add(new Country__c(Name = 'India',Currency_Code__c = 'INR'));
        TestCountryList.add(new Country__c(Name = 'USA',Currency_Code__c = 'Dollar'));
        TestCountryList.add(new Country__c(Name = 'Japan',Currency_Code__c = 'Yen'));
        insert TestCountryList;
        
         //Create account data
        List<Account> accList = new List<account>();        
        accList = TestUtility.createAccountTestRecords();
        if(CrudUtil.isAccountCreateable()){ 
            accList[0].Country__c = TestCountryList[0].Id;
            accList[0].Warranty_Account_Type__c = 'Dealer';
            insert accList[0];
        } 
        
         Warehouse__c wc = new Warehouse__c();
         wc.Name = 'USA warehouse';        
         insert wc;
         
        //Create warranty product data
        Warranty_Product__c wpParent = TestUtility.createWarrantyProduct('Beetel', 'Beetel', 'Product', '', '','',null);
        insert wpParent;
        Warranty_Product__c  wpModel = TestUtility.createWarrantyProduct('BeetelModel', 'BeetelModel', 'Model', '', '','', wpParent.Id);
        insert wpModel;
        Warranty_Product__c  wpItem = TestUtility.createWarrantyProduct('BeetelItem', 'BeetelItem', 'Item', 'Machine', 'Serialized','Miles', wpParent.Id);
        insert wpItem;
        
         //insert warranty code
        String warrantyCodeRecordTypeId = RecordTypeUtils.getRecordTypeId('Fault_Code',Warranty_Code__c.sObjectType); 
        Warranty_Code__c warrantyCode = TestUtility.createWarrantyCode('TestWarrantyCode',wpItem.Id,warrantyCodeRecordTypeId);
        insert warrantyCode ;
        
        //Create Rate details data 
        Rates_Details__c tempRateDetail = TestUtility.createRateDetail();
        tempRateDetail.Dealer__c = accList[0].Id;
        tempRateDetail.Status__c = 'Active';
        tempRateDetail.Active_From__c = System.today()-6;
        tempRateDetail.Active_Until__c = System.today()+6;
        tempRateDetail.LaborRate__c = 12;
        tempRateDetail.TravelByDistanceRate__c = 12;

        insert tempRateDetail;
        
         list<Inventory__c> invList = TestUtility.createInventoryTestRecords();
         
         invList[0].Item__c = wpItem.Id;
         insert invList;
         
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
         claimList[0].In_Approval_Process__c     = true;
         claimList[0].Rate__c                    = tempRateDetail.Id;
         claimList[0].Account__c                 = accList[0].Id;         
         claimList[0].Claim_Status__c            ='Submitted';
         insert claimList[0];
        // genericAuraController.retrieveSObject(claimList[0]);
        //craeting Supplier Contract Records
        Supplier_Contract__c supplierContract = new Supplier_Contract__c();
        supplierContract.Name = 'Test Suppiler';
        supplierContract.Part_Payment_Condition__c = 'Flat Rate';
        insert supplierContract;
        
        //Insert test Warranty Product
        Warranty_Product__c TestWarrantyProduct1 = TestUtility.createWarrantyProduct();
        TestWarrantyProduct1.Item_Type__c = 'Machine';
        TestWarrantyProduct1.Type__c = 'Item';
        TestWarrantyProduct1.Track_Type__c = 'Non-Serialized';
        if(CrudUtil.isWarrantyProductCreateable()){ 
            insert TestWarrantyProduct1;
        }
         if(TestWarrantyProduct1.id !=null){
         System.assertEquals('Item', TestWarrantyProduct1.Type__c);
        }
        
        Supplier_Recovery_Claim__c SupplyClaim = new Supplier_Recovery_Claim__c();
        SupplyClaim.Supplier_Contract__c = supplierContract.Id;
        SupplyClaim.Warranty_Claim__c = claimList[0].Id;
        insert SupplyClaim;
        
        Removed_Claim_Part__c remPart = new Removed_Claim_Part__c(claim__c = claimList[0].id,Warranty_Product__c=TestWarrantyProduct1.Id,inventory__c = invList[0].Id,is_approved__c=false);
        insert remPart;
        
        list<Supplier_Product__c> supplyProductList = TestutilityRecoveryClaim.createsupplierproductRecords();
        
        Supply_Recovery_Claim_Line_Items__c RecoveryLineItemTest  = new Supply_Recovery_Claim_Line_Items__c();
        RecoveryLineItemTest.Name='abcrec';
        RecoveryLineItemTest.Part_Type__c = 'Removed';
        RecoveryLineItemTest.Is_Part_Return_Required__c = false;
        RecoveryLineItemTest.Part_Price__c = 2;
        RecoveryLineItemTest.Part_Return_Location_Warehouse__c = wc.Id;
        RecoveryLineItemTest.Quantity__c = 10;
        RecoveryLineItemTest.Supplier_Product__c = supplyProductList[0].id;
        RecoveryLineItemTest.Removed_Claim_Part__c =remPart.Id;
        RecoveryLineItemTest.Supplier_Recovery_Claim__c =SupplyClaim.Id;
        RecoveryLineItemTest.Pending_Shipment_Quantity__c = 10;
        RecoveryLineItemTest.Supplier_Recovery_Claim__c =SupplyClaim.Id ;
        RecoveryLineItemTest.Warranty_Product__c = TestWarrantyProduct1.Id;                       
        insert RecoveryLineItemTest;
        
        RecoveryLineItemTest.Is_Part_Return_Required__c = true;
        update RecoveryLineItemTest;
        
        Shipment_Detail__c sh = new Shipment_Detail__c();
        sh.Name = 'a0M28000007saqG';
        sh.Tracking_Number__c ='123';
        sh.Carrier__c = 'UPS';
        sh.Return_Location__c = wc.id;
        sh.isShipped__c = true;
        sh.Shipment_Date__c = system.today();
        insert sh;
               
        Recovery_Claim_Shipment__c rc = new Recovery_Claim_Shipment__c();
        rc.Name = 'Recovery claim shipment';
        rc.Quantity__c = 2;
        rc.Shipment__c = sh.id;
        rc.Supply_Recovery_Claim_Line_Item__c = RecoveryLineItemTest.Id;
        insert rc;
        
        List<Recovery_Claim_Shipment__c> lst = new List<Recovery_Claim_Shipment__c>();
        
        genericAuraController up = new genericAuraController();
       
        genericAuraController.getclaimPrefix();
        //genericAuraController.updatePolicyDefinition(claimList[0]);
        //genericAuraController.recordUnlock(claimList[0].Id,claimList[0]);
        genericAuraController.claimInstalledPartsInventoryIds(claimList[0].Id);
         //genericAuraController.selectDealerAccount();  
         genericAuraController.casualPartNumber(TestWarrantyProduct1.Name);  
       genericAuraController.popClaimType(invList[0].Id); 
              
        test.stopTest();
    
    
    
    } 



 /*   global static string NameSpace = SystemUtils.getNameSpace();  
  static testmethod void TestgenericAuraController(){
         CustomSettingsUtilityTest.init();
      //Insert test Country
        list<Country__c> TestCountryList = new list<Country__c>();
        TestCountryList.add(new Country__c(Name = 'India',Currency_Code__c = 'INR'));
        TestCountryList.add(new Country__c(Name = 'USA',Currency_Code__c = 'Dollar'));
        TestCountryList.add(new Country__c(Name = 'Japan',Currency_Code__c = 'Yen'));
        insert TestCountryList;
        
        list<Account> tempAccountRecordsList = TestUtility.createAccountTestRecords();
        if(CrudUtil.isAccountCreateable()){ 
            tempAccountRecordsList[0].Country__c = TestCountryList[0].Id;
            insert tempAccountRecordsList[0];
        } 
        
        WOD__c tempCustomSetting=WOD__c.getValues('Default Rate');
        Rates_Details__c tempRateDetail = TestUtility.createRateDetail();
        tempRateDetail.Dealer__c = tempAccountRecordsList[0].id;
        insert tempRateDetail;
        if(tempCustomSetting==null){
            if(CrudUtil.isWODCreateable()){
                tempCustomSetting = new WOD__c();
                tempCustomSetting.Trigger_Value__c = tempRateDetail.id;
                tempCustomSetting.name = 'Default Rate';
                insert tempCustomSetting;
            }
        }
        
        WOD__c objDefPolicySetting1 = new WOD__c(Name = 'All Payment Configurations',Trigger_Value__c='Labor');
        insert objDefPolicySetting1;
        
        //Insert test Warranty Product
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        TestWarrantyProduct.Item_Type__c = 'Machine';
        TestWarrantyProduct.Type__c = 'Item';
        TestWarrantyProduct.Track_Type__c = 'Serialized';
        if(CrudUtil.isWarrantyProductCreateable()){ 
            insert TestWarrantyProduct;
        }
        //Insert test Warranty Product
        Warranty_Product__c TestWarrantyProduct1 = TestUtility.createWarrantyProduct();
        TestWarrantyProduct1.Item_Type__c = 'Machine';
        TestWarrantyProduct1.Type__c = 'Item';
        TestWarrantyProduct1.Track_Type__c = 'Non-Serialized';
        if(CrudUtil.isWarrantyProductCreateable()){ 
            insert TestWarrantyProduct1;
        }
        
        list<Inventory__c> invList = TestUtility.createInventoryTestRecords();
        invList[0].Account__c=tempAccountRecordsList[0].Id;
        invList[0].Item__c = TestWarrantyProduct.id;
        insert invList[0];
        
        list<Warranty_Registration__c> tempWarrantyRegistrationRecordsList = TestUtility.createWarrantyRegistrationTestRecords();
        tempWarrantyRegistrationRecordsList[0].Account__c = tempAccountRecordsList[0].id;
        tempWarrantyRegistrationRecordsList[0].Inventory__c = invList[0].id;
        If(CrudUtil.isWRCreateable())
            insert tempWarrantyRegistrationRecordsList[0];
        
        
        system.assertNotEquals(null,tempWarrantyRegistrationRecordsList[0]);
        
        list<Payment_Definitions__c> TestPDlist = TestUtility.createPaymentDefinitionsTestRecords();
        If(CrudUtil.isPaymentDefinitionCreateable())
            insert TestPDlist[0];
        
        Payment_Configuration__c testPC = TestUtility.createPaymentConfiguration();
        testPC.Claim_Field_Name__c = 'Parts';
        If(CrudUtil.isPaymentConfigurationCreateable())
            insert testPC;
                
        Payment_Definition_Items__c testPDI = new Payment_Definition_Items__c(Payment_Definition__c = TestPDlist[0].Id,Payment_Configuration__c = testPC.Id);
        If(CrudUtil.isPDItemsCreateable())
            insert testPDI;
            
        list<Policy_Definition__c> tempPolicyDefinitionRecordsList = TestUtility.createPolicyDefinitionTestRecords();
        If(CrudUtil.isPolicyDefinitionCreatable())
        {
            tempPolicyDefinitionRecordsList[0].Payment_Definition__c = TestPDlist[0].Id;
            insert tempPolicyDefinitionRecordsList[0];
        }
        
        
        Warranty_Product_Pricebook__c  PriceBook = TestUtility.createWarrantyPricebook();
        PriceBook.Warranty_Product__c  = TestWarrantyProduct1.Id;
        insert PriceBook;
                      
        Payment_Modifiers__c payModifierTest = new Payment_Modifiers__c();
        payModifierTest.Part__c = TestWarrantyProduct1.id;
        payModifierTest.Payment_Configuration__c = testPC.id;
        payModifierTest.Payment_Definition__c = TestPDlist[0].id;
        payModifierTest.Priority__c = 1;
        payModifierTest.Type__c = 'Flat';
        payModifierTest.value__c = 20;
        payModifierTest.Active_From__c = system.today();
        payModifierTest.Active_Until__c = system.today();
        payModifierTest.Dealer__c=tempAccountRecordsList[0].id;
        insert payModifierTest;
        
        String RecType = RecordTypeUtils.getRecordTypeId('Serialized_Part',Claim__c.sObjectType);
        String RecTypeCT = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);       
        Claim__c tempClaimObj = new Claim__c(recordtypeId=RecType);
        
        Claim__c tempClaimObj1 = new Claim__c(recordtypeId=RecTypeCT);
        if(Schema.sObjectType.Claim__c.fields.Name.isUpdateable()&&
               Schema.sObjectType.Claim__c.fields.Account__c.isUpdateable()) {
              
                tempClaimObj1.claim_type__c =tempClaimObj.claim_type__c = 'Machine';
                
                tempClaimObj1.Account__c=tempClaimObj.Account__c=tempAccountRecordsList[0].id;
                tempClaimObj1.Inventory__c =tempClaimObj.Inventory__c =invList[0].id;
                tempClaimObj1.Claim_Status__c =tempClaimObj.Claim_Status__c = 'Draft';
                tempClaimObj1.Date_of_Failure__c = tempClaimObj.Date_of_Failure__c = System.today()-4;
                tempClaimObj1.Date_of_Repair__c = tempClaimObj.Date_of_Repair__c = System.today()-2;
                tempClaimObj1.in_approval_process__c =tempClaimObj.in_approval_process__c =false;
                tempClaimObj1.Applicable_Policy__c = tempClaimObj.Applicable_Policy__c =tempPolicyDefinitionRecordsList[0].id;
                tempClaimObj1.Approved_Labor_Cost__c =tempClaimObj.Approved_Labor_Cost__c = 200;
                tempClaimObj1.Warranty_Product__c= tempClaimObj.Warranty_Product__c = TestWarrantyProduct1.id;
                tempClaimObj1.Final_Labor_Cost__c = tempClaimObj.Final_Labor_Cost__c = 200;
                tempClaimObj1.Total_Labor_Cost__c = tempClaimObj.Total_Labor_Cost__c = 200;
            }
        list<Claim__c> clmList = new list<Claim__c>();
        clmList.add(tempClaimObj);
        clmList.add(tempClaimObj1);
        if(CrudUtil.isClaimCreateable()){ 
            insert clmList;
        }
          
         
          String ReturnedResult = genericAuraController.getclaimPrefix();
          System.assertNotEquals(null,ReturnedResult);    
          
         
          String ReturnedResultMeta = genericAuraController.getFieldMetaData(NameSpace+'claim__c',NameSpace+'Caused_by__c');
          System.assertNotEquals(null,ReturnedResultMeta);
          
          
          String ReturnedResultFields = genericAuraController.getFieldsInfo(NameSpace+'claim__c');
          System.assertNotEquals(null,ReturnedResultFields);
          
         
          tempClaimObj.Total_Labor_Cost__c = 100;
          Claim__c  ReturnedClaim = genericAuraController.upsertClaim(tempClaimObj);
           System.assertEquals(100,tempClaimObj.Total_Labor_Cost__c);
           
         
          genericAuraController.updateClaim(clmList[0]);
          Double  Price  = genericAuraController.receiveProductCost('select id from '+NameSpace+'Inventory__c',true);
          System.assertNotEquals(null,Price);
          
         
          List<Warranty_Product_Pricebook__c> WarrantPriceBookList = genericAuraController.receiveProductCostAndPriceBookId('select id from '+NameSpace+'Inventory__c',true);
          
          
         
          List<String> PickListValues = genericAuraController.generatePicklistValues(NameSpace+'Caused_by__c',NameSpace+'claim__c');
          Boolean TestString = false;
          for(String pickLists: PickListValues ){
           TestString  =pickLists.contains('Assembly');
          }
          
           
           
         
          List<String> PickListIds = genericAuraController.getAllInventoryIds(clmList[0].id);
          System.assertNotEquals(null,PickListIds);
          
          
          List<String> RelatedInventoriesIds = genericAuraController.getRelatedInventories(String.valueOf(invList[0].id),'');
          System.assertNotEquals(null,RelatedInventoriesIds);
          
          
          List<Claim_Service_Information__c> ClaimServiceList = new List<Claim_Service_Information__c>();
          Claim_Service_Information__c ClaimService = new Claim_Service_Information__c();
          ClaimService.claim__c = clmList[0].Id;
          ClaimServiceList.add(ClaimService);
          //insert ClaimServiceList;
          
          List<Removed_Claim_Part__c > RemovedClaimList = new List<Removed_Claim_Part__c>();
          Removed_Claim_Part__c remPart = new Removed_Claim_Part__c(claim__c = clmList[0].id,Warranty_Product__c=TestWarrantyProduct1.Id,inventory__c = invList[0].Id,is_approved__c=false);
          RemovedClaimList.add(remPart);
          insert RemovedClaimList;
          
          list<Claim_Part__c> ClaimPartList = TestUtility.createClaimPartList();
          for(Claim_Part__c claimPart: ClaimPartList){
          claimPart.claim__c = clmList[0].id;
          claimPart.Warranty_Product_Pricebook__c = PriceBook.id;
          claimPart.Inventory__c = invList[0].Id;
          }
          insert ClaimPartList;
          
          genericAuraController.InputWrapper inputWrapper = new genericAuraController.InputWrapper();
          inputWrapper.ortId='Test';
          inputWrapper.scId = clmList[0].Id;
          
          List<genericAuraController.inputWrapper> InputWrapperList = new List<genericAuraController.inputWrapper>();
          InputWrapperList.add(inputWrapper);
          
          genericAuraController.ReadSObjects('select id from '+NameSpace+'Inventory__c');
          genericAuraController.UpdateClaimSObjects(clmList);
             List<string> IdsString = new List<string>();
          IdsString.add(clmList[1].Id);
          genericAuraController.findSObjectsBySOQLByAvoiding(clmList[0].Id,'select id from '+NameSpace+'Inventory__c',IdsString,invList[0].Id,'Name',null);
          genericAuraController.savePdf('Test',clmList[0].Id);
          genericAuraController.savePdfFlow(InputWrapperList);
          genericAuraController.generateGroups('Name');
         
          //genericAuraController.updatePolicyDefinition(clmList[0]);
          //genericAuraController.InsertSObjects(clmList);
          genericAuraController.updateRemovedPartSObjects(RemovedClaimList);
          genericAuraController.UpdateSObjects(clmList);
          genericAuraController.UpsertSObjects(clmList);
          genericAuraController.InsertSObjectServiceInfo(ClaimServiceList);
              String jsonInput = '{\n' +'\"'+Namespace+
    'Inspector_Comments__c" :"An appliance",\n' + '\"'+Namespace+
    'claim__c" : "'+clmList[0].id+'",\n' + '\"'+Namespace+
    'Warranty_Product__c" : "'+TestWarrantyProduct1.Id+'",\n' + '\"'+Namespace+
    'Quantity__c" : "2",\n' + '\"'+Namespace+
    'inventory__c" : "'+invList[0].Id+'"\n' + 
    '}';
 String jsonInput1 = '{\n' + '\"'+Namespace+
    'Miscellaneous_Part_Name__c" :"An appliance",\n' + '\"'+Namespace+
    'claim__c" : "'+clmList[0].id+'",\n' + '\"'+Namespace+
    'Warranty_Product_Pricebook__c" : "'+PriceBook.id+'",\n' + '\"'+Namespace+
    'Inventory__c" : "'+invList[0].Id+'",\n' + '\"'+Namespace+
    'Quantity__c" : "2"\n' +
    '}';
    
    system.debug('jsonInput1 '+ jsonInput1 );
          Claim_Part__c records1 = (Claim_Part__c)JSON.deserialize(jsonInput1, Claim_Part__C.class);
          Removed_Claim_Part__c  records2 = (Removed_Claim_Part__c)JSON.deserialize(jsonInput, Removed_Claim_Part__C.class);
          
          insert records1;
          insert records2;
          
          //String str6 = JSON.serialize(records1);
          //String str9 = JSON.serialize(records2);
          String str6 = JSON.serialize(ClaimPartList[0]);
          String str9 = JSON.serialize(RemovedClaimList[0]);
          String jsonInput3 = '{\n' + '\"'+Namespace+
    'Inspector_Comments__c" :"An appliance",\n' +
    '"Id" : "'+records2.id+'",\n' + '\"'+Namespace+
    'Quantity__c" : "2"\n' +
    '}';
 String jsonInput4 = '{\n' + '\"'+Namespace+
    'Miscellaneous_Part_Name__c" :"An appliance",\n' + '\"'+Namespace+
    'claim__c" : "'+clmList[0].id+'",\n' + '\"'+Namespace+
    'Warranty_Product_Pricebook__c" : "'+PriceBook.id+'",\n' + '\"'+Namespace+
    'Inventory__c" : "'+invList[0].Id+'",\n' +
    '"Id" : "'+records1.id+'",\n' + '\"'+Namespace+
    'Quantity__c" : "2"\n' +
    '}';
            Test.startTest();
            genericAuraController.insertRemovedPartForSerializedInventory(jsonInput,'Test');
          genericAuraController.insertInstalledPartAndRemovedPartRecords(jsonInput1,jsonInput);
          //genericAuraController.UpdateSObjectRecords(jsonInput4,jsonInput3);
          //genericAuraController.UpdateSObjectRecords(records1,records2);
          String str = JSON.serialize(invList[0].Id);
          String str1 = JSON.serialize(invList[0].Id);
          String claimStr= String.ValueOf(clmList[0].id);
          String InvStr= String.ValueOf(invList[0].Id);
          String WarStr= String.ValueOf(TestWarrantyProduct1.Id);
      
         
          genericAuraController.DeleteSObjects(clmList);
          //genericAuraController.updatePolicyDefinition(clmList[0]);
          genericAuraController.claimInstalledPartsInventoryIds(clmList[0].Id);
          // genericAuraController.InsertSObjectsForInstalledParts(ClaimPartList[0],remPart,clmList[0].Id);
          
          genericAuraController.InsertSObjectsForRemovedPartFromInstalledPart(RemovedClaimList,invList[0].Id);
          genericAuraController.InsertSObjects(RemovedClaimList);
          genericAuraController.InsertSObjectsForRemovedParts(RemovedClaimList,clmList[0].id,TestWarrantyProduct1.Id,invList[0].Id,'Serialized Part');
         Test.stopTest();
    }*/
  }