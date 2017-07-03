/**********************************************************************
 Name:  TestUtility
 Copyright ? 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Contains unit tests for validating the behavior of Apex classes and triggers.
                                                     -------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Abhishek        11/11/2014      INITIAL DEVELOPMENT            
***********************************************************************/

@isTest
global class TestUtility {
    global static string NameSpace = SystemUtils.getNameSpace();
    /********************************************************************
    PURPOSE:   To Create Test Records for Payment Definition Object                                                
    PARAMETERS: N/A
    RETURNS: list of Payment Definition Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/    
    global static testmethod list<Payment_Definitions__c> createPaymentDefinitionsTestRecords(){
           
        list<Payment_Definitions__c> testPaymentDefinitionList = new list<Payment_Definitions__c>();
    
        for(integer i=0;i<10;i++){
                
                Payment_Definitions__c tempPaymentDefinition = new Payment_Definitions__c();
                if(Schema.sObjectType.Payment_Definitions__c.fields.Is_Default__c.isUpdateable() &&
                   Schema.sObjectType.Payment_Definitions__c.fields.Status__c.isUpdateable()
                )
                {
                    tempPaymentDefinition.Is_Default__c=false;
                    tempPaymentDefinition.Status__c='Inactive';
                }                   
                testPaymentDefinitionList.add(tempPaymentDefinition);
        }
        
        system.assertNotEquals(null,testPaymentDefinitionList);
        
        return testPaymentDefinitionList; 
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Payment Definition Items Object                                                
    PARAMETERS: N/A
    RETURNS: list of Payment Definition Item Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/ 
    global static testmethod list<Payment_Definition_Items__c> createPaymentDefinitionItemTestRecords(){              
            CustomSettingsUtilityTest.init();
            list<Payment_Definitions__c> testPaymentDefinitionList = createPaymentDefinitionsTestRecords();
            list<Payment_Configuration__c> testPaymentConfigurationList = createPaymentConfigurationTestRecords();
            
           // If(CrudUtil.isPaymentDefinitionCreateable())
                insert testPaymentDefinitionList;
           // If(CrudUtil.isPaymentConfigurationCreateable())
                insert testPaymentConfigurationList;
            
            system.assertNotEquals(null,testPaymentDefinitionList);
            system.assertNotEquals(null,testPaymentConfigurationList);
            
            list<Payment_Definition_Items__c> testPaymentDefinitionItemList = new list<Payment_Definition_Items__c>();
      for(integer i=1;i<10;i++)
                {
                    Payment_Definition_Items__c tempPaymentDefinitionItem = new Payment_Definition_Items__c();
                    tempPaymentDefinitionItem.Payment_Definition__c = testPaymentDefinitionList[i-1].id;
                    tempPaymentDefinitionItem.Payment_Configuration__c = testPaymentConfigurationList[i-1].id;
                    testPaymentDefinitionItemList.add(tempPaymentDefinitionItem);
                }

            return testPaymentDefinitionItemList;        
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Payment Configuration Object                                                
    PARAMETERS: N/A
    RETURNS: list of Payment Configuration Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
     global static testmethod list<Payment_Configuration__c> createPaymentConfigurationTestRecords(){
        
        
        list<Payment_Configuration__c> testPaymentConfigurationList = new list<Payment_Configuration__c>();
        if(Schema.sObjectType.Payment_Configuration__c.fields.Name.isUpdateable() &&
            Schema.sObjectType.Payment_Configuration__c.fields.Is_Mandatory__c.isUpdateable() 
        )
        {
            for(Integer i=0;i<10;i++){
            
                    Payment_Configuration__c tempPaymentConfiguration = new Payment_Configuration__c();
                    tempPaymentConfiguration.Name='TestPaymentConfiguration '+(i+1);
                    tempPaymentConfiguration.Is_Mandatory__c = false;
                    testPaymentConfigurationList.add(tempPaymentConfiguration); 
            }
        }
        
        system.assertNotEquals(null,testPaymentConfigurationList);
        
        return testPaymentConfigurationList;
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Account Object                                                
    PARAMETERS: N/A
    RETURNS: list of Account Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
     global static testmethod list<Account> createAccountTestRecords(){                
            
            Account ac = new Account(Name = 'forTest');
            If(CrudUtil.isAccountCreateable())
                insert ac;
            
            system.assertNotEquals(null,ac);
            
            list<Account> testAccountRecords = new list<Account>();
            if(Schema.sObjectType.Account.fields.Name.isUpdateable() &&
                Schema.sObjectType.Account.fields.ParentId.isUpdateable() 
            )
            {
                for(Integer i=0;i<10;i++){
                        
                        Account tempAccountObj=new Account();
                        tempAccountObj.Name='TestingAccountRecord'+i;
                        tempACCountObj.ParentId= ac.Id;
                        tempACCountObj.Warranty_Account_Type__c='Dealer';
                        testAccountRecords.add(tempAccountObj);
                }
            }    
                
            return testAccountRecords;                    
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Account Object                                                
    PARAMETERS: N/A
    RETURNS: list of Account Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/ 
    global static testmethod list<Contact> createContactTestRecords(){        
               
            
            list<Account> testAccountList = TestUtility.createAccountTestRecords();
            If(CrudUtil.isAccountCreateable())
                insert testAccountList;
            
            system.assertNotEquals(null,testAccountList);
            
            list<Contact> testContactList = new list<Contact>();
            if(Schema.sObjectType.Contact.fields.LastName.isUpdateable()   )
            {
                for(Integer i=0;i<10;i++)
                {
                    Contact tempContact =new Contact();
                    tempContact.LastName='last';
                    tempContact.accountid = testAccountList[i].id;
                    testContactList.add(tempContact);
                }
            }
            return testContactList;        
                
    }
    
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Inventory Object                                                
    PARAMETERS: N/A
    RETURNS: list of Inventory Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/    
    global static testmethod list<Inventory__c> createInventoryTestRecords(){
            
            list<Account> tempAccountRecordsList = createAccountTestRecords();
            If(CrudUtil.isAccountCreateable())
                insert tempAccountRecordsList;
            
            system.assertNotEquals(null,tempAccountRecordsList);
            
            list<Inventory__c> testInventoryRecords = new list<Inventory__c>();
            if(Schema.sObjectType.Inventory__c.fields.Name.isUpdateable() &&
                Schema.sObjectType.Inventory__c.fields.Serial_Number__c.isUpdateable() &&
                Schema.sObjectType.Inventory__c.fields.Install_Date__c.isUpdateable() 
            )
            {
                for(Integer i=0;i<10;i++){
                
                        Inventory__c tempInventoryObj = new Inventory__c();
                        tempInventoryObj.Name='TestingInventoryReocrd '+i;
                        tempInventoryObj.Serial_Number__c='XYZ'+i;
                        tempInventoryObj.Account__c=tempAccountRecordsList[0].Id;
                        tempInventoryObj.Install_Date__c=System.today();
                        tempInventoryObj.Asset_Type__c = 'Warrantable';
                        testInventoryRecords.add(tempInventoryObj);
                }
            }
            
            system.assertNotEquals(null,testInventoryRecords);
            
            return testInventoryRecords;        
          
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Policy Definition Object                                                
    PARAMETERS: N/A
    RETURNS: list of Policy Definition Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod list<Policy_Definition__c> createPolicyDefinitionTestRecords(){
    
            
            list<Policy_Definition__c> testPolicyDefinitionRecords = new list<Policy_Definition__c>();
            /*
            if(Schema.sObjectType.Policy_Definition__c.fields.Name.isUpdateable() &&
                Schema.sObjectType.Policy_Definition__c.fields.Status__c.isUpdateable() &&
                Schema.sObjectType.Policy_Definition__c.fields.Active_From__c.isUpdateable() &&
                Schema.sObjectType.Policy_Definition__c.fields.Active_Until__c.isUpdateable()&&
                Schema.sObjectType.Policy_Definition__c.fields.Months_Covered__c.isUpdateable()
            )
            {*/
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
                        
                        
                        testPolicyDefinitionRecords.add(tempPolicyDefinitionObj);
                }
            /*}*/
            
            system.assertNotEquals(null,testPolicyDefinitionRecords);
            
            return testPolicyDefinitionRecords;
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for WarrantyRegistration Object                                                
    PARAMETERS: N/A
    RETURNS: list of WarrantyRegistration Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod list <Warranty_Registration__c> createWarrantyRegistrationTestRecords(){
                
            
            list<Account> tempAccountRecordsList = createAccountTestRecords();
            If(CrudUtil.isAccountCreateable())
                insert tempAccountRecordsList;
            
            system.assertNotEquals(null,tempAccountRecordsList);
            
            list<Warranty_Registration__c> testWarrantyRegistrationRecordsList = new list<Warranty_Registration__c>();
            if(Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isUpdateable() &&
                Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isUpdateable() 
            )
            {
                for(Integer i=0;i<10;i++){
                        
                        Warranty_Registration__c tempWarrantyRegistrationObj = new Warranty_Registration__c();
                        tempWarrantyRegistrationObj.Account__c=tempAccountRecordsList[i].id;
                        tempWarrantyRegistrationObj.Registration_Date__c=System.today();
                        testWarrantyRegistrationRecordsList.add(tempWarrantyRegistrationObj);
                }
            }
            return testWarrantyRegistrationRecordsList;       
        
            
    }
    /********************************************************************
    PURPOSE:   To Create Test Records for WarrantyCoverage Object                                                
    PARAMETERS: N/A
    RETURNS: list of WarrantyCoverage Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/ 
   global static testmethod list<Warranty_Coverages__c>createWarrantyCoverageTestRecords(){
         
            
            list<Warranty_Registration__c> tempWarrantyRegistrationRecordsList = createWarrantyRegistrationTestRecords();
            If(CrudUtil.isWRCreateable())
                insert tempWarrantyRegistrationRecordsList;
            
            system.assertNotEquals(null,tempWarrantyRegistrationRecordsList);
            
            list<Policy_Definition__c> tempPolicyDefinitionRecordsList = createPolicyDefinitionTestRecords();
            If(CrudUtil.isPolicyDefinitionCreatable())
                insert tempPolicyDefinitionRecordsList;
            
            list<Warranty_Coverages__c> testWarrantyCoverageRecordsList = new list<Warranty_Coverages__c>();
            if( Schema.sObjectType.Warranty_Coverages__c.fields.Is_Active__c.isUpdateable() &&
                Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Start_Date__c.isUpdateable() &&
                Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_End_Date__c.isUpdateable() 
            )
            {
                for(Integer i=0;i<10;i++){
                
                        Warranty_Coverages__c tempWarrantyCoverageObj = new Warranty_Coverages__c();
                        tempWarrantyCoverageObj.Warranty_Registration__c=tempWarrantyRegistrationRecordsList[i].id;
                        tempWarrantyCoverageObj.Policy_Definition__c=tempPolicyDefinitionRecordsList[i].Id;
                        tempWarrantyCoverageObj.Is_Active__c=true;
                        tempWarrantyCoverageObj.Warranty_Start_Date__c=(system.today()-1);
                        tempWarrantyCoverageObj.Warranty_End_Date__c=(system.today()+1);
                    tempWarrantyCoverageObj.Maximum_Unit__c=0;
                        testWarrantyCoverageRecordsList.add(tempWarrantyCoverageObj);
                
                }
            }            
            return testWarrantyCoverageRecordsList;        
                  
   }
   
    /********************************************************************
    PURPOSE:   To Create Test Records for WarrantyRule Object                                                
    PARAMETERS: N/A
    RETURNS: list of WarrantyRule Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/ 
   global static testmethod list<Warranty_Rule__c> createWarrantyRuleTestRecords(){
    
            
            list<Warranty_Rule__c> testWarrantyRuleRecordsList = new list<Warranty_Rule__c>();
            
            String objPrefix = SObjectType.Warranty_Rule__c.Name.substringBefore(NameSpace+'Warranty_Rule__c');
            
            if(Schema.sObjectType.Warranty_Rule__c.fields.Name.isUpdateable()&&
               Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isUpdateable()&&
               Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isUpdateable())    
            {
                for(Integer i=0;i<10;i++){
                    
                        Warranty_Rule__c tempWarrantyRuleObj = new Warranty_Rule__c();
                        tempWarrantyRuleObj.Name='TestingWarrantyRule'+i;
                        tempWarrantyRuleObj.Object_Type__c='Claim';
                        tempWarrantyRuleObj.Object_API_Name__c=objPrefix+NameSpace+'Claim__c';
                        
                        testWarrantyRuleRecordsList.add(tempWarrantyRuleObj);
                }
            }
            system.assertNotEquals(null,testWarrantyRuleRecordsList);
            
            return testWarrantyRuleRecordsList;
   }
   
    /********************************************************************
    PURPOSE:   To Create Test Records for WarrantyRuleAssociation Object                                                
    PARAMETERS: N/A
    RETURNS: list of WarrantyRuleAssociation Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/ 
   global static testmethod list<Warranty_Rule_Association__c> createWarrantyRuleAssociationTestRecords(){
     
            
            list<Warranty_Rule_Association__c> testWarrantyRuleAssociationRecordsList = new list<Warranty_Rule_Association__c>();
            
            list<Policy_Definition__c> tempPolicyDefinitionRecordsList = new list<Policy_Definition__c>();//createPolicyDefinitionTestRecords();
            
           // for(Integer i=0; i<10; i++){
            Policy_Definition__c tempPolicyDefinitionObj = new Policy_Definition__c();
                        if(Schema.sObjectType.Policy_Definition__c.fields.Name.isUpdateable())
                          tempPolicyDefinitionObj.Name='testingPolicyDefinitionX';
                        if(Schema.sObjectType.Policy_Definition__c.fields.Status__c.isUpdateable())
                          tempPolicyDefinitionObj.Status__c='Draft';
                        if(Schema.sObjectType.Policy_Definition__c.fields.Active_From__c.isUpdateable())
                          tempPolicyDefinitionObj.Active_From__c=(system.today()-1);
                        if(Schema.sObjectType.Policy_Definition__c.fields.Active_Until__c.isUpdateable())
                          tempPolicyDefinitionObj.Active_Until__c=(system.today()+1);
                        if(Schema.sObjectType.Policy_Definition__c.fields.Months_Covered__c.isUpdateable())
                          tempPolicyDefinitionObj.Months_Covered__c = 24;
                        if(Schema.sObjectType.Policy_Definition__c.fields.Priority__c.isUpdateable())
                          tempPolicyDefinitionObj.Priority__c = 10000;
                        tempPolicyDefinitionRecordsList.add(tempPolicyDefinitionObj);              
            //}
            If(CrudUtil.isPolicyDefinitionCreatable())
                insert tempPolicyDefinitionRecordsList;
            
            system.assertNotEquals(null,tempPolicyDefinitionRecordsList);
            
            list<Warranty_Rule__c> tempWarrantyRuleRecordsList = createWarrantyRuleTestRecords();
            If(CrudUtil.isWRuleCreateable())
                insert tempWarrantyRuleRecordsList;
            
            system.assertNotEquals(null,tempWarrantyRuleRecordsList);
            
            if(Schema.sObjectType.Warranty_Rule_Association__c.fields.Policy_Definition__c.isUpdateable()&&
               Schema.sObjectType.Warranty_Rule_Association__c.fields.Is_Active__c.isUpdateable())    
            {
                for(Integer i=0;i<1;i++)
                {
                    
                    Warranty_Rule_Association__c tempWarrantyRuleAssociationObj = new Warranty_Rule_Association__c();
                    tempWarrantyRuleAssociationObj.Policy_Definition__c=tempPolicyDefinitionRecordsList[i].id;
                    tempWarrantyRuleAssociationObj.Warranty_Rule__c=tempWarrantyRuleRecordsList[i].Id;
                    tempWarrantyRuleAssociationObj.Is_Active__c=true;

                    testWarrantyRuleAssociationRecordsList.add(tempWarrantyRuleAssociationObj);
                
                }
            }
            return testWarrantyRuleAssociationRecordsList;       
        
       
            
   } 
    
   /********************************************************************
    PURPOSE:   To Create Test Records for WarrantyRuleCriteria Object                                                
    PARAMETERS: N/A
    RETURNS: list of WarrantyRuleCriteria Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/ 
   global static testmethod list<Warranty_Rule_Criteria__c> createWarrantyRuleCriteriaTestRecords(){
        
            list<Warranty_Rule__c> tempWarrantyRuleRecordsList = createWarrantyRuleTestRecords();
            If(CrudUtil.isWRuleCreateable())
                insert tempWarrantyRuleRecordsList;
            
            String objPrefix = SObjectType.Warranty_Rule_Criteria__c.Name.substringBefore(NameSpace+'Warranty_Rule_Criteria__c');
            
            system.assertNotEquals(null,tempWarrantyRuleRecordsList);
            
            list<Warranty_Rule_Criteria__c> testWarrantyRuleCriteriaRecordsList = new list<Warranty_Rule_Criteria__c>();
            
            if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isUpdateable()&&
               Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isUpdateable())    
            {
                for(Integer i=0;i<15;i++){
                        
                        Warranty_Rule_Criteria__c tempWarrantyRuleCriteriaObj = new Warranty_Rule_Criteria__c();
                        tempWarrantyRuleCriteriaObj.Warranty_Rule__c=tempWarrantyRuleRecordsList[math.mod(i,10)].id;
                        tempWarrantyRuleCriteriaObj.Field_API_Name__c=objPrefix+NameSpace+'Claim_Type__c';
                        tempWarrantyRuleCriteriaObj.Criteria_Value__c = 'Machine';
                        tempWarrantyRuleCriteriaObj.Criteria_Type__c = 'Equals';
                        tempWarrantyRuleCriteriaObj.Field_Type__c = 'PICKLIST';
                        tempWarrantyRuleCriteriaObj.Field_Name__c = 'Claim Type';
                        tempWarrantyRuleCriteriaObj.Sequence__c= i ;
                        testWarrantyRuleCriteriaRecordsList.add(tempWarrantyRuleCriteriaObj);
                }
            }
            system.assertNotEquals(null,testWarrantyRuleCriteriaRecordsList);
            
            return testWarrantyRuleCriteriaRecordsList;      
        
        
   }
    /********************************************************************
    PURPOSE:   To Create Test Records for Claim Object                                                
    PARAMETERS: N/A
    RETURNS: list of Claim Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod list<Claim__c> createClaimTestRecords(){
           
           list<Account> tempAccountRecordsList = createAccountTestRecords();
            If(CrudUtil.isAccountCreateable())
                insert tempAccountRecordsList;
            
            system.assertNotEquals(null,tempAccountRecordsList);
            
            list<Claim__c> testClaimRecords = new list<Claim__c>();
            
            if(Schema.sObjectType.Claim__c.fields.Name.isUpdateable()&&
               Schema.sObjectType.Claim__c.fields.Account__c.isUpdateable())
            {
                for(Integer i=0;i<10;i++){
                        
                        Claim__c tempClaimObj = new Claim__c();
                        //tempClaimObj.Name='TempClaim'+i;
                        tempClaimObj.Account__c=tempAccountRecordsList[i].id;
                        tempClaimObj.Date_of_Failure__c=system.today();
                        tempClaimObj.Units_Run__c=10;
                        testClaimRecords.add(tempClaimObj);
                }
            }
            system.assertNotEquals(null,testClaimRecords);
            
            return testClaimRecords;                 
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Policy Applicability Term Object                                                
    PARAMETERS: N/A
    RETURNS: list of Policy Applicability Term Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod list<Policy_Applicability_Term__c> createPATTestRecords(){
              
            list<Policy_Definition__c> tempPolicyDefinitionRecordsList = createPolicyDefinitionTestRecords();
            If(CrudUtil.isPolicyDefinitionCreatable())
                insert tempPolicyDefinitionRecordsList;
            
            system.assertNotEquals(null,tempPolicyDefinitionRecordsList);
            
            list<Policy_Applicability_Term__c> testPATRecordsList = new list<Policy_Applicability_Term__c>();
            
            if(Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isUpdateable()&&
               Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isUpdateable()&&
               Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isUpdateable()&&
               Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable())
            {
                for(Integer i=0;i<10;i++){
                
                    Policy_Applicability_Term__c tempPATObj = new Policy_Applicability_Term__c();
                    tempPATObj.Policy_Definition__c=tempPolicyDefinitionRecordsList[i].id;
                    tempPATObj.Applicability_Label__c='Test';
                    tempPATObj.Applicability_SubType__c='Account';
                    if(i==2){
                        tempPATObj.Applicability_Term_Type__c='Referred by Text';
                        tempPATObj.WR_Field_Mapping__c=NameSpace+'Account__r.type';
                    }else{
                        tempPATObj.Applicability_Term_Type__c='Referred by ID';
                        tempPATObj.WR_Field_Mapping__c=NameSpace+'Account__c';
                    }
                    
                    
                    testPATRecordsList.add(tempPATObj);
                }
            }
            
            system.assertNotEquals(null,testPATRecordsList);              
            return testPATRecordsList;
           
    } 
    
        
    /********************************************************************
    PURPOSE:   To Create Single Test Records for Policy Applicability Term Object                                                
    PARAMETERS: N/A
    RETURNS: A Single Policy Applicability Term Record
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
     global static testmethod Policy_Applicability_Term__c createSinglePATRecord(){
             
           list<Policy_Definition__c> tempPolicyDefinitionRecordsList = createPolicyDefinitionTestRecords();
            If(CrudUtil.isPolicyDefinitionCreatable())
                insert tempPolicyDefinitionRecordsList;
            
            system.assertNotEquals(null,tempPolicyDefinitionRecordsList);
            Policy_Applicability_Term__c tempPATRecord=new Policy_Applicability_Term__c();
                
            if(Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isUpdateable()&&
               Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isUpdateable()&&
               Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isUpdateable())
            {
                tempPATRecord.Policy_Definition__c=tempPolicyDefinitionRecordsList[0].id;
                tempPATRecord.Applicability_Label__c='Test';
                tempPATRecord.Applicability_SubType__c='Account';
                tempPATRecord.Applicability_Term_Type__c='fghfg';
            }
            system.assertNotEquals(null,tempPATRecord);
            
            return tempPATRecord;
          
     }
    
    /********************************************************************
    PURPOSE:   To Create Records for Custom Settting                                                
    PARAMETERS: N/A
    RETURNS: list of Custom Setting Record
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod Lookup_Layout_Fields__c createCustomSetting(){
    
      Lookup_Layout_Fields__c testCustomSetting=Lookup_Layout_Fields__c.getValues('Account'); 
       if(testCustomSetting==null){
            testCustomSetting=new Lookup_Layout_Fields__c(Name='Account');
            testCustomSetting.Field1__c='Name';
            testCustomSetting.Field2__c=NameSpace+'Active__c';
            testCustomSetting.Field3__c=NameSpace+'SLA__c';
            testCustomSetting.Field4__c=NameSpace+'Warranty_Account_Type__c';
            testCustomSetting.Field5__c=NameSpace+'NumberOfLocations__c';
            testCustomSetting.Limit__c=10;
       }
        
       system.assertNotEquals(null,testCustomSetting);  
       return testCustomSetting;
    }
    /********************************************************************
    PURPOSE:   To Create Warranty Register Record                                                
    PARAMETERS: N/A
    RETURNS: Warranty Register Record
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod Warranty_Registration__c createTestdataWR(){
        
        Warranty_Registration__c warrantyReg = new Warranty_Registration__c();
        if(Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isUpdateable())
        {
            warrantyReg.Registration_Date__c = System.today();
        }
        system.assertNotEquals(null,warrantyReg);
        return warrantyReg;
    }
    /********************************************************************
    PURPOSE:   To Create Policy Definition Record                                               
    PARAMETERS: N/A
    RETURNS: Policy Definition Record
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod Policy_Definition__c createTDPolDef(){
        
        Policy_Definition__c poldef = new Policy_Definition__c();      
        if(Schema.sObjectType.Policy_Definition__c.fields.Months_Covered__c.isUpdateable()&&
           Schema.sObjectType.Policy_Definition__c.fields.Active_From__c.isUpdateable()&&
           Schema.sObjectType.Policy_Definition__c.fields.Active_Until__c.isUpdateable()&&
           Schema.sObjectType.Policy_Definition__c.fields.Status__c.isUpdateable())
        {
            poldef.Months_Covered__c = 6;
            poldef.Active_From__c = System.today()-182;
            poldef.Active_Until__c = System.today()+365;
            poldef.Status__c = 'Active';
            
        }  
        system.assertNotEquals(null,poldef);
        return poldef;
    }
    /********************************************************************
    PURPOSE:   To Policy Applicability Term Records                                                
    PARAMETERS: N/A
    RETURNS: Policy Applicability Term Record
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod Policy_Applicability_Term__c createTDPAT(){
        
        Policy_Applicability_Term__c pat = new Policy_Applicability_Term__c();
        
        system.assertNotEquals(null,pat);
        
        return pat;
    } 
    
    /********************************************************************
    PURPOSE:   To Create Test Records for rate detail Object                                                
    PARAMETERS: N/A
    RETURNS: list of rate detail Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
     global static testmethod Rates_Details__c createRateDetail(){                
            
           Rates_Details__c rDetail = new Rates_Details__c();
            rDetail.name = 'tews34';
            rDetail.Active_From__c = system.today();
            rDetail.Active_Until__c = system.today();
            rDetail.Status__c = 'Active';
            return rDetail;                            
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Warranty Product Object                                                
    PARAMETERS: N/A
    RETURNS: list of rate detail Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod Warranty_Product__c createWarrantyProduct(){                
        
       Warranty_Product__c TestWarrantyProduct = new Warranty_Product__c();
        if(Schema.sObjectType.Warranty_Product__c.fields.Type__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Product__c.fields.Item_Type__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Product__c.fields.Product_Name__c.isUpdateable())
        {   
            Integer milli=DateTime.now().millisecond();
            TestWarrantyProduct.Name = 'Engine'+milli;
            TestWarrantyProduct.Type__c = 'Item';
            TestWarrantyProduct.Item_Type__c = 'Parts';
            TestWarrantyProduct.Product_Name__c = 'Engine'; 
        }
        return TestWarrantyProduct ;                        
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Warranty Pricebook                                               
    PARAMETERS: N/A
    RETURNS: list of rate detail Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod Warranty_Product_Pricebook__c createWarrantyPricebook(){    
        
        Warranty_Product__c TestWarrantyProduct = createWarrantyProduct();
        Warranty_Product_Pricebook__c testPricebook = new Warranty_Product_Pricebook__c();
        if(Schema.sObjectType.Warranty_Product_Pricebook__c.fields.Country__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Product_Pricebook__c.fields.Valid_From__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Product_Pricebook__c.fields.Valid_Until__c.isUpdateable())
        {
            testPricebook.Valid_From__c = date.parse('8/12/1990');
            testPricebook.Valid_Until__c = date.parse('8/12/2099'); 
            testPricebook.Warranty_Product__c = TestWarrantyProduct.Id;
        }
        return testPricebook ;                        
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for Claim Part                                              
    PARAMETERS: N/A
    RETURNS: list of rate detail Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod list<Claim_Part__c> createClaimPartList(){    
        
        list<Claim_Part__c> TestClaimPartList = new list<Claim_Part__c>();
                    
        if(Schema.sObjectType.Claim_Part__c.isCreateable() && 
           Schema.sObjectType.Claim_Part__c.fields.Quantity__c.isUpdateable()&&
           Schema.sObjectType.Claim_Part__c.fields.Type__c.isUpdateable())
        {
            for(integer i=0;i<10;i++)
            {
                Claim_Part__c testCP = new Claim_Part__c();
                testCP.Name = 'CP-001'+i;
                testCP.Quantity__c = 0.5;
                testCP.Type__c = 'Installed Part';
                TestClaimPartList.add(testCP);
            } 
        }
        return TestClaimPartList ;                        
    }
    
    /********************************************************************
    PURPOSE:   To Create Test Records for single Payment Configuration                                               
    PARAMETERS: N/A
    RETURNS: list of rate detail Records
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static testmethod Payment_Configuration__c createPaymentConfiguration(){    
                    
        Payment_Configuration__c testPC = new Payment_Configuration__c();
        if(Schema.sObjectType.Payment_Configuration__c.fields.Claim_Field_Name__c.isUpdateable())
        {
            testPC.Name = 'Labor Fee';
            testPC.Claim_Field_Name__c = 'Labor';
            
        }
        return testPC ;                        
    }
    
    
  /******************************************************************
   * Purpose : Method to create warranty product data. 
   *******************************************************************/
   global static Warranty_Product__c createWarrantyProduct(String pCode, String pName, String type, String itemType, String trackType, String UOM, Id parentId){
       Warranty_Product__c wp = new Warranty_Product__c();
       wp.name                = pCode;
       wp.Product_Name__c     = pName;
       wp.Type__c             = type;
       wp.Item_Type__c        = itemType;
       wp.Track_Type__c       = trackType;
       wp.Units_of_Measure__c = UOM;
       wp.Parent_Product__c   = parentId;
       return wp;
   }
   
   
    
   /******************************************************************
   * Purpose : Method to create inventory data.
   *******************************************************************/
   global static Inventory__c createInventory(String invName, String serialNumber, String assetType, String type, Id accountId, Id itemId, Id invId){
       
       
       Inventory__c  inv = new Inventory__c ();
       inv.Name             = invName;
       inv.Serial_Number__c = serialNumber;
       inv.Asset_Type__c    = assetType;
       inv.Type__c          = type;
       inv.Account__c       = accountId;
       inv.Item__c          = itemId;
       inv.Inventory__c     = invId;
       return inv;
   }
   
   
   /******************************************************************
   * Purpose : Method to create Warranty Registration data.
   *******************************************************************/
   global static Warranty_Registration__c createWarrantyRegistration(String wName, Id accountId, Id invId, String status){
       
       
       Warranty_Registration__c wr = new Warranty_Registration__c();
       wr.name                    = wName;
       wr.Account__c              = accountId;
       wr.Customer__c             = accountId;
       wr.Inventory__c            = invId;
       wr.Status__c               = status;
       wr.Registration_Date__c    = date.today();             
       return wr;
   }
   
   /******************************************************************
   * Purpose : Method to create Warranty coverages data.
   *******************************************************************/
   global static Warranty_Coverages__c createWarrantyCoverages(Id WRId, Id PDID){
       
       
       Warranty_Coverages__c wc = new Warranty_Coverages__c();
       wc.Warranty_Registration__c  = WRId;
       wc.Policy_Definition__c      = PDID;
       wc.Warranty_Start_Date__c    = date.today();
       wc.Warranty_End_Date__c      = date.today();
       return wc;      
   }
   
   /******************************************************************
   * Purpose : Method to create policy definition data.
   *******************************************************************/
   global static Policy_Definition__c createPolicyDefinition(String pdName, Id paymentDefId, Integer Priority){
       
      
       Policy_Definition__c pd = new Policy_Definition__c();
       pd.Name                   = pdName;
       pd.Active_From__c         = date.today();
       pd.Type__c                = 'Standard';
       pd.Active_Until__c        = date.today();
       pd.Priority__c            = Priority;
       pd.Status__c              = 'Active';
       pd.Payment_Definition__c  = paymentDefId;
       pd.Months_Covered__c      = 12;      
       return pd;
   }
   
   /******************************************************************
   * Purpose : Method to create Policy Applicability Terms data.
   *******************************************************************/
   global static Policy_Applicability_Term__c createPolicyApplicabilityTerm(Id pdID,String pdName,String applicabilityValue){
       
       
       Policy_Applicability_Term__c pat = new Policy_Applicability_Term__c();
       pat.Applicability_Term_Type__c = 'Referred by ID';
       pat.Applicability_SubType__c   = NameSpace+'Warranty_Product__c';
       pat.Policy_Definition__c       =  pdID;
       pat.Applicability_Label__c     =  pdName;
       pat.Applicability_Value__c = applicabilityValue;
       return pat;      
   }
    
   /******************************************************************
   * Purpose : Method to create warranty code data.
   *******************************************************************/
   global static Warranty_Code__c createWarrantyCode(String wCodeName,Id wpID, Id recordTypeId){
       
       
       Warranty_Code__c warrantyCode = new Warranty_Code__c();
       warrantyCode.Name                         = wCodeName;
       warrantyCode.Warranty_Product__c          = wpID;
       warrantyCode.Standard_Labor_Hour__c       =  10;
       warrantyCode.RecordTypeID                 =  recordTypeId;            
       return warrantyCode;      
   }
   
   /******************************************************************
   * Purpose : Method to create FaultCode Mapper data.
   *******************************************************************/
   global static FaultCode_Mapper__c createFaultCodeMapper(String faultMapperName,Id faultCodeID,Id wpID){
       
      
       FaultCode_Mapper__c faultMapper = new FaultCode_Mapper__c();
       faultMapper.Name                          = faultMapperName;
       faultMapper.Fault_Code__c                 = faultCodeID;
       faultMapper.Warranty_Product__c           =  wpID;
       faultMapper.Status__c                     =  true;       
       return faultMapper;      
   }
   
   /******************************************************************
   * Purpose : Method to create service campaign data.
   *******************************************************************/
   global static Service_Campaign__c createServiceCampaign(Id claimTemplateId,Id paymentDefId){
       
       
       Service_Campaign__c servicecampaign = new Service_Campaign__c();
       servicecampaign.Name                          = 'Test Service Campaign';
       servicecampaign.Start_Date__c                 = date.today();
       servicecampaign.End_Date__c                   =  date.today();
       servicecampaign.Claim_Template__c             =  claimTemplateId; 
       servicecampaign.Payment_Definitions__c        =  paymentDefId;        
       return servicecampaign;      
   } 
    
   /******************************************************************
   * Purpose : Method to create campaign memebers data.
   *******************************************************************/
   global static Campaign_Members__c createCampaignMember(Id invId,Id serviceCampaignId){
       
       
       Campaign_Members__c campaignMember = new Campaign_Members__c();
       campaignMember.Inventory__c                       = invId;
       campaignMember.Service_Campaign__c                = serviceCampaignId;       
       return campaignMember;      
   }
   
   /******************************************************************
   * Purpose : Method to create claim parts data.
   *******************************************************************/
   global static Claim_Part__c createClaimPart(String claimPartName,String type, Id wpId, Integer quantity, Id claimId, Id InvId){
       
       
       Claim_Part__c claimPart = new Claim_Part__c();
       claimPart.Name                        = claimPartName;
       claimPart.Type__c                     = type;  
       claimPart.Warranty_Product__c         = wpId; 
       claimPart.Quantity__c                 = quantity; 
       claimPart.Claim__c                    = claimId; 
       claimPart.Inventory__c                = InvId;
       return claimPart;      
   }
    
   /******************************************************************
   * Purpose : Method to create claim service information data.
   *******************************************************************/
   global static Claim_Service_Information__c createClaimService(Id jobCode, Integer quantity, Id claimId){
       
       
       Claim_Service_Information__c claimService = new Claim_Service_Information__c();
       claimService.Name                         = 'Test Claim Service';
       claimService.Service_Job_Code__c          = jobCode;  
       claimService.Total_Labor_hours__c         = quantity;
       claimService.claim__c                     = claimId;
       return claimService;      
   }   
}