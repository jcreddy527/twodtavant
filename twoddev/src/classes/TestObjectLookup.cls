/**********************************************************************
 Name:  TestObjectLookup()
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Test class for Object LookUp Controller 
                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Vino        11/21/2014      INITIAL DEVELOPMENT            
***********************************************************************/

@isTest
global class TestObjectLookup{
    /*******************************************************************
    PURPOSE:   To test Object lookup controller                                            
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    //Test method for ObjectLookupController
    global static testmethod void testObjectLookupController(){
        CustomSettingsUtilityTest.init();
        
        WOD__c custsett1 = new WOD__c();        
        custsett1.Name = 'Lookup Record Limit on PAT';
        insert custsett1;   
        
        
        
        PageReference pageRef =  Page.ObjectLookup;
        Test.setCurrentPage(pageRef);
                              
        /*******TEST SCENARIO 1 : Test with a search string value********/
       
        PageUtils.put('oName','Account');
        PageUtils.put('searchStr','T');
        PageUtils.put('displayType','Single');
        
        //Creation and Insertion of Payment Definition Items
        list<Account> testAccount = TestUtility.createAccountTestRecords();
        
        Test.startTest();
        if(CrudUtil.isAccountCreateable())
            insert testAccount;
        
        system.assertNotEquals(null, testAccount);
        ObjectLookupController testController1 = new ObjectLookupController();
        //testController1.onCheck();
        
        
        /*******TEST SCENARIO 2 : Test without search string********/
         
        PageUtils.put('oName','Account');
        PageUtils.put('searchStr','');
        PageUtils.put('displayType','Single');
        
       // ObjectLookupController testController2 = new ObjectLookupController();
        testController1.noRecordSelected(); 
        testController1.onCheck();
        Test.stopTest();      
    }
}