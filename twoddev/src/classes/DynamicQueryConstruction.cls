/**********************************************************************
 Name:  DynamicQueryConstruction
 Copyright ? 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Class is used to constrcut dynamic query based on object API 
Name and Claim Records IDs as Parameters.                                                   
-------                                                             
===============================================================
without sharing explanation: 
This class is used to construct dynamic query on claim object. We compare field modification and claim template records once field modification claim is submitted. 
We have define fields in custom settings to compare when field modification claim is submitted. Fields defined in custom settings cane be changed any time. 
Dealer profile don’t have necessary access on fields define in custom settings. I.e. we are constructing dynamic query with fields for feature scalability. 

===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 - Siva             10/04/2016     INITIAL DEVELOPMENT            
***********************************************************************/

global without sharing class DynamicQueryConstruction {
   global static string NameSpace;
  static{
    NameSpace = SystemUtils.getNameSpace();
    system.debug('---NameSpace-'+NameSpace);
  } 
    //Variable Declaration
    public string query;
    public SObjectType objectSchema;
    public Map<String, Schema.SObjectField> ObjFieldMap;
    public List <String> ObjAPIFieldNames{get;set;}
    public Map<String, String> mapObjAPIFieldNames {get;set;}
    
    //Method to construct dynamic query
    public String DynamicQuery(String objName, set<Id> ClaimRecordIds){
        ObjAPIFieldNames = new List <String>();
        mapObjAPIFieldNames = new Map<String, String>();
        
         /*****************************************************
             * query custom settings data
             * Parent and child objects info
             * ***************************************************/              
             WOD__c parentChildInfoList = WOD__c.getValues('FieldMod_Objects');           
             List<String> objValues = parentChildInfoList.Trigger_Value__c.split(','); 
        
        
        //--Getting claim object field api names dynamically
        objectSchema = schema.getGlobalDescribe().get(NameSpace+objName);
        ObjFieldMap = objectSchema.getDescribe().fields.getMap();
        
        //--Construct generic query string used to query claim data dynamically
        query ='select ';
        for(Schema.SObjectField s : ObjFieldMap.values()){
            if(s.getDescribe().isCustom()){
                ObjAPIFieldNames.add(s.getDescribe().getName());
                mapObjAPIFieldNames.put(s.getDescribe().getName(),s.getDescribe().getLabel());
            }
            query = query + s.getDescribe().getName()+',';                    
        }
        query = query.removeEnd(',');
        if(objName == objValues[1]){
            query = query+','+NameSpace+'Warranty_Product__r.name,'+NameSpace+'Inventory__r.name';
        }
        if(objName == objValues[2]){
            query = query+','+NameSpace+'Service_Job_Code__r.name';
        } 
        query = query + ','+NameSpace+'Claim__r.'+NameSpace+'ClaimTemplateID__c from '+NameSpace+objName+' where '+NameSpace+'Claim__c IN: claimRecordIds'; 
        system.debug('the query is'+query);
        return query;
    } 
}