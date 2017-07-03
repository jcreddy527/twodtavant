@isTest
global class MasterRecoveryClaimShipmentTriggerTest{
     static testmethod void TestMethod1(){
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
        
        UpdateQuantityOnRecoveryLineItemsTrigCls up = new UpdateQuantityOnRecoveryLineItemsTrigCls();
        up.UpdateQuantityOnRecoveryLineItemsTrigMethod(lst);
 
                      
        test.stopTest();
      }
}