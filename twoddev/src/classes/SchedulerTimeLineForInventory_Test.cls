@isTest
global class SchedulerTimeLineForInventory_Test{
    static testMethod void testSchedulerTimeLineCreationForInventory(){
        
        CustomSettingsUtilityTest.init();
                
        //insert country
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        //insert dealer
        Account acc = new Account();
        acc.Name = 'Beta testac';
        acc.Country__c = country.Id;
        acc.Warranty_Account_Type__c = 'Dealer';
        insert acc;
        
        //insert customer
        Account customer = new Account();
        customer.name = 'cus';
        customer.Warranty_Account_Type__c = 'Customer';
        insert customer;
        
        //insert product
        Warranty_Product__c demoProduct = new Warranty_Product__c();
        demoProduct.Name = 'Product';
        demoProduct.Units_of_Measure__c = 'Hours';
        demoProduct.Product_Name__c = 'Product';
        demoProduct.Type__c = 'Product';
        insert demoProduct;
        
        //insert model
        Warranty_Product__c demoModel = new Warranty_Product__c();
        demoModel.Name = 'Model';
        demoModel.Parent_Product__c = demoProduct.Id;
        demoModel.Units_of_Measure__c = 'Hours';
        demoModel.Product_Name__c = 'Model';
        demoModel.Type__c = 'Model';
        insert demoModel;
        
        //insert item
        Warranty_Product__c demoItem = new Warranty_Product__c();
        demoItem.Name = 'Item';
        demoItem.Parent_Product__c = demoModel.Id;
        demoItem.Item_Type__c = 'Part';
        demoItem.Track_Type__c = 'Serialized';
        demoItem.Units_of_Measure__c = 'Hours';
        demoItem.Product_Name__c = 'Item';
        demoItem.Type__c = 'Item';
        insert demoItem;
        
        
        List<RecordType> RecordTypeList1 = [select Id,DeveloperName from RecordType where SobjectType='Inventory__c' AND DeveloperName='Warrantable'];
        //insert inventory
        Inventory__c inv = new Inventory__c();
        inv.Name = 'invTest';
        inv.Serial_Number__c = 'inv123344';
        inv.Item__c = demoItem.Id;
        inv.Account__c = acc.Id;
        inv.Install_Date__c = system.today();
        inv.Type__c = 'Stock';
        inv.Asset_Type__c = 'Warrantable';
        inv.RecordTypeId = RecordTypeList1[0].Id;
        insert inv;
        
        //insert Warranty rule
        Warranty_Rule__c rule = new Warranty_Rule__c();
        rule.Name = 'test';
        rule.Logical_Grouping__c = 'OR';
        rule.Object_API_Name__c = 'INVENTORY__C';
        rule.Enabled__c = false;
        rule.Rule_Type__c = 'Eligibility Rule';
        rule.Object_Type__c = 'Inventory';
        insert rule;
        
        //insert Warranty rule criteria
        Warranty_Rule_Criteria__c ruleCriteria = new Warranty_Rule_Criteria__c();
        ruleCriteria.Warranty_Rule__c = rule.id;
        ruleCriteria.Criteria_Type__c = 'Equals';
        ruleCriteria.Field_Name__c = 'Record ID';
        ruleCriteria.Field_API_Name__c = 'Id';
        ruleCriteria.Field_Type__c = 'ID';
        ruleCriteria.Criteria_Value__c = inv.Id;
        ruleCriteria.Sequence__c = 2;
        insert ruleCriteria;
        
        //activate Warranty rule
        rule.Enabled__c = true;
        upsert rule;
        
        //insert payment def
        Payment_Definitions__c pd = new Payment_Definitions__c();
        pd.Name = 'Labour';
        pd.Status__c = 'Active';
        insert pd;
        
        List<RecordType> RecordTypeListPd = [select Id,DeveloperName from RecordType where SobjectType='Policy_Definition__c' AND DeveloperName='Standard_Warranty'];
        //insert policy
        Policy_Definition__c policy = new Policy_Definition__c();
        policy.name = 'test';
        policy.Description__c = 'test';
        policy.Priority__c = 1;
        policy.Active_From__c = system.today()-10;
        policy.Active_Until__c = system.today()+10;
        policy.Type__c = 'Standard';
        policy.Status__c ='Active';
        policy.Payment_Definition__c = pd.Id;
        policy.RecordTypeId = RecordTypeListPd[0].Id;
        policy.Months_Covered__c = 36;
        insert policy;
        
        //insert PAT
        Policy_Applicability_Term__c pat = new Policy_Applicability_Term__c();
        pat.Applicability_Term_Type__c = 'Referred by ID';
        pat.Applicability_SubType__c = 'Warranty_Product__c';
        pat.Applicability_Value__c = demoItem.id;
        pat.Policy_Definition__c = policy.Id;
        insert pat;
        
        //insert Master Schedule
        Master__c masterScheduler = new Master__c();
        masterScheduler.name = 'Master Scheduler 11';
        masterScheduler.Warranty_Rule__c = rule.id;
        masterScheduler.Active_From__c = system.today()-10;
        masterScheduler.Active_Until__c = system.today()+10;
        masterScheduler.Active__c = true;
        masterScheduler.Priority__c = 2;
        insert masterScheduler;
        
        //insert timeline
        Scheduler_Timeline__c timeline = new Scheduler_Timeline__c();
        timeline.name = 'Rule 1';
        timeline.Master_Scheduler__c = masterScheduler.Id;
        timeline.Description__c = 'Engine Oil Change';
        timeline.Time_Unit__c = 'Months';
        timeline.Scheduler_Time__c = 4;
        timeline.Order__c = 1;
        timeline.Unit_Type_Usage__c = 'Hours';
        timeline.Units_Allowed_Usage__c = 500;
        //timeline.Claim_Template__c = 
        insert timeline;
        
        
        WarrantyRegistrationCtrl wr = new WarrantyRegistrationCtrl(new ApexPages.StandardController(inv));
        wr.fetchPolicyDefinitions();
        wr.registerInventory();
    }
}