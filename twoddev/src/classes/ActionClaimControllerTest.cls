/********************************************************************************
 Name: ActionClaimControllerTest
 Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: 
This class contains unit tests for validating the behaviour of
ActionClaimController and ActionClaimUtility.
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          11/10/2016     INITIAL DEVELOPMENT            
**********************************************************************************/
@isTest(seeAllData = false)
private class ActionClaimControllerTest{
    //Varibale declaration
    private static List<account> accList;
    private static Warranty_Product__c wpParent ;
    private static Warranty_Product__c wpModel;
    private static Warranty_Product__c wpItem;   
    private static Warranty_Code__c warrantyCode;   
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
    private static List<WOD__c> customSettings;
    private static ClaimActions__c claimActionSettings;    
    private static WOD__c tempCustomSetting;
    private static WOD__c tempCustomSettingPrice;
    private static Warranty_Product_Pricebook__c warrantyPrice;
    private static Approval.ProcessSubmitRequest req;
    private static Group queue;
    private static Group groups;
    private static GroupMember gm;
    private static GroupMember gm1;
    
    //method to prepare test data
    private static void init(){
        
      
        //create custom settings data
        CustomSettingsUtilityTest.init();
        
        //Create custom settings
        customSettings = new List<WOD__c>();
        claimActionSettings = ClaimActions__c.getInstance('Approved');
        if(claimActionSettings == null){            
            claimActionSettings = new ClaimActions__c();
            claimActionSettings.Name = 'Approved';
            claimActionSettings.Status_Values__c ='Open';
            insert claimActionSettings;
        }
        
        
        WOD__c  w1= new WOD__c();
        w1.Name = 'Allowed Ids';
        w1.Trigger_Value__c = UserInfo.getUserId();
        customSettings.add(w1);
        
        WOD__c  w2= new WOD__c();
        w2.Name = 'All Payment Configurations';
        w2.Trigger_Value__c ='Labor,TravelByDistance,TravelByHours,Parts,Meals,Parking,Category1';
        customSettings.add(w2);
        insert customSettings;

        
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
        
        if(tempCustomSettingPrice==null){           
                tempCustomSettingPrice = new WOD__c();
                tempCustomSettingPrice.Trigger_Value__c = warrantyPrice.id;
                tempCustomSettingPrice.name = 'Default Price';
                insert tempCustomSettingPrice;
        } 
        
        //create users
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@tavant.com');
        insert u;
        system.runAs(u){
            //create queue and queuemembers
            queue = new Group(Name='testname', type='Queue');
            insert queue;
            groups = new Group(Name='testname', type='Regular');
            insert groups;
            gm1 = new GroupMember();
            gm1.UserOrGroupId = UserInfo.getUserId();
            gm1.GroupId = groups.Id;
            insert gm1;
            gm = new GroupMember();
            gm.UserOrGroupId = groups.Id;
            gm.GroupId = queue.Id;
            insert gm;
        }
        
        //get the claim record types
        FieldModificationId = RecordTypeUtils.getRecordTypeId('Field_Modification',Claim__c.sObjectType);
        ClaimTemplateID = RecordTypeUtils.getRecordTypeId('Claim_Template',Claim__c.sObjectType);
        
        //Insert calimTemplate records
         claimList = TestUtility.createClaimTestRecords();
         claimList[0].RecordTypeId               = ClaimTemplateID;
         claimList[0].Causal_Part_Number__c      = wpItem.Id;
         claimList[0].Fault_Code__c              = warrantyCode.Id;
         claimList[0].Fault_found__c             = 'Alignment';
         claimList[0].Caused_by__c               ='Incorrect Setup';
         claimList[0].Total_Labor_Cost__c        = 16.00;
         claimList[0].Claim_Status__c            = 'Draft';
         claimList[0].Date_of_Failure__c         = System.today()-6;
         claimList[0].Date_of_Repair__c          = System.today()-2;
         claimList[0].In_Approval_Process__c     = true;
         claimList[0].Rate__c                    = tempRateDetail.Id;
         claimList[0].Account__c                 = accList[0].Id;
         //claimList[0].Is_Eligible_for_Appeal__c  = true;
         claimList[0].Claim_Status__c            ='Submitted';
         insert claimList[0];
        

        
         
    }
    
    //test method to call claimActionController
    static testMethod void claimActionApproveTest(){
        init();
        //Create approval Process for claim Record
        if([select count() from ProcessInstance where targetobjectid=:claimList[0].id] < 1){
            req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(claimList[0].Id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);           
        }
        Test.startTest();
            Claim__c claimObj = new Claim__c();
            ActionClaimUtility.getPicklistValues(claimObj,'Responsible_Code__c');           
            ActionClaimController.getFields();
            ActionClaimController.getApprovalAction('Approved');
            ActionClaimController.getResponsibleCodeOption();
            ActionClaimController.getClaimDetails(claimList[0].Id);
            ActionClaimController.getCurrentApproverId(claimList[0].Id);
            ActionClaimController.updateClaim(claimList[0],'Approved', 'Test Comments',2000);                   
        Test.stopTest();
    }
    
    static testMethod void claimActionRejectTest(){
        init();
        //Create approval Process for claim Record
        if([select count() from ProcessInstance where targetobjectid=:claimList[0].id] < 1){
            req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {queue.Id});
            req.setObjectId(claimList[0].Id);
            req.setProcessDefinitionNameOrId('Claim_Manual_SMR_Approval');
            req.setSkipEntryCriteria(true);
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);             
        }
        Test.startTest();
            Claim__c claimObj = new Claim__c();
            ActionClaimUtility.getPicklistValues(claimObj,'Responsible_Code__c');           
            ActionClaimController.getFields();
            ActionClaimController.getApprovalAction('Approved');
            ActionClaimController.getResponsibleCodeOption();
            ActionClaimController.getClaimDetails(claimList[0].Id);
            ActionClaimController.getCurrentApproverId(claimList[0].Id);            
            ActionClaimController.updateClaim(claimList[0],'Rejected', 'Test Comments',2000);
            ActionClaimController.updateClaim(claimList[0],'On hold', 'Test Comments',2000);
            claimList[0].Internal_Comments__c='';
            ActionClaimController.updateClaim(claimList[0],'Open', 'Test Comments',2000);            
        Test.stopTest();
    }
  
    
}