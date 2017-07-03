/********************************************************************************
 Name:  ComparingClaimRecordsTestClass
 Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: 
This class contains unit tests for validating the behaviour of
ComparingClaimRecordsTestClass.
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          10/21/2016     INITIAL DEVELOPMENT            
**********************************************************************************/
@isTest(seeAllData = false)
global class ComparingClaimRecordsTest{

global static string NameSpace;
  static{
    NameSpace = SystemUtils.getNameSpace();
    system.debug('---NameSpace-'+NameSpace);
  } 
  
    //Varibale declaration
    private static List<account> accList;
    private static Warranty_Product__c wpParent ;
    private static Warranty_Product__c wpModel;
    private static Warranty_Product__c wpItem;
    private static Warranty_Product__c wpItem1;
    private static Warranty_Product__c wpItem2;
    private static Warranty_Product__c wpItem3;
    private static Warranty_Code__c warrantyCode;
    private static Warranty_Code__c warrantyCode1;
    private static Warranty_Code__c warrantyCode2;
    private static Warranty_Code__c warrantyCode3;
    private static FaultCode_Mapper__c faultMapperCode;
    private static List<Payment_Definitions__c> paymentDefList;
    private static Policy_Definition__c pd;
    private static List<Claim__c> claimList;
    private static List<Claim__c> fieldModificationClaimList;
    private static String FieldModificationId ;
    private static String ClaimTemplateID;
    private static String warrantyCodeRecordTypeId;
    private static String warrantyCodeRecordTypeId1;
    private static Service_Campaign__c serviceCampaign;
    private static Inventory__c  invParent;
    private static Inventory__c  invParent1;
    private static Inventory__c  invParent2;
    private static Campaign_Members__c campaignMembers;
    private static Rates_Details__c tempRateDetail;
    private static WOD__c defaultRateWod;
    private static List<WOD__c> claimFields;
    private static List<Claim_Part__c> claimPartsList;
    private static List<Claim_Part__c> FieldModificationclaimPartsList;
    private static List<Claim_Service_Information__c> claimserviceInfoList;
    private static List<Claim_Service_Information__c> claimserviceInfoList1;
    private static WOD__c tempCustomSetting;
    private static WOD__c tempCustomSettingPrice;
    private static Warranty_Product_Pricebook__c warrantyPrice;
    private static String nonSerializedPartRecordTypeId;
    private static String SerializedPartRecordTypeId;
    
    //method to prepare test data
    private static void init(){
        
        //create custom settings data
        
        CustomSettingsUtilityTest.init();
        //Create claim fields custom settings
        claimFields = new List<WOD__c>();
        
        WOD__c FieldModClaimCompareFields1 = new WOD__c();
        FieldModClaimCompareFields1 = WOD__c.getInstance('FieldMod_Claim_CompareFields1');
        if(FieldModClaimCompareFields1 == null){
        WOD__c  w1= new WOD__c();
        w1.Name = 'FieldMod_Claim_CompareFields1';
        w1.Trigger_Value__c =NameSpace+'Total_Labor_Cost__c,'+NameSpace+'Total_Meals_Cost__c,'+NameSpace+'Total_Parking_Cost__c';
        claimFields.add(w1);
        }
        
        WOD__c FieldModClaimCompareFields2 = new WOD__c();
        FieldModClaimCompareFields2 = WOD__c.getInstance('FieldMod_Claim_CompareFields2');
        if(FieldModClaimCompareFields2 == null){
        WOD__c  w2= new WOD__c();
        w2.Name = 'FieldMod_Claim_CompareFields2';
        w2.Trigger_Value__c =NameSpace+'Total_TravelByDistance_Cost__c,'+NameSpace+'Total_TravelByHours_Cost__c';
        claimFields.add(w2);
        }
        
        WOD__c FieldModClaimCompareFields3 = new WOD__c();
        FieldModClaimCompareFields3 = WOD__c.getInstance('FieldMod_Claim_CompareFields3');
        if(FieldModClaimCompareFields3 == null){
        WOD__c  w3= new WOD__c();
        w3.Name = 'FieldMod_Claim_CompareFields3';
        w3.Trigger_Value__c =NameSpace+'Final_Parking_Cost__c,'+NameSpace+'Final_Parts_Cost__c';
        claimFields.add(w3);
        }
        
        WOD__c FieldModClaimPartsCompareFields1 = new WOD__c();
        FieldModClaimPartsCompareFields1 = WOD__c.getInstance('FieldMod_ClaimParts_CompareFields1');
        if(FieldModClaimPartsCompareFields1 == null){
        WOD__c  w4= new WOD__c();
        w4.Name = 'FieldMod_ClaimParts_CompareFields1';
        w4.Trigger_Value__c =NameSpace+'Quantity__c';
        claimFields.add(w4);
        }
        
        WOD__c FieldModClaimServiceCompareFields1 = new WOD__c();
        FieldModClaimServiceCompareFields1 = WOD__c.getInstance('FieldMod_ClaimService_CompareFields1');
        if(FieldModClaimServiceCompareFields1 == null){
        WOD__c  w5= new WOD__c();
        w5.Name = 'FieldMod_ClaimService_CompareFields1';
        w5.Trigger_Value__c =NameSpace+'Total_Labor_hours__c';
        claimFields.add(w5);
        }
        
        WOD__c FieldModObjects = new WOD__c();
        FieldModObjects = WOD__c.getInstance('FieldMod_Objects');
        if(FieldModObjects == null){
        WOD__c  w6= new WOD__c();
        w6.Name = 'FieldMod_Objects';
        w6.Trigger_Value__c =NameSpace+'Claim__c,'+NameSpace+'Claim_Part__c,'+NameSpace+'Claim_Service_Information__c';
        claimFields.add(w6);
        }
        
        WOD__c EnablePDIGroupLogic = new WOD__c();
        EnablePDIGroupLogic = WOD__c.getInstance('Enable PDI Group Logic');
        if(EnablePDIGroupLogic == null){
        WOD__c  w7= new WOD__c();
        w7.Name = 'Enable PDI Group Logic';
        w7.isTriggered__c=false;
        claimFields.add(w7);
        }
        
        system.debug('claimFields-->'+claimFields);
        if(claimFields.size()>0){
        insert claimFields;
        }
        
        
        //Insert test Country
        list<Country__c> TestCountryList = new list<Country__c>();
        TestCountryList.add(new Country__c(Name = 'India',Currency_Code__c = 'INR'));
        TestCountryList.add(new Country__c(Name = 'USA',Currency_Code__c = 'Dollar'));
        TestCountryList.add(new Country__c(Name = 'Japan',Currency_Code__c = 'Yen'));
        insert TestCountryList;
        
        //Create account data
        accList = new List<account>();        
        accList = TestUtility.createAccountTestRecords();
        if(CrudUtil.isAccountCreateable()){ 
            accList[0].Country__c = TestCountryList[0].Id;
            insert accList[0];
        } 
        
        //Insert warranty product
        //Create warranty product data
        wpParent = TestUtility.createWarrantyProduct('Beetel', 'Beetel', 'Product', '', '','',null);
        insert wpParent;
        wpModel = TestUtility.createWarrantyProduct('BeetelModel', 'BeetelModel', 'Model', '', '','', wpParent.Id);
        insert wpModel;
        wpItem = TestUtility.createWarrantyProduct('BeetelItem', 'BeetelItem', 'Item', 'Machine', 'Serialized','Miles', wpParent.Id);
        insert wpItem;
        wpItem1 = TestUtility.createWarrantyProduct('BeetelItem1', 'BeetelItem1', 'Item', 'Machine', 'Non-Serialized','Miles', wpParent.Id);
        insert wpItem1;
        wpItem2 = TestUtility.createWarrantyProduct('BeetelItem2', 'BeetelItem2', 'Item', 'Machine', 'Non-Serialized','Miles', wpParent.Id);
        insert wpItem2;
        wpItem3 = TestUtility.createWarrantyProduct('BeetelItem3', 'BeetelItem3', 'Item', 'Machine', 'Non-Serialized','Miles', wpParent.Id);
        insert wpItem3;
        
        //insert warrantyPricebook
        warrantyPrice = TestUtility.createWarrantyPricebook();
        warrantyPrice.Name = 'Test PriceBook';
        warrantyPrice.Warranty_Product__c =wpItem.Id;
        warrantyPrice.Country__c =TestCountryList[1].Id;
        insert warrantyPrice;
        
        //insert warranty code
        warrantyCodeRecordTypeId = RecordTypeUtils.getRecordTypeId('Fault_Code',Warranty_Code__c.sObjectType);
        warrantyCode = TestUtility.createWarrantyCode('TestWarrantyCode',wpItem.Id,warrantyCodeRecordTypeId);
        insert warrantyCode ;
        
        //insert fault code mappers
        faultMapperCode = TestUtility.createFaultCodeMapper('TestFaultCode',warrantyCode.Id,wpItem.Id);
        insert faultMapperCode ;
        
        //Insert payment definitions
        paymentDefList = TestUtility.createPaymentDefinitionsTestRecords();
        paymentDefList[0].Status__c = 'Active';
        insert paymentDefList[0];
        
        //Insert policy Definition data        
        pd = TestUtility.createPolicyDefinition('beetelpolicy', paymentDefList[0].Id,100);
        insert pd;
        
        tempCustomSetting=WOD__c.getValues('Default Rate');
       //Create Rate details data 
        tempRateDetail = TestUtility.createRateDetail();
        tempRateDetail.Dealer__c = accList[0].Id;
        tempRateDetail.Status__c = 'Active';
        tempRateDetail.Active_From__c = System.today()-6;
        tempRateDetail.Active_Until__c = System.today()+6;
        tempRateDetail.LaborRate__c = 12;
        tempRateDetail.TravelByDistanceRate__c = 12;

        insert tempRateDetail;
        if(tempCustomSetting==null){
            if(CrudUtil.isWODCreateable()){
                tempCustomSetting = new WOD__c();
                tempCustomSetting.Trigger_Value__c = tempRateDetail.id;
                tempCustomSetting.name = 'Default Rate';
                insert tempCustomSetting;
            }
        }
        
        /*if(tempCustomSettingPrice==null){           
                tempCustomSettingPrice = new WOD__c();
                tempCustomSettingPrice.Trigger_Value__c = warrantyPrice.id;
                tempCustomSettingPrice.name = 'Default Price';
                insert tempCustomSettingPrice;
        }*/ 
        
        
        //get the claim record types
        FieldModificationId = RecordTypeUtils.getRecordTypeId('Field_Modification',Claim__c.sObjectType);
        ClaimTemplateID = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);
        system.debug('ClaimTemplateID-->'+ClaimTemplateID);
        
        //Insert calimTemplate records
         claimList = TestUtility.createClaimTestRecords();
         claimList[0].Claim_Record_Type__c       ='Claim Template';
         claimList[0].RecordTypeId               = ClaimTemplateID;
         claimList[0].Claim_Type__c              ='Claim Template'; 
         claimList[0].Causal_Part_Number__c      = wpItem.Id;
         claimList[0].Fault_Code__c              = warrantyCode.Id;
         claimList[0].Fault_found__c             = 'Alignment';
         claimList[0].Caused_by__c               ='Incorrect Setup';
         claimList[0].Total_Labor_Cost__c        = 16.00;
         claimList[0].Claim_Status__c            = 'Draft';
         claimList[0].Date_of_Failure__c         = System.today()-6;
         claimList[0].Date_of_Repair__c          = System.today()-2;
         claimList[0].In_Approval_Process__c     = false;
         claimList[0].Rate__c                    = tempRateDetail.Id;
         claimList[0].Account__c                 = accList[0].Id;
         //claimList[0].Is_Eligible_for_Appeal__c  = true;
         
         insert claimList[0]; 
         system.debug('claimList[0]-->'+claimList[0]);
         
         
         //Create service campaign data
         serviceCampaign = TestUtility.createServiceCampaign(claimList[0].Id,paymentDefList[0].Id);
         system.debug('serviceCampaign -->'+serviceCampaign );
         insert serviceCampaign ;  
         
         //Create Inventory data 
         invParent = TestUtility.createInventory('Beetel','Beetel123','Warrantable','Stock',accList[0].Id, wpItem.Id,null);
         insert invParent;        
         invParent1 = TestUtility.createInventory('Beetel2','Beetel1234','Warrantable','Stock',accList[0].Id, wpItem.Id,null);
         insert invParent1;
         invParent2 = TestUtility.createInventory('Beetel3','Beetel12345','Warrantable','Stock',accList[0].Id, wpItem.Id,null);
         insert invParent2;
         
         //Create campaign Members data
         campaignMembers = TestUtility.createCampaignMember(invParent.Id,serviceCampaign.Id);
         insert campaignMembers ;
         
         //activate service campaign
         servicecampaign.Status__c =  'Active'; 
         update servicecampaign;
        
        
        //Insert custom seetings data
        /*defaultRateWod = new WOD__c();
        defaultRateWod.Name = 'Default Rate';
        defaultRateWod.Trigger_Value__c =tempRateDetail.Id;
        insert defaultRateWod;
        */
        //Create claim parts
        
         nonSerializedPartRecordTypeId = RecordTypeUtils.getRecordTypeId('Non_Serialized_Part',Claim_Part__c.sObjectType);
         SerializedPartRecordTypeId = RecordTypeUtils.getRecordTypeId('Serialized_Part',Claim_Part__c.sObjectType);
        
         claimPartsList = new List<Claim_Part__c>();
         Claim_Part__c part1 = TestUtility.createClaimPart('Part1','Installed Part',wpItem1.Id,12,claimList[0].Id,null);
         part1.RecordTypeId = nonSerializedPartRecordTypeId ;
         claimPartsList.add(part1);        
         Claim_Part__c part2 = TestUtility.createClaimPart('Part2','Serialized Part',null,12,claimList[0].Id,invParent.Id);
         part2.RecordTypeId = SerializedPartRecordTypeId ;
         claimPartsList.add(part2);
         //Claim_Part__c part3 = TestUtility.createClaimPart('Part3','Miscellaneous Part',wpItem1.Id,12,claimList[0].Id,null);
         //claimPartsList.add(part3);
         Claim_Part__c part10 = TestUtility.createClaimPart('Part10','Installed Part',wpItem3.Id,12,claimList[0].Id,null);
         part10.RecordTypeId = nonSerializedPartRecordTypeId ;
         claimPartsList.add(part10);
         Claim_Part__c part11 = TestUtility.createClaimPart('Part11','Serialized Part',null,12,claimList[0].Id,invParent2.Id);
         part11.RecordTypeId = SerializedPartRecordTypeId ;
         claimPartsList.add(part11);
         //Claim_Part__c part12 = TestUtility.createClaimPart('Part123','Miscellaneous Part',wpItem3.Id,12,claimList[0].Id,null);
         //claimPartsList.add(part12);
         insert claimPartsList;
                  
         //insert warranty code
         warrantyCodeRecordTypeId1 = RecordTypeUtils.getRecordTypeId('Job_Code',Warranty_Code__c.sObjectType);
         warrantyCode1 = TestUtility.createWarrantyCode('TestjobCode',wpItem.Id,warrantyCodeRecordTypeId1 );
         insert warrantyCode1 ;
         warrantyCode2 = TestUtility.createWarrantyCode('TestjobCode2',wpItem.Id,warrantyCodeRecordTypeId1 );
         insert warrantyCode2 ;
         warrantyCode3 = TestUtility.createWarrantyCode('TestjobCode3',wpItem.Id,warrantyCodeRecordTypeId1 );
         insert warrantyCode3 ;
         
         //Create claim Service Info
         claimserviceInfoList = new List<Claim_Service_Information__c>();
         Claim_Service_Information__c csic = TestUtility.createClaimService(warrantyCode1.Id,12,claimList[0].Id);
         claimserviceInfoList.add(csic);
         Claim_Service_Information__c csic3 = TestUtility.createClaimService(warrantyCode3.Id,12,claimList[0].Id);
         claimserviceInfoList.add(csic3);
         insert claimserviceInfoList ;
         
         //Insert fieldModification records
         fieldModificationClaimList = TestUtility.createClaimTestRecords();
         fieldModificationClaimList[0].RecordTypeId               = FieldModificationId;
         fieldModificationClaimList[0].Claim_Record_Type__c       = 'Field Modification';
         fieldModificationClaimList[0].Inventory__c               = invParent.Id;
         fieldModificationClaimList[0].Rate__c                    = tempRateDetail.Id;
         fieldModificationClaimList[0].Campaign_Members__c        = campaignMembers.Id;
         fieldModificationClaimList[0].Claim_Type__c              ='Field Modification';
         fieldModificationClaimList[0].Total_Labor_Cost__c        = 18.00;
         fieldModificationClaimList[0].Causal_Part_Number__c      = wpItem.Id;
         fieldModificationClaimList[0].Fault_Code__c              = warrantyCode.Id;
         fieldModificationClaimList[0].Account__c                 = accList[0].Id;
         fieldModificationClaimList[0].In_Approval_Process__c     = false;
         fieldModificationClaimList[0].Date_of_Failure__c         = System.today()-6;
         fieldModificationClaimList[0].Date_of_Repair__c          = System.today()-2;
         //fieldModificationClaimList[0].Is_Eligible_for_Appeal__c  = true;
         fieldModificationClaimList[0].Approved_Labor_Cost__c     = 200;
         fieldModificationClaimList[0].Warranty_Product__c        = wpItem1.id;
         fieldModificationClaimList[0].Final_Labor_Cost__c        = 200;
         fieldModificationClaimList[0].Total_Labor_Cost__c        = 200;
         fieldModificationClaimList[0].Claim_Status__c            ='Draft';
         fieldModificationClaimList[0].Total_TravelByDistance_Cost__c= 200;
         fieldModificationClaimList[0].Total_TravelByHours_Cost__c = 200;
         fieldModificationClaimList[0].TravelByHours__c = 10;
         fieldModificationClaimList[0].TravelByDistance__c = 10;
         
        
        
     }
     
     //Method to insert field modification claim records
     static testMethod void claimCompareTest(){
         
         
         
         Test.startTest();
            init();         
         insert fieldModificationClaimList[0];
         
         //Create claim part for fieldModification claims record        
         FieldModificationclaimPartsList = new List<Claim_Part__c>();
         Claim_Part__c part4 = TestUtility.createClaimPart('Part1','Installed Part',wpItem1.Id,12,fieldModificationClaimList[0].Id,null);
         part4.RecordTypeId = nonSerializedPartRecordTypeId ;
         FieldModificationclaimPartsList.add(part4);
         Claim_Part__c part5 = TestUtility.createClaimPart('Part2','Serialized Part',null,12,fieldModificationClaimList[0].Id,invParent.Id);
         part5.RecordTypeId = SerializedPartRecordTypeId ;
         FieldModificationclaimPartsList.add(part5);
         //Claim_Part__c part6 = TestUtility.createClaimPart('Part3','Miscellaneous Part',wpItem1.Id,12,fieldModificationClaimList[0].Id,null);
         //FieldModificationclaimPartsList.add(part6);
         //Claim_Part__c part7 = TestUtility.createClaimPart('Part4','Miscellaneous Part',wpItem1.Id,12,fieldModificationClaimList[0].Id,null);
         //FieldModificationclaimPartsList.add(part7);
         Claim_Part__c part8 = TestUtility.createClaimPart('Part5','Serialized Part',null,12,fieldModificationClaimList[0].Id,invParent1.Id);
         part8.RecordTypeId = SerializedPartRecordTypeId ;
         FieldModificationclaimPartsList.add(part8);
         Claim_Part__c part9 = TestUtility.createClaimPart('Part9','Installed Part',wpItem2.Id,12,fieldModificationClaimList[0].Id,null);
         part9.RecordTypeId = nonSerializedPartRecordTypeId ;
         FieldModificationclaimPartsList.add(part9);
         insert FieldModificationclaimPartsList;
  
         //Create claim Service Info for field modification claim records.
         claimserviceInfoList1 = new List<Claim_Service_Information__c>();
         Claim_Service_Information__c csic1 = TestUtility.createClaimService(warrantyCode1.Id,12,fieldModificationClaimList[0].Id);         
         claimserviceInfoList1.add(csic1);
          Claim_Service_Information__c csic2 = TestUtility.createClaimService(warrantyCode2.Id,12,fieldModificationClaimList[0].Id);         
         claimserviceInfoList1.add(csic2);
         insert claimserviceInfoList1;
         
         //update information
         //FieldModificationclaimPartsList[0].Quantity__c = 15;
         //FieldModificationclaimPartsList[1].Quantity__c = 15;
         //FieldModificationclaimPartsList[2].Quantity__c = 15;
         //update FieldModificationclaimPartsList; 
         claimserviceInfoList1[0].Total_Labor_hours__c = 20;
         update claimserviceInfoList1;
         fieldModificationClaimList[0].Total_Labor_Cost__c = 20;
         fieldModificationClaimList[0].Claim_Status__c ='submitted';
         update fieldModificationClaimList[0];     
         Test.stopTest();   
     }
     
     //Method to create exception scenarios.
     static testMethod void claimCompareTest1(){
         
         
         
         Test.startTest();  
            
        init();
         
         //update custom settings data        
         claimFields[5].Trigger_Value__c =NameSpace+'Claim__c,'+NameSpace+'Claim_Service_Information__c';
         update claimFields[5];
         insert fieldModificationClaimList[0]; 
         fieldModificationClaimList[0].Claim_Status__c ='submitted';
         update fieldModificationClaimList[0]; 
         Test.stopTest();
     }
      
}