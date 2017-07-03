/**********************************************************************
 Name:  AllClaimServiceTest 
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for FindClaimPolicyService,ClaimTotalAmountService,
ClaimAmountModifierService,RemovedClaimPartTriggerHandler,
UpdateClaimPartsPendingService,ClaimTotalApprovedAmountLogicService,
ServiceCampaignLogicService
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Neethu           07/09/2015      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
private class AllClaimServiceTest {

    static testmethod void testFindClaimPolicyService(){
        
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
        
        WOD__c tempPDIGroupLogic = new WOD__c(Name='Enable PDI Group Logic');
        insert tempPDIGroupLogic;
        
        list<Claim__c> clmList = new list<Claim__c>();
        clmList.add(tempClaimObj);
        //clmList.add(tempClaimObj1);
        if(CrudUtil.isClaimCreateable()){ 
            insert clmList[0];
        }
        
        WOD__c objDefPolicySetting = new WOD__c(Name = 'Default Policy',Trigger_Value__c=string.valueOf(tempPolicyDefinitionRecordsList[0].Id));
        insert objDefPolicySetting;
        
        
        system.debug('tempClaimObj.Applicable_Policy__c is ---->>>'+tempClaimObj.Applicable_Policy__c);
        
        //Insert test Warranty Pricebook
        Warranty_Product_Pricebook__c testPricebook = TestUtility.createWarrantyPricebook();
        testPricebook.Country__c = TestCountryList[0].Id;
        testPricebook.Warranty_Product__c = TestWarrantyProduct1.Id;
        testPricebook.price__c = 20;
        
        if(CrudUtil.isWarrantyPricebookCreateable()){ 
            insert testPricebook;
        } 
        
        WOD__c tempCustomSetting1=WOD__c.getValues('Default Price');
        if(tempCustomSetting1==null){
            if(CrudUtil.isWODCreateable()){
                tempCustomSetting1 = new WOD__c();
                tempCustomSetting1.Trigger_Value__c = testPricebook.id;
                tempCustomSetting1.name = 'Default Price';
                insert tempCustomSetting1;
            }
        }
        
        system.debug('tempClaimObj is ----->>>'+tempClaimObj);
        String CPRecType = RecordTypeUtils.getRecordTypeId('Non_Serialized_Part',Claim_Part__c.sObjectType);
        
      
        list<Claim_Part__c> TestClaimPartList = TestUtility.createClaimPartList();
        for(Claim_Part__c testCP : TestClaimPartList)
        {
            testCP.recordtypeId = CPRecType;
            testCP.Claim__c = clmList[0].Id;
            testCP.Warranty_Product_Pricebook__c=testPricebook.Id;
            testCP.Warranty_Product__c=TestWarrantyProduct1.Id;
            testCP.inventory__c = invList[0].Id;
            testCP.Warranty_Product__c = TestWarrantyProduct1.Id;
        }
        /*TestClaimPartList[1].Claim__c = clmList[1].Id;
        list<Claim_Part__c> TestClaimPart = new list<Claim_Part__c>();
        TestClaimPart.add(TestClaimPartList[0]);
        TestClaimPart.add(TestClaimPartList[1]);*/
        
        Removed_Claim_Part__c remPart = new Removed_Claim_Part__c(claim__c = clmList[0].id,Warranty_Product__c=TestWarrantyProduct1.Id,inventory__c = invList[0].Id,is_approved__c=false);
        //Removed_Claim_Part__c remPartCT = new Removed_Claim_Part__c(claim__c = clmList[1].id,inventory__c = invList[0].Id,is_approved__c=false);
        //list<Removed_Claim_Part__c> remList = new list<Removed_Claim_Part__c>();
        //remList.add(remPart);
        //remList.add(remPartCT);
        insert remPart;
        if(CrudUtil.isClaimPartCreateable()){ 
            //insert TestClaimPartList[0];
        }
        
        update clmList[0];

        UpdateClaimPartsPendingService.ClaimPartPendingWrapper wrpTest = new UpdateClaimPartsPendingService.ClaimPartPendingWrapper();
        wrpTest.isChanged=true;wrpTest.targetId=TestClaimPartList[0].id;
        UpdateClaimPartsPendingService.updatePendingParts(new list<UpdateClaimPartsPendingService.ClaimPartPendingWrapper>{wrpTest});
        
        
       /* ClaimAllAmountModifierService.InputWrapper wrp= new ClaimAllAmountModifierService.InputWrapper();
        wrp.warrantyProductId=TestWarrantyProduct1.id;
        wrp.ApplicablePaymentDefinition=TestPDlist[0].id;
        wrp.claim =clmList[0];
        list<ClaimAllAmountModifierService.InputWrapper> wrpList = new list<ClaimAllAmountModifierService.InputWrapper>{wrp};
        ClaimAllAmountModifierService.CalculateFinalCost(wrpList);*/
        
        
        
        tempWarrantyRegistrationRecordsList[0].Status__c = System.Label.Registered;
        update tempWarrantyRegistrationRecordsList[0];
        try
        {
        delete tempWarrantyRegistrationRecordsList[0];
        }catch(exception ex)
        { system.debug('ex is--->>'+ex);}
        
        
        Claim__c objClm = [Select Id,Applicable_Policy__c,Applicable_Payment_Definition__c,Total_Labor_Cost__c,Final_Labor_Cost__c,Approved_Labor_Cost__c,account__c,Warranty_Product__c,Date_of_Repair__c FROM Claim__c where id=:clmList[0].Id];
        system.debug('Applicable_Payment_Definition__c----------->'+objClm.Applicable_Policy__c+'---------------'+objClm.Applicable_Payment_Definition__c);
        system.debug(tempPolicyDefinitionRecordsList[0].id+'---'+tempPolicyDefinitionRecordsList[0].Payment_Definition__c);
        
        
        list<ClaimTotalApprovedAmountLogicService.InputWrapper> TestInputWrapperList = new list<ClaimTotalApprovedAmountLogicService.InputWrapper>();
        ClaimTotalApprovedAmountLogicService.InputWrapper wrpInp = new ClaimTotalApprovedAmountLogicService.InputWrapper();
        wrpInp.ApplicablePaymentDefinition = TestPDlist[0].id;
        wrpInp.claim = objClm;
        TestInputWrapperList.add(wrpInp);
        ClaimTotalApprovedAmountLogicService.CalculateTotalClaimCost(TestInputWrapperList);
        
        list<ClaimAllAmountModifierService.InputWrapper> TestAmtInputWrapperList = new list<ClaimAllAmountModifierService.InputWrapper>();
        ClaimAllAmountModifierService.InputWrapper wrpAmtInp = new ClaimAllAmountModifierService.InputWrapper();
        wrpAmtInp.ApplicablePaymentDefinition = TestPDlist[0].id;
        wrpAmtInp.claim = objClm;
        wrpAmtInp.warrantyProductId = TestWarrantyProduct1.id;
        TestAmtInputWrapperList.add(wrpAmtInp);
        ClaimAllAmountModifierService.CalculateFinalCost(TestAmtInputWrapperList);
        
        list<Claim__c> ClaimLst = new list<Claim__c>{clmList[0]};
        FindClaimPolicyService.findClaimPolicy(ClaimLst);

        delete remPart;

    }         
}