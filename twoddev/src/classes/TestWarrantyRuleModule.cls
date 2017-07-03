/**********************************************************************
 Name:  TestWarrantyRuleModule()
 Copyright � 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Test class for 1.ManageRuleCtrl 2.RulesCriteriaCtrl 3.RuleEngine
                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Vino        11/18/2014      INITIAL DEVELOPMENT            
***********************************************************************/

@isTest
global class TestWarrantyRuleModule {
    global static string NameSpace = SystemUtils.getNameSpace();
    /*******************************************************************
    PURPOSE:   To test insertion, updation and creation of Warranty Rule                                                
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    //Test method for Manage Rule Controller
    global static testmethod void testManageRuleController(){
        CustomSettingsUtilityTest.init();
        PageReference pageRef = Page.ManageRulesPage;
        Test.setCurrentPage(pageRef);
        
        // Creating and Inserting Test Records for Warranty Rule
        list<Warranty_Rule__c> testWarrantyRuleList = TestUtility.createWarrantyRuleTestRecords();
        
        Test.startTest();
        if(Schema.sObjectType.Warranty_Rule__c.fields.Logical_Grouping__c.isUpdateable())
        {
            try{
                if(CrudUtil.isWRuleCreateable()){
                    insert testWarrantyRuleList;  
                }
             
               //creating object of ManageRule controller using standard controller 
                ApexPages.StandardController stdController1 = new ApexPages.StandardController(testWarrantyRuleList[0]);
                ManageRuleCtrl testController1 = new ManageRuleCtrl(stdController1);
                
                /*******TEST SCENARIO 1 : Test for inserting /updating a rule without Logical Grouping********/
                PageReference returnedPageReference1 = testController1.saveRule();
                System.assertEquals(null,returnedPageReference1);
                
                /*******TEST SCENARIO 1 : Test for inserting /updating a rule with Logical Grouping********/
                testWarrantyRuleList[1].Logical_Grouping__c = 'AND';
                
                if(CrudUtil.isWRuleUpdatable()){
                    update testWarrantyRuleList[1];
                }
                
                ApexPages.StandardController stdController2 = new ApexPages.StandardController(testWarrantyRuleList[1]);
                system.debug('warranty Rule---' +testWarrantyRuleList[1].Logical_Grouping__c);
                ManageRuleCtrl testController2 = new ManageRuleCtrl(stdController2);
                testController2.saveRule();
                
                /*******TEST SCENARIO 2 : Test for inserting /updating a rule and creating a new rule********/
                PageReference returnedPageReference3 = testController1.saveAndNewRule();
                System.assertEquals(null,returnedPageReference3);
                
                String returnedPageReference4 = testController2.saveAndNewRule().getUrl();
                
                /*******TEST SCENARIO 3 : Test with rule record with null values********/
                Warranty_Rule__c testRuleObj = new Warranty_Rule__c();
                ApexPages.StandardController stdController3 = new ApexPages.StandardController(testRuleObj);
                ManageRuleCtrl testController3 = new ManageRuleCtrl(stdController3);
                
                PageReference returnedPageReference5 = testController3.saveRule();
                System.assertEquals(null,returnedPageReference5);
            }
            catch(Exception e){
                system.debug('Exception--'+e);
            }
        }
        Test.stopTest();
    }
    
    /*******************************************************************
    PURPOSE:   To test creation and updation of Rule Criteria                                                
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    //Test method for Rule Criteria Controller
     global static testmethod void testRuleCriteriaController(){
        CustomSettingsUtilityTest.init();
        PageReference pageRef= Page.RuleCriteriaPage;
        Test.setCurrentPage(pageRef);
        
        String objPrefix = SObjectType.Warranty_Rule_Criteria__c.Name.substringBefore(NameSpace+'Warranty_Rule_Criteria__c');
        
        DescribeSObjectUtil.getFieldNameLabelMap(objPrefix+NameSpace+'Warranty_Rule_Criteria__c');
        DescribeSObjectUtil.getFieldNameTypeMap(objPrefix+NameSpace+'Warranty_Rule_Criteria__c');
        
        //Warranty Rule Criteria Test Record
        list<Warranty_Rule_Criteria__c> testWarrantyRuleCriteriaList = TestUtility.createWarrantyRuleCriteriaTestRecords();
       
        Test.startTest();
        
        if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Type__c.isUpdateable())
        {
            //Preparing records for Picklist type
            testWarrantyRuleCriteriaList[0].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[0].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[0].Criteria_Type__c = 'Contains';
            testWarrantyRuleCriteriaList[0].Minimum_Value__c = '1';
            testWarrantyRuleCriteriaList[0].Maximum_Value__c = '1';
            testWarrantyRuleCriteriaList[0].Criteria_Value__c = 'Parts';
            
            //Preparing records for reference type
            testWarrantyRuleCriteriaList[1].Field_Name__c = 'Account';
            testWarrantyRuleCriteriaList[1].Field_API_Name__c = objPrefix+NameSpace+'Account__c';
            testWarrantyRuleCriteriaList[1].Criteria_Type__c = 'Equals';
            
            testWarrantyRuleCriteriaList[2].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[2].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[2].Criteria_Type__c = '';
            testWarrantyRuleCriteriaList[2].Field_Type__c= '';
            testWarrantyRuleCriteriaList[2].Maximum_Value__c = '1';
            testWarrantyRuleCriteriaList[2].Criteria_Value__c = 'Parts';
          
            try{
                if(CrudUtil.isWRuleCriteriaCreateable()){
                    insert testWarrantyRuleCriteriaList;  
                }
                
                ApexPages.StandardController stdController1 = new ApexPages.StandardController(testWarrantyRuleCriteriaList[0]);
                RulesCriteriaCtrl testController1 = new RulesCriteriaCtrl(stdController1);

                system.debug('wr ------ '+testWarrantyRuleCriteriaList[0]);
                
                /*******TEST SCENARIO 1 : Test for record without Cvalue********/
                //Test for Save
                PageReference returnedPageReference1 = testController1.saveRuleCriteria();
                System.assertEquals(null,returnedPageReference1);
                
                //Test for Save And New
                PageReference returnedPageReference6 = testController1.saveAndNewRuleCriteria();
                System.assertEquals(null,returnedPageReference6);
                
                /*******TEST SCENARIO 2 : Test for record with Cvalue********/
                testController1.CValue = 'Machine';
                
                //Test for save
                PageReference returnedPageReference2 = testController1.saveRuleCriteria();
                
                //Test for Save And New
                testController1.saveAndNewRuleCriteria();
                
                //Assigning WarrantyRuleCriteria fieldName to set fieldType value
                PageUtils.put('fieldName', testWarrantyRuleCriteriaList[0].Field_API_Name__c);
                
                //Test for setting fieldApiName
                testController1.getSelectedValue();
                
                PageReference returnedPageReference4 = testController1.setFieldApiName();
                
                /*******TEST SCENARIO 3 : Test for record with reference fieldtype********/
                ApexPages.StandardController stdController2 = new ApexPages.StandardController(testWarrantyRuleCriteriaList[1]);
                RulesCriteriaCtrl testController2 = new RulesCriteriaCtrl(stdController2);
              
                list<Account> testAccountList = TestUtility.createAccountTestRecords();
                if(CrudUtil.isAccountCreateable()){
                    insert testAccountList;  
                }
          
                testController2.CValue = testAccountList[0].id;
               
                system.debug('account Value ----- '+testAccountList[0].id);
              
                PageReference returnedPageReference5 = testController2.saveRuleCriteria();
                
                PageUtils.put('fieldName', testWarrantyRuleCriteriaList[1].Field_API_Name__c);
              
                /*******TEST SCENARIO 5 : Test with rule record with null values********/
                Warranty_Rule_Criteria__c testRuleCriteriaObj = new Warranty_Rule_Criteria__c();
                
                ApexPages.StandardController stdController5 = new ApexPages.StandardController(testRuleCriteriaObj);
                RulesCriteriaCtrl testController5 = new RulesCriteriaCtrl(stdController5);
                
                PageReference returnedPageReference9 = testController5.saveRuleCriteria();
            }
            catch(Exception e){
                system.debug('Exception--'+e);
            }
        }
        Test.stopTest();
     }
     
    /*******************************************************************
    PURPOSE:   To test Rule Engine                                                
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    //Test method for Rule Engine
    global static testmethod void testRuleEngine(){
        
        /*******TEST SCENARIO 1 : Test for fetching all active rules and corresponding rule criteria********/
        
        //creating Warranty Rule Record List
        CustomSettingsUtilityTest.init();
        list<Warranty_Rule__c> testWarrantyRuleList = TestUtility.createWarrantyRuleTestRecords();
           
        Test.startTest();
        
        if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Related_Object__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Type__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isUpdateable()&&
           Schema.sObjectType.Account.fields.Name.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule__c.fields.Enabled__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Rule__c.fields.Logical_Grouping__c.isUpdateable())
        {              
            if(CrudUtil.isWRuleCreateable()){
                insert testWarrantyRuleList;   
          }
            
            Account ac = new Account(Name = 'forTest');
            
            if(CrudUtil.isAccountCreateable()){
                insert ac;  
          }
            
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
            
           
            
            String objPrefix = SObjectType.Warranty_Rule_Criteria__c.Name.substringBefore(NameSpace+'Warranty_Rule_Criteria__c');
            
            //creating WarrantyRuleCriteria Records and assigning them to warranty rules
            list<Warranty_Rule_Criteria__c> testWarrantyRuleCriteriaList = TestUtility.createWarrantyRuleCriteriaTestRecords();
            for(Integer i=0;i<10;i++){
                testWarrantyRuleCriteriaList[i].Warranty_Rule__c = testWarrantyRuleList[1].id;
            }
            testWarrantyRuleCriteriaList[0].Field_API_Name__c = objPrefix+NameSpace+'Account__c';
            testWarrantyRuleCriteriaList[0].Field_Name__c = 'Account';
            testWarrantyRuleCriteriaList[0].Related_Object__c = 'Account';
            testWarrantyRuleCriteriaList[0].Criteria_Type__c = 'Equals';
            testWarrantyRuleCriteriaList[0].Criteria_Value__c = string.valueOf(ac.Id);
            
            testWarrantyRuleCriteriaList[1].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[1].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[1].Criteria_Type__c = 'Equals';
            testWarrantyRuleCriteriaList[1].Criteria_Value__c = 'Parts';
            
            testWarrantyRuleCriteriaList[2].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[2].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[2].Criteria_Type__c = 'Not Equal To';
            testWarrantyRuleCriteriaList[2].Criteria_Value__c = 'Machine';
            
            testWarrantyRuleCriteriaList[3].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[3].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[3].Criteria_Type__c = 'Contains';
            testWarrantyRuleCriteriaList[3].Criteria_Value__c = 'Pa';
            
            testWarrantyRuleCriteriaList[4].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[4].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[4].Criteria_Type__c = 'Does not Contain';
            testWarrantyRuleCriteriaList[4].Criteria_Value__c = 'Mac';
            
            testWarrantyRuleCriteriaList[5].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[5].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[5].Criteria_Type__c = 'Starts With';
            testWarrantyRuleCriteriaList[5].Criteria_Value__c = 'P';
            
            testWarrantyRuleCriteriaList[6].Field_API_Name__c = objPrefix+NameSpace+'Claim_Type__c';
            testWarrantyRuleCriteriaList[6].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[6].Criteria_Type__c = 'Ends With';
            testWarrantyRuleCriteriaList[6].Criteria_Value__c = 's';
            
            testWarrantyRuleCriteriaList[7].Field_API_Name__c = objPrefix+NameSpace+'Date_of_Failure__c';
            testWarrantyRuleCriteriaList[7].Field_Name__c = 'Date of Failure';
            testWarrantyRuleCriteriaList[7].Criteria_Type__c = 'Equals';
            testWarrantyRuleCriteriaList[7].Criteria_Value__c = '11/21/2014';
            
            testWarrantyRuleCriteriaList[8].Field_API_Name__c = objPrefix+NameSpace+'Date_of_Failure__c';
            testWarrantyRuleCriteriaList[8].Field_Name__c = 'Date of Failure';
            testWarrantyRuleCriteriaList[8].Criteria_Type__c = 'Not Equal To';
            testWarrantyRuleCriteriaList[8].Criteria_Value__c = '11/21/2014';
            
            testWarrantyRuleCriteriaList[9].Field_API_Name__c = objPrefix+NameSpace+'Date_of_Failure__c';
            testWarrantyRuleCriteriaList[9].Field_Name__c = 'Date of Failure';
            testWarrantyRuleCriteriaList[9].Criteria_Type__c = 'Greater Than';
            testWarrantyRuleCriteriaList[9].Criteria_Value__c = '11/21/2014';
            
            testWarrantyRuleCriteriaList[10].Field_API_Name__c = 'CreatedDate';
            testWarrantyRuleCriteriaList[10].Field_Name__c = 'Created Date';
            testWarrantyRuleCriteriaList[10].Field_Type__c = 'DATETIME';
            testWarrantyRuleCriteriaList[10].Criteria_Type__c = 'Equals';
            testWarrantyRuleCriteriaList[10].Criteria_Value__c = '10/14/2011 11:46 AM';
                
            testWarrantyRuleCriteriaList[11].Field_API_Name__c = 'CreatedDate';
            testWarrantyRuleCriteriaList[11].Field_Name__c = 'Created Date';
            testWarrantyRuleCriteriaList[11].Field_Type__c = 'DATETIME';
            testWarrantyRuleCriteriaList[11].Criteria_Type__c = 'Not Equal To';
            testWarrantyRuleCriteriaList[11].Criteria_Value__c = '10/14/2011 11:46 AM';
                
            testWarrantyRuleCriteriaList[12].Field_API_Name__c = 'CreatedDate';
            testWarrantyRuleCriteriaList[12].Field_Name__c = 'Created Date';
            testWarrantyRuleCriteriaList[12].Field_Type__c = 'DATETIME';
            testWarrantyRuleCriteriaList[12].Criteria_Type__c = 'Greater Than';
            testWarrantyRuleCriteriaList[12].Criteria_Value__c = '10/14/2011 11:46 AM';

            testWarrantyRuleCriteriaList[13].Field_API_Name__c = 'CreatedDate';
            testWarrantyRuleCriteriaList[13].Field_Name__c = 'Created Date';
            testWarrantyRuleCriteriaList[13].Field_Type__c = 'DATETIME';
            testWarrantyRuleCriteriaList[13].Criteria_Type__c = 'Greater Or Equal';
            testWarrantyRuleCriteriaList[13].Criteria_Value__c = '10/14/2011 11:46 AM';
                
            testWarrantyRuleCriteriaList[14].Field_API_Name__c = 'CreatedDate';
            testWarrantyRuleCriteriaList[14].Field_Name__c = 'Created Date';
            testWarrantyRuleCriteriaList[14].Field_Type__c = 'DATETIME';
            testWarrantyRuleCriteriaList[14].Criteria_Type__c = 'Less Than';
            testWarrantyRuleCriteriaList[14].Criteria_Value__c = '10/14/2011 11:46 AM'; 
            
            if(CrudUtil.isWRuleCriteriaCreateable()){
                insert testWarrantyRuleCriteriaList; 
          }
          
            testWarrantyRuleList[1].Enabled__c = true;
            testWarrantyRuleList[1].Logical_Grouping__c = 'OR';
            
            if(CrudUtil.isWRuleUpdatable()){
                update testWarrantyRuleList;
          }
          
          //instantiating to cover the wrapper class
            RuleCriteriaWrapper ruleWr = new RuleCriteriaWrapper(testWarrantyRuleCriteriaList[0]);
            
            set<id> RuleIdSet = new set<id>();
            list<RuleWrapper> testRuleWrapperList = new list<RuleWrapper>();
            list<RuleWrapper> testRuleWrapperList1 = new list<RuleWrapper>();
            //getting all Warranty Rule Ids from the testWarrantyRuleList
            for(Warranty_Rule__c tempRule : testWarrantyRuleList)
            {
                RuleIdSet.add(tempRule.id);
            }
            
            testRuleWrapperList = RuleEngine.getRulesList(RuleIdSet,objPrefix+'Claim__c');
            testRuleWrapperList1 = RuleEngine.executeRule(clmList[0],testRuleWrapperList,objPrefix+'Claim__c');
            //system.assertEquals(1,testRuleWrapperList.size());
                    
            /*******TEST SCENARIO 2 : Test for fetching all validated rules for a claim********/
     
           /* list<Policy_Definition__c> testPolicyDefinitionList1 = TestUtility.createPolicyDefinitionTestRecords();
            if(CrudUtil.isPolicyDefinitionCreatable()){
                insert testPolicyDefinitionList1;
          }*/
          
            list<Warranty_Rule_Association__c> testWarrantyRuleAssociationTestRecords = TestUtility.createWarrantyRuleAssociationTestRecords();
            for(Integer i=0;i<testWarrantyRuleAssociationTestRecords.size();i++)
                {
                   testWarrantyRuleAssociationTestRecords[i].Policy_Definition__c=tempPolicyDefinitionRecordsList[i].id;
                   testWarrantyRuleAssociationTestRecords[i].Warranty_Rule__c=testWarrantyRuleList[1].Id;
                }
            if(CrudUtil.isWRuleAssociationCreatable()){
                insert testWarrantyRuleAssociationTestRecords;
          }    
          //system.debug('PD1-&7------' +testClaimList[1].id);
            list<sObject> finalPDList = RuleEngine.RunEligibityRules(clmList[0],new set<Id>{tempPolicyDefinitionRecordsList[0].Id});
            //system.debug('PD1-------' + finalPDList);
          
            RuleManager objRuleManager = new RuleManager();
            objRuleManager.getSelectedValue(testWarrantyRuleCriteriaList[0],ac.Id);
          
        }
        Test.stopTest();
    } 
    
}