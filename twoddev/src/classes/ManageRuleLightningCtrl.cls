public class ManageRuleLightningCtrl {
    
    @AuraEnabled
    public  static Map<string, list<string>> getPicklistValues(){        
        Map<string, list<string>> optionsMap =new Map<string, list<string>>();
        list<string> options = new list<string>();                   
        
        List<Schema.PicklistEntry> ple  = Schema.SObjectType.Warranty_Rule__c.fields.getMap().get('Logical_Grouping__c').getDescribe().getPicklistValues();
        options.add('--None--');
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
            
        }
        optionsMap.put('Logical_Grouping__c', new list<string>(options)); 
        
        ple  = Schema.SObjectType.Warranty_Rule__c.fields.getMap().get('Rule_Type__c').getDescribe().getPicklistValues();        
        options = new list<string>();
        options.add('--None--');
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
            
        }
        optionsMap.put('Rule_Type__c', new list<string>(options));
        return optionsMap;
    }
    
    @AuraEnabled
    public static map<string, string > getObjectType(){
        Map<String, Schema.SObjectType> mapObj = Schema.getGlobalDescribe();     
        map<string, string > objOptions = new map<string, string>();        
        objOptions.put('Account', 'Account');
        objOptions.put('Contact', 'Contact');
        for(String objname:mapObj.keySet()){
            Schema.SObjectType sobj = mapObj.get(objname);
            Schema.DescribeSObjectResult descRes = sobj.getDescribe();
            
            if(descRes.isCustom() && !descRes.isCustomSetting()){                
                objOptions.put(descRes.getLabel(), descRes.getName());
            }            
        }
        return objOptions;        
    }
    
    @AuraEnabled
    public  static string createRecord(string WarrantyRuleName, string LogicalGrouping, string ObjectType, string ObjectAPIName, string RuleType){
        Warranty_Rule__c newrule = new Warranty_Rule__c();
        
        if (Schema.sObjectType.Warranty_Rule__c.fields.Name.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Name.isUpdateable() ){
            newrule.Name = WarrantyRuleName;
        }
        if (Schema.sObjectType.Warranty_Rule__c.fields.Logical_Grouping__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Logical_Grouping__c.isUpdateable() ){
            newrule.Logical_Grouping__c = LogicalGrouping;
        }
        if (Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isUpdateable() ){
            newrule.Object_Type__c = ObjectType;
        }
        if (Schema.sObjectType.Warranty_Rule__c.fields.Rule_Type__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Rule_Type__c.isUpdateable() ){
            newrule.Rule_Type__c = RuleType;
        }
        if (Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isUpdateable() ){            
            newrule.Object_API_Name__c = ObjectAPIName;
        }
        
        insert newrule;
        return newrule.id;
    }   
    
}