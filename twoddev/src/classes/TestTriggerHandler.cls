/**********************************************************************
 Name:  TestTriggerHandler
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Test class for PaymentDefinitionTriggerHandler , PaymentDefinitionItemTriggerHandler , TriggerHandler
                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Vino        11/21/2014      INITIAL DEVELOPMENT       
   2.0      Abhishek    21/11/2014      ADDED ONE METHOD FOR AFTER INSERTION 
***********************************************************************/

@isTest
private class TestTriggerHandler {
    public static string NameSpace = SystemUtils.getNameSpace();    
    /*******************************************************************
    PURPOSE:   To test AfterInsert Event of CorePaymentDefinitionTrigger                                                   
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    public static testmethod void testAfterInsertionForPaymentDefinitionRecord(){
        
        /*******TEST SCENARIO 1 : Test for afterInert function of PaymentDefinitionTriggerHandler ********/
        
        //Creating and Inserting Test Records for Payment Configuration
        CustomSettingsUtilityTest.init();
        list<Payment_Configuration__c> paymentConfigurationTestRecordList=TestUtility.createPaymentConfigurationTestRecords();
        
        Test.startTest();
        
        if(Schema.sObjectType.Payment_Configuration__c.fields.Is_Mandatory__c.isCreateable())
        {
            for(Integer i=0;i<10;i++){
                paymentConfigurationTestRecordList[i].Is_Mandatory__c=true;  
            }
            
            if(CrudUtil.isPaymentConfigurationCreateable()){
                insert paymentConfigurationTestRecordList;
            }
    
            //fetching records with active and default definitions
            String soql = new SoqlBuilder()
            .selectx(NameSpace+'Payment_Definition__c')
            .selectx(NameSpace+'Payment_Configuration__c')
            .fromx(NameSpace+'Payment_Definition_Items__c')
            .wherex(new FieldCondition(NameSpace+'Is_Mandatory__c').equals(true))
            .toSoql();
         
            list<Payment_Definition_Items__c> resultPaymentDefinitionItemsList = database.query(soql);
            System.assertNotEquals(null,resultPaymentDefinitionItemsList);
        }
        Test.stopTest();
    }
    
    
    /*******************************************************************
    PURPOSE:   To test Active and Default PaymentDefinition insertion and updation                                                   
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
     
    public static testMethod void testActiveAndDefaultPaymentDefinition() {  
        
        /*******TEST SCENARIO 1 : Test for first active record insertion ********/
        
        CustomSettingsUtilityTest.init();
        //Creating Test Records for Payment Definitions
        list<Payment_Definitions__c> testPaymentDefinitionList = TestUtility.createPaymentDefinitionsTestRecords();
        if(Schema.sObjectType.Payment_Definitions__c.fields.Is_Default__c.isCreateable()&&
           Schema.sObjectType.Payment_Definitions__c.fields.Status__c.isCreateable())
        {
            //Making the first record Default and Active        
            testPaymentDefinitionList[0].Is_Default__c=True;
            testPaymentDefinitionList[0].Status__c='Active';
            
            Test.startTest();
            
            if(CrudUtil.isPaymentDefinitionCreateable()){
                insert testPaymentDefinitionList;
            }
     
            //fetching records with active and default definitions
            String soql = new SoqlBuilder()
            .selectx('id')
            .fromx(NameSpace+'Payment_Definitions__c')
            .wherex(new AndCondition()
                .add(new FieldCondition(NameSpace+'status__c').equals('active'))
                .add(new FieldCondition(NameSpace+'Is_Default__c').equals(true))
            )
            .toSoql();
         
            list<Payment_Definitions__c> PaymentDefinitionList = database.query(soql);
            System.assertEquals(1,PaymentDefinitionList.size());
            
            /*******TEST SCENARIO 2 : Test for updating existing active record ********/
            if(CrudUtil.isPaymentDefinitionUpdatable()){
                update PaymentDefinitionList[0];
            }
          
            /*******TEST SCENARIO 3 : Test for second active record insertion ********/
            Payment_Definitions__c activePaymentDefinition2 = new Payment_Definitions__c();
            activePaymentDefinition2.Is_Default__c=True;
            activePaymentDefinition2.Status__c='Active';
            try{
                if(CrudUtil.isPaymentDefinitionCreateable()){
                    insert activePaymentDefinition2;
                }
            }
            catch(DMLException ex){
                System.assertEquals(System.Label.ValidatePaymentDefinitionLabel,ex.getDmlMessage(0));
            }
       
            /*******TEST SCENARIO 4 : Test for updating inactive record with active definition ********/
            testPaymentDefinitionList[1].Is_Default__c=True;
            testPaymentDefinitionList[1].Status__c='Active';
            try{
                if(CrudUtil.isPaymentDefinitionUpdatable()){
                    update testPaymentDefinitionList;
                }   
            }
            catch(DMLException ex){
                System.assertEquals(System.Label.ValidatePaymentDefinitionLabel,ex.getDmlMessage(0));
            }     
        }
        Test.stopTest();
    }
    
    /*******************************************************************
    PURPOSE:   To test Payment Definition Item Deletion                                                   
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    public static testmethod void testPaymentDefinitionItemDeletion(){
        
        /*******TEST SCENARIO 1 : Test for deletion of mandatory Payment Definition Item ********/
        
        CustomSettingsUtilityTest.init();
        //Creating Test Records for Payment Configuration
        list<Payment_Configuration__c> testPaymentConfigurationList = TestUtility.createPaymentConfigurationTestRecords();
        
            if(Schema.sObjectType.Payment_Configuration__c.fields.Is_Mandatory__c.isCreateable())
            {
                ////Making the first Payment Configuration record Mandatory  
                testPaymentConfigurationList[0].Is_Mandatory__c = true;
            }    
            Test.startTest();
            
            if(CrudUtil.isPaymentConfigurationCreateable()){
                insert testPaymentConfigurationList;
            }
     
            //Creating Test Records for Payment Definitions
            list<Payment_Definitions__c> testPaymentDefinitionList = TestUtility.createPaymentDefinitionsTestRecords();
            System.debug('###testPaymentDefinitionList' + testPaymentDefinitionList);
            if(CrudUtil.isPaymentDefinitionCreateable()){
                insert testPaymentDefinitionList;
            }
     
            //Creating Test Record for Payment Definition Items
            Payment_Definition_Items__c mandatoryPaymentDefinitionItem = new Payment_Definition_Items__c();
            mandatoryPaymentDefinitionItem.Payment_Configuration__c = testPaymentConfigurationList[0].id;
            mandatoryPaymentDefinitionItem.Payment_Definition__c = testPaymentDefinitionList[0].id;
            
            if(CrudUtil.isPDItemsCreateable()){
                insert mandatoryPaymentDefinitionItem;
            }
            
            try{
                if(CrudUtil.isPDItemsDeletable()){
                    delete mandatoryPaymentDefinitionItem;
                }
            }
            catch(DMLException ex){
                System.assertEquals(System.Label.PaymentDefinitionItemDeletionMessage,ex.getDmlMessage(0));
            }  
        
        Test.stopTest();
    }
    
    /*******************************************************************
    PURPOSE:   To test TriggerHandler functions                                                   
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    public static testMethod void testTriggerHandler() {
        
        CustomSettingsUtilityTest.init();
        /*******TEST SCENARIO 1 : Test for setMaxLoopCount ********/
        TriggerHandler testTrigger = new TriggerHandler();
        testTrigger.setMaxLoopCount(1);
        testTrigger.setMaxLoopCount(5);
        
        
        /*******TEST SCENARIO 2 : Test for execution of Context-Specific methods ********/
        list<Payment_Definitions__c> testPaymentDefinitionList = TestUtility.createPaymentDefinitionsTestRecords();
        
        Test.startTest();
        if(Schema.sObjectType.Payment_Definitions__c.fields.Is_Default__c.isUpdateable())
        {
            if(CrudUtil.isPaymentDefinitionCreateable()){
                insert testPaymentDefinitionList; 
            }
             
            testPaymentDefinitionList[0].Is_Default__c=True;
            
            if(CrudUtil.isPaymentDefinitionUpdatable()){
                update testPaymentDefinitionList[0];
            }
            
            if(CrudUtil.isPaymentDefinitionDeletable()){
                delete testPaymentDefinitionList[0];
            }
              
            /*******TEST SCENARIO 3 : Test for Custom Setting OnOffTrigger ********/
            OnOffTrigger__c testCustomSetting= OnOffTrigger__c.getValues('System Administrator');
            if(testCustomSetting==null)
            {
                testCustomSetting= new OnOffTrigger__c(Name='System Administrator');
                testCustomSetting.Function_Name__c='CustomFunction';
                testCustomSetting.isEnabled__c=true;
                if(CrudUtil.isOnOffTriggerCreateable()){
                    insert testCustomSetting;
                } 
                boolean testIsEnabled = testTrigger.isEnabled(testCustomSetting.Function_Name__c);
                System.assertEquals(testIsEnabled,true);
            }       
        }
        Test.stopTest();
    }
    
    /*******************************************************************
    PURPOSE:   To test the validation for multiple Rule Criteria Insertion for a specific Rule                                                    
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    public static testmethod void testMultipleRuleCriteriaInsertion(){
        CustomSettingsUtilityTest.init();
        list<Warranty_Rule_Criteria__c> testWarrantyRuleCriteriaList = TestUtility.createWarrantyRuleCriteriaTestRecords();

        Warranty_Rule__c testWarrantyRule = new Warranty_Rule__c(); 
        Test.startTest();
        if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isUpdateable())
        {
            try{
                if(CrudUtil.isWRuleCriteriaCreateable()){
                    insert testWarrantyRuleCriteriaList;
                }  
            }
            catch(DMLException ex){
                System.assertEquals(System.Label.Validation_for_Duplicate_Rule_Criteria_Insertion,ex.getDmlMessage(0));
            }
            
            testWarrantyRuleCriteriaList[0].Field_API_Name__c=NameSpace+'Claim_Type__c';
            
            try{
                if(CrudUtil.isWRuleCriteriaUpdatable()){
                    update testWarrantyRuleCriteriaList;
                }   
            }
            catch(DMLException ex){
                System.assertEquals(System.Label.Validation_for_Duplicate_Rule_Criteria_Insertion,ex.getDmlMessage(0));
            }
        }
        Test.stopTest();
    }
    
      /*******************************************************************
    PURPOSE:   To test the validation for warranty rule association                                                    
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    
    public static testmethod void testWarrantyRuleAssociationTrigger(){
        CustomSettingsUtilityTest.init();
        list<Policy_Definition__c> pd = TestUtility.createPolicyDefinitionTestRecords();
        if(Schema.sObjectType.Warranty_Rule_Association__c.fields.Policy_Definition__c.isUpdateable())
        {
            if(CrudUtil.isPolicyDefinitionCreatable()){
                insert pd[0];
                insert pd[1];
            }
            list<Warranty_Rule__c> wr = TestUtility.createWarrantyRuleTestRecords();
            if(CrudUtil.isWRuleCreateable()){
                insert wr[0];
            }
            
            list<Warranty_Rule_Criteria__c> wrc = TestUtility.createWarrantyRuleCriteriaTestRecords();
            if(CrudUtil.isWRuleCreateable()){
                wrc[0].Warranty_Rule__c = wr[0].id;
                insert wrc[0];
            }
            
            wr[0].Enabled__c = true;
            update wr[0];
            
            Warranty_Rule_Association__c wra = new Warranty_Rule_Association__c();
            wra.Policy_Definition__c= pd[0].id;
            wra.Warranty_Rule__c= wr[0].id;
            if(CrudUtil.isWRuleAssociationCreatable()){
                insert wra;
            }
            
            Warranty_Rule_Association__c wratest = new Warranty_Rule_Association__c();
            wratest.Policy_Definition__c= pd[1].id;
            wratest.Warranty_Rule__c= wr[0].id;
            if(CrudUtil.isWRuleAssociationCreatable()){
                 insert wratest;
            }
            
            Warranty_Rule_Association__c wratestrecord = new Warranty_Rule_Association__c();
            wratestrecord.Policy_Definition__c= pd[0].id;
            wratestrecord.Warranty_Rule__c= wr[0].id;
            try{
                if(CrudUtil.isWRuleAssociationCreatable()){
                 insert wratestrecord;
                }    
            }
            catch(DMLException ex){
                System.assertEquals(System.Label.ValidateWarrantyRuleAssociationLabel,ex.getDmlMessage(0));
            }
            wra.Policy_Definition__c = pd[1].id;
            try{
                if(CrudUtil.isWRuleAssociationUpdatable()){
                    update wra;
                }
                
            }
            catch(DMLException ex){
                System.assertEquals(System.Label.ValidateWarrantyRuleAssociationLabel,ex.getDmlMessage(0));
            }
        }
    }
}