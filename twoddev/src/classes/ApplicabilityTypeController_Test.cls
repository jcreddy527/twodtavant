@isTest
private class ApplicabilityTypeController_Test{
    static testMethod void testApplicabilityTypeController(){

        CustomSettingsUtilityTest.init();
        WOD__c wod = new WOD__c();
        wod.name = 'Lookup Record Limit on PAT';
        wod.Trigger_Value__c = '10';
        insert wod;
        
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
        List<Id> idsList = new List<Id>();
        demoItem.Name = 'Item';
        demoItem.Parent_Product__c = demoModel.Id;
        demoItem.Item_Type__c = 'Part';
        demoItem.Track_Type__c = 'Serialized';
        demoItem.Units_of_Measure__c = 'Hours';
        demoItem.Product_Name__c = 'Item';
        demoItem.Type__c = 'Item';
        insert demoItem;
        idsList.add(demoItem.Id);
        String myJSON = JSON.serialize(demoItem);
        system.debug('myJSON ==>'+myJSON );
        
         //insert payment def
        Payment_Definitions__c pd = new Payment_Definitions__c();
        pd.Name = 'Labour';
        pd.Status__c = 'Active';
        insert pd;
        
        //insert policy
        Policy_Definition__c policy = new Policy_Definition__c();
        String policyId;
        policy.name = 'test';
        policy.Description__c = 'test';
        policy.Priority__c = 1;
        policy.Active_From__c = system.today()-10;
        policy.Active_Until__c = system.today()+10;
        policy.Type__c = 'Standard';
        policy.Status__c ='Active';
        policy.Payment_Definition__c = pd.Id;
        policy.RecordTypeId = '01228000000OK5m';
        policy.Months_Covered__c = 36;
        insert policy;
        policyId = policy.Id;
        
        ApplicabilityTypeController.getApplicabilityTypes();
        ApplicabilityTypeController.getApplicabilitySubTypes('Customer Type');
        ApplicabilityTypeController.getWRFieldMappings();
        ApplicabilityTypeController.findByName('Test');
        ApplicabilityTypeController.getRecords('Account','Test');
        ApplicabilityTypeController.SavePDRecord(myJSON ,'Item','Referred by ID','Warranty_Product__c',idsList,policyId,null,'Item');
    }
    
}