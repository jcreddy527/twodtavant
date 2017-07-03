global with sharing class TestCRUDController {

    @AuraEnabled
    global Static List<sObject> queryData(String query){
        return Database.query(query);
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
    // To get the record count in the report
        @AuraEnabled
        global static Integer totalRecordsCount(String reportId){
            // Run a report synchronously
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            Map<String,Reports.ReportFact> mapReportFacets = results.getFactMap();
            System.debug(':::: dim value:'+mapReportFacets);
            Reports.ReportFact listReportDetails = mapReportFacets.get('T!T');
            system.debug(':::: list data:'+listReportDetails);
            LIST<Reports.SummaryValue> listSummaryValue = listReportDetails.getAggregates();
            system.debug('::: list summary value:'+listSummaryValue);
            system.debug(':: label value:'+listSummaryValue[0].getLabel());

            return Integer.valueOf(listSummaryValue[0].getValue());
        }

    @AuraEnabled
    global static List<DMLOutputWrapper> InsertSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        Map<Id, SObject> sObjMap = new Map<Id, SObject>();
        List<String> errorCodeList = new List<String>();

        System.debug(LoggingLevel.Info, 'this is sobjectlist');
        for(Integer i=0;i<inputSObjectList.size();i++){

           // System.debug(  String.valueOf( inputSObjectList[i].get('FirstName') ));

        }

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
        system.debug('By aman');
        system.debug(srList);
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