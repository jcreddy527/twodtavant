global with sharing class GenericCrudController{
            
    @AuraEnabled
    global static String getclaimPrefix(){ 
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
           Schema.DescribeSObjectResult r =  gd.get(SystemUtils.getNameSpace()+'claim__c').getDescribe();
           String tempName = r.getName();
           String tempPrefix = r.getKeyPrefix();
           System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
        return tempPrefix;
    }
    @AuraEnabled
    global Static List<sObject> queryData(String query){
        return Database.query(query);
    }
    
    @AuraEnabled
    global static string recordUnlock(Id recordId, Claim__c claimRecord) {
        system.debug('-----------inside---------record unlocked');
        system.debug(claimRecord);
        system.debug(recordId);
         if(Approval.isLocked(recordId) == True){
             //Unlock the Record
             Approval.unlock(claimRecord);
             system.debug('--------------------record unlocked');
             return 'recordUnlocked';
         }else if(Approval.isLocked(claimRecord.id) == False){
             return 'recordisNotlocked';
         }
        return 'recordUnlockingexecuted';
    }
     @AuraEnabled
    global static string recordLock(Claim__c claimRecord) {
         //Lock the Record
             Approval.lock(claimRecord);
        return 'recordLocked';
    }

    @AuraEnabled
    global static OutputWrapper ReadSObjects(String query){
        OutputWrapper wrapObj = new OutputWrapper();
        String errorMsg = '';
        Boolean success = TRUE;
        List<SObject> sObjList = new List<SObject>();
        try{
            sObjList = Database.query(query);
        }
        catch (Exception e){
           success = FALSE;
           errorMsg = e.getMessage();
        }
        system.debug('!!!' + errorMsg);
        wrapObj.sObjList = sObjList;
        wrapObj.success = success ;
        wrapObj.errMsg = errorMsg;
        return wrapObj;
    }


    @AuraEnabled
    global static List<DMLOutputWrapper> InsertSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        Map<Id, SObject> sObjMap = new Map<Id, SObject>();
        List<String> errorCodeList = new List<String>();
        system.debug('XXXXX'+inputSObjectList);
        System.debug(LoggingLevel.Info, 'this is sobjectlist');
      /*  for(Integer i=0;i<inputSObjectList.size();i++){

            System.debug(  String.valueOf( inputSObjectList[i].get('FirstName') ));

        } */

        Boolean success = TRUE;
        Set <Id> idSet = new Set<Id>();
        Id sObjID = null ;
        Database.SaveResult[] srList = Database.insert(inputSObjectList, false);
        for(Database.SaveResult sr : srList){
        DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
        success = TRUE;
            if(sr.isSuccess()){
                sObjID = sr.getId();
                idSet.add(sObjID );

            }
            else{
                 success = FALSE;
                 for(Database.Error err : sr.getErrors()){
                    errorCodeList.add(err.getMessage());
                 }
            }
         wrapDMLObj.sObjID = sObjID;
         wrapDMLObj.success = success;
         wrapDMLObj.errorCodeList =errorCodeList;
         wrapDMLObjList.add(wrapDMLObj);
        }
      /*  if(query != null ){
            if(idSet != null && idSet.size() >0){
                query = query + ' where id in (' ;
                for(Id i : idSet ){
                    query = query + '\'' + i + '\',' ;
                }
                query = query.removeEnd(',');
                query = query + ')';
            }
           sObjMap = new Map<Id,sObject> (Database.query(query));
           for (DMLOutputWrapper wrap : wrapDMLObjList){
               wrap.record = sObjMap.get(wrap.sObjID );
           }
        }*/
        return wrapDMLObjList;
    }

    @AuraEnabled
    global static List<DMLOutputWrapper> UpdateSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        Map<Id, SObject> sObjMap = new Map<Id, SObject>();
        List<String> errorCodeList = new List<String>();
        Set <Id> idSet = new Set<Id>();
        Boolean success = TRUE;
        Id sObjID = null  ;

        Database.SaveResult[] srList = Database.update(inputSObjectList, false);

        for(Database.SaveResult sr : srList){
        DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
        success = TRUE;
            if(sr.isSuccess()){
                sObjID = sr.getId();
                idSet.add(sObjID );
            }
            else{
            success = FALSE;
                 for(Database.Error err : sr.getErrors()){
                    errorCodeList.add(err.getMessage());
                 }
            }
         wrapDMLObj.sObjID = sObjID;
         wrapDMLObj.success = success;
         wrapDMLObj.errorCodeList =errorCodeList;
         wrapDMLObjList.add(wrapDMLObj);
        }
      /*  if(query != null ){
            if(idSet != null && idSet.size() >0){
                query = query + ' where id in (' ;
                for(Id i : idSet ){
                    query = query + '\'' + i + '\',' ;
                }
                query = query.removeEnd(',');
                query = query + ')';
            }
           sObjMap = new Map<Id,sObject> (Database.query(query));
           for (DMLOutputWrapper wrap : wrapDMLObjList){
               wrap.record = sObjMap.get(wrap.sObjID );
           }
        }*/
        return wrapDMLObjList;
    }
    
      @AuraEnabled
    global static List<DMLOutputWrapper> ForceUpdateSObjects( List<SObject> inputSObjectList){
            system.debug('@@@callin server');
            List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
            Map<Id, SObject> sObjMap = new Map<Id, SObject>();
            Set <Id> idSet = new Set<Id>();
            List <Sobject> lockedSobjects = new List <Sobject>();
            Boolean success = TRUE;
            Id sObjID = null  ;
          
        
            for(sObject sobj : inputSObjectList){
                system.debug('###lock status'+sobj.Id);
                
                //Retrieving the instance of the Record in the Approval  which is locked
                ProcessInstanceWorkitem   pwNeedMoreInfo = null;
                pwNeedMoreInfo  = [ SELECT Id   FROM ProcessInstanceWorkitem   WHERE ProcessInstance.TargetObjectId = :sobj.Id AND ProcessInstance.Status = 'Pending'  LIMIT 1 ];
                Approval.ProcessWorkitemRequest reqNeedMoreInfo = new Approval.ProcessWorkitemRequest();
                reqNeedMoreInfo.setWorkitemId(pwNeedMoreInfo.id);
                reqNeedMoreInfo.setAction('Approve');
                
                Approval.ProcessResult result2 =  Approval.process(reqNeedMoreInfo);
                system.debug('The approval status before this is ' + Approval.isLocked(sobj.Id) );
                
                    // Unlocking record 
                    Approval.UnlockResult lrList  = Approval.unlock(sobj.id,false);
                
                system.debug('The approval status after this is ' + Approval.isLocked(sobj.Id) );
                lockedSobjects.add(sobj);
                
            /*     if(Approval.isLocked(sobj.Id) == True){
                    system.debug('The approval status after this is ' + Approval.isLocked(sobj.Id) );
                    system.debug('@@@Inside if');
                    Id Tempid = sobj.Id;
                    system.debug('@@@Inside if1'+sobj.Id);
                    if(sobj.Id != Null)
                    //Approval.unlock(sobj.Id);
                    Approval.unlock(sobj.id,false);
                    system.debug('The approval status after this is ' + Approval.isLocked(sobj.Id) );
                    lockedSobjects.add(sobj);
                }*/
            }
            Database.SaveResult[] srList = Database.update(inputSObjectList, false);

            if( (lockedSobjects.size() > 0) && (lockedSobjects != Null)){
                for(sobject sobj : lockedSobjects){
                // locking record 
                Approval.lockResult lrList1  = Approval.lock(sobj.id,true);
                //  Approval.lock(sobj.Id);
                }
            }

            for(Database.SaveResult sr : srList){
                    DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
                    List<String> errorCodeList = new List<String>();
                    success = TRUE;
                    if(sr.isSuccess()){
                            sObjID = sr.getId();
                            idSet.add(sObjID );
                    }
                    else{
                            success = FALSE;
                            sObjID = null;
                            for(Database.Error err : sr.getErrors()){
                                    errorCodeList.add(err.getMessage());
                            }
                    }
                    wrapDMLObj.sObjID = sObjID;
                    wrapDMLObj.success = success;
                    wrapDMLObj.errorCodeList =errorCodeList;
                    wrapDMLObjList.add(wrapDMLObj);
            }
            return wrapDMLObjList;
    }
    
    

    @AuraEnabled
    global static List<DMLUpsertWrapper> UpsertSObjects (List<SObject> inputSObjectList){
        List<DMLUpsertWrapper> wrapDMLObjList = new List<DMLUpsertWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = FALSE;
        Boolean isCreated = FALSE ;
        Boolean isUpdated = FALSE ;
        Id recordInsertId = null;
        Id recordUpdateId = null;
        Database.upsertResult[] upsertResultList  = Database.upsert(inputSObjectList);
        for(Database.upsertResult result : upsertResultList  ){
             DMLUpsertWrapper wrapDMLObj = new DMLUpsertWrapper();
             if(result.isSuccess() && result.isCreated()){
                 success = TRUE;
                 isCreated = TRUE ;
                 recordInsertId = result.getId();
                 wrapDMLObj.sObjID = recordInsertId;

             }
             else if(result.isSuccess() && !result.isCreated()){
                 success = TRUE;
                 isUpdated = TRUE;
                 recordUpdateId = result.getId();
                 wrapDMLObj.sObjID = recordUpdateId ;

           }
           else{
                success = FALSE;
                for(Database.Error err : result.getErrors()){
                    errorCodeList.add(err.getMessage());
                 }
           }
           wrapDMLObj.isCreated = isCreated ;
           wrapDMLObj.isUpdated = isUpdated ;
           wrapDMLObj.isSuccess = success;
           wrapDMLObj.errorCodeList =errorCodeList;
           wrapDMLObjList.add(wrapDMLObj);
        }
        return wrapDMLObjList;
    }


    @AuraEnabled
    global static List<DMLOutputWrapper> DeleteSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        Database.DeleteResult[] srList = Database.delete(inputSObjectList,false);
      //  system.debug('By aman');
      //  system.debug(srList);
        for(Database.DeleteResult sr : srList){
        errorCodeList = new List<String>();
        DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
        success = TRUE;
            if(sr.isSuccess()){
                sObjID = sr.getId();
            }
            else{
            success = FALSE;
                 for(Database.Error err : sr.getErrors()){
                    errorCodeList.add(err.getMessage());
                 }
            }
         wrapDMLObj.sObjID = sObjID;
         wrapDMLObj.success = success;
         wrapDMLObj.errorCodeList =errorCodeList;
         wrapDMLObjList.add(wrapDMLObj);
        }
        return wrapDMLObjList;
    }

    @AuraEnabled
    global static User ReadUserInfo(){
        return [SELECT Id, Name, ProfileId, Profile.Name,street,city,state,country,PostalCode FROM User where Id = :UserInfo.getUserId() ];
    }


global class OutputWrapper{
     @AuraEnabled
     global List<SObject> sObjList;
     @AuraEnabled
     global Boolean success;
     @AuraEnabled
     global String errMsg;
 }

 global class DMLOutputWrapper{

     @AuraEnabled
     global Id sObjID;
     @AuraEnabled
     global Boolean success;
     @AuraEnabled
     global List<String> errorCodeList ;
     @AuraEnabled
     global sObject record ;
 }

 global class DMLUpsertWrapper{

     @AuraEnabled
     global Id sObjID;
     @AuraEnabled
     global Boolean isSuccess;
     @AuraEnabled
     global Boolean isCreated;
     @AuraEnabled
     global Boolean isUpdated;
     @AuraEnabled
     global List<String> errorCodeList ;
 }

    @AuraEnabled
    global static String getFieldsInfo( String sObjectType ) {
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,String> fieldSummaryMap = new Map<String,String>();
        fieldSummary fieldSummaryWrapper = new fieldSummary();

        //declare a string to hold the name of an arbitrary sObject
        //sObjectType = 'Account';

        //get the Schema.DescribeSObjectResult of the ObjName arbitrary sObject
        Schema.DescribeSObjectResult arbDSR = schemaMap.get(sObjectType).getDescribe();

        //generate a Map of all Field names (keys) to field tokens (values)

        Map<String, Schema.SobjectField> fieldMap = arbDSR.fields.getMap();

        //get the Schema.DescribeFieldResult o f the fieldName arbitrary field
        for(String fApiName : fieldMap.keySet())
        {
           //fieldSummaryWrapper = new fieldSummary(fieldMap.get(fApiName).getDescribe(), fieldMap.get(fApiName).isAccessible(), fieldMap.get(fApiName).isUpdateable() );
           String label =fieldMap.get(fApiName).getDescribe().getLabel();
          //  System.Debug(fApiName + ' is accessible : ' + fieldSummaryWrapper.isAccessible);
          //  System.Debug(fApiName + ' is updatable : ' + fieldSummaryWrapper.isUpdateable);
            fieldSummaryMap.put(fApiName, label);

        }
        system.debug(JSON.serializePretty(fieldSummaryMap));
        return JSON.serializePretty(fieldSummaryMap);
    }

   global class fieldSummary {

    @AuraEnabled
    global Schema.DescribeFieldResult fieldDescribe{ get;set; }

  }

}