public class RuleCriteriaLightningCmpContr {

    public RuleCriteriaLightningCmpContr(ApexPages.StandardSetController controller) {

    }

   
    
    @AuraEnabled
    public static Map < string, list < string >> getlistValues(String WarrantyRuleId) {
        Map<string, list<string>> optionsMap =new Map<string, list<string>>();
        Warranty_Rule_Criteria__c newRuleCriteria = new Warranty_Rule_Criteria__c();
        list<string> CTypes = new list<string>();
        Warranty_Rule__c SelectedRule;
        
        
        SelectedRule = (Warranty_Rule__c) DatabaseUtils.query(WarrantyRuleId);
        
        
        Schema.DescribeFieldResult fieldResult = Warranty_Rule_Criteria__c.Criteria_Type__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        
        CTypes.add('--None--');        
        for( Schema.PicklistEntry f : pValues)
        {
            CTypes.add(f.getLabel());
        }        
        
        optionsMap.put('Criteria Type',CTypes );
        list<string> objectName = new list<string>();
        objectName.add(SelectedRule.Object_API_Name__c);
        optionsMap.put('Object Name',objectName );
        
        objectName = new list<string>();
        objectName.add(SelectedRule.Name);
        optionsMap.put('Id',objectName );        
        
        
        return optionsMap;
    }
    @AuraEnabled
    public static Map < string, string> getFieldNames(String WarrantyRuleId) {      
        Map<String, Schema.SObjectField> mapField;
        map<string, string> fieldOption = new map <string, string>();
        Warranty_Rule__c SelectedRule;
        
        if (Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isAccessible()) {
            
            SelectedRule = (Warranty_Rule__c) DatabaseUtils.query(WarrantyRuleId);                
            
            mapField = DescribeSObjectUtil.getAllFieldDescription(SelectedRule.Object_API_Name__c);             
            for (String fieldname: mapField.keySet()) {
                Schema.SObjectField sfield = mapField.get(fieldname);
                Schema.DescribeFieldResult descResField = sfield.getDescribe();
                String FTYpe = String.valueOf(descResField.getType());
                if (!'TEXTAREA'.equals(FTYpe)) {                        
                    fieldOption.put(descResField.getLabel(), descResField.getName());
                }
            }
            system.debug('ExitingpopulateFields' + fieldOption );            
        }        
        return fieldOption;
    }
    
    @AuraEnabled
    public static string getfieldDetails(String ObjectName, string fieldName) {
        system.debug('=======ObjectName=='+ObjectName);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[] {ObjectName});
        system.debug(fieldName+'=======ObjectName=='+results);
        Schema.DisplayType fielddataType= null;
        if(results.size() > 0){
        	fielddataType = results[0].fields.getMap().get(fieldName).getDescribe().getType();
        }
        
        if (fielddataType == Schema.DisplayType.String) {
            return 'String';
        }
        if (fielddataType == Schema.DisplayType.Date) {
            return 'Date';
        }
        if (fielddataType == Schema.DisplayType.DateTime) {
            return 'DateTime';
        }
        if (fielddataType == Schema.DisplayType.Picklist) {
            return 'Picklist';
        }
        if (fielddataType == Schema.DisplayType.Boolean) {
            return 'Boolean';
        }
        if (fielddataType == Schema.DisplayType.ID) {
            return 'Id';
        }
        if (fielddataType == Schema.DisplayType.Reference) {
            return 'Reference';
        }
        return 'Other';
    }
    @AuraEnabled
    public static Map<string, string> getPicklistValues(String ObjectName, string fieldName) {
        system.debug('=======ObjectName=='+ObjectName);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[] {ObjectName});
        system.debug(fieldName+'=======ObjectName=='+results);
        List<Schema.PicklistEntry> ple = results[0].fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        
        Map<string, string> options =new Map<string, string>();
        for( Schema.PicklistEntry f : ple)
        {
            options.put(f.getLabel(), f.getValue());
            
        }
        
        return options;
    }
    @AuraEnabled
    public static string getReferenceName(String ObjectName, string fieldName) {
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[] {ObjectName});
        system.debug(fieldName+'=======ObjectName=='+results);
        List<Schema.sObjectType> fielddataType = results[0].fields.getMap().get(fieldName).getDescribe().getReferenceTo();
        
        return fielddataType[0].getDescribe().getName();
    }
    
    @AuraEnabled
    public  static string createRecord(string WarrantyRule, decimal Sequence, string FieldName, string FieldApiName, string FieldType, string CriteriaType, string CriteriaValue, string ReferenceTo){
        Warranty_Rule_Criteria__c newRuleCriteria = new Warranty_Rule_Criteria__c();
        RuleManager objRuleManager  = new RuleManager();
        pagereference pageref = null;
        
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Warranty_Rule__c.isCreateable()){
            newRuleCriteria.Warranty_Rule__c = WarrantyRule;
        }
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isUpdateable() ){
            newRuleCriteria.Sequence__c = Sequence;
        }
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isUpdateable() ){
            newRuleCriteria.Field_Name__c = FieldName;
        }
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isUpdateable() ){
            newRuleCriteria.Field_API_Name__c = FieldApiName;
        }
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Type__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Type__c.isUpdateable() ){
            newRuleCriteria.Field_Type__c = FieldType;
        }
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Type__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Type__c.isUpdateable() ){
            newRuleCriteria.Criteria_Type__c = CriteriaType;
        }
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isUpdateable() ){
            newRuleCriteria.Criteria_Value__c = CriteriaValue;
        }
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Related_Object__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Related_Object__c.isUpdateable() ){
            newRuleCriteria.Related_Object__c = ReferenceTo;
        }
            
        try{
            if(CrudUtil.isWRuleCriteriaUpsertable()){
                Database.UpsertResult result = Database.upsert(newRuleCriteria);
                system.debug('===='+result);
                return 'SUCCESS::'+result.getId();
            }else{
                return 'ERROR:: INSUFFICIENT_ACCESS';
            }            
        }
        catch(Exception e){
            return 'ERROR:: '+e.getDMLMessage(0);
        }        
        
    }
}