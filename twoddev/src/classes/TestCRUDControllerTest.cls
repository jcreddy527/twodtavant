/**********************************************************************
 Name:  TestCRUDControllerTest 
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
global class TestCRUDControllerTest {
  
          static testmethod void TestWarrantyRegistrationController(){
           
                CustomSettingsUtilityTest.init();
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
                      
                        tempClaimObj1.claim_type__c = tempClaimObj.claim_type__c = 'Machine';
                        
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
                system.debug('======clmList1======'+clmList);
                if(CrudUtil.isClaimCreateable()){ 
                    insert clmList;
                }
                system.debug('======clmList2======'+clmList); 
               
             /***############## TEST 1 : Test for ReadSObjects #################****/
               TestCRUDController.OutputWrapper OutputWrapper = TestCRUDController.ReadSObjects('select name from'+SystemUtils.getNameSpace()+'claim__c');
               //System.assertEquals(true, OutputWrapper.success);
            
             //TestCRUDController.totalRecordsCount('Test');
            
            /***############## TEST 2 -ve case: Test for InsertSObjects #################***/
               List<TestCRUDController.DMLOutputWrapper> DMLOutputWrapper = TestCRUDController.InsertSObjects(clmList);
               System.assertNotEquals(null, DMLOutputWrapper[0].success);
               
               clmList.add(tempClaimObj1);
          
           /***############## +ve case : Test for InsertSObjects #################***/
               List<TestCRUDController.DMLOutputWrapper> DMLOutputWrapperneg = TestCRUDController.InsertSObjects(clmList);
               System.assertNotEquals(null, DMLOutputWrapperneg[0].success);    
               
               
            /***############## TEST 3 : Test for UpdateSObjects #################***/    
               List<TestCRUDController.DMLOutputWrapper> DMLOutputWrapperUpdate = TestCRUDController.UpdateSObjects(clmList);
               System.assertEquals(true, DMLOutputWrapperUpdate[0].success);
            
            /***############## TEST 4 : Test for UpsertSObjects #################***/ 
               List<TestCRUDController.DMLUpsertWrapper> DMLUpsertWrapper =TestCRUDController.UpsertSObjects(clmList);
               System.assertEquals(true, DMLUpsertWrapper[0].isSuccess);
            
            /***############## TEST 5 : Test for DeleteSObjects #################***/ 
               List<TestCRUDController.DMLOutputWrapper> DMLOutputWrapperDelete = TestCRUDController.DeleteSObjects(clmList);
               System.assertEquals(true, DMLOutputWrapperDelete[0].success);
           
            /***############## TEST 6 : Test for getFieldsInfo#################***/
               String ReturnedString = TestCRUDController.getFieldsInfo(SystemUtils.getNameSpace()+'claim__c');
               
          }

}