public class CustomSettingLightningAppCmpContr {
    static Map<String, Schema.SObjectType> GlobalDescribe = new Map<String, Schema.SObjectType>();
    
    @AuraEnabled
    public static map<string, string> getAllCustomSettingsName(){
		map<string, string> objectNames = new map<string, string>();        
        // Get the Global Describe which contains details for all objects
        GlobalDescribe =Schema.getGlobalDescribe();        
        for(Schema.SObjectType objName : GlobalDescribe.values() ){
            if(objName.getDescribe().isCustomSetting()){
                Schema.DescribeSObjectResult obj = objName.getDescribe();                
                objectNames.put(obj.getLabel(), obj.getName());
            }
        }        
        return objectNames;
    }
    
    @AuraEnabled
    public static customSettingsWrapper getCustomSettingRecords(string cSLabel, map<string, string> objectNames){
        String objectName = objectNames.get(cSLabel);
        string queryStr = ' ';
        map<string, sObject> sobjList = new map<string, sObject>();
        
        map<string, string> fieldsLabelMap = new map<string, string>();
        customSettingsWrapper CSWrpper = new customSettingsWrapper();
        
        GlobalDescribe = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = GlobalDescribe.get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){            
			DescribeFieldResult  fieldDescr =  sfield.getDescribe();           
            if(fieldDescr.isUpdateable() && fieldDescr.isCustom()){
                
                fieldsLabelMap.put(fieldDescr.getName(), fieldDescr.getLabel());
            }
            if(!string.isBlank(queryStr)){    
                queryStr += ', '+fieldDescr.getName();
            }else{
                queryStr += fieldDescr.getName();                
            }
        }
        
        list<customSettingsRecordsWrapper> csrwList = new list<customSettingsRecordsWrapper>();
        sobjList =new  Map<string, sObject>(Database.query('SELECT '+queryStr+' FROM '+objectName));        
        for(Id  key : sobjList.keySet()){
            customSettingsRecordsWrapper csrw = new customSettingsRecordsWrapper();
            csrw.sObjectrecord = sobjList.get(key);
            csrw.sObjectId = key;
            csrwList.add(csrw);            
        }        
        CSWrpper.sObjectrecords = csrwList ;        
       
        CSWrpper.fieldsLabelMap = fieldsLabelMap;
        return CSWrpper;
    }
    
    @AuraEnabled
    public static void saveRecord(string objectName, string fieldsValue){
        system.debug('========'+fieldsValue);		
        Map<String, Object> recordValues = (Map<String, Object>)JSON.deserializeUntyped(fieldsValue);        
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{objectName});
        Schema.DescribeSobjectResult DescribeSobject;
        
        for(Schema.DescribeSobjectResult ds: results){
            DescribeSobject = ds;
        }
        
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ; 
        
        for(string key : recordValues.keySet()){
            Schema.DisplayType fielddataType  = DescribeSobject.fields.getMap().get(key).getDescribe().getType();
            if(fielddataType != Schema.DisplayType.Boolean){
                sObj.put(key, recordValues.get(key));
            }else{
                sObj.put(key, Boolean.valueOf(recordValues.get(key)));                
            }
        }        
        upsert sObj ;
        return;
    }
    
}