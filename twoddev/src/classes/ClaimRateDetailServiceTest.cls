/**********************************************************************
 Name:  ClaimRateDetailServiceTest
 Copyright � 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for ClaimRateDetailService
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Neethu           04/09/2015      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
private class ClaimRateDetailServiceTest {

    static testmethod void testValidateClaimCtrl(){
    CustomSettingsUtilityTest.init();
                // Creating and Inserting Test Records for Account Objct
        list<Account> tempAccountRecordsList = TestUtility.createAccountTestRecords();
        
        
        WOD__c tempCustomSetting=WOD__c.getValues('Default Rate');
        
        list<Inventory__c> invList = TestUtility.createInventoryTestRecords();
        Test.startTest();
        
        if(CrudUtil.isAccountCreateable()){ 
            insert tempAccountRecordsList[0];
        } 
        invList[0].Account__c=tempAccountRecordsList[0].Id;
        insert invList[0];
        
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
        // Creating and Inserting Test Records for Claim Object
        Claim__c tempClaimObj = new Claim__c();
        if(Schema.sObjectType.Claim__c.fields.Name.isUpdateable()&&
               Schema.sObjectType.Claim__c.fields.Account__c.isUpdateable()) {
              
                
                tempClaimObj.Name='TempClaim'+1;
                tempClaimObj.Account__c=tempAccountRecordsList[0].id;
                tempClaimObj.Inventory__c =invList[0].id;
                tempClaimObj.Date_of_Failure__c = System.today();
                tempClaimObj.Date_of_Repair__c = System.today();
            }
        if(CrudUtil.isClaimCreateable()){ 
            insert tempClaimObj;
        }
        
        ClaimRateDetailLogicService.SetRateDetail(new list<Claim__c>{tempClaimObj});

    }
    
    
}