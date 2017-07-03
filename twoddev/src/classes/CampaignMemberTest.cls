/*************************************************************
 Name: CampaignMemberTest
 Copyright ? 2016  Tavant Technology Inc
==============================================================
==============================================================
Purpose:    To Test GroupCreattionCampaignTest apex class                                                                                                         
==============================================================
==============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Deeptarup      10/04/2016     INITIAL DEVELOPMENT            
***************************************************************/
@isTest 
global class CampaignMemberTest {
    
     global static string NameSpace;
  static{
    NameSpace = SystemUtils.getNameSpace();
    system.debug('---NameSpace-'+NameSpace);
  } 
    
    static testmethod void testGroupCreationCampaign(){
        CustomSettingsUtilityTest.init();
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
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        TestWarrantyProduct.Item_Type__c = 'Machine';
        TestWarrantyProduct.Type__c = 'Item';
        TestWarrantyProduct.Track_Type__c = 'Serialized';
        if(CrudUtil.isWarrantyProductCreateable()){ 
            insert TestWarrantyProduct;
        }
        
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
        
        
        String RecType = RecordTypeUtils.getRecordTypeId('Serialized_Part',Claim__c.sObjectType);
        String RecTypeCT = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);      
        
        Claim__c clm = new Claim__c(recordtypeId=RecType);        
        Claim__c clm1 = new Claim__c(recordtypeId=RecTypeCT);
        if(Schema.sObjectType.Claim__c.fields.Name.isUpdateable()&&
                Schema.sObjectType.Claim__c.fields.Account__c.isUpdateable()) {
              
                clm1.claim_type__c = 'Machine';
                clm1.Name=clm.Name='TempClaim'+1;
                clm1.Account__c=clm.Account__c=tempAccountRecordsList[0].id;
                clm1.Inventory__c =clm.Inventory__c =invList[0].id;
                clm1.Claim_Status__c =clm.Claim_Status__c = 'Draft';
                clm1.Date_of_Failure__c = clm.Date_of_Failure__c = System.today();
                clm1.Date_of_Repair__c = clm.Date_of_Repair__c = System.today();
                clm1.in_approval_process__c =clm.in_approval_process__c =false;
                clm1.Applicable_Policy__c =clm.Applicable_Policy__c =tempPolicyDefinitionRecordsList[0].id;
                
            }
        
        List<Service_Campaign__c> lstSerCampaign = new List<Service_Campaign__c>(); 
        Service_Campaign__c ser1 = new Service_Campaign__c();
        ser1.Name = 'TestServiceCampaign111';
        ser1.Start_Date__c = date.newInstance(2016, 10, 10);
        ser1.End_Date__c = date.newInstance(2016, 10, 18);
        ser1.Claim_Template__c = clm.id;
        ser1.Status__c='Draft';
        ser1.Payment_Definitions__c=TestPDlist[0].id;
        lstSerCampaign.add(ser1);
        
        /*Service_Campaign__c ser2 = new Service_Campaign__c();
        ser2.Name = 'TestServiceCampaign1';
        ser2.Start_Date__c = date.newInstance(2016, 10, 10);
        ser2.End_Date__c = date.newInstance(2016, 10, 18);
        ser2.Claim_Template__c = clm1.id;
        ser2.Status__c='Draft';
        ser2.Payment_Definitions__c=TestPDlist[0].id;
        lstSerCampaign.add(ser2); */       
        insert lstSerCampaign;
        
        List<Campaign_Members__c> lstCampaignMem = new List<Campaign_Members__c>();
        Campaign_Members__c cMem1 = new Campaign_Members__c();
        cMem1.Service_Campaign__c=ser1.id;
        cMem1.Inventory__c=invList[0].id;
        cMem1.Serial_Number__c='ASDF2342';
        lstCampaignMem.add(cMem1);
        Campaign_Members__c cMem2 = new Campaign_Members__c();
        cMem2.Service_Campaign__c=ser1.id;
        cMem2.Inventory__c=invList[0].id;
        cMem2.Serial_Number__c='ASDF2342';
        lstCampaignMem.add(cMem2);
        insert lstCampaignMem;
        
        List<Account> lstAcc = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'acc1';
        lstAcc.add(acc1);
        Account acc2 = new Account();
        acc2.Name = 'acc2';
        lstAcc.add(acc2);
        insert lstAcc;
        
        List<Inventory__c> lstInv = new List<Inventory__c>();
        Inventory__c inv1 = new Inventory__c();
        inv1.Name = '11A-B96N733';
        inv1.Serial_Number__c = '214';
        inv1.Asset_Type__c = 'Warrantable';
        inv1.Account__c = acc1.id;
        inv1.Item__c = TestWarrantyProduct.id;
        lstInv.add(inv1);
        
        Inventory__c inv2 = new Inventory__c();
        inv2.Name = '11A-B96N734';
        inv2.Serial_Number__c = '215';
        inv2.Asset_Type__c = 'Warrantable';
        inv2.Account__c = acc1.id;
        inv2.Item__c = TestWarrantyProduct.id;
        lstInv.add(inv2);
        insert lstInv;
        
        List<String> lstSerCam = new List<String>();
        lstSerCam.add(string.valueof(ser1.id));
        List<String> recordIds=new List<String>();
        recordIds.add(string.valueof(inv2.id));
        
        Service_Campaign__c serCam = new Service_Campaign__c();
        serCam.Name = 'TestServiceCampaign12';
        serCam.Start_Date__c = date.today();
        serCam.End_Date__c = date.today();
        serCam.Claim_Template__c = clm.id;
        serCam.Status__c='Draft';
        serCam.Payment_Definitions__c=TestPDlist[0].id;
        
        String objectName = NameSpace+'Inventory__c';
        String ListOfIds = inv1.id;
        ApexPages.CurrentPage().getParameters().put('id', objectName);
        ApexPages.CurrentPage().getParameters().put('id', ListOfIds);
        
        test.startTest();
        CampaignMember grpCreCam = new CampaignMember();
        CampaignMember.getCampaignServices();
        
        CampaignMember.AddGroupMember(lstSerCam, recordIds);
        CampaignMember.createNwGroup(serCam, recordids);
        CampaignMember.groupSearch('inv');
        CampaignMember.getServiceCampaignStatus();
        CampaignMember.getServiceCampaignType();
        test.stopTest();
    }
    static testmethod void testGroupCreationCampaign1(){
        CustomSettingsUtilityTest.init();
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
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        TestWarrantyProduct.Item_Type__c = 'Machine';
        TestWarrantyProduct.Type__c = 'Item';
        TestWarrantyProduct.Track_Type__c = 'Serialized';
        if(CrudUtil.isWarrantyProductCreateable()){ 
            insert TestWarrantyProduct;
        }
        
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
        
        
        String RecType = RecordTypeUtils.getRecordTypeId('Serialized_Part',Claim__c.sObjectType);
        String RecTypeCT = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);      
        
        Claim__c clm = new Claim__c(recordtypeId=RecType);        
        Claim__c clm1 = new Claim__c(recordtypeId=RecTypeCT);
        if(Schema.sObjectType.Claim__c.fields.Name.isUpdateable()&&
                Schema.sObjectType.Claim__c.fields.Account__c.isUpdateable()) {
              
                clm1.claim_type__c = 'Machine';
                clm1.Name=clm.Name='TempClaim'+1;
                clm1.Account__c=clm.Account__c=tempAccountRecordsList[0].id;
                clm1.Inventory__c =clm.Inventory__c =invList[0].id;
                clm1.Claim_Status__c =clm.Claim_Status__c = 'Draft';
                clm1.Date_of_Failure__c = clm.Date_of_Failure__c = System.today();
                clm1.Date_of_Repair__c = clm.Date_of_Repair__c = System.today();
                clm1.in_approval_process__c =clm.in_approval_process__c =false;
                clm1.Applicable_Policy__c =clm.Applicable_Policy__c =tempPolicyDefinitionRecordsList[0].id;
                
            }
        
        List<Service_Campaign__c> lstSerCampaign = new List<Service_Campaign__c>(); 
        Service_Campaign__c ser1 = new Service_Campaign__c();
        ser1.Name = 'TestServiceCampaign111';
        ser1.Start_Date__c = date.newInstance(2016, 10, 10);
        ser1.End_Date__c = date.newInstance(2016, 10, 18);
        ser1.Claim_Template__c = clm.id;
        ser1.Status__c='Draft';
        ser1.Payment_Definitions__c=TestPDlist[0].id;
        lstSerCampaign.add(ser1);
        
        /*Service_Campaign__c ser2 = new Service_Campaign__c();
        ser2.Name = 'TestServiceCampaign1';
        ser2.Start_Date__c = date.newInstance(2016, 10, 10);
        ser2.End_Date__c = date.newInstance(2016, 10, 18);
        ser2.Claim_Template__c = clm1.id;
        ser2.Status__c='Draft';
        ser2.Payment_Definitions__c=TestPDlist[0].id;
        lstSerCampaign.add(ser2); */       
        insert lstSerCampaign;
        
        //List<Campaign_Members__c> lstCampaignMem = new List<Campaign_Members__c>();
        /*Campaign_Members__c cMem1 = new Campaign_Members__c();
        cMem1.Service_Campaign__c=ser1.id;
        cMem1.Inventory__c=invList[0].id;
        cMem1.Serial_Number__c='ASDF2342';
        insert cMem1;*/
        /*lstCampaignMem.add(cMem1);
        Campaign_Members__c cMem2 = new Campaign_Members__c();
        cMem2.Service_Campaign__c=ser1.id;
        cMem2.Inventory__c=invList[0].id;
        cMem2.Serial_Number__c='ASDF2342';
        lstCampaignMem.add(cMem2);
        insert lstCampaignMem;*/
        
              
        List<Account> lstAcc = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'acc1';
        lstAcc.add(acc1);
        Account acc2 = new Account();
        acc2.Name = 'acc2';
        lstAcc.add(acc2);
        insert lstAcc;
        
        List<Inventory__c> lstInv = new List<Inventory__c>();
        Inventory__c inv1 = new Inventory__c();
        inv1.Name = '11A-B96N733';
        inv1.Serial_Number__c = '214';
        inv1.Asset_Type__c = 'Warrantable';
        inv1.Account__c = acc1.id;
        inv1.Item__c = TestWarrantyProduct.id;
        lstInv.add(inv1);
        
        Inventory__c inv2 = new Inventory__c();
        inv2.Name = '11A-B96N734';
        inv2.Serial_Number__c = '215';
        inv2.Asset_Type__c = 'Warrantable';
        inv2.Account__c = acc1.id;
        inv2.Item__c = TestWarrantyProduct.id;
        lstInv.add(inv2);
        insert lstInv;
        
        List<String> lstSerCam = new List<String>();
        lstSerCam.add(string.valueof(ser1.id));
        List<String> recordIds=new List<String>();
        recordIds.add(string.valueof(inv2.id));
        
        Service_Campaign__c serCam = new Service_Campaign__c();
        serCam.Name = 'TestServiceCampaign12';
        serCam.Start_Date__c = date.today();
        serCam.End_Date__c = date.today();
        serCam.Claim_Template__c = clm.id;
        serCam.Status__c='Draft';
        serCam.Payment_Definitions__c=TestPDlist[0].id;
        
        String objectName = NameSpace+'Inventory__c';
        String ListOfIds = inv1.id;
        ApexPages.CurrentPage().getParameters().put('id', objectName);
        ApexPages.CurrentPage().getParameters().put('id', ListOfIds);
        
        test.startTest();
        CampaignMember grpCreCam = new CampaignMember();
        CampaignMember.getCampaignServices();
        CampaignMember.AddGroupMember(lstSerCam, recordIds);
        CampaignMember.createNwGroup(serCam, recordids);
        CampaignMember.groupSearch('Test');
        CampaignMember.getServiceCampaignStatus();
        CampaignMember.getServiceCampaignType();
        test.stopTest();
    }
}