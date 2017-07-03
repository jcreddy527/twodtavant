/**********************************************************************
 Name:  WarrantyRegistrationController_Test
 Copyright ? 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:    To Test WarrantyRegistrationController                                                         -------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Chethan        21/02/2017      INITIAL DEVELOPMENT            
***********************************************************************/

@isTest
private class WarrantyRegistrationController_Test {
    
static testmethod void TestWarrantyRegistrationController(){
        Test.StartTest();
        // inserting required custom settings
        WOD__c cs = new WOD__c();
        cs.Name = 'Enable changeCustomerName';
        cs.isTriggered__c = true;
        insert cs;
    
    	WOD__c csWOD_EnableWarrantyRegistrationTrigger = new WOD__c(name='Enable WarrantyRegistrationTrigger', isTriggered__c = true);
        insert csWOD_EnableWarrantyRegistrationTrigger;
        System.assert(csWOD_EnableWarrantyRegistrationTrigger != null);
		
        Warranty_Product__c testwarrantyProductrecords =  new Warranty_Product__c();
        testwarrantyProductrecords.Track_Type__c = 'Serialized';
        testwarrantyProductrecords.Type__c = 'Item';
        insert testwarrantyProductrecords;
		
        //creating and inserting the inventory
        list<Policy_Definition__c> tempPolicydefList = TestUtility.createPolicyDefinitionTestRecords();
        //list<Inventory__c> testInventoryRecords = TestUtility.createInventoryTestRecords();
        
        List<RecordType> recordTypeList_Inventory = [SELECT Id, DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'Warrantable' AND SobjectType = 'Inventory__c'];
        Id inventoryRecordTypeId;
        if(recordTypeList_Inventory != null && !recordTypeList_Inventory.isEmpty()){
            inventoryRecordTypeId = recordTypeList_Inventory[0].id;
        }
                
        // list<Account> testAccountList = TestUtility.createAccountTestRecords();
        list<Account> testAccountList = new list<Account>();
        Account acc = new Account();
        acc.name = 'CS_001';
        acc.BillingCountry = 'US';
        acc.ShippingCountry= 'US';
        acc.Warranty_Account_Type__c='Dealer';
        testAccountList.add(acc);
        Account acc2 = new Account();
        acc2.Name = 'CS_test';
        acc2.BillingCountry = 'US';
        acc2.ShippingCountry= 'US';
        acc2.Warranty_Account_Type__c='Dealer';
        insert acc2;
        //creating and inserting the Warranty registration
        insert testAccountList;
        
		Inventory__c inv = new Inventory__c();
        if(inventoryRecordTypeId != null) {
            inv.RecordTypeId = inventoryRecordTypeId;
        }
        inv.Name = 'test inventory';
        inv.Serial_Number__c = '1';
        inv.Asset_Type__c = 'Warrantable';
        inv.Account__c = acc2.id;
    	inv.Customer__c = acc.id;
        inv.Item__c = testwarrantyProductrecords.id;
		
		list<Inventory__c> testInventoryRecords = new list<Inventory__c> {inv};
        //creating and inserting the Account
        testInventoryRecords[0].Item__c = testwarrantyProductrecords.id;
        insert testInventoryRecords;
                
		Warranty_Registration__c testWR = new Warranty_Registration__c();
        testWR.name = 'testWR';
        testWR.Account__c = acc2.Id;
        testWR.Status__c = 'In Progress';
        testWR.Inventory__c = testInventoryRecords[0].Id;
        testWR.Registration_Date__c = system.today();
		
		//list <Warranty_Registration__c> testWarrantyRecords = TestUtility.createWarrantyRegistrationTestRecords();
        list <Warranty_Registration__c> testWarrantyRecords = new list <Warranty_Registration__c>{testWR};
        
        //creating and inserting the  policy defenitions
   
        Group__c Testgroup = new Group__c();
        Testgroup.Object_Name__c = SystemUtils.getNameSpace()+'Warranty_Product__c';
        insert  Testgroup ;
        Group_Member__c groupMember = new Group_Member__c();
        groupMember.Record_Id__c = String.valueOf(testWarrantyRecords[0].id);
        groupMember.Group__c = Testgroup.Id;
        insert groupMember;
   
        testWarrantyRecords[0].Inventory__c = testInventoryRecords[0].id;
        insert testWarrantyRecords;
             
        list<Policy_Applicability_Term__c> testPATRecordsList = TestUtility.createPATTestRecords();
        testPATRecordsList[0].Applicability_Value__c = String.valueOf(testWarrantyRecords[0].id);
        //testPATRecordsList[0].Policy_Definition__c = plcyDef.Id;
        insert testPATRecordsList;
		
        //List<Policy_Definition__c> tempPolicyDefinitionRecordsList = TestUtility.createPolicyDefinitionTestRecords();
        //++++++++++++Added below logic instead of calling TestUtility class method++++++++
        List<Policy_Definition__c> tempPolicyDefinitionRecordsList = new List<Policy_Definition__c>();    	
    	for(Integer i=0; i<10; i++){
                  Policy_Definition__c tempPolicyDefinitionObj = new Policy_Definition__c();
                  if(Schema.sObjectType.Policy_Definition__c.fields.Name.isUpdateable())
                      tempPolicyDefinitionObj.Name='testingPolicyDefinition'+i;
                          
                  if(Schema.sObjectType.Policy_Definition__c.fields.Status__c.isUpdateable())
                      tempPolicyDefinitionObj.Status__c='Active';
                          
                  if(Schema.sObjectType.Policy_Definition__c.fields.Active_From__c.isUpdateable())
                      tempPolicyDefinitionObj.Active_From__c=(system.today()-1);
                        
                  if(Schema.sObjectType.Policy_Definition__c.fields.Active_Until__c.isUpdateable())
                      tempPolicyDefinitionObj.Active_Until__c=(system.today()+1);
                        
                  if(Schema.sObjectType.Policy_Definition__c.fields.Months_Covered__c.isUpdateable())
                      tempPolicyDefinitionObj.Months_Covered__c = 10+i;
                          
                    
                  if(Schema.sObjectType.Policy_Definition__c.fields.Priority__c.isUpdateable())
                      tempPolicyDefinitionObj.Priority__c = i+1;
                        
                        
                  tempPolicyDefinitionRecordsList.add(tempPolicyDefinitionObj);
         }            
         system.assertNotEquals(null,tempPolicyDefinitionRecordsList);
    	//+++++++++++++++++++++
    	//Insert Custom Setting 
    	WOD__c objWod=new WOD__c();
        objWod.name='Enable Extended Registration Logic';
        objWod.isTriggered__c=true;
    	insert objWod;
    
        system.debug(tempPolicyDefinitionRecordsList+'#####tempPolicyDefinitionRecordsList');
        String PolicyDefenitionString = JSON.serialize(tempPolicyDefinitionRecordsList);
        list<PolicyDefWrapper> policyDefList = new list<PolicyDefWrapper>();
        PolicyDefWrapper objwrapper = new PolicyDefWrapper(tempPolicyDefinitionRecordsList[0]);
        objwrapper.selected = true;
        policyDefList.add(objwrapper);
        Map<string,string> mapWRFieldValue = new Map<string,string>();
        mapWRFieldValue.put(testWarrantyRecords[0].id,testWarrantyRecords[0].id);
        ApexPages.currentPage().getParameters().put('WRId',testWarrantyRecords[0].id);
        WarrantyRegistrationController controller = new WarrantyRegistrationController();
        WarrantyRegistrationController.usageTypeRetrun();
        WarrantyRegistrationController.getInitialData(testInventoryRecords[0].id);
        WarrantyRegistrationController.frameWarrantyRegistration(testInventoryRecords[0],'','');
        WarrantyRegistrationController.registerInventory(PolicyDefenitionString,'',testInventoryRecords[0],'9/28/2016',testWarrantyRecords[0].id,'Commercial',acc2.Id,'11/18/2016');
    	WarrantyRegistrationController.registerInventory(PolicyDefenitionString,'',testInventoryRecords[0],'9/28/2016',testWarrantyRecords[0].id,'Commercial',null,'11/18/2016');
        WarrantyRegistrationController.isMultipleWarrantyRegistration();
        WarrantyRegistrationController.createWarrantyRegistration(true,testInventoryRecords[0],'Test','9/28/2016',testWarrantyRecords[0].id,'Commercial',testAccountList[0].id);
    	WarrantyRegistrationController.createWarrantyRegistration(true,testInventoryRecords[0],'Test','9/28/2016',null,'Commercial',testAccountList[0].id);
        new WarrantyRegisterManager().doSearch(testWR);
    	WarrantyRegistrationController.EnableExtendedRegistrationLogic();
        //WarrantyRegistrationController.fetchPolicyDefinitionsMngr(true,testWarrantyRecords[0]);
        system.debug(testWarrantyRecords[0]+ +'############testWarrantyRecords[0].id');
   
        list<WarrantyRegistrationController.fieldset> FieldSetReturn = WarrantyRegistrationController.fieldstodisplay();
        list<WarrantyRegistrationController.fieldset> FieldSetReturned =  WarrantyRegistrationController.policydefFields();
    	            
        WarrantyRegisterManager objctrl = new WarrantyRegisterManager();
        objctrl.doRegisterManager(testWarrantyRecords[0],policyDefList);
        objctrl.doSearch(mapWRFieldValue, system.today());
        
        Test.StopTest();
     }
    
    
     static testMethod void myUnitTest(){
        Test.StartTest();
        WOD__c csWOD_ForMultipleWarrantyRegistration = new WOD__c(name='Multiple Warranty Registration',isTriggered__c = true);
        insert csWOD_ForMultipleWarrantyRegistration;		
        System.assert(csWOD_ForMultipleWarrantyRegistration != null);
        WarrantyRegistrationController.isMultipleWarrantyRegistration();
         
        WOD__c csWOD_ExecuteAccountTrigger = new WOD__c(name='Execute Account Trigger', isTriggered__c = true);
        insert csWOD_ExecuteAccountTrigger;
        System.assert(csWOD_ExecuteAccountTrigger != null);
        
        WOD__c csWOD_ExecuteClaimTrigger = new WOD__c(name='Execute Claim Trigger', isTriggered__c = true);
        insert csWOD_ExecuteClaimTrigger;
        System.assert(csWOD_ExecuteClaimTrigger != null);
        
        WOD__c csWOD_ExecuteClaimTriggerForPolicyChange = new WOD__c(name='Enable OnPolicyChange', isTriggered__c = true);
        insert csWOD_ExecuteClaimTriggerForPolicyChange;
        System.assert(csWOD_ExecuteClaimTriggerForPolicyChange != null);
        
        WOD__c csWOD_AllPaymentConfigurations = new WOD__c(name='All Payment Configurations',Trigger_Value__c = 'Labor,Meals,Parking,TravelByDistance,TravelByHours,Category1,Category2');
        insert csWOD_AllPaymentConfigurations;
        System.assert(csWOD_AllPaymentConfigurations != null);
        
        WOD__c csWOD_AllPrefixConfigurations = new WOD__c(name='All Prefix Configurations', Trigger_Value__c = 'Percent_,Final_,Total_,Approved_');
        insert csWOD_AllPrefixConfigurations;
        System.assert(csWOD_AllPrefixConfigurations != null);
        
        WOD__c csWOD_ExecutePaymentDefinitionTrigger = new WOD__c(name='Enable PaymentDefinitionTrigger', isTriggered__c = true);
        insert csWOD_ExecutePaymentDefinitionTrigger;
        System.assert(csWOD_ExecutePaymentDefinitionTrigger != null);
        
        
        WOD__c csWOD_EnableWarrantyRegistrationTrigger = new WOD__c(name='Enable WarrantyRegistrationTrigger', isTriggered__c = true);
        insert csWOD_EnableWarrantyRegistrationTrigger;
        System.assert(csWOD_EnableWarrantyRegistrationTrigger != null);
        
        WOD__c csWOD_ExecuteInventoryTrigger = new WOD__c(name='Enable changeCustomerName', isTriggered__c = true);
        insert csWOD_ExecuteInventoryTrigger ;
        System.assert(csWOD_ExecuteInventoryTrigger  != null);
        
        WOD__c csWOD_ForEnableUpdateMaximumUnitTrigger = new WOD__c(name='Enable updateMaximumUnit', isTriggered__c = true);
        insert csWOD_ForEnableUpdateMaximumUnitTrigger;
        System.assert(csWOD_ForEnableUpdateMaximumUnitTrigger  != null);
         
        Account acc1 = new Account();
        acc1.name = 'TestAccount';
        acc1.BillingCountry = 'US';
        acc1.ShippingCountry= 'US';
        acc1.Warranty_Account_Type__c = 'Dealer';
        insert acc1;
        System.assert(acc1.id != null);        
        
		Account acc2 = new Account();
        acc2.name = 'TestAccount';
        acc2.BillingCountry = 'US';
        acc2.ShippingCountry= 'US';
        acc2.Warranty_Account_Type__c = 'Dealer';
        acc2.ParentId = acc1.Id;
        insert acc2;
        
        Contact con1 = new Contact();
        con1.firstName = 'TestContact';
        con1.lastName = 'xyz';
        con1.accountId = acc2.id;
        insert con1;
        System.assert(con1.id != null);
	         
        List<RecordType> recordTypeList_Product = [SELECT DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Item' AND SobjectType = 'Warranty_Product__c'];
        Id productRecordTypeId;
        if(recordTypeList_Product != null && !recordTypeList_Product.isEmpty()){
            productRecordTypeId = recordTypeList_Product[0].id;
        }
         
        
        Warranty_Product__c product = new Warranty_Product__c();
        //if(productRecordTypeId != null) {
          //  product.RecordTypeId = productRecordTypeId;
        //}
        product.Product_Name__c = 'Test product';
        product.Name = '1';
        product.Track_Type__c = 'Non-Serialized';
        product.Type__c = 'Item';
        product.Item_Type__c = 'Machine';
        product.Units_of_Measure__c = 'Hours';
		insert product;

		Warranty_Product__c product1 = new Warranty_Product__c();
        //if(productRecordTypeId != null) {
        //    product1.RecordTypeId = productRecordTypeId;
       // }
        product1.Product_Name__c = 'Test product';
        product1.Name = '1';
        product1.Track_Type__c = 'Serialized';
        product1.Type__c = 'Item';
        product1.Item_Type__c = 'Machine';
        product1.Units_of_Measure__c = 'Hours';
		insert product1;
		            
		Country__c country = new Country__c(Name = 'India', Currency_Code__c = 'INR');
        insert country;
        System.assert(country != null);
                
		Warranty_Product_Pricebook__c wpPriceBook = new Warranty_Product_Pricebook__c();
        wpPriceBook.Name = 'Test Pricebook';
        wpPriceBook.Country__c = country.Id;
        wpPriceBook.Warranty_Product__c = product.id;
        wpPriceBook.Valid_From__c = System.today()-35;
        wpPriceBook.Valid_Until__c = System.today()+365;
        wpPriceBook.Price__c = 400;
        insert wpPriceBook;
        System.assert(wpPriceBook != null);
         
                
		Group__c grp = new Group__c();
        grp.Name__c='grp';
        grp.Object_Name__c='Account';
        insert grp;
        
        system.debug('account id --  '+acc2.Id);
		Group_Member__c grpMember = new Group_Member__c();
        grpMember.Group__c = grp.Id;
        grpMember.Record_Id__c = string.valueOf(acc2.Id).substring(0, 15);
        grpMember.Account__c = acc2.Id;
        insert grpMember;
                
		Warranty_Code__c wcode = new Warranty_Code__c();
        wcode.Name = 'testWrCode';
        wcode.Warranty_Product__c = product.id;
        wcode.Standard_Labor_Hour__c = 10;
        insert wcode;
        
        List<RecordType> recordTypeList_Inventory = [SELECT DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'Warrantable' AND SobjectType = 'Inventory__c'];
        Id inventoryRecordTypeId;
        if(recordTypeList_Inventory != null && !recordTypeList_Inventory.isEmpty()){
            inventoryRecordTypeId = recordTypeList_Inventory[0].id;
        }
                        
		Inventory__c inv = new Inventory__c();
        if(inventoryRecordTypeId != null) {
            inv.RecordTypeId = inventoryRecordTypeId;
        }
        inv.Name = 'Test inventory';
        inv.Serial_Number__c = '1';
        inv.Asset_Type__c = 'Warrantable';
        inv.Account__c = acc2.id;
        inv.Item__c = product1.id;
        insert inv;
                
		Warranty_Registration__c testWR = new Warranty_Registration__c();
        testWR.name = 'testWR';
        testWR.Account__c = acc2.Id;
        testWR.Status__c = 'In Progress';
        testWR.Inventory__c = inv.Id;
        testWR.Registration_Date__c = system.today();
        insert testWR;
        List <Warranty_Registration__c> testWarrantyRecords = new List <Warranty_Registration__c>{testWR};
        
                
		Payment_Definitions__c paymtDefinition = new Payment_Definitions__c();
        paymtDefinition.Name= 'testPaymentDef';
        insert paymtDefinition;
                
		Payment_Configuration__c paymentConfiguration = new Payment_Configuration__c();
        paymentConfiguration.Name = 'TestPC';
        paymentConfiguration.Claim_Field_Name__c = 'Test Parts';
        insert paymentConfiguration;
        //paymentConfiguration = [select Claim_Field_Name__c from Payment_Configuration__c where id = :paymentConfiguration.id];
                
		Payment_Modifiers__c paymtModifier = new Payment_Modifiers__c();
        paymtModifier.Name = 'Test PaymentModifier';
        paymtModifier.Payment_Definition__c = paymtDefinition.Id;
        paymtModifier.Payment_Configuration__c = paymentConfiguration.id;
        paymtModifier.Active_From__c = system.today();
        paymtModifier.Active_Until__c = system.today().addDays(10);
        paymtModifier.Value__c = 10;
        paymtModifier.Priority__c = 10;
        paymtModifier.Part__c = product.id;
        paymtModifier.Dealer__c = acc2.id;
        insert paymtModifier;
                
		Payment_Definition_Items__c paymtDefinitionItem = new Payment_Definition_Items__c();
        paymtDefinitionItem.Payment_Configuration__c = paymentConfiguration.id;
        paymtDefinitionItem.Payment_Definition__c = paymtDefinition.id;
        //insert paymtDefinitionItem;
        
		Policy_Definition__c plcyDef =new Policy_Definition__c();
        plcyDef.Name = 'testplDf';
        plcyDef.Active_From__c = system.today();
        plcyDef.Active_Until__c = system.today().addDays(50);
        plcyDef.Priority__c = 1;
        plcyDef.Months_Covered__c = 10;
        plcyDef.Payment_Definition__c = paymtDefinition.id;
        plcyDef.Type__c = 'Standard';
        plcyDef.Sub_Type__c = 'Marketing';
        plcyDef.Pricebook_Type__c = 'List';
        plcyDef.Status__c = 'Draft';
        insert plcyDef;
        
        Policy_Definition__c pdd = [SELECT Id , Name, Active_From__c ,Months_Covered__c ,Active_Until__c ,Priority__c ,Status__c ,Transferable__c ,Transfer_Fee__c ,Type__c ,Sub_Type__c ,Is_Policy_Optional__c ,Pricebook_Type__c FROM Policy_Definition__c where id = :plcyDef.id];
        
        List<Warranty_Coverages__c> warrantyCoverageList=new List<Warranty_Coverages__c>();
         
		Warranty_Coverages__c warrantyCoverage = new Warranty_Coverages__c();
		//warrantyCoverage.Name = 'TestWC';
        warrantyCoverage.Warranty_Registration__c = testWR.Id;
        warrantyCoverage.Is_Active__c = false;
        warrantyCoverage.Warranty_End_Date__c = System.today().addDays(50);
        warrantyCoverage.Warranty_Start_Date__c = System.today();
        warrantyCoverage.Maximum_Unit__c = 100;
        warrantyCoverage.Policy_Definition__c = plcyDef.Id;
        //insert  warrantyCoverage;
         
        Warranty_Coverages__c warrantyCoverage1 = new Warranty_Coverages__c();
		//warrantyCoverage.Name = 'TestWC';
        warrantyCoverage1.Warranty_Registration__c = testWR.Id;
        warrantyCoverage1.Is_Active__c = false;
        warrantyCoverage1.Warranty_End_Date__c = System.today().addDays(50);
        warrantyCoverage1.Warranty_Start_Date__c = System.today();
        warrantyCoverage1.Maximum_Unit__c = 200;
        warrantyCoverage1.Policy_Definition__c = plcyDef.Id;
        //insert  warrantyCoverage1;
         
        warrantyCoverageList.add(warrantyCoverage);
        warrantyCoverageList.add(warrantyCoverage1);
        insert  warrantyCoverageList;
         
        String warrantyCoverageObj = JSON.serialize(warrantyCoverageList[0]);
         
         
        List<Inventory__c> inventory=new List<Inventory__c>();
        inventory.add(inv);
        
        String inventory1 = JSON.serialize(inventory);
                 
		Policy_Applicability_Term__c pat = new Policy_Applicability_Term__c();
		//pat.Name = 'test';
        pat.Applicability_Term_Type__c = 'Referred by Text';
        pat.Applicability_SubType__c = 'Warranty_Product__c';
        pat.Applicability_Value__c = '1';
        pat.Policy_Definition__c = plcyDef.id;
        insert pat;
		
        WarrantyRegistrationController.fetchPolicyDefinitionsMngr(true,testWarrantyRecords[0],true,inv.Id,'Standard');
        WarrantyRegistrationController.fetchPolicyDefinitionsMngr(true,testWarrantyRecords[0],true,inv.Id,'Goodwill');
        WarrantyRegistrationController.getAllCoveragesRealtedtoInventory(inv.Id);
        WarrantyRegistrationController.getMaxMonthsCovered(testWR.Id);
        WarrantyRegistrationController.updateCoverages(warrantyCoverageObj,inventory1,'testCustomer');
        
        Test.StopTest(); 
     }

}