@isTest
global class UpdateQuantityOnRecoveryLnItmsTestClass {


    global static testMethod void testingwithexistingshipmentdelete() {
        CustomSettingsUtilityTest.init();
        Warehouse__c testWareHouse = new Warehouse__c();
        testWareHouse.Name = 'XYZcompany';
        insert testWareHouse;
       list<Supply_Recovery_Claim_Line_Items__c> testSupplyRecoveryLineItems = new list<Supply_Recovery_Claim_Line_Items__c>();
       list<Recovery_Claim_Shipment__c> Shipmentrecordlist = new list<Recovery_Claim_Shipment__c>();
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
        if(TestWarrantyProduct1.id !=null){
         System.assertEquals('Item', TestWarrantyProduct1.Type__c);
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
        testPC.Claim_Field_Name__c = 'Labor';
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
        
               
        Warranty_Coverages__c tempWarrantyCoverageObj = new Warranty_Coverages__c();
        if( Schema.sObjectType.Warranty_Coverages__c.fields.Is_Active__c.isUpdateable() &&
            Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Start_Date__c.isUpdateable() &&
            Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_End_Date__c.isUpdateable())
        {
            tempWarrantyCoverageObj.Warranty_Registration__c=tempWarrantyRegistrationRecordsList[0].id;
            tempWarrantyCoverageObj.Policy_Definition__c=tempPolicyDefinitionRecordsList[0].Id;
            tempWarrantyCoverageObj.Is_Active__c=true;
            tempWarrantyCoverageObj.Warranty_Start_Date__c=(system.today()-1);
            tempWarrantyCoverageObj.Warranty_End_Date__c=(system.today()+1);
           
        }
        if(CrudUtil.isWCCreateable()){
            insert tempWarrantyCoverageObj;
        }
        
        list<Warranty_Rule_Criteria__c> testWarrantyRuleCriteriaList = TestUtility.createWarrantyRuleCriteriaTestRecords();
        if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isUpdateable())
        {
            if(CrudUtil.isWRuleCriteriaCreateable()){
                insert testWarrantyRuleCriteriaList[0];
            }  
        }
        Warranty_Rule__c wrTest = new Warranty_Rule__c(id = testWarrantyRuleCriteriaList[0].Warranty_Rule__c, Enabled__c = true);
        update wrTest;
        
        Warranty_Rule_Association__c tempWarrantyRuleAssociationObj = new Warranty_Rule_Association__c();
        tempWarrantyRuleAssociationObj.Policy_Definition__c=tempPolicyDefinitionRecordsList[0].id;
        tempWarrantyRuleAssociationObj.Warranty_Rule__c=testWarrantyRuleCriteriaList[0].Warranty_Rule__c;
        tempWarrantyRuleAssociationObj.Is_Active__c=true;
        insert tempWarrantyRuleAssociationObj;

              
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
               // tempClaimObj1.Name=tempClaimObj.Name='TempClaim'+1;
                tempClaimObj1.Account__c=tempClaimObj.Account__c=tempAccountRecordsList[0].id;
                tempClaimObj1.Inventory__c =tempClaimObj.Inventory__c =invList[0].id;
                tempClaimObj1.Claim_Status__c = 'Draft';
                tempClaimObj.Claim_Status__c = 'SMR Rejected';
                tempClaimObj1.Date_of_Failure__c = tempClaimObj.Date_of_Failure__c = System.today();
                tempClaimObj1.Date_of_Repair__c = tempClaimObj.Date_of_Repair__c = System.today();
                tempClaimObj1.in_approval_process__c =tempClaimObj.in_approval_process__c =false;
                tempClaimObj1.Applicable_Policy__c = tempClaimObj.Applicable_Policy__c =tempPolicyDefinitionRecordsList[0].id;
                tempClaimObj1.Approved_Labor_Cost__c =tempClaimObj.Approved_Labor_Cost__c = 200;
                tempClaimObj.Warranty_Product__c = TestWarrantyProduct1.id;
                tempClaimObj.Final_Labor_Cost__c = 200;
                tempClaimObj.Total_Labor_Cost__c = 200;
            }
        list<Claim__c> clmList = new list<Claim__c>();
        clmList.add(tempClaimObj);
        //clmList.add(tempClaimObj1);
        if(CrudUtil.isClaimCreateable()){ 
            insert clmList[0];
        }
        /* Warranty_Product__c warrantyProd = Testutility.createWarrantyProduct();
        insert warrantyProd;*/
         list<Supplier_Product__c> supplyProductList = TestutilityRecoveryClaim.createsupplierproductRecords();
         Supplier_Contract__c SupplierContact = new Supplier_Contract__c();
        SupplierContact.Name = 'Test Suppiler';
        SupplierContact.Part_Payment_Condition__c = 'Flat Rate';
        insert SupplierContact;
        Supplier_Recovery_Claim__c SupplyClaim = new Supplier_Recovery_Claim__c();
        SupplyClaim.Supplier_Contract__c = SupplierContact.Id;
        SupplyClaim.Warranty_Claim__c = clmList[0].Id;
        insert SupplyClaim;
        
        Removed_Claim_Part__c remPart = new Removed_Claim_Part__c(claim__c = clmList[0].id,Warranty_Product__c=TestWarrantyProduct1.Id,inventory__c = invList[0].Id,is_approved__c=false);
         insert remPart;
        Shipment_Detail__c shipmentRecord1 = new Shipment_Detail__c();
        Shipment_Detail__c shipmentRecord2 = new Shipment_Detail__c();
        
        system.debug(':::the Id'+testWareHouse.Id);
        Supply_Recovery_Claim_Line_Items__c RecoveryLineItemTest  = new Supply_Recovery_Claim_Line_Items__c();
        RecoveryLineItemTest.Name='abcrec';
        RecoveryLineItemTest.Part_Return_Location_Warehouse__c = testWareHouse.Id;
        RecoveryLineItemTest.Part_Type__c = 'Removed';
        RecoveryLineItemTest.Is_Part_Return_Required__c = false;
        RecoveryLineItemTest.Part_Price__c = 2;
        RecoveryLineItemTest.Supplier_Product__c = supplyProductList[0].id;
        //RecoveryLineItemTest.Quantity__c = 10;
        RecoveryLineItemTest.Removed_Claim_Part__c =remPart.Id;
         RecoveryLineItemTest.Pending_Shipment_Quantity__c =5;
        //RecoveryLineItemTest.Pending_Shipment_Quantity__c = 10;
        RecoveryLineItemTest.Supplier_Recovery_Claim__c =SupplyClaim.Id ;
        RecoveryLineItemTest.Warranty_Product__c = TestWarrantyProduct1.Id;
        testSupplyRecoveryLineItems.add(RecoveryLineItemTest);
        
        
        
        //Creating the test shioment record
        Test.startTest();
        insert testSupplyRecoveryLineItems;
        System.debug('::::The LineItem Id'+testSupplyRecoveryLineItems[0].id);
        String InsertedLineItem = [select id from Supply_Recovery_Claim_Line_Items__c where Part_Return_Location_Warehouse__r.Name = 'XYZcompany' ][0].id;
        
        system.debug(':::inserted lineitem'+InsertedLineItem);
        
        //Create Warehouse
        Warehouse__c war = new Warehouse__c(Name='Dummy Warehouse');
        insert war;
        
        //Create Shipemnt
        Shipment_Detail__c shipment = new Shipment_Detail__c();
        shipment.Name = 'Dummy Shipment';
        shipment.Return_Location__c = war.id;
        insert shipment;
        
        Recovery_Claim_Shipment__c testRecoveryShipmentRecord = new Recovery_Claim_Shipment__c();
        testRecoveryShipmentRecord.Name = 'XYZrec';
        system.debug(':::id'+testSupplyRecoveryLineItems[0].id);
        //testRecoveryShipmentRecord.Supply_Recovery_Claim_Line_Item__c = InsertedLineItem;
        testRecoveryShipmentRecord.Supply_Recovery_Claim_Line_Item__c = RecoveryLineItemTest.Id;
        testRecoveryShipmentRecord.Shipment__c = shipment.id;
        testRecoveryShipmentRecord.Quantity__c = 5;
        
        insert testRecoveryShipmentRecord;
        
        Decimal PendingQuantity = [select id,Pending_Shipment_Quantity__c from Supply_Recovery_Claim_Line_Items__c where id =:InsertedLineItem][0].Pending_Shipment_Quantity__c;
        system.debug('::::THe Pending quanity after creating the shipment record'+PendingQuantity);
        String LineItemId = [select id,Supply_Recovery_Claim_Line_Item__c from Recovery_Claim_Shipment__c where Supply_Recovery_Claim_Line_Item__c =: testSupplyRecoveryLineItems[0].id][0].Supply_Recovery_Claim_Line_Item__c;
        system.debug(':::::Shipmnet record'+testRecoveryShipmentRecord);
        
        
        //Test to check if the pending shipment quantity in recovery line items back to original value after deletion of the shipment Record
        Shipmentrecordlist.add(testRecoveryShipmentRecord);
        
        delete Shipmentrecordlist;
        //Pending shipment after deletion
        Decimal PendingQuantityDeletion = [select id,Pending_Shipment_Quantity__c from Supply_Recovery_Claim_Line_Items__c where id =:InsertedLineItem][0].Pending_Shipment_Quantity__c;
        system.debug('::::The Pending quanity after deleting the shipment record'+PendingQuantityDeletion);
        Test.stopTest();
        
        
    }

}