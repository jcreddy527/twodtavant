@isTest
global class ClaimCreateEditExtTest {
    
    @isTest static void testStandardVFPageController() {

           //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
                 
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Claim Duplicate Check Period In Days';
        objsetting8.Trigger_Value__c = '90';
        customSettings.add(objsetting8);
        
        insert customSettings;        
        
        Claim__c dummyClaim = new Claim__c();
        List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Claim_Template'];
        dummyClaim.RecordTypeId = claimRecordTypeList[0].Id;
        insert dummyClaim;

        //add job code
        List<RecordType> jobCodeRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Warranty_Code__c' AND DeveloperName='Job_Code'];
        Warranty_Code__c jobCode  = new Warranty_Code__c();
        jobCode.Selectable__c = true;
        jobCode.Standard_Labor_Hour__c = 6;
        jobCode.name = 'Text-JC';
        jobCode.RecordTypeId = jobCodeRecordTypeList[0].Id;
        insert jobCode;

        //add claim service info code
        Claim_Service_Information__c csi = new Claim_Service_Information__c();
        csi.Claim__c = dummyClaim.Id;
        csi.Service_Job_Code__c = jobCode.Id;
        insert csi;


        //set the custom setting
        insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
        insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
        ApexPages.StandardController std = new ApexPages.StandardController(dummyClaim);

        //set the vf page parameters
        Test.setCurrentPageReference(new PageReference('Page.ClaimCreateEdit_vf'));
        System.currentPageReference().getParameters().put('id', dummyClaim.Id);


        new ClaimCreateEditExt(std);

    }

    @isTest static void testClaimDetailGetter() {
            //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
              
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Enable changeCustomerName';
        objsetting8.isTriggered__c = true;
        customSettings.add(objsetting8);
        
        WOD__c  objsetting9 = new WOD__c();
        objsetting9.Name = 'Claim Duplicate Check Period In Days';
        objsetting9.Trigger_Value__c = '90';
        customSettings.add(objsetting9);
        
        insert customSettings;
                
        //simple test
        insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
        insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
        //Claim__c dummyClaim = new Claim__c();
        //List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Claim_Template'];
        //dummyClaim.RecordTypeId = claimRecordTypeList[0].Id;
        //insert dummyClaim;
        
        List<Inventory__c> inv = TestUtility.createInventoryTestRecords();
        insert inv;
       
        Claim__c dummyClaim2 = new Claim__c();
        List<RecordType> claimRecordTypeList1 = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Serialized_Part'];
        dummyClaim2.RecordTypeId = claimRecordTypeList1[0].Id;
        dummyClaim2.Claim_Record_Type__c = 'Serialized';
        dummyClaim2.Inventory__c = inv[0].Id;
        insert dummyClaim2;
        //ApexPages.StandardController std = new ApexPages.StandardController(dummyClaim);
        ApexPages.StandardController std1 = new ApexPages.StandardController(dummyClaim2);
        //new ClaimCreateEditExt(std).getClaimDetails(null);
        new ClaimCreateEditExt(std1).getClaimDetails(null);

    }
    
    @isTest static void testGetPartPrice() {
            //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
        
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Enable changeCustomerName';
        objsetting8.isTriggered__c = true;
        customSettings.add(objsetting8);
        
        WOD__c  objsetting9 = new WOD__c();
        objsetting9.Name = 'Claim Duplicate Check Period In Days';
        objsetting9.Trigger_Value__c = '90';
        customSettings.add(objsetting9);
        
        insert customSettings;
                
        //simple test
        insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
        insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
        //Claim__c dummyClaim = new Claim__c();
        //List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Claim_Template'];
        //dummyClaim.RecordTypeId = claimRecordTypeList[0].Id;
        //insert dummyClaim;
        
        List<Inventory__c> inv = TestUtility.createInventoryTestRecords();
        insert inv;
        
        Claim__c dummyClaim2 = new Claim__c();
        List<Id> claimList = new List<Id>();
        List<RecordType> claimRecordTypeList1 = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Serialized_Part'];
        dummyClaim2.RecordTypeId = claimRecordTypeList1[0].Id;
        dummyClaim2.Claim_Record_Type__c = 'Serialized';
        dummyClaim2.inventory__c = inv[0].id;
        insert dummyClaim2;
        claimList.add(dummyClaim2.Id);
        system.debug('claimList-->'+claimList);
        //ApexPages.StandardController std = new ApexPages.StandardController(dummyClaim);
        //ApexPages.StandardController std1 = new ApexPages.StandardController(dummyClaim2);
        //new ClaimCreateEditExt(std).getClaimDetails(null);
        //ClaimCreateEditExt claimRec = new ClaimCreateEditExt(new ApexPages.StandardController(dummyClaim2));
        ClaimCreateEditExt.getPartPrice(claimList);
        
    }

    @isTest static void testClaimDetailGetterWithLookupException() {
            //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
        
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Claim Duplicate Check Period In Days';
        objsetting8.Trigger_Value__c = '90';
        customSettings.add(objsetting8);
        
        insert customSettings;
        
        //with lookup characters as not integer test
        insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
        insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
        Claim__c dummyClaim = new Claim__c();
        List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Claim_Template'];
        dummyClaim.RecordTypeId = claimRecordTypeList[0].Id;
        insert dummyClaim;
        ApexPages.StandardController std = new ApexPages.StandardController(dummyClaim);
        new ClaimCreateEditExt(std).getClaimDetails(null);


    }

    @isTest static void testClaimDetailGetterAsDealerUser() {
            //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
        
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Claim Duplicate Check Period In Days';
        objsetting8.Trigger_Value__c = '90';
        customSettings.add(objsetting8);
        
        insert customSettings;

        //with dealer as a user
        Id partnerProfileId = [select id from profile where name='Partner Community User'].id;
        Account partnerUserAccount = new Account(name ='testAccount') ;
        insert partnerUserAccount;

        Contact partnerUserContact = new Contact(LastName ='testCon',AccountId = partnerUserAccount.Id);
        insert partnerUserContact;
        
        

        system.runAs(new User(Id = UserInfo.getUserId())) {


        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = partnerProfileId, country='United States',IsActive =true,
                             ContactId = partnerUserContact.Id,PortalRole = 'Manager',
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
            insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
            insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
            Claim__c dummyClaim = new Claim__c();
            List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Claim_Template'];
            dummyClaim.RecordTypeId = claimRecordTypeList[0].Id;
            insert dummyClaim;
            ApexPages.StandardController std = new ApexPages.StandardController(dummyClaim);
            // new ClaimCreateEditExt(std).getClaimDetails(null);
        }



    }
    

    @isTest static void testClaimDetailGetterWithDummyClaim() {
            //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
        
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Claim Duplicate Check Period In Days';
        objsetting8.Trigger_Value__c = '90';
        customSettings.add(objsetting8);
        
        insert customSettings;
        
        Claim__c dummyClaim = new Claim__c();
        List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Claim_Template'];
        dummyClaim.RecordTypeId = claimRecordTypeList[0].Id;
        insert dummyClaim;
        ApexPages.StandardController std = new ApexPages.StandardController(dummyClaim);
        //simple test
        insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
        insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
        new ClaimCreateEditExt(std).getClaimDetails(dummyClaim.Id);


    }

    @isTest static void policyDefinitionUpdateTester() {
            //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
        
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Claim Duplicate Check Period In Days';
        objsetting8.Trigger_Value__c = '90';
        customSettings.add(objsetting8);
        
        WOD__c  objsetting9 = new WOD__c();
        objsetting9.Name = 'Enable changeCustomerName';
        objsetting9.isTriggered__c = true;
        customSettings.add(objsetting9);
        
        insert customSettings;
        
        List<Inventory__c> inv = TestUtility.createInventoryTestRecords();
        insert inv;
        
        Claim__c dummyClaim = new Claim__c();
        List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Serialized_Part'];
        dummyClaim.RecordTypeId = claimRecordTypeList[0].Id;
        dummyClaim.inventory__c = inv[0].id;
        insert dummyClaim;

        //simple test
        insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
        insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
        ClaimCreateEditExt.updatePolicyDefinition(dummyClaim.Id);


    }

    @isTest static void deepCloneClaimTester() {
            //creating required custom settings
        List<WOD__c> customSettings = new List<WOD__c>();
        WOD__c  objsetting = new WOD__c();
        objsetting.isTriggered__c = true;
        objsetting.Name = 'Enable PaymentDefinitionTrigger';
        customSettings.add(objsetting);
        WOD__c  objsetting1 = new WOD__c();
        objsetting1.isTriggered__c = true;
        objsetting1.Name = 'Enable PaymentDefinitionItemsTrigger';
        customSettings.add(objsetting1);
        WOD__c  objsetting3 = new WOD__c();
        objsetting3.isTriggered__c = true;
        objsetting3.Name = 'Enable updateMaximumUnit';
        customSettings.add(objsetting3);
        WOD__c  objsetting4 = new WOD__c();
        objsetting4.isTriggered__c = true;
        objsetting4.Name = 'Enable OnPolicyChange';
        customSettings.add(objsetting4);
        WOD__c  objsetting5 = new WOD__c();
        objsetting5.isTriggered__c = true;
        objsetting5.Name = 'All Prefix Configurations';
        objsetting5.Trigger_Value__c ='Percent_,Final_,Total_,Approved_';
        customSettings.add(objsetting5);
        WOD__c  objsetting6 = new WOD__c();
        objsetting6.isTriggered__c = true;
        objsetting6.Name = 'All Payment Configurations';
        objsetting6.Trigger_Value__c ='Labor,Meals,Parking,TravelByDistance,TravelByHours';
        customSettings.add(objsetting6);
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        WOD__c  objsetting7 = new WOD__c();
        objsetting7.Name = 'Default Price';
        objsetting7.Trigger_Value__c = String.valueOf(priceBook.Id);
        customSettings.add(objsetting7);
        
        WOD__c  objsetting8 = new WOD__c();
        objsetting8.Name = 'Claim Duplicate Check Period In Days';
        objsetting8.Trigger_Value__c = '90';
        customSettings.add(objsetting8);
        
        insert customSettings;
        
        List<RecordType> claimRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Claim__c' AND DeveloperName='Claim_Template'];
        Claim__c dummyClaimTemplate1 = new Claim__c();
        Claim__c dummyClaimTemplate2 = new Claim__c();


        dummyClaimTemplate1.RecordTypeId = claimRecordTypeList[0].Id;
        dummyClaimTemplate2.RecordTypeId = claimRecordTypeList[0].Id;
        system.debug('$$$$$$$$$$$$$------'+dummyClaimTemplate1);
        system.debug('$$$$$$$$$$$$$------'+dummyClaimTemplate2);
        insert dummyClaimTemplate1;
        insert dummyClaimTemplate2;

        //add job code
        List<RecordType> jobCodeRecordTypeList = [select Id,DeveloperName from RecordType where SobjectType='Warranty_Code__c' AND DeveloperName='Job_Code'];
        Warranty_Code__c jobCode  = new Warranty_Code__c();
        jobCode.Selectable__c = true;
        jobCode.Standard_Labor_Hour__c = 6;
        jobCode.name = 'Text-JC';
        jobCode.RecordTypeId = jobCodeRecordTypeList[0].Id;
        insert jobCode;

        //add claim service info code
        Claim_Service_Information__c csi = new Claim_Service_Information__c();
        csi.Claim__c = dummyClaimTemplate1.Id;
        csi.Service_Job_Code__c = jobCode.Id;
        insert csi;

        //add installed part
        Warranty_Product__c part = new Warranty_Product__c();
        part.Name = 'Part';
        part.Product_Name__c = 'Part';
        part.Type__c = 'Item';
        part.Item_Type__c = 'Part';
        //part.Active__c = true;
        part.Track_Type__c = 'Non-Serialized';
        insert part;

        Warranty_Product_Pricebook__c pb = new Warranty_Product_Pricebook__c();
        pb.Country__c = country.Id;
        pb.Warranty_Product__c = part.Id;
        pb.Valid_From__c = Date.today();
        pb.Valid_Until__c = Date.today();
        insert pb;
        
        WOD__c customSetting = new WOD__c();
        customSetting.Name = 'Enable InstalledClaimPart_AT';
        customSetting.isTriggered__c = true;
        insert customSetting;

        List<RecordType> installedPartRecordTypeList  = [select Id,DeveloperName from RecordType where SobjectType='Claim_Part__c' AND DeveloperName='Non_Serialized_Part'];
        Claim_Part__c installedPart = new Claim_Part__c();
        installedPart.RecordTypeId = installedPartRecordTypeList[0].Id;
        installedPart.Name = 'Installed Part';
        installedPart.Type__c = 'Installed Part';
        installedPart.Claim__c = dummyClaimTemplate1.Id;
        installedPart.Warranty_Product__c = part.Id;
        installedPart.Quantity__c = 5;
        installedPart.Warranty_Product_Pricebook__c = pb.Id;
        system.debug('@@@@@@----'+installedPart);
        insert installedPart;
        
        //simple test
        insert new WOD__c(isTriggered__c = true,Name='Auto Add Non-Serialized Removed Part');
        insert new WOD__c(Trigger_Value__c = '2',Name='Lookup Minium Characters');
        ClaimCreateEditExt.deepCloneTemplateToFieldMod(dummyClaimTemplate1.Id,dummyClaimTemplate2.Id);


    }
    
    

}