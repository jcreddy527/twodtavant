/**********************************************************************
 Name:  WarrantyRegistrationControllerTest 
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for GenericCrudController
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    sainath 28/09/2016      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
private class WarrantyRegistrationControllerTest {


  static testmethod void TestWarrantyRegistrationController(){
        CustomSettingsUtilityTest.init();
        
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable changeCustomerName';
        customSettings.add(objsetting1);
        insert customSettings;
     
        Warranty_Product__c testwarrantyProductrecords = TestutilityRecoveryClaim.createWarrantyProductRecords();
        testwarrantyProductrecords.Track_Type__c = 'Serialized';
        update testwarrantyProductrecords;
        //creating and inserting the inventory
        list<Inventory__c> testInventoryRecords = TestUtility.createInventoryTestRecords();
        System.debug('----+++=---'+testInventoryRecords);
        //creating and inserting the Account
        testInventoryRecords[0].Item__c = testwarrantyProductrecords.id;
        insert testInventoryRecords;
        list<Account> testAccountList = TestUtility.createAccountTestRecords();
        //creating and inserting the Warrwnt registration
        insert testAccountList;
        list <Warranty_Registration__c> testWarrantyRecords = TestUtility.createWarrantyRegistrationTestRecords();
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
      insert testPATRecordsList;
      list<Policy_Definition__c> tempPolicyDefinitionRecordsList = TestUtility.createPolicyDefinitionTestRecords();
      system.debug(tempPolicyDefinitionRecordsList+'#####tempPolicyDefinitionRecordsList');
      
     
        
      
      
      list<PolicyDefinitionWrapper> listWra = new list<PolicyDefinitionWrapper>();
      for(Policy_Definition__c pd : tempPolicyDefinitionRecordsList){
          listWra.add(new PolicyDefinitionWrapper(pd));
      }
      for(PolicyDefinitionWrapper pdw : listWra){
          pdw.selected = true;
      }
      
      String PolicyDefenitionString = JSON.serialize(listWra);
      WarrantyRegistrationController.isMultipleWarrantyRegistration();
      //WarrantyRegistrationController.createWarrantyRegistration(true,testInventoryRecords[0],'Test','1/01/2017',testWarrantyRecords[0].id, 'Demo', 'a0M28000007uUlREAU'); 
      
      //creating and inserting
      list<Account> testAccountRecrd = TestUtility.createAccountTestRecords();
        insert testAccountRecrd;
       WarrantyRegistrationController.createWarrantyRegistration(true,testInventoryRecords[0],'Test','1/01/2017',testWarrantyRecords[0].id, 'Demo', testAccountRecrd[0].id); 
       // WarrantyRegistrationController.lstResponse = new list<Response>();
        // testing registerInventory method
        WarrantyRegistrationController.registerInventory(PolicyDefenitionString,'Test',testInventoryRecords[0],'1/01/2017',testWarrantyRecords[0].id, 'Demo', testAccountRecrd[0].id, '9/28/2020');
        WarrantyRegistrationController.registerInventory(PolicyDefenitionString,'Test',testInventoryRecords[0],'1/01/2017',null, 'Demo', testAccountRecrd[0].id, '9/28/2020');
    
        // testing createWarrantyRegistration method
        WarrantyRegistrationController.createWarrantyRegistration(true,testInventoryRecords[0],'Test','1/01/2017',testWarrantyRecords[0].id, 'Demo', testAccountRecrd[0].id);
        WarrantyRegistrationController.createWarrantyRegistration(true,testInventoryRecords[0],'Test','1/01/2017',null, 'Demo', testAccountRecrd[0].id);
        system.debug(testWarrantyRecords[0]+ +'############testWarrantyRecords[0].id');
       
        id invId=testInventoryRecords[0].id;
        WarrantyRegistrationController.getInitialData(invId);
   }
    
    @isTest static void testFetchPolicyDefinitionsMngr() {
        
       
           //Boolean isDeleted,Warranty_Registration__c newWR,Boolean preowned,String inventoryId,String regType
           
           // creating and inserting Warranty-Registration
           List<Inventory__c> testInventoryRecs = TestUtility.createInventoryTestRecords();
           //insert testInventoryRecs;
           List <Warranty_Registration__c> testWarrantyRecs = TestUtility.createWarrantyRegistrationTestRecords();
           Group__c Testgroup = new Group__c();
           Testgroup.Object_Name__c = SystemUtils.getNameSpace()+'Warranty_Product__c';
           insert  Testgroup ;
           Group_Member__c groupMember = new Group_Member__c();
           groupMember.Record_Id__c = String.valueOf(testWarrantyRecs[0].id);
           groupMember.Group__c = Testgroup.Id;
           insert groupMember;
           
           testWarrantyRecs[0].Inventory__c = testInventoryRecs[0].id;
           insert testWarrantyRecs;
           WarrantyRegistrationController.fetchPolicyDefinitionsMngr(true,testWarrantyRecs[0],true,testInventoryRecs[0].id,'Standard');
           WarrantyRegistrationController.fetchPolicyDefinitionsMngr(false,testWarrantyRecs[0],true,testInventoryRecs[0].id,'Standard');
                	
  		   list<WarrantyRegistrationController.fieldset> FieldSetReturn = WarrantyRegistrationController.fieldstodisplay();
           list<WarrantyRegistrationController.fieldset> FieldSetReturned =  WarrantyRegistrationController.policydefFields();
           
           WarrantyRegistrationController.getMaxMonthsCovered(testWarrantyRecs[0].id);
        
           
    }
    

}