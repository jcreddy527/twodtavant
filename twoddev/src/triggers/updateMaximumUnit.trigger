trigger updateMaximumUnit on Warranty_Coverages__c (before insert) {

    // Get all 'CustomSettings' records
        WOD__c enableupdateMaximumUnit = WOD__c.getValues('Enable updateMaximumUnit');  
    if(enableupdateMaximumUnit.isTriggered__c == true){
        set<Id> warrantyRegistrationId= new set<Id>();
        set<Id> policyDefinitionId= new set<Id>();
        String unitsOfMeasure;
        List<Warranty_Registration__c> warrantyRegistration =new List<Warranty_Registration__c>();  
        Map<Id,Warranty_Registration__c> warrantyRegistrationMap=new map<Id,Warranty_Registration__c>();
        
        List<Policy_Definition_Inventory_Usage__c> policyDefinitionInventoryUsage =new List<Policy_Definition_Inventory_Usage__c>();  
        
        
        for(Warranty_Coverages__c warrantyCoverage: Trigger.new )
        {
            warrantyRegistrationId.add(warrantyCoverage.Warranty_Registration__c);
            policyDefinitionId.add(warrantyCoverage.Policy_Definition__c);
        }
        
        warrantyRegistration =[select Id,Inventory__c,Inventory__r.Item__c,Inventory__r.Item__r.Units_of_Measure__c from Warranty_Registration__c where Id IN: warrantyRegistrationId];
        
        for(Warranty_Registration__c warrantyReg:  warrantyRegistration )
        {
            warrantyRegistrationMap.put(warrantyReg.Id, warrantyReg);   
        }
        
        policyDefinitionInventoryUsage =[select Id,Name,Maximum_Unit__c,Policy_Definition__c,Units_of_Measure__c from Policy_Definition_Inventory_Usage__c where Policy_Definition__c IN: policyDefinitionId];
    
        for(Warranty_Coverages__c warrantyCoverage : Trigger.new)
        {
            Warranty_Registration__c warrantyRegi=warrantyRegistrationMap.get(warrantyCoverage.Warranty_Registration__c);
            unitsOfMeasure=warrantyRegi.Inventory__r.Item__r.Units_of_Measure__c;
            system.debug('unitsOfMeasure---' + unitsOfMeasure);
            for(Policy_Definition_Inventory_Usage__c policyDef : policyDefinitionInventoryUsage)
            {
                system.debug('policyDef.Policy_Definition__c---' + policyDef.Policy_Definition__c);
                system.debug('warrantyCoverage.Policy_Definition__c---' + warrantyCoverage.Policy_Definition__c);
                system.debug('policyDef.Units_of_Measure__c---' + policyDef.Units_of_Measure__c);
                system.debug('unitsOfMeasure---' +unitsOfMeasure);
                
                if((policyDef.Policy_Definition__c==warrantyCoverage.Policy_Definition__c)&&(policyDef.Units_of_Measure__c==unitsOfMeasure))
                {
                    warrantyCoverage.Maximum_Unit__c=policyDef.Maximum_Unit__c;       
                }
            }
            
        } 
    } 
}