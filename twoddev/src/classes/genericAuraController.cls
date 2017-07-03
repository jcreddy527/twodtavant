global with sharing class genericAuraController {
    global static string NameSpace = SystemUtils.getNameSpace();
    @AuraEnabled
    global static String getclaimPrefix(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
           Schema.DescribeSObjectResult r =  gd.get(NameSpace+'claim__c').getDescribe();
           String tempName = r.getName();
           String tempPrefix = r.getKeyPrefix();
           System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
        return tempPrefix;
    }
    
    @AuraEnabled
    global static string updatePolicyDefinition(Claim__c tmpClm) {
            // Call the Flow
            system.debug('came here');
           list<Policy_Definition__c> PolicyDefList = new list<Policy_Definition__c>();
            ClaimManager objClmManager = new ClaimManager();
            PolicyDefList = objClmManager.findPolicyDefinitionList(tmpClm);
            system.debug('PolicyDefList is----->>>'+PolicyDefList);
            return PolicyDefList[0].Pricebook_Type__c;
            //Map<String, Object> params = new Map<String, Object>();
            //params.put('VarClaimId', claimId);
            //Flow.Interview.Updating_Policy_Definition_in_Claim calcFlow = new Flow.Interview.Updating_Policy_Definition_in_Claim(params);
            //calcFlow.start();
        }
    
    
   @AuraEnabled
   global static String getFieldMetaData(String objectName, String fieldName){
       Map<String,Schema.SObjectType> schemaMap     = Schema.getGlobalDescribe();
       Map<String,String> fieldSummaryMap           = new Map<String,String>();
       Schema.DescribeSObjectResult arbDSR          = schemaMap.get(objectName).getDescribe();
       Map<String, Schema.SobjectField> fieldMap    = arbDSR.fields.getMap();
       
        system.debug('::::: Field Map:');
        system.debug(fieldMap);
        //get the Schema.DescribeFieldResult o f the fieldName arbitrary field
        //for(String fApiName : fieldMap.keySet()){
            //fieldSummaryWrapper = new fieldSummary(fieldMap.get(fApiName).getDescribe(), fieldMap.get(fApiName).isAccessible(), fieldMap.get(fApiName).isUpdateable() );
            String label =fieldMap.get(fieldName).getDescribe().getLabel();
            //  System.Debug(fApiName + ' is accessible : ' + fieldSummaryWrapper.isAccessible);
            //  System.Debug(fApiName + ' is updatable : ' + fieldSummaryWrapper.isUpdateable);
            fieldSummaryMap.put(fieldName, label);
            fieldSummaryMap.put('DefaultValue',String.valueOf(fieldMap.get(fieldName).getDescribe().getDefaultValue()));
            fieldSummaryMap.put('Type',String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
        //}
        system.debug('::::: JSON string:');
        system.debug(JSON.serializePretty(fieldSummaryMap));
        return JSON.serializePretty(fieldSummaryMap);
   }
   
   
    global class fieldSummary {
        @AuraEnabled
        global Schema.DescribeFieldResult fieldDescribe{ get;set; }
    
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

    @AuraEnabled
    global static List<sObject> findSObjectsBySOQL(String query) {
        system.debug('----------query--------'+query);
        return  Database.query(query);
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
    global static List<String> claimInstalledPartsInventoryIds(String claimId) {
        system.debug('----------claimId--------'+claimId);
        List<Claim_Part__c> listObj     =   new List<Claim_Part__c>();
        List<String> listString         =   new List<String>();
        listObj     =   [SELECT Id, Name, Inventory__c FROM Claim_Part__c WHERE Claim__c =:claimId ];
        for(Claim_Part__c objPart : listObj){
            if(objPart.Inventory__c != null) {
                listString.add(objPart.Inventory__c);
            }
        }
        return  listString;
    }

    @AuraEnabled
    global static List<sObject> findSObjectsBySOQLByAvoiding(String claimId, String query, List<String> idsToAvoid, String inventoryId, String searchKey, String conditionS) {

        List<String> idsToAvoidVal  =   new List<String>();
        List<Claim_Part__c> listPart = new List<Claim_Part__c>();
        listPart    =   [SELECT Id, Inventory__c FROM Claim_Part__c WHERE Claim__c =: claimId AND Inventory__c != null];
        List<Removed_Claim_Part__c> listRemovedPart = new List<Removed_Claim_Part__c>();
        listRemovedPart =   [SELECT Id, Inventory__c FROM Removed_Claim_Part__c WHERE Claim__c =: claimId  AND Inventory__c != null];

        for(Claim_Part__c objPart : listPart){
            idsToAvoidVal.add(objPart.Inventory__c);
        }

        for(Removed_Claim_Part__c objPart : listRemovedPart){
            idsToAvoidVal.add(objPart.Inventory__c);
        }

        system.debug(':::::::::: Ids to avoid val:'+idsToAvoidVal);
        system.debug('----------findSObjectsBySOQLByAvoiding:'+query);
        //system.debug('----------idsToAvoid:'+idsToAvoid);
        system.debug(':::::::::: Prevous inventory id:'+inventoryId);
        //idsToAvoid.add('a0915000013hKqM');
        String itemId = '';
        List<String> listInventoryId    =   new List<String>();
        listInventoryId.add(inventoryId);
        if(inventoryId != null && inventoryId != '') {
            itemId  =   [SELECT Id, Name, Item__c FROM Inventory__c  WHERE Id =: inventoryId].Item__c;
            System.debug('::::::::: Generated item id:'+itemId);
        }
        List<Inventory__c> listInventories  =   new List<Inventory__c>();
        String warrantableValue =   'Warrantable';
        List<Inventory__c> listInventoriesToAdd = new List<Inventory__c>();

        //listInventoriesToAdd    =   [SELECT Id, Name FROM Inventory__c WHERE Item__c =:itemId AND Asset_Type__c =: warrantableValue AND Id NOT IN :idsToAvoidVal AND Id NOT IN :idsToAvoid AND Id NOT IN :listInventoryId AND Name LIKE '%'+searchKey+'%'];

        String queryVal = 'SELECT Id, Name FROM '+NameSpace+'Inventory__c WHERE '+NameSpace+'Item__c =: itemId  AND '+NameSpace+'Asset_Type__c =: warrantableValue AND Id NOT IN :idsToAvoidVal AND Id NOT IN :idsToAvoid AND Id NOT IN:listInventoryId AND  Name LIKE \'%'  + searchKey + '%\'';
        //listInventories     =   [SELECT Id, Name FROM Inventory__c WHERE Item__c =:itemId AND Asset_Type__c = 'Warrantable' AND Id NOT IN :idsToAvoid AND  Name LIKE  '%\'' + searchKeyword + '%\''];
        system.debug(':::::: query:'+queryVal);
        system.debug(':::: Results:'+Database.query(queryVal));
        return  Database.query(queryVal);
    }

    @AuraEnabled
    global static Claim__c upsertClaim(Claim__c claimRecord) {
        //Claim__c objClaim = [SELECT Id, Name, Claim_Auto_Number__c FROM Claim__c ORDER BY CreatedDate DESC LIMIT 1 ];
        //system.debug(':::: obj claim:'+objClaim);
        //claimRecord.Name = Label.Claim_Name_Prefix+ '-' + (Integer.valueOf(objClaim.Claim_Auto_Number__c)+1);
        upsert claimRecord;
        return claimRecord;
    }

    @AuraEnabled
    global static void updateClaim(Claim__c claimRecord) {
        system.debug('The claim recrod is : ');
        system.Debug(claimRecord);
        //Claim__c objClaim = [SELECT Id, Name, Claim_Auto_Number__c FROM Claim__c ORDER BY CreatedDate DESC LIMIT 1 ];
        //system.debug(':::: obj claim:'+objClaim);
        //claimRecord.Name = Label.Claim_Name_Prefix+ '-' + (Integer.valueOf(objClaim.Claim_Auto_Number__c)+1);
      //  update claimRecord;
      //  return claimRecord;
    }


    @AuraEnabled
    global static sobject upsertClaimServiceInfo(Claim_Service_Information__c claimServiceInfo) {
        //Claim_Service_Information__c objClaim = [SELECT Id, Name, Claim_Service_Auto_Number__c FROM Claim_Service_Information__c ORDER BY CreatedDate DESC LIMIT 1 ];
        //system.debug(':::: obj claim:'+objClaim);
        //claimServiceInfo.Name = Label.Claim_Service_Info_Prefix+ '-' + (Integer.valueOf(objClaim.Claim_Service_Auto_Number__c)+1);
        upsert claimServiceInfo;
        return claimServiceInfo;
    }


    @AuraEnabled
    global static List<List <sObject>> findSObjectsBySOSL(String query) {
        return  search.query(query);
    }

    // Need to modify this to update the warrany product price book
    @AuraEnabled
    global static Double receiveProductCost(String query, Boolean isInv){
        Double costValue = 0;
        List<sobject> listValues = Database.query(query);
        system.debug('::::: list values:'+listValues);
        system.debug('::::: isInv:'+isInv);
        String idValue = listValues[0].Id;
        List<Warranty_Product_Pricebook__c> listPriceBook = new List<Warranty_Product_Pricebook__c>();
        if(isInv){
            Inventory__c objInv             =  new Inventory__c();
            objInv          =   [SELECT Id, Name, Item__c FROM Inventory__c WHERE id =: idValue];
            system.debug('::::: object inv:'+objInv);
            listPriceBook   =   [SELECT Id, Name, Price__c FROM Warranty_Product_Pricebook__c WHERE Warranty_Product__c =: objInv.Item__c];
            if(listPriceBook.size()== 1){
                return listPriceBook[0].Price__c;
            }else {
                return 0.00;
            }
        }else{
            listPriceBook   =   [SELECT Id, Name, Price__c FROM Warranty_Product_Pricebook__c WHERE Warranty_Product__c =: idValue];
            if(listPriceBook.size()==1){
                return listPriceBook[0].Price__c;
            }else {
                return 0.00;
            }
        }
    }
    
    
   @AuraEnabled
    global static List<Warranty_Product_Pricebook__c> receiveProductCostAndPriceBookId(String query, Boolean isInv){
        Double costValue = 0;
        List<String> listString = new List<String>();
        List<sobject> listValues = Database.query(query);
        system.debug('::::: list values:'+listValues);
        system.debug('::::: isInv:'+isInv);
        String idValue = listValues[0].Id;
        List<Warranty_Product_Pricebook__c> listPriceBook   =   new List<Warranty_Product_Pricebook__c>();
        Warranty_Product_Pricebook__c objPriceBook          =   new Warranty_Product_Pricebook__c();
        if(isInv){
            Inventory__c objInv             =  new Inventory__c();
            objInv          =   [SELECT Id, Name, Item__c FROM Inventory__c WHERE id =: idValue];
            system.debug('::::: object inv:'+objInv);
            listPriceBook   =   [SELECT Id, Name, Price__c FROM Warranty_Product_Pricebook__c WHERE Warranty_Product__c =: objInv.Item__c];
            system.debug(':::: list price book values:'+listPriceBook);
            if(listPriceBook.size()== 1){
                //listString.add(listPriceBook[0].Price__c);
                return listPriceBook;
            }else {
                return listPriceBook;
            }
        }else{
            listPriceBook   =   [SELECT Id, Name, Price__c FROM Warranty_Product_Pricebook__c WHERE Warranty_Product__c =: idValue];
            system.debug(':::: list price book values:'+listPriceBook);
            if(listPriceBook.size()==1){
                return listPriceBook;
            }else {
                return listPriceBook;
            }
        }
    }
    


   /*

    @AuraEnabled
    global static void insertCampMembers(List<twod__Inventory__c> listInventories, String serviceCampaignId){
        system.debug('::::: list inventories:'+listInventories);
        List<twod__Campaign_Members__c> listCampaignMembers =   new List<twod__Campaign_Members__c>();
        for(twod__Inventory__c objInv : listInventories){
            twod__Campaign_Members__c objmember =   new twod__Campaign_Members__c();
            objMember.twod__Inventory__c        =   objInv.Id;
            objMember.twod__Service_Campaign__c =   Id.valueOf(serviceCampaignId);
            objMember.twod__Serial_Number__c    =   '123456';
            listCampaignMembers.add(objMember);
        }
        try{
            if(listCampaignMembers.size()>0){
                insert listCampaignMembers;
            }
        }catch(Exception objException){

        }

    }
      */
   @AuraEnabled
    global static void modifyAnysObject( sObject recordToUpdate, String fieldToModify, String valueToPut ) {

        recordToUpdate.put(fieldToModify, valueToPut);
        update recordToUpdate;
    }

    /*
    @AuraEnabled
    global static List<twod__Campaign_Members__c> serviceCampaignMembers(String serviceCampaign){
        List<twod__Campaign_Members__c> listCampaignMembers    =    new List<twod__Campaign_Members__c>();
        system.debug(':::: service Campaign:'+serviceCampaign);
        listCampaignMembers = [SELECT Id, Name, twod__Inventory__r.Name, twod__Inventory__c,twod__Serial_Number__c,twod__Status__c,Camp_Member_Status__c,twod__Service_Campaign__c,twod__Service_Campaign__r.Name FROM twod__Campaign_Members__c WHERE twod__Service_Campaign__c =:serviceCampaign];
        system.debug('::: campaign Members:'+listCampaignMembers);
        return listCampaignMembers;
    }

    @AuraEnabled
    global static sobject serviceCampaignDetails(String serviceCampaign){
    sobject servicecamp = [Select Id,Name,twod__End_Date__c,twod__Start_Date__c,twod__Status__c From twod__Service_Campaign__c Where ID=:serviceCampaign];
    return servicecamp ;
    }

    @AuraEnabled
    global static List<twod__Campaign_Members__c> PaginatedCampaignMembers(String serviceCampaign, Integer offsetsize){
        List<twod__Campaign_Members__c> listCampaignMembers    =    new List<twod__Campaign_Members__c>();
        system.debug(':::: service Campaign:'+serviceCampaign);
        Integer offsets = Integer.valueOf(offsetsize);
        listCampaignMembers = [SELECT Id, Name, twod__Inventory__r.Name, twod__Inventory__c,twod__Serial_Number__c,twod__Status__c,Camp_Member_Status__c,twod__Service_Campaign__c,twod__Service_Campaign__r.Name FROM twod__Campaign_Members__c WHERE twod__Service_Campaign__c =:serviceCampaign Limit 5 OFFSET :offsets];
        system.debug('::: campaign Members:'+listCampaignMembers);
        return listCampaignMembers;
    }


    global static integer counter = 0;
    global static integer recNum = 0;
    global static integer limitsVal = 5;

    @AuraEnabled
    global static Integer showVINRecsCount(Integer startVIN, Integer endVIN){
        Integer countVal = [SELECT Count() FROM twod__Inventory__c WHERE serialSufix__c >= :startVIN AND serialSufix__c <= : endVIN  LIMIT 10000];
        return countVal;
    }

    @AuraEnabled
    global static List<twod__Inventory__c> showVINRecs(Integer startVIN, Integer endVIN, Integer counterVal){
        List<twod__Inventory__c> listOfVINS     =    new List<twod__Inventory__c>();
        Integer val =   Integer.valueOf(counterVal);
        listOfVINS    =    [SELECT Id, Name, twod__Serial_Number__c, Contact__c,Contact__r.Name,VIN_Number__c,SerialSufix__c,Batch__c,twod__Account__c,twod__Account__r.Name,Contact__r.Email,Contact__r.Phone FROM twod__Inventory__c WHERE serialSufix__c >= :startVIN AND serialSufix__c <= :endVIN LIMIT :5 OFFSET :val];
        return listOfVINS;
    }



   @AuraEnabled
    global static string addVINSToServiceCampaigns(String query, String serviceCampaignId , Integer offsetsize, Integer startVIN, Integer endVIN){
        String returnValue = 'FAILED';
        List<twod__Campaign_Members__c> listCampaignMembers =   new List<twod__Campaign_Members__c>();
        Integer count = 0;
        twod__Inventory__c  objinventory = [SELECT Id, Name, twod__Serial_Number__c, Contact__c,Contact__r.Name,VIN_Number__c,SerialSufix__c,Batch__c FROM twod__Inventory__c WHERE serialSufix__c >= :startVIN AND serialSufix__c <= : endVIN  LIMIT 1 OFFSET 0];

        twod__Campaign_Members__c objcampmember =   new twod__Campaign_Members__c();
            objcampmember .twod__Inventory__c        =   objinventory .Id;
            objcampmember .twod__Service_Campaign__c =   Id.valueOf(serviceCampaignId);
            objcampmember .twod__Serial_Number__c    =   serviceCampaignId + objinventory .twod__Serial_Number__c;
            objcampmember .twod__Unique_Identifier__c=   serviceCampaignId + objinventory .twod__Serial_Number__c;
            objcampmember.Camp_Member_Status__c     =   'Draft';
            listCampaignMembers.add(objcampmember);

        for(twod__Inventory__c objInv : Database.query(query)){
            twod__Campaign_Members__c objmember =   new twod__Campaign_Members__c();
            objMember.twod__Inventory__c        =   objInv.Id;
            objMember.twod__Service_Campaign__c =   Id.valueOf(serviceCampaignId);
            objMember.twod__Serial_Number__c    =   serviceCampaignId + objInv.twod__Serial_Number__c;
            objMember.twod__Unique_Identifier__c=   serviceCampaignId + objInv.twod__Serial_Number__c; //String.valueOf(DateTime.now()) + Datetime.now().second() + count;
            objMember.Camp_Member_Status__c     =   'Draft';
            count ++;
            listCampaignMembers.add(objMember);
        }
        try{
            if(listCampaignMembers.size()>0){
                system.debug('-----------'+listCampaignMembers);
                //Schema.SObjectField f = twod__Campaign_Members__c.Fields.twod__Serial_Number__c;
                //Database.UpsertResult [] cr = Database.upsert(listCampaignMembers, f, false);﻿
                upsert listCampaignMembers twod__Serial_Number__c;
                returnValue = 'SUCCESS,'+counter;
            }
        }catch(Exception objException){
            returnValue = 'FAILED';
        }
        return returnValue;
    }

    @AuraEnabled
    global static List<sObject> nextList(String queryVal){
        system.debug('::::: query val:'+queryVal);
        List<sObject> listInvs = Database.query(queryVal);
        return listInvs;
    }

    @AuraEnabled
    global static List<sObject> prevList(String queryVal){
        system.debug('::::: query val:'+queryVal);
        List<sObject> listInvs = Database.query(queryVal);
        return listInvs;
    } */

    /* Code started for the multiple childs insertion */
    @AuraEnabled
    global static List<String> childFieldsDetails(List<sObject> listChildFields){
        system.debug(':::: list Data:'+listChildFields);
        List<String> listChildsString = new List<String>();
        return listChildsString;
    }

    @AuraEnabled
    global static List<String> generatePicklistValues(string fieldName, String objectName){
        List<String> listPicklists  =   new List<String>();
        //sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ;
        //Schema.DescribeFieldResult fieldResult = sObj.fieldName.getDescribe();
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        system.debug(':::: schema map:'+schemaMap);
        Schema.DescribeSObjectResult arbDSR = schemaMap.get(objectName).getDescribe();

        //generate a Map of all Field names (keys) to field tokens (values)
        Map<String, Schema.SobjectField> fieldMap   =   arbDSR.fields.getMap();

        Schema.DescribeFieldResult fieldResult           =   fieldMap.get(fieldName).getDescribe();
        //if(fieldName == 'Status'){
        //Schema.DescribeFieldResult fieldResult =    OfficeLocation__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        system.debug('::::: pick list values:'+ple);
        for( Schema.PicklistEntry f : ple){
            //if(f.getValue().contains(searchKey)){
            listPicklists.add(f.getValue());
            //}
        }

        return listPicklists;
    }

    @AuraEnabled
    static global Attachment savePdf(String ortId, String scId){
        Attachment a = new Attachment();

       PageReference pagePdf =new PageReference('/apex/outreachTemplatePDF?id='+ortId);

        System.debug('----------------'+ortId);

        Blob pdfPageBlob;


        try {
            pdfPageBlob = pagePdf.getContentAsPDF();
        } catch (VisualforceException e) {
            pdfPageBlob = Blob.valueOf('Some Text');
        }

        a.Body = pdfPageBlob;
        a.ParentID = scId;//'00128000008vl0K'
        a.Name = 'outReachTemplate.pdf';
        a.ContentType = 'application/pdf';
        a.Description = 'OutReachTemplatePDF';


        system.debug('Page PDF is : ' + pagePdf);

      //  system.debug('Page PDF Blob content is : ' + a );


        insert a;

     return a;

    }

    @InvocableMethod
    static global List<String> savePdfFlow(List<InputWrapper> InputWrapperList){
    List<Attachment> aList = new List<Attachment>();
        Attachment a = new Attachment();
        List<String> idList = new List<String>();
       String ortId = InputWrapperList[0].ortId;
       String scId = InputWrapperList[0].scId;

       PageReference pagePdf =new PageReference('/apex/outreachTemplatePDF?id='+ortId);

        System.debug('----------------'+ortId);

        Blob pdfPageBlob;


        try {
            pdfPageBlob = pagePdf.getContentAsPDF();
        } catch (VisualforceException e) {
            pdfPageBlob = Blob.valueOf('Some Text');
        }

        a.Body = pdfPageBlob;
        a.ParentID = scId;//'00128000008vl0K'
        a.Name = 'outReachTemplate.pdf';
        a.ContentType = 'application/pdf';
        a.Description = 'OutReachTemplatePDF';


        system.debug('Page PDF is : ' + pagePdf);

      //  system.debug('Page PDF Blob content is : ' + a );


        insert a;
        idList.add(a.Id);
        return(idList);

    }




    global class InputWrapper{

        @InvocableVariable(required=true)
        global String ortId;

        @InvocableVariable(required=true)
        global String scId;

    }

   @AuraEnabled
   global static List<String> checkSystemAdmin(){
       List<String> listStrings =   new List<String>();
       listStrings.add([SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name);

       return listStrings;
   }
   @AuraEnabled
   global static Id findPolicyDef(){
      Id objpolicyId = [Select Id from Policy_Definition__c LIMIT 1].Id ;

       return objpolicyId;
   }
   @AuraEnabled
   global static sobject selectDealerAccount(){
      Id objAccountId = [Select AccountId from User Where Id=:UserInfo.getUserId()].AccountId;
      sobject objAccount = [Select Id,Name FROM Account Where Id=:objAccountId ];
       return objAccount ;
   }


    @AuraEnabled
    global Static String casualPartNumber(String name){
        String idValue  =   [SELECT Id, Name FROM Warranty_Product__c WHERE Name =:name].Id;
        System.debug(':::: idValue:'+idValue);
        return idValue;
    }

   @AuraEnabled
    global static List<sObject> generateGroups(String filterCondition){
        system.debug(':::: Entered in to controller');
        String searchValue ='\'%' + String.escapeSingleQuotes(filterCondition.trim()) + '%\'';
        Map<Id, String> mapGropInfo =   new Map<Id, String>();
        List<Group__c> listGroups    =   new List<Group__c>();
        String defaultQuery         =   'SELECT Id, Name FROM '+NameSpace+'Group__c';
        if(filterCondition == null || filterCondition == '') {
            listGroups       =   Database.query(defaultQuery);
        }else {
            listGroups       =   Database.query(defaultQuery + ' WHERE Name LIKE '+searchValue);
        }
        System.debug('::::: listGrops:'+listGroups);
        return listGroups;
    }

    /************************************************************************************************************************************/
    @AuraEnabled
    global static sObject createSObject(sObject insertObject) {

        system.debug(':::: Before insert:'+insertObject);
        //List<sObject> listInsertedRecords   =   new List<sObject>();
        upsert insertObject;
        //listInsertedRecords.addAll(insertObject);
        system.debug(':::: listInsertedRecords:'+insertObject);
        return insertObject;
    }

    @AuraEnabled
    global static string upsertSObject(sObject insertObject) {
        try{
            system.debug(':::: Before insert:'+insertObject);
            //List<sObject> listInsertedRecords   =   new List<sObject>();
            update insertObject;
            return 'SUCCESS';
        }catch(Exception e) {
            return e.getMessage();
        }
    }

   @AuraEnabled
    global static sObject retrieveSObject(sObject insertObject) {

        system.debug(':::: Before insert:'+insertObject);
        //List<sObject> listInsertedRecords   =   new List<sObject>();
        insert insertObject;
        //listInsertedRecords.addAll(insertObject);
        system.debug(':::: listInsertedRecords:'+insertObject);
        return insertObject;
    }
    @AuraEnabled
    global static Warranty_Product__c popClaimType(Id InventoryId) {
         Id WarrantyProductId = [Select Item__c from Inventory__c Where Id=:InventoryId].Item__c ;
          system.debug('------------WarrantyProductId-------'+WarrantyProductId);
         Warranty_Product__c objWp= [Select Item_Type__c,Product_Name__c,Units_of_Measure__c FROM Warranty_Product__c Where Id=:WarrantyProductId] ;
         system.debug('------------objWp-------'+objWp);
         return objWp;

    }

    @AuraEnabled
    global static String deleteSObject(List<sObject> deleteRecords) {
        try{
            system.debug(':::: delete records:'+deleteRecords);
            if(deleteRecords != null){
                Schema.SObjectType ObjectType = deleteRecords[0].getSobjectType();
                delete deleteRecords;
              
            }
            return 'SUCCESS';
        }catch(Exception e){
            return e.getMessage();
        }

    }


     /* temporary code for sobject list update, will remove later */
    @AuraEnabled
    global static List<DMLOutputWrapper> UpdateClaimSObjects( List<Claim__c> inputSObjectList){
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        system.debug('::: update record:'+inputSObjectList);
        Database.SaveResult[] srList = Database.update(inputSObjectList);
        System.debug(':::: srList:'+srList);
        for(Database.SaveResult sr : srList){
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
        system.debug(':::: wrap dml object list:'+wrapDMLObjList);
        return wrapDMLObjList;
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
        wrapObj.sObjList = sObjList;
        wrapObj.success = success ;
        wrapObj.errMsg = errorMsg;
        return wrapObj;
    }

    @AuraEnabled
    global static List<DMLOutputWrapper> InsertSObjectServiceInfo( List<Claim_Service_Information__c> inputSObjectList){

        //Claim_Service_Information__c objClaim = [SELECT Id, Name, Claim_Service_Auto_Number__c FROM Claim_Service_Information__c ORDER BY CreatedDate DESC LIMIT 1 ];
        //system.debug(':::: obj claim:'+objClaim);
        Integer increaseCount   =   0;
        system.debug('::::: sobject list:'+inputSObjectList);
        for(Claim_Service_Information__c objSObject : inputSObjectList){
            //objClaim.Claim_Service_Auto_Number__c   =   objClaim.Claim_Service_Auto_Number__c+1;
            system.debug('::: obj:'+objSObject);
            objSObject.Name                         =   Label.Claim_Service_Info_Prefix;//+ '-' + (Integer.valueOf(objClaim.Claim_Service_Auto_Number__c)+increaseCount);
            system.debug('::::: sObject name:'+objSObject.Name);
            increaseCount ++;
        }
        //claimServiceInfo.Name = Label.Claim_Service_Info_Prefix+ '-' + (Integer.valueOf(objClaim.Claim_Service_Auto_Number__c)+1);
        System.debug(':::: sObject list to insert:'+inputSObjectList);
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null ;
        Database.SaveResult[] srList = Database.insert(inputSObjectList);
        for(Database.SaveResult sr : srList){
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

    // For Removed parts updation (temporary code, will remove later)
    @AuraEnabled
    global static List<DMLOutputWrapper> updateRemovedPartSObjects( List<Removed_Claim_Part__c> inputSObjectList){
        system.debug(':::::::'+ inputSObjectList);


        //Removed_Claim_Part__c objClaim = [SELECT Id, Name, Inventory__c, Removed_Part_Auto_Number__c FROM Removed_Claim_Part__c ORDER BY CreatedDate DESC LIMIT 1 ];
        //system.debug(':::: obj claim:'+objClaim);
        Integer increaseCount   =   0;
        system.debug('::::: sobject list:'+inputSObjectList);
        for(Removed_Claim_Part__c objSObject : inputSObjectList){
            //objClaim.Claim_Service_Auto_Number__c   =   objClaim.Claim_Service_Auto_Number__c+1;
            system.debug('::: obj:'+objSObject);
            //if(objSObject)
            //objSObject.Name                         =   Label.Removed_Part_Name_Prefix+ '-' + (Integer.valueOf(objClaim.Removed_Part_Auto_Number__c)+increaseCount);
            //system.debug('::::: sObject name:'+objSObject.Name);
            increaseCount ++;
        }



        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        system.debug('::: update record:'+inputSObjectList);
        Database.SaveResult[] srList = Database.update(inputSObjectList);
        System.debug(':::: srList:'+srList);
        for(Database.SaveResult sr : srList){
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
        system.debug(':::: wrap dml object list:'+wrapDMLObjList);
        return wrapDMLObjList;
    }
    /***************************************************************/
    
    global static List<SObject> convertJSONToListOfSObject(String json) {
        Object[] values = (Object[])System.JSON.deserializeUntyped(json);
        system.debug('::::: object values:'+values);
        List<SObject> newSObjectsList = new List<SObject>();
        for (Object v : values) {
            Map<String, Object> m = (Map<String, Object>)v;
            system.debug(':::: value for M:'+m);
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get((String)m.get('sobjectType'));

            SObject o = targetType.newSObject();

            Map<String, Schema.SObjectField> fields = targetType.getDescribe().fields.getMap();
            for (String fieldName : m.keySet()) {
                // Filter out any psuedo fields such as LastNameLocal
                Schema.SObjectField fi = fields.get(fieldName);
                if (fi != null) {
                    if (fi.getDescribe().isCreateable() && fi.getDescribe().isUpdateable()) {
                        o.put(fieldName, m.get(fieldName)); 
                    }
                }
            }
            //system.debug('::::: ');
            newSObjectsList.add(o);
        }

        return newSObjectsList;
    }
    
    // Move to Dev Org
    @AuraEnabled
    global static List<sObject> insertRemovedPartForSerializedInventory(String removedPart, String inventoryId){
        
        System.debug('::::: removed part:'+removedPart);
        List<sObject> listSObject   =   new List<sObject>();
        sObject sObjRemovedPart     = Schema.getGlobalDescribe().get(NameSpace+'Removed_Claim_Part__c').newSObject();
        
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(removedPart);
        
        for(String fieldAPIName : fieldMap.keySet()){
            if(fieldAPIName == NameSpace+'Quantity__c'){  
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjRemovedPart.put(fieldAPIName,Integer.valueOf(fieldMap.get(fieldAPIName)));
                }
            }
            else if(fieldAPIName == NameSpace+'Price__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjRemovedPart.put(fieldAPIName,Double.valueOf(fieldMap.get(fieldAPIName)));
                }
            }
            else if(fieldAPIName == NameSpace+'Invoice_Date__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    String[] strDate    = String.valueOf(fieldMap.get(fieldAPIName)).split('-');
                    Integer myIntDate   = integer.valueOf(strDate[2]);
                    Integer myIntMonth  = integer.valueOf(strDate[1]);
                    Integer myIntYear   = integer.valueOf(strDate[0]);
                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                    sObjRemovedPart.put(fieldAPIName,d);
                }
            }
            else
            if(fieldAPIName != 'sobjectType' && fieldAPIName != ''){
                sObjRemovedPart.put(fieldAPIName,fieldMap.get(fieldAPIName));
            }
        }
        listSObject.add(sObjRemovedPart);
        insert listSObject;
        return listSObject;
    }
    
    
    
    
    // Move it to DEV Org data into the database
    @AuraEnabled
    global static List<sObject> insertInstalledPartAndRemovedPartRecords(String installedPart, String removedPart){
        System.debug('::::: installed Part:'+installedPart);
        System.debug('::::: removed part:'+removedPart);
        // {"sobjectType":"Claim_Part__c","Name":"","Warranty_Product__c":"a0N610000003fKaEAI","Claim__c":"a056100000OtEHfAAN","RecordTypeId":"01261000000cCqOAAU"}
        // Claim__c:{Claim_Status__c=Draft, RecordTypeId=01261000000cCqfAAE, Id=a056100000KziY5AAJ}
        //installedPart   =   'Claim_Part__c:'+installedPart;
        List<sObject> listSObject   =   new List<sObject>();
        sObject sObjInstalledPart   = Schema.getGlobalDescribe().get(NameSpace+'Claim_Part__c').newSObject();
        sObject sObjRemovedPart     = Schema.getGlobalDescribe().get(NameSpace+'Removed_Claim_Part__c').newSObject();
       // convertJSONToListOfSObject(installedPart);
        //Object[] values = (Object[])System.JSON.deserializeUntyped(installedPart);
        //System.debug('::: values:'+values);
        //system.debug('::: JSON Parsing:'+JSON.serialize(sObjInstalledPart));
        
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(installedPart);
        
        for(String fieldAPIName : fieldMap.keySet()){
            if(fieldAPIName == NameSpace+'Quantity__c'){  
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,Integer.valueOf(fieldMap.get(fieldAPIName)));
                }
            }
            else if(fieldAPIName == NameSpace+'Price__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,Double.valueOf(fieldMap.get(fieldAPIName)));
                }
            }
            else if(fieldAPIName == NameSpace+'Custom_Part_Cost__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,Double.valueOf(fieldMap.get(fieldAPIName)));
                }
            }
            else if(fieldAPIName == NameSpace+'Invoice_Date__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    String[] strDate    = String.valueOf(fieldMap.get(fieldAPIName)).split('-');
                    Integer myIntDate   = integer.valueOf(strDate[2]);
                    Integer myIntMonth  = integer.valueOf(strDate[1]);
                    Integer myIntYear   = integer.valueOf(strDate[0]);
                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                    sObjInstalledPart.put(fieldAPIName,d);
                }
            }
            else
            if(fieldAPIName != 'sobjectType' && fieldAPIName != '' && fieldAPIName != 'Id'){
                sObjInstalledPart.put(fieldAPIName,fieldMap.get(fieldAPIName));
            }
            /*
            if(sObjInstalledPart.get('Inventory__c') != null && sObjInstalledPart.get('Inventory__c') != ''){
                sObjInstalledPart.put('RecordTypeId', Schema.SObjectType.Claim_Part__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId());
            }else{
                sObjInstalledPart.put('RecordTypeId', Schema.SObjectType.Claim_Part__c.getRecordTypeInfosByName().get('Non-Serialized Part').getRecordTypeId());
            } */
        }
        
        List<sObject> listSObjectToInsert = new List<sObject>();
        if(removedPart != null && removedPart != ''){
            Map<String, Object> fieldMapRemovedPart = (Map<String, Object>)JSON.deserializeUntyped(removedPart);
            
            for(String fieldAPIName : fieldMapRemovedPart.keySet()){
                if(fieldAPIName == NameSpace+'Quantity__c'){  
                    if(fieldMapRemovedPart.get(fieldAPIName) != null && fieldMapRemovedPart.get(fieldAPIName) != ''){
                        sObjRemovedPart.put(fieldAPIName,Integer.valueOf(fieldMapRemovedPart.get(fieldAPIName)));
                    }
                }
                else if(fieldAPIName == NameSpace+'Price__c'){
                    if(fieldMapRemovedPart.get(fieldAPIName) != null && fieldMapRemovedPart.get(fieldAPIName) != ''){
                        sObjRemovedPart.put(fieldAPIName,Double.valueOf(fieldMapRemovedPart.get(fieldAPIName)));
                    }
                }
                else if(fieldAPIName == NameSpace+'Invoice_Date__c'){
                    if(fieldMapRemovedPart.get(fieldAPIName) != null && fieldMapRemovedPart.get(fieldAPIName) != ''){
                        String[] strDate    = String.valueOf(fieldMapRemovedPart.get(fieldAPIName)).split('-');
                        Integer myIntDate   = integer.valueOf(strDate[2]);
                        Integer myIntMonth  = integer.valueOf(strDate[1]);
                        Integer myIntYear   = integer.valueOf(strDate[0]);
                        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                        sObjRemovedPart.put(fieldAPIName,d);
                    }
                }
                else
                if(fieldAPIName != 'sobjectType' && fieldAPIName != ''){
                    sObjRemovedPart.put(fieldAPIName,fieldMapRemovedPart.get(fieldAPIName));
                }
                /*
                if(sObjInstalledPart.get('Inventory__c') != null && sObjInstalledPart.get('Inventory__c') != ''){
                    sObjInstalledPart.put('RecordTypeId', Schema.SObjectType.Removed_Claim_Part__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId());
                }else{
                    sObjInstalledPart.put('RecordTypeId', Schema.SObjectType.Removed_Claim_Part__c.getRecordTypeInfosByName().get('Non-Serialized Part').getRecordTypeId());
                }*/
            }
            listSObjectToInsert.add(sObjRemovedPart);
        }
        
        system.debug('::::: installedPart2:'+sObjInstalledPart); 
        system.debug('::::: sObjRemovedPart:'+sObjRemovedPart);
        
        String attributeString = '';
        
        
        listSObjectToInsert.add(sObjInstalledPart);
        
        insert listSObjectToInsert;
        //System.debug(':::: deserializedRemovedPart::'+deserializedRemovedPart);
        return listSObjectToInsert;
    }
    
    /***************************************************************/

    @AuraEnabled
    global static List<DMLOutputWrapper> InsertSObjectsForInstalledParts(sObject installedPart, sObject removedPart, String claimId){
        
        system.debug(':::::::: installed part:'+installedPart);
        System.debug(':::::::: removed part:'+removedPart);
        System.debug(':::::::: Claim id:'+claimId);
        
        List<sObject> inputSObjectList = new List<sObject>();
        inputSObjectList.add(installedPart);
        inputSObjectList.add(removedPart);
        
        
        system.debug(':::::::'+ inputSObjectList);
        String claimRecordId = claimId;
        for(sObject obj : inputSObjectList){
            system.debug('::::::: object'+ obj);
            if(String.valueOf(obj.get(NameSpace+'Claim__c')) != null && String.valueOf(obj.get(NameSpace+'Claim__c')) != ''){
                claimRecordId   =   String.valueOf(obj.get(NameSpace+'Claim__c'));
            }
        }
        
        for(sObject obj : inputSObjectList){
            
            obj.put(NameSpace+'Claim__c',claimRecordId);
            
            //obj.Claim__c    =   claimRecordId;
        }
        
        inputSObjectList.sort();
        
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null ;

        Database.SaveResult[] srList = Database.insert(inputSObjectList,false);
        for(Database.SaveResult sr : srList){
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

    /***************************************************************/
    @AuraEnabled
    global static List<DMLOutputWrapper> InsertSObjectsForRemovedPartFromInstalledPart( List<SObject> inputSObjectList, String inventoryId){
        system.debug(':::::::'+ inputSObjectList);
        system.debug('::::::: inventory id:'+inventoryId);
        String claimRecordId = '';
        for(sObject obj : inputSObjectList){
            system.debug('::::::: object'+ obj);
            if(String.valueOf(obj.get(NameSpace+'Claim__c')) != null && String.valueOf(obj.get(NameSpace+'Claim__c')) != ''){
                claimRecordId   =   String.valueOf(obj.get(NameSpace+'Claim__c'));
            }
        }
        
        for(sObject obj : inputSObjectList){
            obj.put(NameSpace+'Claim__c',claimRecordId);
            obj.put(NameSpace+'Inventory__c', inventoryId);
            //obj.Claim__c    =   claimRecordId;
        }
        
        inputSObjectList.sort();
        system.debug('::::: inputSObjectList:'+inputSObjectList);
        
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null ;

        Database.SaveResult[] srList = Database.insert(inputSObjectList,false);
        for(Database.SaveResult sr : srList){
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

/***************************************************************/
    @AuraEnabled
    global static List<DMLOutputWrapper> InsertSObjects( List<SObject> inputSObjectList){
        system.debug('::::::: InsertSObjects:'+ inputSObjectList);
        String claimRecordId = '';
        for(sObject obj : inputSObjectList){
            system.debug('::::::: object'+ obj);
            if(String.valueOf(obj.get(NameSpace+'Claim__c')) != null && String.valueOf(obj.get(NameSpace+'Claim__c')) != ''){
                claimRecordId   =   String.valueOf(obj.get(NameSpace+'Claim__c'));
            }
        }
        
        for(sObject obj : inputSObjectList){
            obj.put(NameSpace+'Claim__c',claimRecordId);
            //obj.Claim__c    =   claimRecordId;
        }
        
        inputSObjectList.sort();
        
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null ;
        Database.SaveResult[] srList;
        try{
        srList = Database.insert(inputSObjectList,false);
        }
        catch(exception e)
        {
           errorCodeList.add( e.getMessage() );
        }
        for(Database.SaveResult sr : srList){
        DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
        success = FALSE;
            if(sr.isSuccess()){
                success = TRUE;
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
    
    /***********************************************************************************************/
    @AuraEnabled
    global static List<DMLOutputWrapper> InsertSObjectsForRemovedParts( List<SObject> inputSObjectList, String claimId, String warrantyId, String inventoryId,String recordtype){
        system.debug('::::::: InsertSObjects:'+ inputSObjectList);
        String claimRecordId = '';
        for(sObject obj : inputSObjectList){
            system.debug('::::::: object'+ obj);
            if(String.valueOf(obj.get(NameSpace+'Claim__c')) != null && String.valueOf(obj.get(NameSpace+'Claim__c')) != ''){
                claimRecordId   =   String.valueOf(obj.get(NameSpace+'Claim__c'));
            } else {
                claimRecordId = claimId;
            }
            
            
        }
        
        for(sObject obj : inputSObjectList){
            obj.put(NameSpace+'Claim__c',claimRecordId);
            if(warrantyId != null && warrantyId != ''){
                obj.put(NameSpace+'Warranty_Product__c', warrantyId);
            }
            
            if(InventoryId != null && inventoryId != ''){
                obj.put(NameSpace+'Inventory__c', inventoryId);
                
                // edited by aman
                obj.put(NameSpace+'Quantity__c', 1);  
            }
            
            if(recordtype !=null && recordtype!=''){
              obj.put('RecordTypeId', recordtype);
              }
            
            
              
            
            
            //obj.Claim__c    =   claimRecordId;
        }
        
        inputSObjectList.sort();
        
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null ;

        Database.SaveResult[] srList = Database.insert(inputSObjectList,false);
        for(Database.SaveResult sr : srList){
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
    /***********************************************************************************************/

    @AuraEnabled
    global static List<DMLOutputWrapper> UpdateSObjects( List<SObject> inputSObjectList){
        system.debug('--------------------------------------------');
        system.debug('-----------------------'+inputSObjectList);
        List<DMLOutputWrapper> wrapDMLObjList = new List<DMLOutputWrapper>();
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
        Id sObjID = null  ;
        system.debug('::: update record:'+inputSObjectList);
         Database.SaveResult[] srList;
        try{
       srList = Database.update(inputSObjectList);
        }
        catch(Exception e)
        {
            errorCodeList.add( e.getMessage() );
        }
        System.debug(':::: srList:'+srList);        
        for(Database.SaveResult sr : srList){
        DMLOutputWrapper wrapDMLObj = new DMLOutputWrapper();
        success = FALSE;
            if(sr.isSuccess()){
                success = TRUE;
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
        system.debug(':::: wrap dml object list:'+wrapDMLObjList);
        return wrapDMLObjList;
    }
    
    
    @AuraEnabled
    global static List<sobject> UpdateSObjectRecords( String installedPart, String removedPart){
        System.debug('::::: installed Part:'+installedPart);
        System.debug('::::: removed part:'+removedPart);
        // {"sobjectType":"Claim_Part__c","Name":"","Warranty_Product__c":"a0N610000003fKaEAI","Claim__c":"a056100000OtEHfAAN","RecordTypeId":"01261000000cCqOAAU"}
        // Claim__c:{Claim_Status__c=Draft, RecordTypeId=01261000000cCqfAAE, Id=a056100000KziY5AAJ}
        //installedPart   =   'Claim_Part__c:'+installedPart;
        List<sObject> listSObject   =   new List<sObject>();
        sObject sObjInstalledPart   = Schema.getGlobalDescribe().get(NameSpace+'Claim_Part__c').newSObject();
        sObject sObjRemovedPart     = Schema.getGlobalDescribe().get(NameSpace+'Removed_Claim_Part__c').newSObject();
       // convertJSONToListOfSObject(installedPart);
        //Object[] values = (Object[])System.JSON.deserializeUntyped(installedPart);
        //System.debug('::: values:'+values);
        //system.debug('::: JSON Parsing:'+JSON.serialize(sObjInstalledPart));
        
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(installedPart);
        
        for(String fieldAPIName : fieldMap.keySet()){
            if(fieldAPIName == NameSpace+'Quantity__c'){  
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,Integer.valueOf(fieldMap.get(fieldAPIName)));
                }
            }else
            if(fieldAPIName == 'Id'){  
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,fieldMap.get(fieldAPIName));
                }
            }
            else if(fieldAPIName == NameSpace+'Price__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,Double.valueOf(fieldMap.get(fieldAPIName)));
                }
            }
            else if(fieldAPIName == NameSpace+'Warranty_Product__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,fieldMap.get(fieldAPIName));
                }
            }
            else if(fieldAPIName == NameSpace+'Invoice_Number__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,fieldMap.get(fieldAPIName));
                }
            }
            else if(fieldAPIName == NameSpace+'Inventory__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    sObjInstalledPart.put(fieldAPIName,fieldMap.get(fieldAPIName));
                }
            }
            else if(fieldAPIName == NameSpace+'Invoice_Date__c'){
                if(fieldMap.get(fieldAPIName) != null && fieldMap.get(fieldAPIName) != ''){
                    String[] strDate    = String.valueOf(fieldMap.get(fieldAPIName)).split('-');
                    Integer myIntDate   = integer.valueOf(strDate[2]);
                    Integer myIntMonth  = integer.valueOf(strDate[1]);
                    Integer myIntYear   = integer.valueOf(strDate[0]);
                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                    sObjInstalledPart.put(fieldAPIName,d);
                }
            }
            
        }
        
        List<sObject> listSObjectToInsert = new List<sObject>();
        if(removedPart.contains('Id')){
            Map<String, Object> fieldMapRemovedPart = (Map<String, Object>)JSON.deserializeUntyped(removedPart);
            
            for(String fieldAPIName : fieldMapRemovedPart.keySet()){
                if(fieldAPIName == NameSpace+'Quantity__c'){  
                    if(fieldMapRemovedPart.get(fieldAPIName) != null && fieldMapRemovedPart.get(fieldAPIName) != ''){
                        sObjRemovedPart.put(fieldAPIName,Integer.valueOf(fieldMapRemovedPart.get(fieldAPIName)));
                    }
                }
                else if(fieldAPIName == NameSpace+'Price__c'){
                    if(fieldMapRemovedPart.get(fieldAPIName) != null && fieldMapRemovedPart.get(fieldAPIName) != ''){
                        sObjRemovedPart.put(fieldAPIName,Double.valueOf(fieldMapRemovedPart.get(fieldAPIName)));
                    }
                }
                else if(fieldAPIName == NameSpace+'Invoice_Date__c'){
                    if(fieldMapRemovedPart.get(fieldAPIName) != null && fieldMapRemovedPart.get(fieldAPIName) != ''){
                        String[] strDate    = String.valueOf(fieldMapRemovedPart.get(fieldAPIName)).split('-');
                        Integer myIntDate   = integer.valueOf(strDate[2]);
                        Integer myIntMonth  = integer.valueOf(strDate[1]);
                        Integer myIntYear   = integer.valueOf(strDate[0]);
                        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                        sObjRemovedPart.put(fieldAPIName,d);
                    }
                }
                else
                if(fieldAPIName != 'sobjectType' && fieldAPIName != ''){
                    sObjRemovedPart.put(fieldAPIName,fieldMapRemovedPart.get(fieldAPIName));
                }
            }
            listSObjectToInsert.add(sObjRemovedPart);
        }
        
        system.debug('::::: installedPart2:'+sObjInstalledPart); 
        system.debug('::::: sObjRemovedPart:'+sObjRemovedPart);
        
        String attributeString = '';
        
        
        listSObjectToInsert.add(sObjInstalledPart);
        
        update listSObjectToInsert;
        //System.debug(':::: deserializedRemovedPart::'+deserializedRemovedPart);
        return listSObjectToInsert;
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
        Database.DeleteResult[] srList = Database.delete(inputSObjectList);

        for(Database.DeleteResult sr : srList){
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
    global static List<String> getRelatedInventories(String selectedId, String query){
        List<String> listInventoryIds                   =   new List<String>();
        List<Inventory__c> listInventories              =   new List<Inventory__c>();
        Inventory__c    objinventory                    =   new Inventory__c();
        objinventory        =   [SELECT Id, name, Item__c FROM Inventory__c WHERE Id =:selectedId];

        listInventories =   [SELECT Id, Name, Item__c FROM Inventory__c WHERE Item__c =:objinventory.Item__c];
        for(Inventory__c obj : listInventories){
            if(obj.Id != selectedId){
                listInventoryIds.add(obj.Id);
            }
        }
        return listInventoryIds;
    }

    // To identify the duplicate inventory ids while creating the Installed part and removed parts
    @AuraEnabled
    global static List<String> getAllInventoryIds(String claimId){
        List<String> listInventoryIds                   =   new List<String>();
        Claim__c objClaim       =   [SELECT Id, Account__c FROM Claim__c WHERE Id =:claimId];
        List<Claim_Part__c> listClaimParts                  =   new List<Claim_Part__c>();
        List<Removed_Claim_Part__c> listClaimRemovedParts   =   new List<Removed_Claim_Part__c>();
        listClaimParts          =   [SELECT Id, Inventory__c FROM Claim_Part__c WHERE Claim__c =:claimId AND Inventory__c != null];
        listClaimRemovedParts   =   [SELECT Id, Inventory__c FROM Removed_Claim_Part__c WHERE Claim__c =:claimId AND Inventory__c != null];
        for(Claim_Part__c objPart : listClaimParts){
            listInventoryIds.add(objPart.Inventory__c);
        }

        for(Removed_Claim_Part__c objPart : listClaimRemovedParts){
            listInventoryIds.add(objPart.Inventory__c);
        }
        system.debug(':::: listInventoryIds:'+listInventoryIds);
        return listInventoryIds;
    }


}