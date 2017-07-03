/**********************************************************************
 Name:  ClaimPartAmountModifierTest 
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for ClaimPartAmountModifierService
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Neethu           14/09/2015      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class ClaimPartAmountModifierTest {


    static testmethod void testClaimPartModifier(){
        
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
        
        Group__c newGroup = new Group__c();
        newGroup.Object_Name__c = 'Warranty_Product__c';
        newGroup.Name__c = 'Breakwire Group';
        insert newGroup;
        
        Group_Member__c gm = new Group_Member__c();
        gm.Name = 'ad';
        gm.Record_Id__c = TestWarrantyProduct.id;
        gm.Group__c = newGroup.id;
        gm.Warranty_Product__c = TestWarrantyProduct.id;
        insert gm;
        
        Group__c newGroupAccount = new Group__c();
        newGroupAccount.Object_Name__c = 'Account';
        newGroupAccount.Name__c = 'acc';
        insert newGroupAccount;
        
        Group_Member__c gm1 = new Group_Member__c();
        gm1.Name = 'ada';
        gm1.Record_Id__c = tempAccountRecordsList[0].id;
        gm1.Group__c = newGroupAccount.id;
        gm1.Account__c = tempAccountRecordsList[0].id;
        insert gm1;
        
        
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
            system.debug('TestPDlist[0]---((>'+TestPDlist[0].id);
        
        Payment_Configuration__c testPC = TestUtility.createPaymentConfiguration();
        testPC.Claim_Field_Name__c = 'Parts';
        If(CrudUtil.isPaymentConfigurationCreateable())
            insert testPC;
                
        Payment_Definition_Items__c testPDI = new Payment_Definition_Items__c(Payment_Definition__c = TestPDlist[0].Id,Payment_Configuration__c = testPC.Id);
        If(CrudUtil.isPDItemsCreateable())
            insert testPDI;
        system.debug('testPDI-->'+testPDI);
           
        list<Policy_Definition__c> tempPolicyDefinitionRecordsList = TestUtility.createPolicyDefinitionTestRecords();
        If(CrudUtil.isPolicyDefinitionCreatable())
        {
            tempPolicyDefinitionRecordsList[0].Payment_Definition__c = TestPDlist[0].Id;
            insert tempPolicyDefinitionRecordsList[0];
        }
                      
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
                tempClaimObj1.Name=tempClaimObj.Name='TempClaim'+1;
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
        //clmList.add(tempClaimObj1);
        if(CrudUtil.isClaimCreateable()){ 
            insert clmList[0];
        }
        system.debug('clmList[0]--->'+clmList[0]);
        
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
        //Insert test Claim Part
        list<Claim_Part__c> TestClaimPartList = TestUtility.createClaimPartList();
        for(Claim_Part__c testCP : TestClaimPartList)
        {
            testCP.recordtypeId = CPRecType;
            testCP.Claim__c = clmList[0].Id;
            testCP.Warranty_Product_Pricebook__c=testPricebook.Id;
            testCP.inventory__c = invList[0].Id;
          
           // testCP.Warranty_Product__c = TestWarrantyProduct1.Id;
        }

        
        Removed_Claim_Part__c remPart = new Removed_Claim_Part__c(claim__c = clmList[0].id,Warranty_Product__c=TestWarrantyProduct1.Id,inventory__c = invList[0].Id,is_approved__c=false);
        insert remPart;
        if(CrudUtil.isClaimPartCreateable()){ 
            insert TestClaimPartList;
        }
        
               
        Claim__c objClm = [Select Id,Applicable_Policy__c,Applicable_Payment_Definition__c,Total_Labor_Cost__c,Final_Labor_Cost__c,Approved_Labor_Cost__c,account__c,Warranty_Product__c,Date_of_Repair__c FROM Claim__c where id=:clmList[0].Id];
        system.debug('Applicable_Payment_Definition__c----------->'+objClm.Applicable_Policy__c+'---------------'+objClm.Applicable_Payment_Definition__c);
        system.debug(tempPolicyDefinitionRecordsList[0].id+'---'+tempPolicyDefinitionRecordsList[0].Payment_Definition__c);
        
                
        list<ClaimPartAmountModifierService.InputWrapper> TestPartInputWrapperList = new list<ClaimPartAmountModifierService.InputWrapper>();
        ClaimPartAmountModifierService.InputWrapper wrpPartInp = new ClaimPartAmountModifierService.InputWrapper();
        wrpPartInp.ApplicablePaymentDefinition = TestPDlist[0].id;
        wrpPartInp.claimPart = TestClaimPartList[0];
        wrpPartInp.warrantyProductId = TestWarrantyProduct1.id;
        TestPartInputWrapperList.add(wrpPartInp);
        //ClaimPartAmountModifierService.CalculateFinalCost(TestPartInputWrapperList );


    }         

}