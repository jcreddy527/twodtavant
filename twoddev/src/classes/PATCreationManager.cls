/**********************************************************************
 Name:  PATCreationManager
 Copyright ? 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Manager class for the Controller that handles creation of PAT record                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -   Abhishek        17/11/2014      INITIAL DEVELOPMENT
***********************************************************************/
global with sharing class PATCreationManager{

    global map<Id,String> nameIDMap;
    global List<String> recordIDList;
    
    //Constructor
    global PATCreationManager() {
        recordIDList = new List<String>();
    }
    
    /*******************************************************************
    Purpose: Get the selected records from the lookup window                                               
    Parameters: map<Id,String> nameIDMap,List<sObject> sObjList,List<SObjectFieldValueWrapper> fieldValueWrapperRecordList,PolicyApplicabilityWrapper PDAppsWrapr,List<String> recordIDList,boolean isRendered,List<String> fieldList,String selectedObjectIds,Map<String, String> mapApiNameLabel
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global List<SObjectFieldValueWrapper> addNewObjectRecordMngr(String selectedObjectIds, Set<String> setFields,String objName) {
        List<SObjectFieldValueWrapper> fieldValueWrapperRecordList = new List<SObjectFieldValueWrapper>();        
        recordIDList = new List<String>();
        if(!StringUtils.isBlank(selectedObjectIds)) {
            nameIDMap= new map<Id,String>();
            
            list<string> temp = new list<String>();
            temp = selectedObjectIds.split(',');
            
            Set<String> appRecordSet = new Set<String>();
            for(String s : temp){
                appRecordSet.add(String.escapeSingleQuotes(s));
            }
            
            //recordIDList = new List<String>();
            for(String str : appRecordSet) {
                recordIDList.add(String.escapeSingleQuotes(str));
            }
            
            String soql = new SoqlBuilder()
                .selectx(setFields)
                .fromx(String.escapeSingleQuotes(objName))
                .wherex(new AndCondition()
                    .add(new SetCondition('Id')
                    .inx(recordIDList)))
                .toSoql();
            List<sObject> sObjList = Database.query(soql);
            if(sObjList!=null && sObjList.size()>0){
                for(sOBject sObj:sObjList){
                    nameIDMap.put((Id)sObj.get('Id'),String.valueof(sObj.get('name')));
                    Map<String, String> sObjRecordMap = new Map<String,String>();
                    String value ='';
                    for(String f : setFields) {
                        System.debug('===============>'+f);
                        if(!f.contains('.')) {
                            value = String.valueOf(sObj.get(f));
                        } else {
                             String pre = f.subString(0,f.indexOf('.'));
                             String post = f.subString(f.indexOf('.')+1,f.length());
                             value = String.valueOf(sObj.getSobject(pre).get(post));
                        }
                        if(StringUtils.isBlank(value)) {
                            value = '';
                        }
                        sObjRecordMap.put(f, value);
                    }
                    fieldValueWrapperRecordList.add(new SObjectFieldValueWrapper((String)sObj.get('Id'), sObjRecordMap)); 
                }
            }
        }        
        return fieldValueWrapperRecordList;
    }
    
    
    /*******************************************************************
    Purpose:   Saves the selected service campaign records                                                   
    Parameters: String selectedObjectIds,PolicyApplicabilityWrapper PDAppsWrapr,Id patId,List<String> recordIDList,map<Id,String> nameIDMap
    Returns: PageReference
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference savePDRecordMngr(PolicyApplicabilityWrapper PDAppsWrapr,String patId,set<string> selectedValSet,boolean isExist) {
        boolean isApplied = true;
        if((recordIDList.size() == 0 && (StringUtils.isBlank(PDAppsWrapr.policyAppTerm.Applicability_Label__c))) || (isExist == true && (selectedValSet == null || selectedValSet.size() == 0))) {
            PageUtils.addError('Please add atleast one related item');
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
                         //if(Schema.sObjectType.Policy_Applicability_Term__c.fields.Id.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Id.isUpdateable()){
                             system.debug('#####################'+ApexPages.currentPage().getParameters().get('id'));
                          // pAppTermRecord.Id = ApexPages.currentPage().getParameters().get('id');
                       // }
                        if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Policy_Definition__c.isCreateable()){                  
                            pAppTermRecord.Policy_Definition__c = patId;
                        }
                        if (Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable()){
                            pAppTermRecord.WR_Field_Mapping__c = patRecord.WR_Field_Mapping__c;
                        }
                        
                        if(!StringUtils.isBlank(PDAppsWrapr.PolicyAppTerm.id) ){
                            if(Schema.sObjectType.Policy_Applicability_Term__c.fields.id.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.id.isUpdateable()){
                                pAppTermRecord.id = PDAppsWrapr.PolicyAppTerm.id;
                            }
                        }
                        pAppTermRecord.Id =  ApexPages.currentPage().getParameters().get('id');
                      		system.debug('pAppTermRecord.Id'+pAppTermRecord.Id);
                        	
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
               //if(Schema.sObjectType.Policy_Applicability_Term__c.fields.Id.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Id.isUpdateable()){
                          //  pAppTermRecord.Id = ApexPages.currentPage().getParameters().get('id');
                        //}
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Policy_Definition__c.isCreateable()){
                 pAppTermRecord.Policy_Definition__c = patId;
                 }
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
                //if(Schema.sObjectType.Policy_Applicability_Term__c.fields.Id.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.Id.isUpdateable()){
                           // pAppTermRecord.Id = ApexPages.currentPage().getParameters().get('id');
                        //}
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.Policy_Definition__c.isCreateable()){
                 pAppTermRecord.Policy_Definition__c = patId;
                 }
                 if (Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable()){
                    pAppTermRecord.WR_Field_Mapping__c =PDAppsWrapr.PolicyAppTerm.WR_Field_Mapping__c;
                 }
                
                if(!StringUtils.isBlank(PDAppsWrapr.PolicyAppTerm.id)){
                    pAppTermRecord.id = PDAppsWrapr.PolicyAppTerm.id;
                }
                patRecordList.add(pAppTermRecord);
            }
            if(!patRecordList.isEmpty()){
                if(CrudUtil.isPATUpsertable() && Schema.sObjectType.Policy_Applicability_Term__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.isUpdateable()){
                    system.debug('======patRecordList======'+patRecordList);
                    upsert  patRecordList;
                    system.debug('======patRecordList======'+patRecordList);
                }else{                
                    ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                    return null;
                }
            }
        }
        PageReference pageRef = new PageReference('/' + patId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}