/**********************************************************************
 Name:  WarrantyRegistrationCtrlTest
 Copyright ? 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:    To Test WarrantyRegistrationCtrl and Inventory Manager                                                         -------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Abhishek        20/11/2014      INITIAL DEVELOPMENT            
2.0 -    Chethan         21/02/2017
***********************************************************************/
@isTest
global class WarrantyRegistrationCtrlTest {


    /*******************************************************************
    PURPOSE:   To Test WarrantyRegistrationCtrl and Inventory Manager                                                    
    PARAMETERS: N/A 
    RETURNS: N/A 
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    
    static testmethod void testWarrantyRegistrationCtrl(){
        CustomSettingsUtilityTest.init();
        PageReference pageRef=Page.WarrantyRegistration;
        Test.setCurrentPage(pageRef);
        
        //Creating and Inserting Test Records for Inventory Object
        list<Inventory__c> tempInventoryRecordList = TestUtility.createInventoryTestRecords();
        
        Test.startTest();
        if(Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isCreateable() &&
            Schema.sObjectType.Inventory__c.fields.Install_Date__c.isUpdateable()
        )
        {
          /*Testing The fucntionality to select customer on Warranty Registration page*/
                Account acc=new Account();
                acc.Name='Shah';
                insert acc;
                
                tempInventoryRecordList[0].Item__c=TestUtility.createWarrantyProduct().Id;
                tempInventoryRecordList[0].Customer__c = acc.id;    
           
                if(CrudUtil.isInventoryCreateable()){
                    insert tempInventoryRecordList;
                }
                
                //Creating and Inserting Test Records for PAT Object
                list<Policy_Applicability_Term__c> tempPATRecordList = TestUtility.createPATTestRecords();
                for(Integer i=0;i<10;i++){
                    
                    tempPATRecordList[i].Applicability_Value__c=tempInventoryRecordList[i].Account__c;
                }
                if(CrudUtil.isPATCreateable()){
                    insert tempPATRecordList;
                }
                
                /*******TEST SCENARIO 1 : Test for Properly instantiation of Controller  ********/
                ApexPages.Standardcontroller stdController=new ApexPages.Standardcontroller(tempInventoryRecordList[0]);
                WarrantyRegistrationCtrl tempController=new WarrantyRegistrationCtrl(stdController);
                
                /*******TEST SCENARIO 2 : +ve Testcase for fetchPolicyDefinitions() and registerInventory()********/
                tempController.fetchPolicyDefinitions();
                Pagereference returnedPageRef=tempController.registerInventory();
                System.assertEquals(null, returnedPageRef);
                
                /*******TEST SCENARIO 3 : -ve Testcase for fetchPolicyDefinitions() and registerInventory()********/  
                  
                for(Integer i=0;i<10;i++){
                    tempInventoryRecordList[i].Install_Date__c=null;
                }
                try{
                    if(CrudUtil.isInventoryUpdatable()){
                        update tempInventoryRecordList;
                    } 
                }
                catch(Exception ex){
                
                    System.assertNotEquals(System.Label.ValidatePaymentDefinitionLabel,ex.getDmlMessage(0));
                }
                
                tempController.getCustomerInfo();
                tempController.fetchPolicyDefinitions();
                tempController.registerInventory();
                tempController.cancelRegistration();
        }
        Test.stopTest();

    }
    
    
}