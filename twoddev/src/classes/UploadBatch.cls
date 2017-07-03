/**********************************************************************
 Name:  UploadBatch
 Copyright � 2014  Tavant Technologies Inc.
 ==============================================================
===============================================================
Purpose: 
Batch lass to process the upload of campaign members                                                 
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Neethu         10/11/2014      INITIAL DEVELOPMENT
   2.0 -    Bhanu          17/11/2014      Accessing ServiceCampaignWrapper direct
***********************************************************************/
global with sharing class UploadBatch implements Database.batchable<string>, Database.Stateful{
    
    global String mCSVFile;
    global String headerValue;
    global String sId;
    global List<String> errorTraceList = new List<String>();
    
    /*******************************************************************
    Purpose: Start method which calls the iterator class                                             
    Parameters: N/A
    Returns: String value
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global Iterable<string> start(Database.batchableContext batchableContext){ 
        return new CSVIterator(mCSVFile, Parser.crlf);
    }
    
    /*******************************************************************
    Purpose: Execute method to insert each rows as separte record of
             campaign members                                              
    Parameters: N/A
    Returns: Void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void execute(Database.BatchableContext batchableContext, List<string> scope) {
        try{
            String csvFile = '';
            String[] apiName  = new String[]{};
            SObjectType campMemberType;
            List<ServiceCampaignWrapper> apiNameValueMap;
            set<String> apiNameSet = new set<String>();
            list<SObject> sObjectList = new list<SObject>();
            List<List<ServiceCampaignWrapper>> apiNameValueMapList = new List<List<ServiceCampaignWrapper>>(); 
            for(String row : scope) {
                if(headerValue.trim()!= row.trim()){
                    csvFile += row + Parser.crlf;
                }
            }
            apiName = headerValue.split(',');
            List<list<string>> csvLines = CSVReader.readCSVFile(csvFile);
            for(List<String> eachLine : csvLines) {
                apiNameValueMap = new List<ServiceCampaignWrapper>();
                system.debug('##-->Row'+eachLine);
                for (Integer j=0;j<eachLine.size();j++){
                    ServiceCampaignWrapper scWrapper = new ServiceCampaignWrapper();
                    scWrapper.apiName = apiName[j];
                    scWrapper.value = eachLine[j];
                    apiNameValueMap.add(scWrapper);
                }
                apiNameValueMapList.add(apiNameValueMap); 
            }
            system.debug(apiNameValueMapList+'#->API name and value list');
            
            
            //describe the fields
            for(Schema.SObjectField fieldList:Campaign_Members__c.sObjectType.getDescribe().fields.getMap().values()){
                apiNameSet.add(string.valueof(fieldList.getdescribe().getname()));
            }
            
            string crntObjectName = DatabaseUtils.retrieveObjectName(sId);
            
            String objPrefix = SObjectType.Campaign_Members__c.Name.substringBefore(SystemUtils.getNameSpace()+'Campaign_Members__c');
            system.debug(objPrefix);
            
            
            //Createdthe record list
            campMemberType = Schema.getGlobalDescribe().get(objPrefix+SystemUtils.getNameSpace()+'Campaign_Members__c');
            for(List<ServiceCampaignWrapper> sCampaignList: apiNameValueMapList){
                SObject campMemberRecord = campMemberType.newSObject();
                campMemberRecord.put(objPrefix+SystemUtils.getNameSpace()+'Service_Campaign__c',sId);
                for(ServiceCampaignWrapper sCampaign: sCampaignList){
                    if(apiNameSet.contains(sCampaign.apiName.trim())){                  
                        campMemberRecord.put(sCampaign.apiName.trim(),sCampaign.value); 
                    }
                
                }
                sObjectList.add(campMemberRecord);
                system.debug('Exiting uploadFile'+sObjectList );
            }
            //insert the record list
            if(CrudUtil.isCampaignMemberCreatable()){
                Database.SaveResult[] uploadList = database.insert(sObjectList,false);
                    
                for(Database.SaveResult sr : uploadList){
                    if (sr.isSuccess()){
                        System.debug('Successfully inserted: ' + sr.getId());
                    }else{
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred while uploading campaign members.'+err);    
                            errorTraceList.add(string.valueof(err.getMessage()));             
                        }
                    }
                }
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
            }
            
        }catch(Exception e){
            errorTraceList.add(e.getMessage());//+'::'+e.getStackTraceString()+'\n');
        }
    }
    
    /*******************************************************************
    Purpose: Finish mehtod to update record flagging as uploaded                                            
    Parameters: N/A
    Returns: String value
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void finish(Database.BatchableContext batchableContext){
        try{
        system.debug('Service Campaign Id'+sId);
        WOD__c wod = WOD__c.getValues('Batch Upload Member');
        If(wod!=null && wod.isTriggered__c!=null && wod.isTriggered__c){
            AsyncApexJob bJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                                    FROM AsyncApexJob WHERE Id =:batchableContext.getJobId()];
                                    system.debug('Job Details#'+bJob);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {bJob.CreatedBy.Email};
            if(wod.Trigger_Value__c!=null && wod.Trigger_Value__c.trim()!=''){
                toAddresses.add(wod.Trigger_Value__c);
            }
            mail.setToAddresses(toAddresses);
            mail.setSubject('Upload Campaign Member Batchjob Status');
            String message ;
            if(!errorTraceList.isEmpty()){
                message = '<html><table cellspacing = "50"><tr><td style="font-weight:bold;color:BLACK;">Error Messages</td></tr>';
                for(String str:errorTraceList){
                    message+= '<tr><td >'+str+'</td></tr>';
                }
                message+=   '</table></html>';
            }else{
                message = 'The batch Apex job processed ' + bJob.TotalJobItems +' batches';
            }
            mail.setHtmlBody(message);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
     }catch(Exception e){
         system.debug('# Error Upload Batch Class Final Method : '+e);
     }               
    }
    global with sharing class LogWrapper{
        global String errorText;
    }
}