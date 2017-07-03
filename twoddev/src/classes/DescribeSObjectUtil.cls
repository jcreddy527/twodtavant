global with sharing class DescribeSObjectUtil {

	global static Schema.DescribeSObjectResult describeObject(string objName)
	{
		Map<String,Schema.SObjectType> objGlobalDescribe = Schema.getGlobalDescribe();
		string crntObjName = objName;
        Schema.SObjectType sobjTypeParent = objGlobalDescribe.get(crntObjName);
        Schema.DescribeSObjectResult ObjDescription= sobjTypeParent.getDescribe();
        
        return ObjDescription;
	} 
	
	
	global static Map<String, Schema.SObjectField> getAllFieldDescription(string objName)
	{
		Map<String, Schema.SObjectField> allFieldMap = new Map<String, Schema.SObjectField>();
		Schema.DescribeSObjectResult ObjDescription = describeObject(objName);
		allFieldMap = ObjDescription.fields.getMap();
		
		return allFieldMap;
	}
	
	global static map<string,string> getFieldNameLabelMap(string objName)
	{
		map<string,string> FieldNameLabelMap = new map<string,string>();
		Map<String, Schema.SObjectField> allFieldMap = getAllFieldDescription(objName);
		
		for(String fieldname:allFieldMap.keySet()){
            Schema.SObjectField sfield = allFieldMap.get(fieldname);
            Schema.DescribeFieldResult descResField = sfield.getDescribe();
            FieldNameLabelMap.put(descResField.getName(),descResField.getLabel());
            
        }
        
        return FieldNameLabelMap;
	}
	
	global static map<string,string> getFieldNameTypeMap(string objName)
	{
		map<string,string> FieldNameTypeMap = new map<string,string>();
		Map<String, Schema.SObjectField> allFieldMap = getAllFieldDescription(objName);
		
		for(String fieldname:allFieldMap.keySet()){
			
            Schema.SObjectField sfield = allFieldMap.get(fieldname);
            Schema.DescribeFieldResult descResField = sfield.getDescribe();
            String FldType = String.valueOf(descResField.getType());
            FieldNameTypeMap.put(descResField.getName(),FldType);
        }
        
        return FieldNameTypeMap;
	}
}