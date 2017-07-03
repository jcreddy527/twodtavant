@isTest
private class RecoveryClaimpageCtrlTest {
    static claim__c testclaim;
    static Removed_Claim_Part__c testremovedpart;
    static Supply_Recovery_Claim_Line_Items__c testRecoveryClaimLineItems;
   // static Supplier_Contract__c testSupplierContract;
    static Supplier_Contract_Item__c testSupplierContractLineItem;


    private static testMethod void TestingRecoveryClaimCreationPage(){
       CustomSettingsUtilityTest.init();
       Test.startTest();  
     //creating and inserting the warranty product
        Warranty_Product__c testwarrantyProductrecords = TestutilityRecoveryClaim.createWarrantyProductRecords();
        
     
            
    //creating and inserting the removed part    
        list<Removed_Claim_Part__c> testRemovedClaimPartsRecords = TestutilityRecoveryClaim.createremovedclaimpartsRecords();
        
  
        
   //creating and inserting the supplier product 
        list<Supplier_Product__c> testSupplierProductRecords = TestutilityRecoveryClaim.createsupplierproductRecords();
        
        
    //Creating and inserting The Supplier Contract
        Supplier_Contract__c testSupplierContract = TestutilityRecoveryClaim.createsuppliercontractRecords();
       
        
   //Creating and inserting the supplier Contract Lineitems 
        
       list<Supplier_Contract_Item__c> testSupplierContractLineitems =  TestutilityRecoveryClaim.createcontractlineitems();       
        
    //creating the claim 
    
    
        Rates_Details__c  rateDetail = TestUtility.createRateDetail();
        insert rateDetail;
        
        Service_Campaign__c serviceCampaign = new Service_Campaign__c();
        serviceCampaign.Name = 'Test Service';
        insert serviceCampaign;
        
        Campaign_Members__c campaign = new Campaign_Members__c();
        campaign.Service_Campaign__c = serviceCampaign.Id;
        insert campaign;
        
        List<claim__c> claimrecords =  TestUtility.createClaimTestRecords();
        for(claim__c claim : claimrecords ){
          claim.Rate__c = rateDetail.Id;
          claim.Date_of_Repair__c = system.today();
          claim.In_Approval_Process__c = false;
          claim.Campaign_Members__c = campaign.Id;
          claim.Claim_Status__c = 'Draft';
        
        }
        //insert claimrecords;
        
        
        
        
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
        
        WOD__c objDefPolicySetting2 = new WOD__c(Name = 'Enable PDI Group Logic',isTriggered__c=true);
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
        
           list<Account> tempAccountRecordsList1 = TestUtility.createAccountTestRecords();
        
        Rates_Details__c tempRateDetail1 = TestUtility.createRateDetail();
        tempRateDetail1.Dealer__c = tempAccountRecordsList1[0].id;
        insert tempRateDetail1;
        
        
         WOD__c tempCustomSetting1 =WOD__c.getValues('Default Rate');
           if(tempCustomSetting==null){
            if(CrudUtil.isWODCreateable()){
                tempCustomSetting = new WOD__c();
                tempCustomSetting.Trigger_Value__c = tempRateDetail1.id;
                tempCustomSetting.name = 'Default Rate';
                insert tempCustomSetting1;
            }
        }
   
    //Refering the Claim page 
        Removed_Claim_Part__c testremovedpart1 = new Removed_Claim_Part__c();
            testremovedpart1.Name = 'TestPartRem';
            testremovedpart1.Claim__c = clmList[0].id;
            testremovedpart1.Warranty_Product__c = testwarrantyProductrecords.id;
            testremovedpart1.Quantity__c = 10;
            testremovedpart1.Inventory__c = invList[0].id;
           
        insert testremovedpart1;
        clmList[0].Causal_Part_Number__c = testwarrantyProductrecords.id;
        update clmList[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(clmList[0]);
        RecoveryClaimpageCtrl controller = new RecoveryClaimpageCtrl(sc);
        
        PageReference pageRef = Page.RecoveryClaimPage; // Add your VF page Name here
    //    pageRef.getParameters().put('id', String.valueOf(claimrecord.Id));
        pageRef.getParameters().put('id',String.valueOf(clmList[0].Id));
        Test.setCurrentPage(pageRef);
   
          controller.getRemovedPartdetails();
          controller.ShowRemovedPartSection = true;
          controller.SearchContractForParts();
          controller.ShowCreatedClaim();
          controller.Goback();
 
     //Displaying the Whole date of objects related to the Recovery cLaim Page Functionality
  
    system.debug('::Warranty Prodct'+testwarrantyProductrecords);
    
    system.debug('::removed ClaimPart'+testRemovedClaimPartsRecords);
    
    system.debug('::supplier product'+testSupplierProductRecords);
    
    system.debug('::supplier Contract'+testSupplierContract);
    
    system.debug('::Contract Line Items'+testSupplierContractLineitems);   
    Test.stopTest();
        
    }
    
      
      
 
    
    

}