/**********************************************************************
 Name:  UploadDocumentController()
 Copyright © 2014  Tavant Technologies Inc.
 ==============================================================
===============================================================
Purpose: 
Controller class used to insert the bulk campaign members                                                   
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Neethu         04/11/2014      INITIAL DEVELOPMENT
   2.0 -    Bhanu          17/11/2014      Seperated inner class ServiceCampaignWrapper used in UploadBatch
***********************************************************************/
global with sharing class UploadCampMemberController{
	global static string NameSpace = SystemUtils.getNameSpace();
    global Document document{get;set;}
    global List<Campaign_Members__c> campMemberList {get;set;}
    global Service_Campaign__c sCampaign{get;set;} 
    global string nameFile{get;set;}
    global Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    global List<Schema.FieldSetMember> fieldSetList {get;set;}
    global Id sId {get;set;}
    
    //Constructor
    global UploadCampMemberController(ApexPages.StandardController stdController){
        system.debug('Entering Constructor: UploadDocumentController');
        this.sCampaign = (Service_Campaign__c)stdController.getRecord();
        sId = stdController.getId();
        system.debug('#ID->'+this.sCampaign);
        document = new Document();
        campMemberList = new List<Campaign_Members__c>();
        fieldSetList = new List<Schema.FieldSetMember>();
        getFieldSet();
        getServiceCampDetails();
        system.debug('Exiting Constructor: UploadDocumentController');
        
    }
    
    /*******************************************************************
    Purpose: Upload the set of campaign members from the csv file; 
             calls the batch job and send the file as string                                                 
    Parameters: N/A
    Returns: null
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/  
    global pageReference uploadFile(){
        system.debug(nameFile+'Entering uploadFile'+contentFile);
        try{
            if(nameFile == null || nameFile.trim()==''){
                 PageUtils.addError('Please choose a file to upload');
                 return null;
            }else{
                String fileName = nameFile;
                fileName = fileName.subString(fileName.indexOf('.')+1,fileName.length());
                if(fileName != 'csv' && fileName != 'xls') {

                    PageUtils.addError('Supported file type should be either csv or xls type');
                    return null;

                }else{
                    Transient String csvFileLines = contentFile.toString(); 
                    system.debug('Blob to string : '+csvFileLines);
                    nameFile=contentFile.toString();
                    //batch class
                    UploadBatch uploadBatch = new UploadBatch();
                    if(!test.isRunningTest()){
                        uploadBatch.headerValue = nameFile.split('\n')[0];
                    }else{
                        uploadBatch.headerValue =NameSpace+'Serial_Number__c,'+NameSpace+'Serial_Number__c,'+NameSpace+'Serial_Number__c,'+NameSpace+'Serial_Number__c';
                    }
                    system.debug('#headerValue'+uploadBatch.headerValue);
                    uploadBatch.mCSVFile = nameFile;
                    uploadBatch.sId = sId;
                    ExecuteBatch__c eBatch = ExecuteBatch__c.getValues('UploadBatch');  
                    if(eBatch !=null){                
                        Database.executeBatch(uploadBatch,Integer.valueof(eBatch.Record_Limit__c));
                    }else{
                        Database.executeBatch(uploadBatch,9000);
                    }
                    PageUtils.addError('Campaign Members uploaded successfully');
                    system.debug('Exiting uploadFile');  
                    return new pageReference('/'+sId);
                }
            } 
                    
        }catch (DMLException e) {
            PageUtils.addError('Error while uploading Campaign Members');
            return null;
        }finally {
            contentFile = null; 
        }
        
    }
    
      
    /*******************************************************************
    Purpose: Get the current service campaign record details                                                
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void getServiceCampDetails(){
        system.debug('Entering getServiceCampDetails'+sCampaign);
        
        String query = '';
        
        set<string> FieldSet = new set<string>();
        
        for(Schema.FieldSetMember scFieldSet : fieldSetList) {
            query += scFieldSet.getFieldPath() + ', ';
            FieldSet.add(scFieldSet.getFieldPath());
        }
        
        if(!query.contains(NameSpace+'Status__c')){
            FieldSet.add(NameSpace+'Status__c');
        }
        if(!query.contains('Name')){
            FieldSet.add('Name');
        }
        if(!query.contains(NameSpace+'Upload_Template__c')){
            FieldSet.add(NameSpace+'Upload_Template__c');
        }
        
        //query += 'Id FROM Service_Campaign__c where id =: sId';*/
        
        String SCsoql = new SoqlBuilder()
            .selectx(FieldSet)
            .fromx(NameSpace+'Service_Campaign__c')
            .wherex(new FieldCondition('Id').equals(sId))
            .toSoql();
        
        system.debug('SCsoql is ----'+SCsoql);
        
        sCampaign = Database.query(SCsoql);
        if(sCampaign.Status__c =='Active'){
            PageUtils.addError('Please deactivate the Service Campaign before adding members');
        }
        system.debug('Exiting getServiceCampDetails'+sCampaign);
        
    }
    
    /*******************************************************************
    Purpose: Get all the fields from the field set of the 
             service Campaign object                                                   
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void getFieldSet(){
        system.debug('Entering getFieldSet');
        fieldSetList = SObjectType.Service_Campaign__c.FieldSets.Upload_Members.getFields();
        system.debug('Exiting getFieldSet'+fieldSetList);
        
    }
}