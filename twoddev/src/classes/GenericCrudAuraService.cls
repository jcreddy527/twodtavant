global with sharing class GenericCrudAuraService {
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
        
        
        System.debug(LoggingLevel.Info, 'this is sobjectlist');
        
        Boolean success = TRUE;
        Set <Id> idSet = new Set<Id>();
        Id sObjID = null ;
        Database.SaveResult[] srList = Database.insert(inputSObjectList, false);
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
    global static List<DMLOutputWrapper> UpdateSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        Map<Id, SObject> sObjMap = new Map<Id, SObject>();
        Set <Id> idSet = new Set<Id>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        
        Database.SaveResult[] srList = Database.update(inputSObjectList, false);
        
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
            List<ProcessInstanceWorkitem> pwNeedMoreInfoList  = [ SELECT Id   FROM ProcessInstanceWorkitem   WHERE ProcessInstance.TargetObjectId = :sobj.Id AND ProcessInstance.Status = 'Pending'  LIMIT 1 ];
            
            if(pwNeedMoreInfoList.size()!=0){
                Approval.ProcessWorkitemRequest reqNeedMoreInfo = new Approval.ProcessWorkitemRequest();
                reqNeedMoreInfo.setWorkitemId(pwNeedMoreInfoList[0].id);
                reqNeedMoreInfo.setAction('Approve');
                Approval.ProcessResult result2 =  Approval.process(reqNeedMoreInfo);
                system.debug('The approval status before this is ' + Approval.isLocked(sobj.Id) );
                // Unlocking record 
                Approval.UnlockResult lrList  = Approval.unlock(sobj.id,false);
                system.debug('The approval status after this is ' + Approval.isLocked(sobj.Id) );
                lockedSobjects.add(sobj);
            }else{
                 // Unlocking record 
                Approval.UnlockResult lrList  = Approval.unlock(sobj.id,false);
                system.debug('The approval status after this is ' + Approval.isLocked(sobj.Id) );
                lockedSobjects.add(sobj);
            }
            

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
    global static List<DMLOutputWrapper> DeleteSObjects( List<SObject> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        Database.DeleteResult[] srList = Database.delete(inputSObjectList,false);
        
        for(Database.DeleteResult sr : srList){
            errorCodeList = new List<String>();
            DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
            success = TRUE;
            System.debug('This is delete debug');
            System.debug(sr);
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
}