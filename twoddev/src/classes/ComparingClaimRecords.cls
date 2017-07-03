/**********************************************************************
 Name:  ComparingClaimRecords
 Copyright ? 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Class is used to compare claimModification records vs Claim Template records and 
It's related records.                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 - Siva             10/04/2016     INITIAL DEVELOPMENT            
***********************************************************************/
Global class ComparingClaimRecords {
    
    /*******************************************************************
    Purpose: Method which accepts wrapper for updating the
             FieldModification Claim Records if mismatch in FieldModificationrecord and Claimtemplate record.
    ********************************************************************/
    
    global static string NameSpace;
  static{
    NameSpace = SystemUtils.getNameSpace();
    system.debug('---NameSpace-'+NameSpace);
  } 
    
    
    @InvocableMethod
    global static void updateFieldModificationRecords(list<ClaimRecordsWrapper> claimRecordsWrpList){
        system.debug('##'+ClaimRecordsWrpList);
        
        //Varibale intialization
        string query;       
        set<Id> fieldModificationIds = new set<Id>();
        Set<Id> claimTemplateIds = new set<Id>();
        set<Id> claimRecordIds = new set<Id>();
        Map<String, String> parentChildInfoMap = new Map<String,String>();
        SObjectType objectSchema;
        Map<String, Schema.SObjectField> claimFieldMap;
        List<Claim__c> fieldModificationRecords = new List<Claim__c>();
        List<Claim__c> ClaimTemplateRecords = new List<Claim__c>();
        List<Claim__c> finalUpdateClaimRecords = new List<Claim__c>();
        List <String> claimAPIFieldNames = new List <String>();
        Map<String, String> mapClaimAPIFieldNames = new Map<String,String>();
        List <String> claimPartAPIFieldNames = new List <String>();
        Map<String, String> mapClaimPartAPIFieldNames = new Map<String,String>();
        //List <String> removedClaimPartAPIFieldNames = new List <String>();
        //Map<String, String> mapRemovedClaimPartAPIFieldNames = new Map<String,String>();        
        List <String> claimServiceAPIFieldNames = new List <String>();
        Map<String, String> mapClaimServiceAPIFieldNames = new Map<String,String>();        
        List<Claim_Part__c> finalUpdateClaimPartRecords = new List<Claim_Part__c>();
        //List<Removed_Claim_Part__c> finalUpdateRemovedClaimPartRecords = new List<Removed_Claim_Part__c>();
        List<Claim_Service_Information__c> finalUpdateClaimServiceRecords = new List<Claim_Service_Information__c>();
        Map<Id,String> finaldataupdate = new Map<Id,String>();
        Map<Id, Claim__c> mapIdwithClaimRecord = new Map<Id,Claim__c>();
        Set<String> claimFieldsSet = new Set<String>();
        Set<String> claimPartsFieldsSet = new Set<String>();
        Set<String> claimServiceFieldsSet = new Set<String>(); 
        Map<String, Claim__c> mapClaims = new Map<String, Claim__c>();
        Map<String, Claim__c> mapClaimParts = new Map<String, Claim__c>();
        Map<String, Claim__c> mapClaimServices = new Map<String, Claim__c>(); 
        set<String> claimPartMatchIds = new set<String>();
        set<String> claimServiceMatchIds = new set<String>();
        Map<String, String> claimPartsMatchMap = new Map<String, String>();
        Map<String, String> claimserviceMatchMap = new Map<String, String>();
        String claimParts = '\n Claim Parts \n';  
        
        //Start the process logic        
        try {

            if(claimRecordsWrpList!=null && !claimRecordsWrpList.isEmpty()){
                for(ClaimRecordsWrapper cpWrapper : claimRecordsWrpList){
                    system.debug('$$$'+cpWrapper); 
                    for(Claim__c fieldModificationClaim:cpWrapper.fieldModificationClaimList){
                        claimRecordIds.add(fieldModificationClaim.Id); //added field modification claim records
                        fieldModificationIds.add(fieldModificationClaim.Id); //only field modification claim records
                    }
                    for(Claim__c claimtemplateClaim:cpWrapper.claimTemplateClaimList){
                        claimRecordIds.add(claimtemplateClaim.Id); //added claim template claim records
                        claimTemplateIds.add(claimtemplateClaim.Id);//only claim template claim records
                    }
                }
                system.debug('The Claim Ids are...'+claimRecordIds);
            }
            
            /*****************************************************
             * query custom settings data
             * Parent and child objects info
             * ***************************************************/             
             WOD__c parentChildInfoList = WOD__c.getValues('FieldMod_Objects');      
            system.debug('******'+parentChildInfoList);
             List<String> objValues = parentChildInfoList.Trigger_Value__c.split(','); 
             
             /*****************************************************
             * query custom settings data
             * Claims Fields to compare
             * ***************************************************/             
             Map<string, WOD__c> ClaimFieldCompareMap =  WOD__c.getAll();
             system.debug('##--------->'+ClaimFieldCompareMap);
             for(String str:ClaimFieldCompareMap.keySet()){
                 if(str.contains('FieldMod_Claim_CompareFields')){
                     system.debug('The values are'+ClaimFieldCompareMap.get(str));
                     WOD__c claimFieldList = ClaimFieldCompareMap.get(str);
                     List<String> claimFields = claimFieldList.Trigger_Value__c.split(',');
                     claimFieldsSet.addAll(claimFields);      
                 }
                 if(str.contains('FieldMod_ClaimParts_CompareFields')){
                     system.debug('The values are'+ClaimFieldCompareMap.get(str));
                     WOD__c claimFieldList = ClaimFieldCompareMap.get(str);
                     List<String> claimPartsFields = claimFieldList.Trigger_Value__c.split(',');
                     claimPartsFieldsSet.addAll(claimPartsFields);
                 }
                 if(str.contains('FieldMod_ClaimService_CompareFields')){
                     system.debug('The values are'+ClaimFieldCompareMap.get(str));
                     WOD__c claimFieldList = ClaimFieldCompareMap.get(str);
                     List<String> claimServiceFields = claimFieldList.Trigger_Value__c.split(',');
                     claimServiceFieldsSet.addAll(claimServiceFields);
                 }   
             }
             
                                                   
            //--Getting claim object field api names dynamically
            objectSchema = schema.getGlobalDescribe().get(objValues[0]);
            claimFieldMap = objectSchema.getDescribe().fields.getMap();
            
            //--Construct generic query string used to query claim data dynamically
            query ='select ';
            for(Schema.SObjectField s : claimFieldMap.values()){
                     query = query + s.getDescribe().getName()+',';
                     if(s.getDescribe().isCustom()){
                        ClaimAPIFieldNames.add(s.getDescribe().getName());
                        mapClaimAPIFieldNames.put(s.getDescribe().getName(),s.getDescribe().getLabel());
                     }
            }
            query = query.removeEnd(','); 
            query = query + ' from '+NameSpace+'Claim__c where Id IN:  claimRecordIds';      
            List<Claim__c> claimList = Database.query(query);
            System.debug('*********Claim List**************'+ClaimList);
            
            //Compare the FieldModification Claim Record Vs ClaimTemplate Claim Record
            for(Claim__c claim:claimList){
                mapIdwithClaimRecord.put(claim.id, claim);
                if(FieldModificationIds.contains(claim.Id)){
                    FieldModificationRecords.add(claim);                  
                }
                if(ClaimTemplateIds.contains(claim.Id)){
                    ClaimTemplateRecords.add(claim);
                    String claimTempId = claim.Id;                    
                    mapClaims.put(claimTempId.left(15),claim);
                }
            }
        
            for(Claim__c fieldClaim:fieldModificationRecords){
                String finalResult ='';
                fieldClaim.Business_Validation__c = '';               
                Claim__c ClaimTemplate = mapClaims.get(fieldClaim.ClaimTemplateID__c);
                //for(Claim__c ClaimTemplate:ClaimTemplateRecords){
                    if(fieldClaim.ClaimTemplateID__c == ClaimTemplate.Id){
                        for(String fieldName:ClaimAPIFieldNames) {
                            if(fieldClaim.get(fieldName)!= ClaimTemplate.get(fieldName) && claimFieldsSet.contains(fieldName)){
                                finalResult = finalResult+' , '+ '('+fieldName+' | '+mapClaimAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | '+fieldClaim.get(fieldName)+')';
                            }
                        }   
                    }
                                 
                //}
                finalResult = finalResult.removeStart(' ,');
                fieldClaim.Business_Validation__c = finalResult;
                finalResult = finalResult+'\n\n Claim Parts Info ';                
                finaldataupdate.put(fieldClaim.Id,finalResult);
                system.debug('The Final Result is'+finaldataupdate);
            } 
            
            //Query for Installed claim part records
            List<Claim_Part__c> fieldModificationClaimPartRecords = new List<Claim_Part__c>();
            List<Claim_Part__c> claimTemplateClaimPartRecords = new List<Claim_Part__c>();
            
            if(objValues.size()>1){                       
                String ObjName = objValues[1];           
                DynamicQueryConstruction DQC = new DynamicQueryConstruction();            
                String claimPartsQuery = DQC.DynamicQuery(ObjName,claimRecordIds);
                system.debug('The claim parts Query'+claimPartsQuery);
                claimPartAPIFieldNames = DQC.ObjAPIFieldNames;
                mapClaimPartAPIFieldNames = DQC.mapObjAPIFieldNames;            
                List<Claim_Part__c> claimPartList = Database.query(claimPartsQuery);
                system.debug('************* part list'+ClaimPartList);
            
                //divide the fieldModification claim parts and cliamtemplate parts
                for(Claim_Part__c claimPart : claimPartList){
                    if(FieldModificationIds.contains(claimPart.Claim__c)){
                        fieldModificationClaimPartRecords.add(claimPart);
                    }
                    if(ClaimTemplateIds.contains(claimPart.Claim__c)){
                        claimTemplateClaimPartRecords.add(claimPart);
                    }
                }
            }
            //Compare the fieldModification claim parts and cliamtemplate parts
            for(Claim_Part__c fieldClaim:fieldModificationClaimPartRecords){
                String finalResult ='\n';
                Boolean newParts = false;                
                for(Claim_Part__c claimTemplate:claimTemplateClaimPartRecords){
                    
                    if(fieldClaim.Type__c == 'Installed Part'){                       
                        if(fieldClaim.Warranty_Product__c == ClaimTemplate.Warranty_Product__c && fieldClaim.Claim__r.ClaimTemplateID__c == claimTemplate.Claim__c){
                              for(String fieldName:claimPartAPIFieldNames) {
                                if(fieldClaim.get(fieldName)!= claimTemplate.get(fieldName) && claimPartsFieldsSet.contains(fieldName)){                                                                  
                                    finalResult = finalResult+' , '+ '('+fieldClaim.Warranty_Product__r.name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | '+fieldClaim.get(fieldName)+')';
                                }
                            }
                            newParts  = true;                            
                            claimPartMatchIds.add(claimTemplate.Id);
                            claimPartsMatchMap.put(claimTemplate.Claim__c,fieldClaim.Claim__c);  
                        }
                    }
                    if(fieldClaim.Type__c == 'Serialized Part' || fieldClaim.Type__c == 'Non-Serialized Part' ){
                        if(fieldClaim.Inventory__c == ClaimTemplate.Inventory__c  && fieldClaim.Claim__r.ClaimTemplateID__c == claimTemplate.Claim__c){
                              for(String fieldName:claimPartAPIFieldNames) {
                                if(fieldClaim.get(fieldName)!= claimTemplate.get(fieldName) && claimPartsFieldsSet.contains(fieldName)){                                
                                    finalResult = finalResult+' , '+ '('+fieldClaim.Inventory__r.name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | '+fieldClaim.get(fieldName)+')';
                                }
                            }
                            newParts  = true;                           
                            claimPartMatchIds.add(claimTemplate.Id);
                            claimPartsMatchMap.put(claimTemplate.Claim__c,fieldClaim.Claim__c);
                               
                        } 
                    }
                    if(fieldClaim.Type__c == 'Miscellaneous Part'){
                        if(fieldClaim.Name == ClaimTemplate.Name && fieldClaim.Claim__r.ClaimTemplateID__c == claimTemplate.Claim__c){
                            for(String fieldName:claimPartAPIFieldNames) {
                                if(fieldClaim.get(fieldName)!= claimTemplate.get(fieldName) && claimPartsFieldsSet.contains(fieldName)){                                
                                    finalResult = finalResult+' , '+ '('+fieldClaim.Name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | '+fieldClaim.get(fieldName)+')';
                                }
                            }
                            newParts  = true;                           
                            claimPartMatchIds.add(claimTemplate.Id);
                            claimPartsMatchMap.put(claimTemplate.Claim__c,fieldClaim.Claim__c);   
                        }
                    }
                    
                }
                
                //checking new parts added to field modification claim.
                if(newParts== false){
                    if(fieldClaim.Type__c == 'Installed Part'){
                        for(String fieldName:claimPartAPIFieldNames){
                            if(claimPartsFieldsSet.contains(fieldName)){
                                finalResult = finalResult+' , '+ '('+fieldClaim.Warranty_Product__r.name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | 0 | '+fieldClaim.get(fieldName)+')';
                            } 
                        }                                                                  
                    }
                    if(fieldClaim.Type__c == 'Serialized Part' || fieldClaim.Type__c == 'Non-Serialized Part' ){
                        for(String fieldName:claimPartAPIFieldNames){
                            if(claimPartsFieldsSet.contains(fieldName)){
                                finalResult = finalResult+' , '+ '('+fieldClaim.Inventory__r.name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | 0 | '+fieldClaim.get(fieldName)+')';
                            } 
                        }                          
                    }
                    if(fieldClaim.Type__c == 'Miscellaneous Part'){
                        for(String fieldName:claimPartAPIFieldNames){
                            if(claimPartsFieldsSet.contains(fieldName)){
                                finalResult = finalResult+' , '+ '('+fieldClaim.Name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | 0 | '+fieldClaim.get(fieldName)+')';
                            } 
                        }                         
                    }                    
                }
                
                //finalResult = finalResult.removeStart('\n ,');
                finalResult = finalResult.replace('\n ,','\n');                              
                claim__c claim = mapIdwithClaimRecord.get(fieldClaim.Claim__c);
                finalResult = finaldataupdate.get(claim.Id)+','+finalResult;
                //finalResult = finalResult.removeEnd(',');
                finalResult = finalResult.replace(' ,','');
                finaldataupdate.put(claim.Id ,finalResult);                             
                system.debug('The Final Result is1'+finaldataupdate);
            }
            
            for(Claim_Part__c claimTemplate:claimTemplateClaimPartRecords){
                String finalResult ='\n';
                String fieldModClaim = claimPartsMatchMap.get(claimTemplate.Claim__c);
                //checking old parts which are not part of field modification claim. 
                    if(!claimPartMatchIds.contains(claimTemplate.Id)){
                        if(claimTemplate.Type__c == 'Installed Part'){
                            for(String fieldName:claimPartAPIFieldNames){
                                if(claimPartsFieldsSet.contains(fieldName)){
                                    finalResult = finalResult+' , '+ '('+claimTemplate.Warranty_Product__r.name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | 0)';
                                } 
                            }                                                                  
                        }
                        if(claimTemplate.Type__c == 'Serialized Part' || claimTemplate.Type__c == 'Non-Serialized Part' ){
                            for(String fieldName:claimPartAPIFieldNames){
                                if(claimPartsFieldsSet.contains(fieldName)){
                                    finalResult = finalResult+' , '+ '('+claimTemplate.Inventory__r.name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | 0)';
                                } 
                            }                          
                        }
                        if(claimTemplate.Type__c == 'Miscellaneous Part'){
                            for(String fieldName:claimPartAPIFieldNames){
                                if(claimPartsFieldsSet.contains(fieldName)){
                                    finalResult = finalResult+' , '+ '('+claimTemplate.Name+' | '+fieldName+' | '+mapClaimPartAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | 0)';
                                } 
                            }                         
                        }   
                    }
                    
                    //finalResult = finalResult.removeStart(' ,'); 
                    finalResult = finalResult.replace('\n ,','\n');                               
                    claim__c claim = mapIdwithClaimRecord.get(fieldModClaim);
                    finalResult = finaldataupdate.get(claim.Id)+','+finalResult;
                    finalResult = finalResult.removeEnd(',');
                    finaldataupdate.put(claim.Id ,finalResult);                             
                    system.debug('The Final Result is1'+finaldataupdate);
                        
            }
            
            
            //adding claim service info text to business validation.
            if(!finaldataupdate.isEmpty()){
                system.debug('the final data update'+finaldataupdate);
                for(Id claimRecId:finaldataupdate.keySet()){
                    String finalResult ='';
                    finalResult = finaldataupdate.get(claimRecId)+'\n Claim Service Info \n';                
                    finaldataupdate.put(claimRecId,finalResult);
                }
            } 
            
            
            /*********************************************************************************
             * Query for claim service part records
             * *******************************************************************************/
            List<Claim_Service_Information__c> fieldModificationClaimServiceRecords = new List<Claim_Service_Information__c>();
            List<Claim_Service_Information__c> claimTemplateClaimServiceRecords = new List<Claim_Service_Information__c>();
             if(objValues.size()>2){
                String ObjName2 = objValues[2];
                DynamicQueryConstruction DQC2 = new DynamicQueryConstruction();
                String claimServiceQuery = DQC2.DynamicQuery(ObjName2,claimRecordIds);
                system.debug('The claim service Query'+claimServiceQuery);
                claimServiceAPIFieldNames = DQC2.ObjAPIFieldNames;
                mapClaimServiceAPIFieldNames = DQC2.mapObjAPIFieldNames;
                List<Claim_Service_Information__c> claimServiceList = Database.query(claimServiceQuery);
                system.debug('************* part list'+claimServiceList);
                
                //divide the fieldModification claim removed parts and cliamtemplate removed parts
                for(Claim_Service_Information__c claimServicePart : claimServiceList){
                    if(FieldModificationIds.contains(claimServicePart.Claim__c)){
                        fieldModificationClaimServiceRecords.add(claimServicePart);
                    }
                    if(ClaimTemplateIds.contains(claimServicePart.Claim__c)){
                        claimTemplateClaimServiceRecords.add(claimServicePart);
                    }
                }
            }
            //Compare the fieldModification claim service parts and cliamtemplate parts
            for(Claim_Service_Information__c fieldClaim:fieldModificationClaimServiceRecords){
                String finalResult ='\n';
                Boolean newParts = false;                
                for(Claim_Service_Information__c claimTemplate:claimTemplateClaimServiceRecords){
                    
                    if(fieldClaim.Service_Job_Code__c == ClaimTemplate.Service_Job_Code__c && fieldClaim.Claim__r.ClaimTemplateID__c == claimTemplate.Claim__c){
                        for(String fieldName:claimServiceAPIFieldNames) {
                            if(fieldClaim.get(fieldName)!= claimTemplate.get(fieldName) && claimServiceFieldsSet.contains(fieldName)){                               
                                finalResult = finalResult+' , '+ '('+fieldClaim.Service_Job_Code__r.name+' | '+fieldName+' | '+mapClaimServiceAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | '+fieldClaim.get(fieldName)+')';
                            }
                        }
                        newParts  = true;                        
                        claimServiceMatchIds.add(claimTemplate.Id);
                        claimserviceMatchMap.put(claimTemplate.Claim__c,fieldClaim.Claim__c);   
                    }
                     
                                 
                }
                
                if(newParts == false){                    
                    for(String fieldName:claimServiceAPIFieldNames){
                        if(claimServiceFieldsSet.contains(fieldName)){
                            finalResult = finalResult+' , '+ '('+fieldClaim.Service_Job_Code__r.name+' | '+fieldName+' | '+mapClaimServiceAPIFieldNames.get(fieldName)+' | 0 | '+fieldClaim.get(fieldName)+')';
                        } 
                    }                                                                                     
                }
               
                finalResult = finalResult.replace('\n ,','');                                              
                claim__c claim = mapIdwithClaimRecord.get(fieldClaim.Claim__c);                
                finalResult = finaldataupdate.get(claim.Id)+','+finalResult;              
                finalResult = finalResult.replace('\n,','\n');
                finaldataupdate.put(claim.Id ,finalResult);               
                system.debug('The Final Result is3'+finaldataupdate);
            }
           
            for(Claim_Service_Information__c claimTemplate:claimTemplateClaimServiceRecords){
                String finalResult ='\n';
                String fieldModClaim = claimserviceMatchMap.get(claimTemplate.Claim__c);
                //checking old claim service info which are not part of field modification claim. 
                    if(!claimServiceMatchIds.contains(claimTemplate.Id)){                       
                        for(String fieldName:claimServiceAPIFieldNames){
                            if(claimServiceFieldsSet.contains(fieldName)){
                                finalResult = finalResult+' , '+ '('+claimTemplate.Service_Job_Code__r.name+' | '+fieldName+' | '+mapClaimServiceAPIFieldNames.get(fieldName)+' | '+ClaimTemplate.get(fieldName)+' | 0)';
                            } 
                        }                                                                  
                    }                   
                    finalResult = finalResult.replace('\n ,','');                  
                    claim__c claim = mapIdwithClaimRecord.get(fieldModClaim);                
                    finalResult = finaldataupdate.get(claim.Id)+','+finalResult;                   
                    finalResult = finalResult.replace('\n,','\n');
                    finaldataupdate.put(claim.Id ,finalResult);               
                    system.debug('The Final Result is3'+finaldataupdate);   
            }
        }
        catch(Exception e){
            System.debug('The Exception is'+e);
        }
        
        
        //Update FieldModification records
        try{
            if(!finaldataupdate.isEmpty()){
                system.debug('the final data update'+finaldataupdate);
                for(Id claimRecId:finaldataupdate.keySet()){
                    system.debug('the final data update1'+claimRecId);
                    claim__c claim = new claim__c();
                    claim.id = claimRecId;
                    claim.Business_Validation__c = finaldataupdate.get(claimRecId);
                    finalUpdateClaimRecords.add(claim);
                }
            } 
            
            if(!finalUpdateClaimRecords.isEmpty()){
                system.debug('the final data update2'+finalUpdateClaimRecords);
                if (Schema.sObjectType.Claim__c.isUpdateable()) {
                    update finalUpdateClaimRecords;
                }
            }                      
        }
        Catch(Exception e){
            System.debug('The Exception is'+e);
        }
        
        
        
    }    
    /***********************************************************
     * Define Requested parameters
     * *********************************************************/
    global class ClaimRecordsWrapper{
        @InvocableVariable(required=false)
        global List<Claim__c> fieldModificationClaimList;
        
        @InvocableVariable(required=false)
        global List<Claim__c> claimTemplateClaimList;
    }
}