/**********************************************************************
Name:  ClaimFinancialModuleTest
Copyright � 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose: To Test ClaimFinancialController class
                                                 
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR              DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Chethan Sharma L    10/10/2016      INITIAL DEVELOPMENT            
***********************************************************************/

@isTest
public class ClaimFinancialControllerTest {

    
     @isTest static void insertTest() {
           /*******************************************************************
            PURPOSE:   To test ClaimFinancialController                                                  
            PARAMETERS: N/A
            RETURNS: N/A
            THROWS [EXCEPTIONS]: N/A  
            *******************************************************************/
            
            // Get all the Custom settings values for the claim
            CustomSettingsUtilityTest.init();
            
            WOD__c objCustomSettings = new WOD__c();
            
            WOD__c enablePolicyConfig = WOD__c.getValues('Enable OnPolicyChange');
            
            objCustomSettings.isTriggered__c = false;
            objCustomSettings.Trigger_Value__c = 'Labor,Meals,Parking,Category1,Category2,TravelByDistance,TravelByHours';
            objCustomSettings.Name = 'All Payment Configurations';
            insert objCustomSettings;
            
            
            WOD__c objCustomSettingsTrigger  = new WOD__c();
            objCustomSettingsTrigger.isTriggered__c = true; 
            objCustomSettingsTrigger.Name = 'Enable OnPolicyChange';
            insert objCustomSettingsTrigger;
            
            WOD__c objCustomSettingsPrefix  = new WOD__c();
            objCustomSettingsPrefix.Trigger_Value__c = 'Percent_,Final_,Total_,Approved_';
            objCustomSettingsPrefix.Name = 'All Prefix Configurations';
            
 
            insert objCustomSettingsPrefix;
            
            
            List<Claim__c> updateClaimsList = new List<Claim__c>();
            
            // Fetch Test-claim record and Insert
             
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
      
         //20th Feb
        list<Inventory__c> invList = TestUtility.createInventoryTestRecords();
        invList[0].Account__c=tempAccountRecordsList[0].Id;
        invList[0].Item__c = TestWarrantyProduct.id;
        insert invList[0]; 
         
        /* list<account> acc = new list<account>();
         Account a = new Account();
         
         a.name='Test1';
         a.Warranty_Account_Type__c='Dealer';
         
         acc.add(a);
         insert acc;
         
         list<Inventory__c> invList = new  list<Inventory__c> ();
         Inventory__c i1 = new Inventory__c();
           
                        i1.Name='TestingInventoryReocrd';
                        i1.Serial_Number__c='INV1';
                        i1.Account__c=a.Id;
                        i1.Install_Date__c=System.today();
                        i1.Asset_Type__c = 'Warrantable';
                        invList.add(i1);
         
         Inventory__c i2 = new Inventory__c();
          
                        i2.Name='TestingInventoryReocrd ';
                        i2.Serial_Number__c='INV2';
                        i2.Account__c=a.Id;
                        i2.Install_Date__c=System.today();
                        i2.Asset_Type__c = 'Warrantable';
                        invList.add(i2);
         
         insert invList; */
         
         
         
         
        
        /*list<Warranty_Registration__c> tempWarrantyRegistrationRecordsList = TestUtility.createWarrantyRegistrationTestRecords();
        tempWarrantyRegistrationRecordsList[0].Account__c = tempAccountRecordsList[0].id;
        tempWarrantyRegistrationRecordsList[0].Inventory__c = invList[0].id;
        If(CrudUtil.isWRCreateable())
            insert tempWarrantyRegistrationRecordsList[0];
        
        
        system.assertNotEquals(null,tempWarrantyRegistrationRecordsList[0]);*/
        
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
            //insert tempPolicyDefinitionRecordsList[0];
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
               // tempClaimObj1.Name=tempClaimObj.Name='TempClaim'+1;
                tempClaimObj1.Account__c=tempClaimObj.Account__c=tempAccountRecordsList[0].id;
                tempClaimObj1.Inventory__c =tempClaimObj.Inventory__c =invList[0].id;
                tempClaimObj1.Claim_Status__c =tempClaimObj.Claim_Status__c = 'Draft';
                tempClaimObj1.Date_of_Failure__c = tempClaimObj.Date_of_Failure__c = System.today()-4;
                tempClaimObj1.Date_of_Repair__c = tempClaimObj.Date_of_Repair__c = System.today()-2;
                tempClaimObj1.in_approval_process__c =tempClaimObj.in_approval_process__c =false;
               //tempClaimObj1.Applicable_Policy__c = tempClaimObj.Applicable_Policy__c =tempPolicyDefinitionRecordsList[0].id;
                tempClaimObj1.Approved_Labor_Cost__c =tempClaimObj.Approved_Labor_Cost__c = 200;
                tempClaimObj1.Warranty_Product__c= tempClaimObj.Warranty_Product__c = TestWarrantyProduct1.id;
                tempClaimObj1.Final_Labor_Cost__c = tempClaimObj.Final_Labor_Cost__c = 200;
                tempClaimObj1.Total_Labor_Cost__c = tempClaimObj.Total_Labor_Cost__c = 200;
        }
        
        list<Claim__c> clmList = new list<Claim__c>();
        clmList.add(tempClaimObj);
        
        // Insert Claim record for testing 
        try{
            if(CrudUtil.isClaimCreateable()){ 
                insert clmList[0];
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
       
        // Insert ClaimFinancials record on Claim record  
        Claim_Financial__c cf = new Claim_Financial__c();
        cf.Name= 'Labor';
        cf.Approved_Amount__c =100;
        cf.Final_Amount__c = 20;
        cf.Total_Amount__c = 12;
        cf.Percent_Amount__c = 13;
        cf.claim__c = clmList[0].Id;
        try{
            insert cf;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        Map<Id,claim__c> clmMap=new Map<Id,claim__c>();
        for(Claim__c clm : clmList)
        {
            clmMap.put(clm.id,clm);
        }
         
        // Perform Update operations on Inserted Claims
        for(claim__c claimrec: clmList){
           claimrec.Total_Labor_Cost__c = 28;
           updateClaimsList.add(claimrec);
        }
         
        clmList[0].Total_Labor_Cost__c = 28;
        clmList[0].Total_Meals_Cost__c = 33;
        clmList[0].Total_Parking_Cost__c = 44;
        clmList[0].Total_TravelByDistance_Cost__c= 33;
        clmList[0].Total_TravelByHours_Cost__c = 73;
         
         clmList[0].Final_Category1_Cost__c= 33;
        clmList[0].Final_Category2_Cost__c = 73;
         
        
        try{
            upsert clmList[0];
        }
         catch(DmlException e) {
             System.debug('The following exception has occurred: ' + e.getMessage());
         }
         
         
       //for delete claimfinancial
         ClaimFinancialController s = ClaimFinancialController.getInstance();
         
         set<id> dsd= new set<id>();         
         dsd.add(tempClaimObj1.id);
         s.claimFinancialsDelete(dsd);
         
     }
    
}