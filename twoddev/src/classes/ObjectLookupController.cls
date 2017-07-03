/**********************************************************************
 Name:  ObjectLookupController ()
 Copyright © 2014  Tavant Technologies Inc.
 ==============================================================
===============================================================
Purpose: 
This class is used for custom multi select lookup                                                
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Manish         29/10/2014      INITIAL DEVELOPMENT
***********************************************************************/
public with sharing class ObjectLookupController {
    public String searchStringLabel{get;set;}
    public String selectedObjectIds{get;set;}
    public List<LookupWrapperClass> ls{get;set;}
    public Map<String, String> mapApiNameLable{get;set;}
    public List<String> fields{get;set;}
    Integer limitValue;
    Integer countLimit;
    Set<String> setOfFields;
    public String objName{get;set;}
    List<String> externalIdFields;
    public String displayType{get;set;}
    public boolean rendermsg{get;set;}
    //Constructor
    public ObjectLookupController() {
        rendermsg = true;
        fields = new List<String>();
        setOfFields = new Set<String>();
        mapApiNameLable = new Map<String, String>();
        ls = new List<LookupWrapperClass>();
        objName = String.escapeSingleQuotes(PageUtils.get('oName'));
        searchStringLabel = PageUtils.get('searchStr');
        displayType = PageUtils.get('displayType');
        if(!StringUtils.isBlank(objName)) {
            mapApiNameLable = CustomSettingFactory.getLookUpFieldsWithLabel(objName);
            if(mapApiNameLable.size() >0){
                limitValue = mapApiNameLable.get('Limit') == null ? 10 : Integer.valueOf(mapApiNameLable.get('Limit'));
                countLimit = limitValue;
                setOfFields.addAll(mapApiNameLable.keySet());
                setOfFields.remove('Limit');
                if(setOfFields.size() >1) {
                    setOfFields.remove('Name');
                    fields.addAll(setOfFields);
                    String s = fields.get(0);
                    fields.set(0,'Name');
                    fields.add(s);
                } else {
                    fields.addAll(setOfFields);
                }
                setOfFields.add('id');
                setOfFields.add('Name');
                fetchRecords();
                system.debug('ls is ----->'+ls.size() +'---'+ls);
            } else {
                displayType = 'No recordtype';
                rendermsg = false;
                PageUtils.addError(System.Label.Smart_Lookup_Fields);
            }
        }
    }
    
    public void noRecordSelected() {
        PageUtils.addError(System.Label.NoRecordSelected);
    }
    
    /*******************************************************************
    Purpose: fetching the records to display on popup window                                                
    Parameters: N/A
    Returns: N/A
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    public void fetchRecords() {
        if(mapApiNameLable.size() ==0) {
            displayType = 'No recordtype';
            rendermsg = false;
            PageUtils.addError(System.Label.Smart_Lookup_Fields);
        } else {
            ls = new List<LookupWrapperClass>();
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
            if(sobjList.size() > limitValue) {
                PageUtils.addError(System.Label.SearchResultErrorMsgPre+' ('+limitValue+'). '+Label.SearchResultErrorMsgPost);
            }
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
                    ls.add(new LookupWrapperClass(false, (String)s.get('Id'), maps)); 
                    i++;
                }
            }
        }
    }
    
    /*******************************************************************
    Purpose: Selecting multiple record.                                              
    Parameters: N/A
    Returns: String
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    public void onCheck() {
        String selectIds = '';
        for(LookupWrapperClass wc : ls) {
            if(wc.isSelected == true) {
                if(StringUtils.isBlank(selectIds))
                    selectIds = wc.objId;
                else
                    selectIds = selectIds+','+wc.objId;
            }
        }
        selectedObjectIds = selectIds;
    }
    
    /*******************************************************************
    Purpose: Wrapper class                                     
    Parameters: N/A
    Returns: N/A
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    public with sharing class LookupWrapperClass {
        public String objId {get;set;}
        public boolean isSelected {get;set;}
        public Map<String,String> fieldMap{get;set;}
        public LookupWrapperClass(Boolean isSel, String ids, Map<String,String> str) {
            isSelected = isSel;
            objId = ids;
            fieldMap = str;
        }
        
    }
}