/**********************************************************************
 Name:  ServiceCampaignServiceTest
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for ServiceCampaignService
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Neethu           15/09/2015      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class ServiceCampaignServiceTest {

  static testmethod void testServiceCampaign(){
        CustomSettingsUtilityTest.init();
        //list<ServiceCampaignLogicService.ServiceCampaignLogicWrapper> wrpList = new list<ServiceCampaignLogicService.ServiceCampaignLogicWrapper>();
        ServiceCampaignLogicService.ServiceCampaignLogicWrapper wrp = new ServiceCampaignLogicService.ServiceCampaignLogicWrapper();
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
         String ClaimTemplateID = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);
        
         String RecType = RecordTypeUtils.getRecordTypeId('Serialized_Part',Claim__c.sObjectType);
         String RecTypeCT = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);     
        Claim__c tempClaimObj = new Claim__c(recordtypeId=RecType);
        
        Claim__c tempClaimObj1 = new Claim__c(recordtypeId=RecTypeCT);
        if(Schema.sObjectType.Claim__c.fields.Name.isUpdateable()&&
               Schema.sObjectType.Claim__c.fields.Account__c.isUpdateable()) {
              
                tempClaimObj1.claim_type__c = 'Machine';
                tempClaimObj1.Name=tempClaimObj.Name='TempClaim'+1;
                tempClaimObj1.Account__c=tempClaimObj.Account__c=tempAccountRecordsList[0].id;
                tempClaimObj1.Inventory__c =tempClaimObj.Inventory__c =invList[0].id;
                tempClaimObj1.Claim_Status__c =tempClaimObj.Claim_Status__c = 'Draft';
                tempClaimObj1.Date_of_Failure__c = tempClaimObj.Date_of_Failure__c = System.today();
                tempClaimObj1.Date_of_Repair__c = tempClaimObj.Date_of_Repair__c = System.today();
                tempClaimObj1.in_approval_process__c =tempClaimObj.in_approval_process__c =false;
                tempClaimObj1.Applicable_Policy__c =tempClaimObj.Applicable_Policy__c =tempPolicyDefinitionRecordsList[0].id;
                tempClaimObj1.Claim_Record_Type__c='Claim Template';
                tempClaimObj1.RecordTypeId= ClaimTemplateID;
                tempClaimObj1.Claim_Type__c ='Claim Template'; 
            }
        //list<Claim__c> clmList = new list<Claim__c>();
        //clmList.add(tempClaimObj);
        //clmList.add(tempClaimObj1);
        if(CrudUtil.isClaimCreateable()){ 
            insert tempClaimObj1;
        }
        
        Service_Campaign__c servCamp = new Service_Campaign__c(Claim_Template__c=tempClaimObj1.id,Payment_Definitions__c=TestPDlist[0].id,Status__c='Draft');
        insert servCamp;
        Campaign_Members__c cmTest = new Campaign_Members__c(Service_Campaign__c=servCamp.id,Inventory__c=invList[0].id,Serial_Number__c='ASDF2342');
        insert cmTest;
        
        
        
        WOD__c objDefPolicySetting = new WOD__c(Name = 'Default Policy',Trigger_Value__c=string.valueOf(tempPolicyDefinitionRecordsList[0].Id));
        insert objDefPolicySetting;
        
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
            testCP.Claim__c = tempClaimObj1.Id;
            
            testCP.Warranty_Product__c = TestWarrantyProduct1.Id;
        }
        
        /*TestClaimPartList[1].Claim__c = clmList[1].Id;
        list<Claim_Part__c> TestClaimPart = new list<Claim_Part__c>();
        TestClaimPart.add(TestClaimPartList[0]);
        TestClaimPart.add(TestClaimPartList[1]);*/
        
        Removed_Claim_Part__c remPart = new Removed_Claim_Part__c(claim__c = tempClaimObj1.id,inventory__c = invList[0].Id,is_approved__c=false);
        //Removed_Claim_Part__c remPartCT = new Removed_Claim_Part__c(claim__c = clmList[1].id,inventory__c = invList[0].Id,is_approved__c=false);
        /*list<Removed_Claim_Part__c> remList = new list<Removed_Claim_Part__c>();
        remList.add(remPart);
        remList.add(remPartCT);*/
        insert remPart;
        if(CrudUtil.isClaimPartCreateable()){ 
            insert TestClaimPartList[0];
        }
        
        String WCRecType = RecordTypeUtils.getRecordTypeId('Job_Code',Warranty_Code__c.sObjectType);
        Warranty_Code__c wcRecord = new Warranty_Code__c(recordTypeId=WCRecType,Standard_Labor_Hour__c = 20,Warranty_Product__c=TestWarrantyProduct1.id);
        insert wcRecord;
        Claim_Service_Information__c claimServiceInfo = new Claim_Service_Information__c(name = 'Testt',Claim__c = tempClaimObj1.id,Additional_Labor_Hour__c=20,
                                        Service_Job_Code__c =wcRecord.id,Labor_Rate__c=20,Standard_Labor_Hour__c=20,Total_Labor_hours__c =100);
        insert claimServiceInfo;
        
        tempClaimObj.Claim_Type__c='Field Modification';
        tempClaimObj.Campaign_Members__c =cmTest.id;
        insert tempClaimObj;
        
        //serviceCampaingnLogicService  Test
        list<ServiceCampaignLogicService.ServiceCampaignLogicWrapper> wrpSerList = new list<ServiceCampaignLogicService.ServiceCampaignLogicWrapper>();
        ServiceCampaignLogicService.ServiceCampaignLogicWrapper wrpSer = new ServiceCampaignLogicService.ServiceCampaignLogicWrapper();
        wrpSer.DealerLaborRate = 20;
        wrpSer.claim = tempClaimObj;
        wrpSer.claimTemplateId = tempClaimObj1.id;
        wrpSerList.add(wrpSer);
        test.startTest();
        ServiceCampaignLogicService.CopyDataFromClaimTemplate(wrpSerList);
        test.stopTest();
    }         

}