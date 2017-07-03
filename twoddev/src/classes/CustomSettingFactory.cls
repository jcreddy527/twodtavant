global with sharing class CustomSettingFactory {
    global static Map<String, String> getLookUpFieldsWithLabel(String objName) {
    
        //Lookup_Layout_Fields__c lookupSetttings = Lookup_Layout_Fields__c.getValues('Warranty Lookup Layout');
        // Added by Chethan
        WOD__c lookupSetttings = WOD__c.getValues('Lookup Record Limit on PAT');
        System.debug('+++++++++++++'+lookupSetttings);
        
        Map<String, String> mapOfFieldWithLabel = new Map<String,String>();
        if(Schema.getGlobalDescribe().get(objName) != null && (Schema.getGlobalDescribe().get(objName).getDescribe().FieldSets.getMap().get('SmartLookupFieldSet') != null || Schema.getGlobalDescribe().get(objName).getDescribe().FieldSets.getMap().get('twod__SmartLookupFieldSet') != null)) {
            List<Schema.FieldSetMember> ls;
            if(Schema.getGlobalDescribe().get(objName).getDescribe().FieldSets.getMap().get('SmartLookupFieldSet') != null)
                ls = Schema.getGlobalDescribe().get(objName).getDescribe().FieldSets.getMap().get('SmartLookupFieldSet').getFields();
            else
                ls = Schema.getGlobalDescribe().get(objName).getDescribe().FieldSets.getMap().get('twod__SmartLookupFieldSet').getFields();
            for(Schema.FieldSetMember each: ls) {
                mapOfFieldWithLabel.put(each.getFieldPath(),each.getLabel());
            }
            if(mapOfFieldWithLabel.get('Name') == null){
                mapOfFieldWithLabel.put('Name','Name');
            }
           mapOfFieldWithLabel.put('Limit',string.ValueOf(lookupSetttings.Trigger_Value__c));
        }
        system.debug('++++++++++++++++'+mapOfFieldWithLabel);
        return mapOfFieldWithLabel;
    }
    
    global static Lookup_Layout_Fields__c getLookupLayoutFields(String objName) {
      /*  Lookup_Layout_Fields__c llf = null;
        for(Lookup_Layout_Fields__c eachLlf : Lookup_Layout_Fields__c.getall().values()) {
            if(StringUtils.equals(StringUtils.upperCase(eachLlf.name),StringUtils.upperCase(objName)) ) {
                llf = eachLlf;
            }
        } 
        return llf; */
        return null;
    }
    
}