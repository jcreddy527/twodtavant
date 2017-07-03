global class MultipleRecordsInsertion {

    
    global static string NameSpace;
  static{
    NameSpace = SystemUtils.getNameSpace();
    system.debug('---NameSpace-'+NameSpace);
  } 
    
    @AuraEnabled
    global static String insertRecords(List<sObject> listSObjects, String parentId){
        return 'SUCCESS';
    }
    
    @AuraEnabled
    global static List<String> listOfFields {get;set;}
    
    @AuraEnabled
    global static Integer recNumber {get;set;}
    
    //@AuraEnabled 
    global Static sObject childRecord {get;set;}
    
    @AuraEnabled
    global static String saveSobject(sObject objSObject){
        system.debug('::::: objSObject:'+objSObject);
        try{
            upsert objSObject;    
            return 'Record has been upserted:'+objSObject.Id;
        }catch(Exception e){
            return e.getMessage();
        }
        
    }
    
    /*
    @AuraEnabled
    global static List<childRecord> getDefaultDatas(String childObjectName, String fields){
        //Map<Integer, sObject> mapSObject    =   new Map<Integer, sObject>();
        List<childRecord> listSObjects  =   new List<childRecord>();
        listChilds                      =   new List<childRecord>();
        List<String> listString         =   new List<String>();
        listString                      =   fields.split(',');
        sObject obj                     =   Schema.getGlobalDescribe().get(childObjectName).newSObject() ;
        childRecord objChildRecord      =   new childRecord();
        for(String fieldName : listString){
            obj.put(fieldname, 'Name@name.com');
        }
        recNumber = objChildRecord.index = 1;
        //childRecord = Schema.getGlobalDescribe().get(childObjectName).newSObject();
        childRecord = objChildRecord.record= obj;
        listSObjects.add(objChildRecord);
        listChilds.add(objChildRecord);
        system.debug(':::: listSObjects:'+listSObjects);
        return listSObjects;
    }
    */
    
    @AuraEnabled
    global static List<sObject> findSObjectsBySOQL(String query) {
        system.debug('----------query--------'+query);
        return  Database.query(query);
    }
    
    
    @AuraEnabled
    global static List<sObject>  getDefaultData(String childObjectName, String fields){
        Map<Integer, sObject> mapSObject    =   new Map<Integer, sObject>();
        List<sObject> listSObjects          =   new List<sObject>();
        //listChilds                        =   new List<childRecord>();
        List<String> listString             =   new List<String>();
        listString                          =   fields.split(',');
        sObject obj       = childRecord     =   Schema.getGlobalDescribe().get(childObjectName).newSObject() ;
        //childRecord objChildRecord        =   new childRecord();
        for(String fieldName : listString){
            obj.put(fieldname, 'Name@name.com');
        }
        //recNumber = objChildRecord.index = 1;
        //childRecord = Schema.getGlobalDescribe().get(childObjectName).newSObject();
        //objChildRecord.record= obj;
        listSObjects.add(obj);
        //listChilds.add(objChildRecord);
        system.debug(':::: mapSObject:'+mapSObject);
        return listSObjects;
    }
    
    @AuraEnabled
    global static List<sObject> addRow(List<sObject> recordsInfo, String childObjectName, String fields){
        System.debug('::: countVal:'+recordsInfo);
        List<sObject> listSobject   =   new List<sObject>();
        sObject obj                 =   Schema.getGlobalDescribe().get(childObjectName).newSObject() ;
        List<String> listString             =   new List<String>();
        listString                          =   fields.split(',');
        for(String fieldName : listString){
            obj.put(fieldname, 'Name');
        }
        recordsInfo.add(obj);
        
        //Map<Integer, sObject> mapSObject    =   new Map<Integer, sObject>();
        //List<childRecord> listSobjects = new List<childRecord>();
        //listSobjects.addAll(listChilds);
        //childRecord objChildRecord  =   new childRecord();
        //objChildRecord.index        =   Integer.valueOf(countVal) + 1;
        //objChildRecord.record       =   childRecord;
        //listSobjects.add(objChildRecord);
        System.debug(':::: recordsInfo:'+recordsInfo);
        return recordsInfo;
    }
    
    /* Code started for the multiple childs insertion */
    @AuraEnabled
    global static List<MultipleRecordsInsertion.GenerateChild> childFieldsDetails(String listChildFields, String objectName){
        Map<Id,String> mapValues    =   new Map<id, String>();
        system.debug(':::: list Data:'+listChildFields);
        List<MultipleRecordsInsertion.GenerateChild> listChilds =   new List<MultipleRecordsInsertion.GenerateChild>();
        List<String> listChildsString = new List<String>();
        listChildsString     =   listChildFields.split(',');
        //Schema.getGlobalDescribe().get(childObjectName).newSObject()
        Set<String> stringFields =   new Set<String>();
        stringFields.addAll(listChildsString);
        //generate a Map of all sObject names (keys) to sObject tokens (values)
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        //declare a string to hold the name of an arbitrary sObject
        String objName = objectName;
        
        //get the Schema.DescribeSObjectResult of the ObjName arbitrary sObject
        Schema.DescribeSObjectResult arbDSR = schemaMap.get(ObjName).getDescribe();
        
        //generate a Map of all Field names (keys) to field tokens (values)
        Map<String, Schema.SobjectField> fieldMap = arbDSR.fields.getMap();
        
        //declare a string to hold the name of an arbitrary picklist field
        //String fieldName = 'FirstName';
        
        //get the Schema.DescribeFieldResult o f the fieldName arbitrary field
        for(String fieldName : stringFields) {
            Schema.DescribeFieldResult arbDFR   =   fieldMap.get(fieldName).getDescribe();
            System.debug('::::: arbDFR:'+arbDFR.getSobjectField());
            GenerateChild    objJSON            =   new GenerateChild(string.valueOf(arbDFR.getSobjectField()),arbDFR.getLabel(),string.valueOf(arbDFR.getType()),boolean.valueOf(arbDFR.isAccessible()),boolean.valueOf(arbDFR.isUpdateable()),'','');
            listChilds.add(objJSON);
            //System.debug('::::: JSON String:'+jsonString);
        }
        
        //system.debug(':::: arbDFR:'+arbDFR);
        //GenerateJSON    objJSON =   new GenerateJSON();
        //String jsonString   =   JSON.serialize(objectToSerialize)

       /* Map<String, Schema.DescribeFieldResult> finalMap =  
          Utils.getFieldMetaData( Schema.getGlobalDescribe().get('Account').newSObject().getSObjectType().getDescribe(), listChildsString);
        
        // only print out the 'good' fields
        for (String field : listChildsString) {  
            System.debug(finalMap.get(field).getName()); // field name
            System.debug(finalMap.get(field).getType()); // field type
            System.debug(finalMap.get(field).getLength()); // field length
        } */
        system.debug('::: list childs:'+listChilds);
        return listChilds;
    }
    
    @AuraEnabled
   global static List<sObject> recordsInfo(){
       return  Database.query('SELECt Id, FirstName, LastName, Email, Phone FROM'+NameSpace+ 'Contact LIMIT 3');
   }
    
    
    global class GenerateChild{
        @AuraEnabled
        global String apiName {get;set;}
        @AuraEnabled
        global string label {get;set;}
        @AuraEnabled
        global string typeValue {get;set;}
        @AuraEnabled
        global boolean read {get;set;}
        @AuraEnabled
        global boolean write {get;set;}
        @AuraEnabled
        global string defaultValue {get;set;}
        @AuraEnabled
        global string lookUpInput {get;set;}
        global GenerateChild(String apiName, String label, String typeValue, boolean read, boolean write, String defaultValue, string lookUpInput){
            this.apiName        =   apiName;
            this.label          =   label;
            this.typeValue      =   typeValue;
            this.read           =   read;
            this.write          =   write;
            this.defaultValue   =   defaultValue;
            this.lookUpInput    =   lookUpInput;
        }
    }
}