public class ApplicabilityTypeController {
    static String searchStringLabel;
    static String selectedObjectIds;
    static  List<SObjectFieldValueWrapper> ls;
    static Map<String, String> mapApiNameLable;
    static public List<String> fields;
    static Integer limitValue;
    static Integer countLimit;
    static Set<String> setOfFields;
    static String objName;
    static List<String> externalIdFields;
     
     boolean rendermsg;
    
    @AuraEnabled
    public  static list<string> getApplicabilityTypes (){
        list<string> ATypes = new list<string>();
        Schema.DescribeFieldResult fieldResult = Policy_Applicability_Term__c.Applicability_Term_Type__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : pValues)
        {
            ATypes.add(f.getLabel());
        } 
        return ATypes;
    }
    @AuraEnabled
    public  static list<string> getApplicabilitySubTypes (string ApplicabilityTypeSelected){
        list<string> ATypes = new list<string>();
        Schema.DescribeFieldResult fieldResult = Policy_Applicability_Term__c.Applicability_SubType__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        if(ApplicabilityTypeSelected.equalsIgnoreCase('Referred by ID')){        
            for( Schema.PicklistEntry f : pValues)
            {
                if(f.getLabel() != 'Customer Type'){
                  ATypes.add(f.getLabel());
                }
            } 
        }else{
            for( Schema.PicklistEntry f : pValues)
            {
                if(f.getLabel() == 'Customer Type'){
                  ATypes.add(f.getLabel());
                }
            } 
        }
        return ATypes;
    }
    @AuraEnabled
    public  static list<string> getWRFieldMappings (){
        list<string> ATypes = new list<string>();
        Schema.DescribeFieldResult fieldResult = Policy_Applicability_Term__c.WR_Field_Mapping__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : pValues)
        {
            ATypes.add(f.getLabel());
        } 
        return ATypes;
    }
    /*@AuraEnabled
    public  static String  getRecords1 (){
    system.debug('===getRecords===');
    list<account> accs = new list<account>();
        list<map<string, string>> mapOfRecords = new list<map<string, string>>();
        List<String> fieldList = new List<String>();
        String selectedObjectIds = '0011500001TS1Nc';
        PATCreationManager PATManager = new PATCreationManager();
        String objName = 'Account';
        Map<String, String> mapApiNameLabel = new Map<String, String>();
        mapApiNameLabel = CustomSettingFactory.getLookUpFieldsWithLabel(objName);
        Set<String> setOfFields = new Set<String>();
        /*setOfFields.addAll(mapApiNameLabel.keySet());
        setOfFields.remove('Name');
        setOfFields.remove('Limit');
        fieldList.add('Name');
        fieldList.addAll(setOfFields);
        setOfFields.add('Name');
        setOfFields.add('id');
        PATLookUpWrapper ps = new PATLookUpWrapper();        
        List<SObjectFieldValueWrapper> fieldValueWrapperRecordList= PATManager.addNewObjectRecordMngr(selectedObjectIds,setOfFields,String.escapeSingleQuotes(objName));  
        //system.debug('fieldValueWrapperRecordList is ------>>>>'+fieldValueWrapperRecordList.size() +'---'+fieldValueWrapperRecordList);           
        /*if(fieldValueWrapperRecordList!= null && fieldValueWrapperRecordList.size() >0) {            
            PDAppsWrapr.name = fieldValueWrapperRecordList[0].objMap.get('Name');
        }
        return JSON.serialize(fieldValueWrapperRecordList);
        //return [SELECT Name, Type, Active__c, AccountNumber FROM account limit 20 ];
    }*/
    @AuraEnabled
    public  static list<account> findByName (string searchKey){ 
        String name = '%' + searchKey + '%';
        return [SELECT Name, Type, Active__c, AccountNumber FROM account WHERE name LIKE :name LIMIT 20];
    }
    
    
    @AuraEnabled
    public  static string getRecords(string oName, string searchKey ){
        
        map<string, string> fieldNameAndLabel = new map<string, string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(oName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            
        fields = new List<String>();
        setOfFields = new Set<String>();
        mapApiNameLable = new Map<String, String>();
        ls = new List<SObjectFieldValueWrapper>();
        objName = oName;
        searchStringLabel = searchKey;
        
        if(!StringUtils.isBlank(objName)) {
            mapApiNameLable = CustomSettingFactory.getLookUpFieldsWithLabel(objName);
            if(mapApiNameLable.size() >0){
              limitValue = mapApiNameLable.get('Limit') == null ? 10 : Integer.valueOf(mapApiNameLable.get('Limit'));
              countLimit = limitValue;
              setOfFields.addAll(mapApiNameLable.keySet());
              setOfFields.remove('Limit');
              fields.addAll(setOfFields);
                for(string fieldName : fields){
                    fieldNameAndLabel.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
                }                
                string recordsAndFieldLabel = fetchRecords() + 'record-Field-Separater' + JSON.serialize(fieldNameAndLabel);
              return recordsAndFieldLabel;
              system.debug('ls is ----->'+ls.size() +'---'+ls);
            } 
        }
        return null;
    }
    
    
    
  
    public static string fetchRecords() {
      if(mapApiNameLable.size() != 0){
        ls = new List<SObjectFieldValueWrapper>();
          List<sObject> sobjList = new List<sObject>();
          String soql;
          if(!StringUtils.isBlank(searchStringLabel)) {
              List<FieldCondition> fList = new List<FieldCondition>();
              fList.add(new FieldCondition('Name').likex(String.escapeSingleQuotes(searchStringLabel)));
              countLimit = countLimit+1;
              soql = new SoqlBuilder()
              .selectx(setOfFields)
              .fromx(String.escapeSingleQuotes(objName))
              .wherex(new AndCondition()
              .add(fList))
              .limitx(countLimit)
              .toSoql(new SoqlOptions().wildcardStringsInLikeOperators());
          } else {
              soql = new SoqlBuilder()
              .selectx(setOfFields)
              .fromx(objName)
              .limitx(countLimit)
              .toSoql(new SoqlOptions().wildcardStringsInLikeOperators());
          }
          system.debug('SOQL Query : '+soql);
          sobjList = Database.query(soql);          
          Integer i=1;
          for(SObject s : sobjList) {
              Map<String, String> maps = new Map<String,String>();
              String value ='';
              system.debug('@manosh : '+fields);
              for(String f : fields) {
                value = String.valueOf(s.get(f));
                if(StringUtils.isBlank(value)) {
                      value = '';
                  }
                    if(f =='Name' && (value == '' || value == null)) {
                      
                  }
                  else {
                      maps.put(f, value);
                  }
              }
              if(i <= limitValue && maps.size() > 0) {
                  ls.add(new SObjectFieldValueWrapper((String)s.get('Id'), maps)); 
                  i++;
              }
          }
      }
        return JSON.serialize(ls);
    }
    
    @AuraEnabled
    public static string SavePDRecord(string fieldValueWrapperRecordString, string RecordName, string ApplicabilityTermType, string ApplicabilitySubType, list<Id> recordIDList, string polDefId, string WRFieldMappings, string ApplicabilityLabel){               
        Id patId;
        map<string, string> nameIDMap =new  map<string, string>();
        PATCreationManager PATManager = new PATCreationManager();
        List<SObjectFieldValueWrapper> fieldValueWrapperRecordList = new List<SObjectFieldValueWrapper>();
        if(!String.isEmpty(fieldValueWrapperRecordString)){
            fieldValueWrapperRecordList = (List<SObjectFieldValueWrapper>)System.JSON.deserialize(fieldValueWrapperRecordString, List<SObjectFieldValueWrapper>.class);
        }
        for(SObjectFieldValueWrapper sof : fieldValueWrapperRecordList){
            nameIDMap.put(sof.objectId, sof.objMap.get('Name') );
        }
        PolicyApplicabilityWrapper PDAppsWrapr;
        PDAppsWrapr = new PolicyApplicabilityWrapper(new Policy_Applicability_Term__c());
        patId = polDefId;
        PDAppsWrapr.name = RecordName;
        PDAppsWrapr.PolicyAppTerm.Applicability_Term_Type__c = ApplicabilityTermType;
        PDAppsWrapr.PolicyAppTerm.Applicability_SubType__c = ApplicabilitySubType;
        //PDAppsWrapr.PolicyAppTerm.WR_Field_Mapping__c = WRFieldMappings;
        PDAppsWrapr.PolicyAppTerm.Applicability_Label__c = ApplicabilityLabel;
        if(CrudUtil.isPATUpsertable()){
            try{
                set<String> selectedValSet = new set<String>();
                boolean isExist = false;
                system.debug('fieldValueWrapperRecordList is --->>>'+fieldValueWrapperRecordList);
                system.debug('PAT Id value..--...>'+selectedObjectIds  );
                If(fieldValueWrapperRecordList != null && fieldValueWrapperRecordList.size() > 0)
                {
                        if(fieldValueWrapperRecordList.size() == 1)
                        {
                                fieldValueWrapperRecordList[0].isSelected = true;
                        }
                        isExist = true;
                    for(SObjectFieldValueWrapper sobjPATWrpr : fieldValueWrapperRecordList)
                    {
                        if(sobjPATWrpr.isSelected)
                        {
                            selectedValSet.add(sobjPATWrpr.objectId);
                        }
                    }
                }
                system.debug('selectedValSet is ---->>>'+selectedValSet);
                system.debug('PDAppsWrapr is ---->>>'+PDAppsWrapr);
                string  p= savePDRecordMngr(PDAppsWrapr,patId,selectedValSet,isExist, recordIDList, nameIDMap);
                return null;
            } catch(Exception e) {
                PageUtils.addError('Error'+e.getMessage());
                return null;
            }
        }else{
                //ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
        }
    }
    public static string savePDRecordMngr(PolicyApplicabilityWrapper PDAppsWrapr,String patId,set<string> selectedValSet,boolean isExist, list<Id> recordIDList, map<string, string> nameIDMap) {
        boolean isApplied = false;
        if((recordIDList.size() == 0 && (StringUtils.isBlank(PDAppsWrapr.policyAppTerm.Applicability_Label__c))) || (isExist == true && (selectedValSet == null || selectedValSet.size() == 0))) {
            //PageUtils.addError('Please add atleast one related item');
            return null;
        } else {
            system.debug(selectedValSet + '----@97------'+recordIDList);
            List<Policy_Applicability_Term__c> patRecordList = new List<Policy_Applicability_Term__c> ();
            Policy_Applicability_Term__c patRecord = PDAppsWrapr.policyAppTerm;
            if(StringUtils.equals(patRecord.Applicability_Term_Type__c, 'Referred by ID')){
                for(String selectedId: recordIDList){
                    
                    if(selectedValSet.contains(selectedId))
                    {
                        Policy_Applicability_Term__c pAppTermRecord = new Policy_Applicability_Term__c();
                        if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isUpdateable()){
                            pAppTermRecord.Applicability_Term_Type__c = patRecord.Applicability_Term_Type__c;   
                        }
                        if(Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isUpdateable()){
                            pAppTermRecord.Applicability_SubType__c = patRecord.Applicability_SubType__c;
                        }
                        if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isUpdateable()){
                            pAppTermRecord.Applicability_Value__c = selectedId;
                        }
                        if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isUpdateable()){
                            pAppTermRecord.Applicability_Label__c= nameIDMap.get(selectedId);
                        }                   
                        pAppTermRecord.Policy_Definition__c = patId;
                        if (Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable()){
                            pAppTermRecord.WR_Field_Mapping__c = patRecord.WR_Field_Mapping__c;
                        }
                        
                        if(!StringUtils.isBlank(PDAppsWrapr.PolicyAppTerm.id)){
                            pAppTermRecord.id = PDAppsWrapr.PolicyAppTerm.id;
                        }
                        patRecordList.add(pAppTermRecord);
                        isApplied = true;
                    }
                }
            }else if(!StringUtils.isBlank(PDAppsWrapr.PolicyAppTerm.Applicability_Label__c)){
                Policy_Applicability_Term__c pAppTermRecord = new Policy_Applicability_Term__c();
                
                if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isUpdateable()){
                    pAppTermRecord.Applicability_Term_Type__c = patRecord.Applicability_Term_Type__c;
                }
                if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isUpdateable()){
                    pAppTermRecord.Applicability_SubType__c = patRecord.Applicability_SubType__c;
                }
                    
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isUpdateable()){
                    pAppTermRecord.Applicability_Value__c = PDAppsWrapr.PolicyAppTerm.Applicability_Label__c;
                 }
                
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isUpdateable()){
                    pAppTermRecord.Applicability_Label__c= PDAppsWrapr.PolicyAppTerm.Applicability_Label__c;
                 }
                 pAppTermRecord.Policy_Definition__c = patId;
                
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable()){
                    pAppTermRecord.WR_Field_Mapping__c =PDAppsWrapr.PolicyAppTerm.WR_Field_Mapping__c;
                 }
                
                if(!StringUtils.isBlank(PDAppsWrapr.PolicyAppTerm.id)){
                    pAppTermRecord.id = PDAppsWrapr.PolicyAppTerm.id;
                }
                patRecordList.add(pAppTermRecord);
                isApplied = true;
            }
            
            if(isApplied == false && PDAppsWrapr != null)
            {
                Policy_Applicability_Term__c pAppTermRecord = new Policy_Applicability_Term__c();
                
                if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Term_Type__c.isUpdateable()){
                    pAppTermRecord.Applicability_Term_Type__c = patRecord.Applicability_Term_Type__c;
                }
                if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_SubType__c.isUpdateable()){
                    pAppTermRecord.Applicability_SubType__c = patRecord.Applicability_SubType__c;
                }
                    
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isUpdateable()){
                    pAppTermRecord.Applicability_Value__c = PDAppsWrapr.PolicyAppTerm.Applicability_Value__c;
                 }
                
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Label__c.isUpdateable()){
                    pAppTermRecord.Applicability_Label__c= PDAppsWrapr.PolicyAppTerm.Applicability_Label__c;
                 }
                 pAppTermRecord.Policy_Definition__c = patId;
                
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable()){
                    pAppTermRecord.WR_Field_Mapping__c =PDAppsWrapr.PolicyAppTerm.WR_Field_Mapping__c;
                 }
                
                if(!StringUtils.isBlank(PDAppsWrapr.PolicyAppTerm.id)){
                    pAppTermRecord.id = PDAppsWrapr.PolicyAppTerm.id;
                }
                patRecordList.add(pAppTermRecord);
            }
            if(!patRecordList.isEmpty()){
                if(CrudUtil.isPATUpsertable()){
                    upsert  patRecordList;
                }else{                
                    //ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                    return null;
                }
            }
        }
        PageReference pageRef = new PageReference('/' + patId);
        pageRef.setRedirect(true);
        return null;
    }
    
}