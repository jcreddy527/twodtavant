/**********************************************************************
Name:  ClaimCreateEditExt
Copyright ? 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose: To handle claim create and edit page initializations and deep cloning.
===============================================================
===============================================================
History
-------
VERSION     AUTHOR               DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    AMAN SAWHNEY         08/10/2016      INITIAL DEVELOPMENT
***********************************************************************/


global with sharing class ClaimCreateEditExt {
    
    //initializations for picklist and configurable parameters on aura page
    global Claim__c claim{get;set;}
    global static List<Upcoming_Completed__c> inventoryScheduleList{get;set;}
    global Id currentUserId {get;set;}
    global Id claimId{get;set;}
    global String defaultDealerAccountJSON{get;set;}
    global List<RecordType> claimPartRecordTypeList{get;set;}
    global List<RecordType> removedClaimPartRecordTypeList{get;set;}
    global List<SelectOption> claimTypeList{get;set;}
    global List<ClaimPicklist> claimPickListArray{get;set;}
    global String picklistJSON{get;set;}
    global String userlangId{get;set;}
    global Boolean autoAddremovedPart{get;set;}
    global List<Claim_Part__c> installedClaimPartList{get;set;}
    global List<Removed_Claim_Part__c> removedClaimPartList{get;set;}
    global List<Claim_Part__c> nonOEMPartList{get;set;}
    global List<Claim_Service_Information__c> claimServiceInfoList{get;set;}
    global Integer lookupMiniumCharacters{get;set;}
    global Integer noOfDaysForDuplicateClaimCheck{get;set;}
    global String relatedListJSON{get;set;}
    global String claimListViewId{get;set;}
    global String faultCodeMapperListJSON{get;set;}
    global String inventoryJSON {get;set;}//added by siva
    global ClaimCreateEditExt(ApexPages.StandardController std) {
        
        claimListViewId = [select Id from ListView where SobjectType='Claim__c'][0].Id;
        Id claimId = std.getRecord().Id;
        getClaimDetails(claimId);
        
        //added by siva
        if(ApexPages.currentPage().getParameters().get('invname')!=null && ApexPages.currentPage().getParameters().get('invname')!=''){
            String invId = ApexPages.currentPage().getParameters().get('invname');
            Inventory__c inv = [select Id,name,Item__c,Units_Run__c,Item__r.Name,Item__r.Description__c,
                                                                          Item__r.Parent_Product__r.Id,Item__r.Parent_Product__r.Name,Item__r.Parent_Product__r.Parent_Product__r.Id,
                                                                          Item__r.Parent_Product__r.Type__c,
                                                                          Item__r.Item_Type__c,Item__r.Units_of_Measure__c,Install_Date__c from Inventory__c where Id =:invId];           
            inventoryJSON = JSON.serialize(inv);
        }
         
        
    }
    
    /**********************************************************************************************
PURPOSE:   To deep clone the claim related list from claim template to field modification claim
PARAMETERS: claim template id and field modification claim id
RETURNS: JSON string of cloned related list
THROWS [EXCEPTIONS]: insertion Exceptions.
***********************************************************************************************/
    @AuraEnabled
    global static String deepCloneTemplateToFieldMod(String claimTemplateId , String fieldModClaimId) {
        
        String returnableRelatedListJSON = '';
        List<Claim_Part__c> installedClaimPartList;
        List<Removed_Claim_Part__c> removedClaimPartList;
        List<Claim_Part__c> nonOEMPartList;
        List<Claim_Service_Information__c> claimServiceInfoList;
        
        //non-serialized and serialized installed parts
        installedClaimPartList = [select Id,External_Claim_Part_Name__c,Name,Total_Parts_Cost__c,Warranty_Product__r.Id,Warranty_Product__r.Name,Warranty_Product__r.Product_Name__c,Inventory__r.Id,Inventory__r.Name,RecordTypeId,
                                  Quantity__c,Price__c,Custom_Part_Cost__c from Claim_Part__c where RecordType.DeveloperName IN ('Non_Serialized_Part','Serialized_Part')
                                  AND Claim__c=:claimTemplateId];
        
        //removed parts
        removedClaimPartList = [select Id,External_Removed_Claim_Part_Name__c,Name,Warranty_Product__r.Id,Warranty_Product__r.Name,Warranty_Product__r.Product_Name__c,Inventory__r.Id,Inventory__r.Name,Return_Location__c,RecordTypeId,
                                Quantity__c,Return_Location__r.Name,Part_Return_Configuration__c,Part_Return_Configuration__r.Days_Due_Within__c from Removed_Claim_Part__c where Claim__c=:claimTemplateId];
        
        //miscelleneous parts
        nonOEMPartList = [select Id,Name,Miscellaneous_Part_Name__c,Miscellaneous_Part_Description__c,Invoice_Number__c,Invoice_Date__c,Quantity__c,RecordTypeId,
                          Custom_Part_Cost__c from Claim_Part__c where RecordType.DeveloperName='Miscellaneous_Part' AND Claim__c=:claimTemplateId];
        
        //claim service infos
        claimServiceInfoList = [select Id,External_Claim_Service_Name__c,Name,Standard_Labor_Hour__c,Service_Job_Code__c,Service_Job_Code__r.Id,Service_Job_Code__r.Name,Service_Job_Code__r.Standard_Labor_Hour__c,
                                Service_Job_Code__r.Description__c,Additional_Labor_Hour__c,Reason_Additional_Labor_hour__c,Claim__c
                                from Claim_Service_Information__c where Claim__c=:claimTemplateId];
        
        /****insert for non-serialized and serialized installed parts****/
        for(Claim_Part__c installedPart : installedClaimPartList){
            installedPart.Id = null ;
            installedPart.External_Claim_Part_Name__c = '';
            installedPart.Claim__c = fieldModClaimId ;
        }
        
        if(!installedClaimPartList.isEmpty()){
            
            try{
                system.debug('----installedClaimPartList---'+installedClaimPartList);
                insert(installedClaimPartList);
                
            }catch(Exception e){
                
                installedClaimPartList.clear();
                system.debug('Installed parts insertion failed');
                system.debug(e.getMessage());
                
            }
            
        }
        
        
        /****insert for removed parts****/
        for(Removed_Claim_Part__c removedPart : removedClaimPartList){
            removedPart.Id = null ;
            removedPart.External_Removed_Claim_Part_Name__c = '';
            removedPart.Claim__c = fieldModClaimId ;
        }
        
        if(!removedClaimPartList.isEmpty()){
            try{
                system.debug('--removedClaimPartList--'+removedClaimPartList);
                insert(removedClaimPartList);
                
            }catch(Exception e){
                
                removedClaimPartList.clear();
                system.debug('Removed parts insertion failed');
                system.debug(e.getMessage());
                
            }
        }
        
        
        
        /****insertion for non-OEM parts****/
        for(Claim_Part__c nonOEMPart : nonOEMPartList){
            nonOEMPart.Id = null ;
            nonOEMPart.Claim__c = fieldModClaimId ;
        }
        
        if(!nonOEMPartList.isEmpty()){
            try{
                
                insert(nonOEMPartList);
                
            }catch(Exception e){
                
                nonOEMPartList.clear();
                system.debug('Non-OEM parts insertion failed');
                system.debug(e.getMessage());
                
            }
        }
        
        
        
        /****insertion for claim service info****/
        for(Claim_Service_Information__c claimServiceInfo : claimServiceInfoList){
            claimServiceInfo.Id = null ;
            claimServiceInfo.External_Claim_Service_Name__c = '';
            claimServiceInfo.Claim__c = fieldModClaimId ;
        }
        
        if(!claimServiceInfoList.isEmpty()){
            try{
                
                insert(claimServiceInfoList);
                
            }catch(Exception e){
                
                nonOEMPartList.clear();
                system.debug('claim service info insertion failed');
                system.debug(e.getMessage());
                
            }
        }
        
        Map<String,List<sObject>> relatedListMap = new Map<String,List<sObject>>();
        
        
        relatedListMap.put('Installed Parts',installedClaimPartList);
        
        relatedListMap.put('Removed Parts',removedClaimPartList);
        
        relatedListMap.put('Non-OEM parts',nonOEMPartList);
        
        relatedListMap.put('Claim Service Infos',claimServiceInfoList);
        
        returnableRelatedListJSON = JSON.serialize(relatedListMap);
        
        return returnableRelatedListJSON;
        
    }
    
    
    /**********************************************************************************************
PURPOSE:   To update the policy definitions for further validation
PARAMETERS: claim Id
RETURNS: void
THROWS [EXCEPTIONS]: insertion Exceptions.
***********************************************************************************************/
    @AuraEnabled
    global static void updatePolicyDefinition(String claimId) {
        
        Map<String, Object> params = new Map<String, Object>();
        params.put('VarClaimId', claimId);
        Flow.Interview.Updating_Policy_Definition_in_Claim calcFlow = new Flow.Interview.Updating_Policy_Definition_in_Claim(params);
        
        try{
            calcFlow.start();
        }catch(Exception e){
            
            system.debug('Exception while updating policies');
            system.debug(e.getMessage());
        }
        
        
    }
    
    
    /**********************************************************************************************
PURPOSE:   To get all the claim details
PARAMETERS: claim Id
RETURNS: void
THROWS [EXCEPTIONS]: none.
***********************************************************************************************/
    
    global void getClaimDetails(Id claimId){
        
        //initialize variables with custom settings//
        WOD__c cs = WOD__c.getInstance('Auto Add Non-Serialized Removed Part');
        
        try{
            autoAddremovedPart = cs.isTriggered__c;
        }catch(Exception e){
            autoAddremovedPart = true;
        }
        
        
        
        cs = WOD__c.getInstance('Lookup Minium Characters');
        try{
            lookupMiniumCharacters = Integer.valueOf(cs.Trigger_Value__c);
        }catch(Exception e){
            lookupMiniumCharacters = 0;
        }
        
        cs = WOD__c.getInstance('Claim Duplicate Check Period In Days');
        try{
            noOfDaysForDuplicateClaimCheck = Integer.valueOf(cs.Trigger_Value__c);
        }catch(Exception e){
            noOfDaysForDuplicateClaimCheck = 180;
        }
        
        /*** if edit claim ****/
        if(Apexpages.CurrentPage().getParameters().get('id') !='' && Apexpages.CurrentPage().getParameters().get('id') !=null){
            
            claim = [select Id,Name,Claim_Record_Type__c,Account__r.Name,Inventory__r.Name,Inventory__r.Item__r.Name,
                     Inventory__r.Item__r.Description__c,Warranty_Product__r.Description__c,
                     Applicable_Policy__r.Id,Applicable_Policy__r.Name,Rate__r.Id,Rate__r.Name,Claim_Template_Payment_Definition__r.Id,
                     Inventory__r.Item__r.Item_Type__c,Warranty_Product__r.Id,Claim_Template_Payment_Definition__r.Name,
                     Warranty_Product__r.Name,Warranty_Product__r.Product_Name__c,Inventory__r.Item__r.Parent_Product__r.Id,Inventory__r.Item__r.Parent_Product__r.Name,Inventory__r.Item__r.Parent_Product__r.Description__c,Inventory__r.Item__r.Product_Name__c,
                     Inventory__r.Item__r.Parent_Product__r.Parent_Product__r.Id,
                     Causal_Part_Number__r.Id,Causal_Part_Number__r.Name,Causal_Part_Number__r.Description__c,Fault_Code__r.Id,Fault_Code__r.Name,
                     Campaign_Members__c,Campaign_Members__r.Service_Campaign__r.Id,Campaign_Members__r.Service_Campaign__r.Name,
                     Campaign_Members__r.Service_Campaign__r.Start_Date__c,Campaign_Members__r.Service_Campaign__r.End_Date__c,
                     Campaign_Members__r.Service_Campaign__c,Claim_Type__c,Warranty_Product__r.Parent_Product__r.Id,Warranty_Product__r.Parent_Product__r.Name from Claim__c where Id=:claimId];
            
            
            installedClaimPartList = [select Id,Name,Warranty_Product__r.Id,Warranty_Product__r.Name,Warranty_Product__r.Product_Name__c,Inventory__r.Id,Inventory__r.Name,RecordTypeId,
                                      Quantity__c,Custom_Part_Cost__c,Price__c  from Claim_Part__c where RecordType.DeveloperName IN
                                      ('Non_Serialized_Part','Serialized_Part') AND Claim__c=:claimId];
            
            
            removedClaimPartList = [select Id,Name,Warranty_Product__r.Id,Warranty_Product__r.Name,Warranty_Product__r.Product_Name__c,Inventory__r.Id,Inventory__r.Name,Return_Location__c,RecordTypeId,
                                    Quantity__c,Return_Location__r.Name,Part_Return_Configuration__c,Part_Return_Configuration__r.Days_Due_Within__c from Removed_Claim_Part__c where Claim__c=:claimId];
            
            
            nonOEMPartList = [select Id,Name,Miscellaneous_Part_Name__c,Miscellaneous_Part_Description__c,Invoice_Number__c,Invoice_Date__c,Quantity__c,RecordTypeId,
                              Custom_Part_Cost__c from Claim_Part__c where RecordType.DeveloperName='Miscellaneous_Part' AND Claim__c=:claimId];
            
            
            claimServiceInfoList = [select Id,Name,Service_Job_Code__c,Service_Job_Code__r.Id,Service_Job_Code__r.Name,Service_Job_Code__r.Standard_Labor_Hour__c,
                                    Service_Job_Code__r.Description__c,Additional_Labor_Hour__c,Reason_Additional_Labor_hour__c,Claim__c
                                    from Claim_Service_Information__c where Claim__c=:claimId];
            
            
            //get the intersection of faultCodes from causal part and inventory's model
            String modelId;
            String modelParentId;
            String causalPartId = claim.Causal_Part_Number__r.Id;
            List<FaultCode_Mapper__c> faultCodeMapperList;
            system.debug('claim.Claim_Record_Type__c-->'+claim.Claim_Record_Type__c);
            if(claim.Claim_Record_Type__c=='Serialized' || claim.Claim_Record_Type__c=='Field Modification'){
                
                modelId = claim.Inventory__r.Item__r.Parent_Product__r.Id;
                modelParentId = claim.Inventory__r.Item__r.Parent_Product__r.Parent_Product__r.Id;
                List<String> partsIdArray = new List<String>();
                partsIdArray.add(modelId);
                partsIdArray.add(modelParentId);
                partsIdArray.add(causalPartId);
                
                faultCodeMapperList = [select Id,Name,Warranty_Product__c,Warranty_Product__r.Product_Name__c,Fault_Code__r.Id,Fault_Code__r.Name
                                       from FaultCode_Mapper__c where Warranty_Product__c IN :partsIdArray AND Fault_Code__r.Lang_Id__c=:UserInfo.getLocale()
                                       AND Fault_Code__r.Selectable__c=true];
                
            }else{
                
                
                
                faultCodeMapperList = [select Id,Name,Warranty_Product__c,Warranty_Product__r.Product_Name__c,Fault_Code__r.Id,Fault_Code__r.Name
                                       from FaultCode_Mapper__c where Warranty_Product__c=:causalPartId AND Fault_Code__r.Lang_Id__c= :UserInfo.getLocale()
                                       AND Fault_Code__r.Selectable__c=true];
                
            }
            try{
                faultCodeMapperListJSON = JSON.serialize(faultCodeMapperList);
            }catch(Exception e){
                faultCodeMapperListJSON = '[]';
                system.debug(e.getMessage());
            }
            
            
            
            Map<String,List<sObject>> relatedListMap = new Map<String,List<sObject>>();
            
            relatedListMap.put('Claim Service Infos',claimServiceInfoList);
            
            relatedListMap.put('Installed Parts',installedClaimPartList);
            
            relatedListMap.put('Removed Parts',removedClaimPartList);
            
            relatedListMap.put('Non-OEM parts',nonOEMPartList);
            
            relatedListJSON = JSON.serialize(relatedListMap);
            
            
        }
        
        
        /*** get user account in create claim case ***/
        //add the default dealer
        currentUserId = UserInfo.getUserId();
        Account defaultDealerAccount;
        
        List<User> currentUserList = [select Id,Name,AccountId,IsPortalEnabled from User where id=:currentUserId];
        
        if(currentUserList[0].IsPortalEnabled){
            
            defaultDealerAccount = [select Id,Name from Account where Id=:currentUserList[0].AccountId];
            
        }else{
            
            defaultDealerAccount = null;
            
        }
        
        defaultDealerAccountJSON = JSON.serialize(defaultDealerAccount);
        
        
        /*******add user lang id********/
        userlangId = UserInfo.getLocale();
        
        
        /******* add claim custom record type list ***/
        claimPickListArray = new List<ClaimPicklist>();
        List<NameValue> optionList=new List<NameValue>();
        Schema.DescribeFieldResult fieldResult = Claim__c.Claim_Record_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            NameValue nv=new NameValue();
            nv.label=f.getLabel();
            nv.value=f.getValue();
            optionList.add(nv);
        }
        
        ClaimPicklist pickList = new ClaimPicklist();
        pickList.key='ClaimRecordTypes';
        pickList.val=optionList;
        
        claimPickListArray.add(pickList);
        
        
        /******* add claim type list in JSON ********/
        
        optionList=new List<NameValue>();
        fieldResult = Claim__c.Claim_Type__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            NameValue nv=new NameValue();
            nv.label=f.getLabel();
            nv.value=f.getValue();
            optionList.add(nv);
        }
        
        pickList = new ClaimPicklist();
        pickList.key='ClaimTypes';
        pickList.val=optionList;
        
        claimPickListArray.add(pickList);
        
        
        /******* add host-non host list in JSON *******/
        optionList=new List<NameValue>();
        fieldResult = Claim__c.Host_NonHost__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            NameValue nv=new NameValue();
            nv.label=f.getLabel();
            nv.value=f.getValue();
            optionList.add(nv);
        }
        pickList = new ClaimPicklist();
        pickList.key='hostNonHost';
        pickList.val=optionList;
        
        claimPickListArray.add(pickList);
        
        
        /******* add SMR reasons list in JSON *******/
        optionList=new List<NameValue>();
        fieldResult = Claim__c.SMR_Reason__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            NameValue nv=new NameValue();
            nv.label=f.getLabel();
            nv.value=f.getValue();
            optionList.add(nv);
        }
        pickList = new ClaimPicklist();
        pickList.key='SMRreasons';
        pickList.val=optionList;
        
        claimPickListArray.add(pickList);
        
        /******* add faultFound list in JSON *******/
        optionList=new List<NameValue>();
        fieldResult = Claim__c.Fault_found__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            NameValue nv=new NameValue();
            nv.label=f.getLabel();
            nv.value=f.getValue();
            optionList.add(nv);
        }
        pickList = new ClaimPicklist();
        pickList.key='FaultFound';
        pickList.val=optionList;
        claimPickListArray.add(pickList);
        
        /******* add causedBy list in JSON *******/
        optionList=new List<NameValue>();
        fieldResult = Claim__c.Caused_by__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            NameValue nv=new NameValue();
            nv.label=f.getLabel();
            nv.value=f.getValue();
            optionList.add(nv);
        }
        pickList = new ClaimPicklist();
        pickList.key='CausedBy';
        pickList.val=optionList;
        claimPickListArray.add(pickList);
        
        
        
        /******* add installed part record type list in JSON *******/
        
        claimPartRecordTypeList = [select Id,Name,DeveloperName from RecordType where SobjectType='Claim_Part__c' order by Name desc];
        ClaimPicklist claimPartRecordTypePickList = new ClaimPicklist();
        claimPartRecordTypePickList.key='Claim Part Record Types';
        claimPartRecordTypePickList.val=claimPartRecordTypeList;
        
        claimPickListArray.add(claimPartRecordTypePickList);
        
        /******* add removed claim part record type list in JSON *******/
        
        removedClaimPartRecordTypeList = [select Id,Name,DeveloperName from RecordType where SobjectType='Removed_Claim_Part__c' order by Name desc];
        ClaimPicklist removedPartRecordTypePicklist = new ClaimPicklist();
        removedPartRecordTypePicklist.key='Claim Removed Part Record Types';
        removedPartRecordTypePicklist.val=removedClaimPartRecordTypeList;
        
        claimPickListArray.add(removedPartRecordTypePicklist);
        
        
        
        
        // convert to JSON
        picklistJSON = JSON.serialize(claimPickListArray);
        
        
    }
    
    
    /**********************************************************************************************
PURPOSE:   To get th part price for multiple parts
PARAMETERS: claim Id
RETURNS: String
THROWS [EXCEPTIONS]: none.
***********************************************************************************************/
    
    
    @AuraEnabled
    global static String  getPartPrice(List<Id> claimIdsList){ 
        
        try {
            
            Map<String,List<Claim_Part__c>> claimPartsMap = new Map<String,List<Claim_Part__c>>();
            Map<String,Claim_Part__c > claimPartPriceMap = new Map<String,Claim_Part__c >();
            List<Claim_Part__c> claimPartsListtoUpdate = new List<Claim_Part__c>();
            
            //Getting all custom settings
            
            WOD__c passwordSettings  = WOD__c.getValues('PartPrice_Keystore_Password');
            WOD__c urnSettings = WOD__c.getValues('PartPrice_URN_Address');
            WOD__c certificateSettings  = WOD__c.getValues('PartPrice_ClientCertificate_Name');
            
            //formation of Request
            
            schemasQadComXmlServices.WSDLGetPriceRequestType response;
            String responseString;
            List<claimResponseController.reponsewraper> responseList = new List<claimResponseController.reponsewraper>(); 
            List<schemasQadComXmlServicesCommon.TtContext> ttContactexList = new List<schemasQadComXmlServicesCommon.TtContext>();
            List<schemasQadComXmlServices.TtPriceInquiryReqType> ttPriceInquiryList;
            schemasQadComXmlServices.QdocWebService  twodService = new schemasQadComXmlServices.QdocWebService();
            schemasQadComXmlServicesCommon.DsSessionContext twodDsSession = new schemasQadComXmlServicesCommon.DsSessionContext();
            schemasQadComXmlServicesCommon.TtContext twodttContext = new schemasQadComXmlServicesCommon.TtContext();
            schemasQadComXmlServicesCommon.TtContext twodttContext1 = new schemasQadComXmlServicesCommon.TtContext();
            
            schemasQadComXmlServices.dsPriceInquiryRequest_element twodPriceEnquiry;
            schemasQadComXmlServices.TtPriceInquiryReqType twodPriceEquiryReqType ;
            wwwW3Org200508Addressing.ReferenceParametersType referen = new  wwwW3Org200508Addressing.ReferenceParametersType();
            wwwW3Org200508Addressing.ReplyToType relType = new  wwwW3Org200508Addressing.ReplyToType ();
            wwwW3Org200508Addressing.ToType refToType = new wwwW3Org200508Addressing.ToType();
            wwwW3Org200508Addressing.MessageIDType refMessToType = new wwwW3Org200508Addressing.MessageIDType();
            wwwW3Org200508Addressing.ActionType refActionType = new wwwW3Org200508Addressing.ActionType();
            referen.suppressResponseDetail = false;
            
            twodttContext.propertyQualifier   =    Label.PartPrice_propertyQualifier;
            twodttContext.propertyName        =    Label.PartPrice_Domain;
            twodttContext.propertyValue       =    Label.PartPrice_DomainValue;
            
            twodttContext1.propertyQualifier  =    Label.PartPrice_propertyQualifier;
            twodttContext1.propertyName       =    Label.PartPrice_VersionProperty;
            twodttContext1.propertyValue      =    Label.PartPrice_VersionValue;
            
            ttContactexList.add(twodttContext);
            ttContactexList.add(twodttContext1);
            twodDsSession.ttContext = ttContactexList;
            
            twodService.referenceParameters = referen ;
            twodService.ReplyTo = relType;
            PartPrice_Wrapper_Class.ToType t= new PartPrice_Wrapper_Class.ToType();
            
            if(urnSettings !=Null && urnSettings.Trigger_Value__c != Null) {
                t.to = urnSettings.Trigger_Value__c;
                relType.Address= urnSettings.Trigger_Value__c;
                twodService.t = t;
            }
            
            twodService.MessageID = refMessToType;
            twodService.Action = refActionType ;
            twodService.endpoint_x = Label.PartPrice_EndpointUrl;
            if(certificateSettings != Null && certificateSettings.Trigger_Value__c != Null) {
                twodService.clientCertName_x= certificateSettings.Trigger_Value__c;
            }
            
            if(passwordSettings != Null &&  passwordSettings.Trigger_Value__c != Null) {
                twodService.clientCertPasswd_x = passwordSettings.Trigger_Value__c ;
            }
            
            if(claimIdsList.size()>0) {
                
                //getting all the installed parts with respect to claims and populating in a map.
                
                for(Claim_Part__c cp : [SELECT Id,Name,Claim__c,Claim__r.Date_of_Repair__c,Claim__r.Account__r.Ext_Dealer_ID__c,Warranty_Product__c,Warranty_Product__r.Name,Warranty_Product__r.Product_Name__c,Inventory__c,Account__c,
                                              Quantity__c,Inventory__r.Item__r.Name,Custom_Part_Cost__c FROM Claim_Part__c WHERE Claim__c IN: claimIdsList]) {
                                                  if(claimPartsMap.Containskey(cp.Claim__c)) {
                                                      claimPartsMap.get(cp.Claim__c).add(cp);
                                                      
                                                  } else {
                                                      claimPartsMap.put(cp.Claim__c,new List<Claim_Part__c>{cp});
                                                      
                                                  }
                                              } 
            } 
            ttPriceInquiryList = new List<schemasQadComXmlServices.TtPriceInquiryReqType>();
            twodPriceEnquiry = new  schemasQadComXmlServices.dsPriceInquiryRequest_element();
            
            if(claimPartsMap.size()>0) {     
                
                for(Id clmId : claimPartsMap.keySet()) {
                    
                    for(Claim_Part__c  clmp : claimPartsMap.get(clmId)) {
                        
                        twodPriceEquiryReqType = new schemasQadComXmlServices.TtPriceInquiryReqType();
                        
                        if(clmp.Warranty_Product__c != null) {
                            twodPriceEquiryReqType.ttPart = clmp.Warranty_Product__r.Name;
                        }
                        
                        else if(clmp.Inventory__c != null) {
                            twodPriceEquiryReqType.ttPart = clmp.Inventory__r.Item__r.Name;
                        }
                        
                        twodPriceEquiryReqType.ttCustomer = clmp.Claim__r.Account__r.Ext_Dealer_ID__c;
                        twodPriceEquiryReqType.ttQty = clmp.Quantity__c;
                        twodPriceEquiryReqType.ttEffDate = clmp.Claim__r.Date_of_Repair__c;
                        ttPriceInquiryList.add(twodPriceEquiryReqType);
                    } 
                }
                twodPriceEnquiry.ttPriceInquiryReq = ttPriceInquiryList;
                System.debug( twodPriceEnquiry.ttPriceInquiryReq+'######');
                
            }
            
            
            if(twodPriceEnquiry != Null) {  
                
                response= twodService.getPriceRequest(twodDsSession,twodPriceEnquiry );
                claimResponseController  cr = new claimResponseController ();
                responseString = cr.reponseGenerator(response.dsPriceInquiryResponse.ttPriceInquiryResp,twodPriceEnquiry.ttPriceInquiryReq,claimIdsList[0]);
                
            }
            
            return responseString;
        }catch(Exception e) {
            
            System.debug('*******Exception*****'+e.getMessage());
            return e.getMessage();
        }
        
    }    
    
    /**********************************************************************************************
PURPOSE:   To get th part price for Individual part.
PARAMETERS: claim Id,PartNumber
RETURNS: String
THROWS [EXCEPTIONS]: none.
***********************************************************************************************/
    
    
    
    @AuraEnabled
    global static String  getIndividualPartPrice(String ClaimId,String PartNumber){ 
        
        try {
            System.debug(ClaimId+'###@@@@');
            System.debug(PartNumber+'###@@@@');
            Map<String,List<Claim_Part__c>> claimPartsMap = new Map<String,List<Claim_Part__c>>();
            Map<String,Claim_Part__c > claimPartPriceMap = new Map<String,Claim_Part__c >();
            List<Claim_Part__c> claimPartsListtoUpdate = 
                new List<Claim_Part__c>();
            
            //Getting all custom settings
            
            WOD__c passwordSettings  = WOD__c.getValues('PartPrice_Keystore_Password');
            WOD__c urnSettings = WOD__c.getValues('PartPrice_URN_Address');
            WOD__c certificateSettings  = WOD__c.getValues('PartPrice_ClientCertificate_Name');
            
            //formation of Request
            
            schemasQadComXmlServices.WSDLGetPriceRequestType response;
            String responseString;
            List<claimResponseController.reponsewraper> responseList = new List<claimResponseController.reponsewraper>(); 
            List<schemasQadComXmlServicesCommon.TtContext> ttContactexList = new List<schemasQadComXmlServicesCommon.TtContext>();
            List<schemasQadComXmlServices.TtPriceInquiryReqType> ttPriceInquiryList;
            schemasQadComXmlServices.QdocWebService  twodService = new schemasQadComXmlServices.QdocWebService();
            schemasQadComXmlServicesCommon.DsSessionContext twodDsSession = new schemasQadComXmlServicesCommon.DsSessionContext();
            schemasQadComXmlServicesCommon.TtContext twodttContext = new schemasQadComXmlServicesCommon.TtContext();
            schemasQadComXmlServicesCommon.TtContext twodttContext1 = new schemasQadComXmlServicesCommon.TtContext();
            
            schemasQadComXmlServices.dsPriceInquiryRequest_element twodPriceEnquiry;
            schemasQadComXmlServices.TtPriceInquiryReqType twodPriceEquiryReqType ;
            wwwW3Org200508Addressing.ReferenceParametersType referen = new  wwwW3Org200508Addressing.ReferenceParametersType();
            wwwW3Org200508Addressing.ReplyToType relType = new  wwwW3Org200508Addressing.ReplyToType ();
            wwwW3Org200508Addressing.ToType refToType = new wwwW3Org200508Addressing.ToType();
            wwwW3Org200508Addressing.MessageIDType refMessToType = new wwwW3Org200508Addressing.MessageIDType();
            wwwW3Org200508Addressing.ActionType refActionType = new wwwW3Org200508Addressing.ActionType();
            referen.suppressResponseDetail = false;
            
            ttPriceInquiryList = new List<schemasQadComXmlServices.TtPriceInquiryReqType>();
            twodPriceEnquiry = new  schemasQadComXmlServices.dsPriceInquiryRequest_element();
            twodPriceEquiryReqType = new schemasQadComXmlServices.TtPriceInquiryReqType();
            
            twodttContext.propertyQualifier   =    Label.PartPrice_propertyQualifier;
            twodttContext.propertyName        =    Label.PartPrice_Domain;
            twodttContext.propertyValue       =    Label.PartPrice_DomainValue;
            
            twodttContext1.propertyQualifier  =    Label.PartPrice_propertyQualifier;
            twodttContext1.propertyName       =    Label.PartPrice_VersionProperty;
            twodttContext1.propertyValue      =    Label.PartPrice_VersionValue;
            
            ttContactexList.add(twodttContext);
            ttContactexList.add(twodttContext1);
            twodDsSession.ttContext = ttContactexList;
            
            twodService.referenceParameters = referen ;
            twodService.ReplyTo = relType;
            PartPrice_Wrapper_Class.ToType t= new PartPrice_Wrapper_Class.ToType();
            
            if(urnSettings !=Null && urnSettings.Trigger_Value__c != Null) {
                t.to = urnSettings.Trigger_Value__c;
                relType.Address= urnSettings.Trigger_Value__c;
                twodService.t = t;
            }
            
            twodService.MessageID = refMessToType;
            twodService.Action = refActionType ;
            twodService.endpoint_x = Label.PartPrice_EndpointUrl;
            if(certificateSettings != Null && certificateSettings.Trigger_Value__c != Null) {
                twodService.clientCertName_x= certificateSettings.Trigger_Value__c;
            }
            
            if(passwordSettings != Null &&  passwordSettings.Trigger_Value__c != Null) {
                twodService.clientCertPasswd_x = passwordSettings.Trigger_Value__c ;
            }
            
            if(ClaimId!= Null) {
                
                Claim__c clm = [SELECT Id,Name,Account__r.Ext_Dealer_ID__c,Date_of_Repair__c FROM Claim__c  WHERE Id=:ClaimId];
                twodPriceEquiryReqType.ttPart = PartNumber;                     
                twodPriceEquiryReqType.ttCustomer = clm.Account__r.Ext_Dealer_ID__c;
                twodPriceEquiryReqType.ttQty = 0.0;
                twodPriceEquiryReqType.ttEffDate = clm.Date_of_Repair__c;
                ttPriceInquiryList.add(twodPriceEquiryReqType);
            } 
            
            twodPriceEnquiry.ttPriceInquiryReq = ttPriceInquiryList;
            System.debug( twodPriceEnquiry.ttPriceInquiryReq+'######');
            
            if(twodPriceEnquiry != Null) {  
                
                response= twodService.getPriceRequest(twodDsSession,twodPriceEnquiry );
                claimResponseController  cr = new claimResponseController ();
                responseString = cr.reponseGenerator(response.dsPriceInquiryResponse.ttPriceInquiryResp,twodPriceEnquiry.ttPriceInquiryReq,ClaimId);
                
            }
            
            return responseString;
        }catch(Exception e) {
            
            System.debug('*******Exception*****'+e.getMessage());
            return e.getMessage();
        }
        
    }

    @AuraEnabled
    global static void updateInventorySchedule(String ClaimId,String ruleId){ 
        Upcoming_Completed__c inventoryRuleScheduleList = [Select id,name,Claim__c,Completed__c,Description__c,Preventative_Maintenance_Date__c FROM Upcoming_Completed__c WHERE id=: ruleId];
        
        if(inventoryRuleScheduleList != null){
            inventoryRuleScheduleList.Claim__c = ClaimId;
            inventoryRuleScheduleList.Completed__c = true;
            update inventoryRuleScheduleList;
        }
    }  
    
    @AuraEnabled
    global static Upcoming_Completed__c getUpcomingSchedule(String ClaimId){
        Upcoming_Completed__c inventoryRuleSchedule = [Select id,Name,Claim__c,Completed__c,Description__c,Preventative_Maintenance_Date__c FROM Upcoming_Completed__c WHERE Claim__c=: ClaimId AND Completed__c = true LIMIT 1];
        system.debug('inventoryRuleSchedule-->'+inventoryRuleSchedule);
        return inventoryRuleSchedule;
    }
    
    // Modified by Mahesh (2/24/17) - Changed the logic for getting the final schedule - Start
    
/*    @AuraEnabled
    global static List<Upcoming_Completed__c> getFinalSchedule(List<Upcoming_Completed__c> schedulerList, String failureDate, String invInstallDate,Decimal claimUnitsRun ){
        system.debug('claimUnitsRun-->'+claimUnitsRun);
        Map<Integer,Upcoming_Completed__c> newMap= new Map<Integer,Upcoming_Completed__c>();
        WOD__c cs = WOD__c.getInstance('Preventive Maintenance Grace Period');
        Integer gracePeriod = Integer.valueOf(cs.Trigger_Value__c);
        List<Upcoming_Completed__c> selectedSchedule = new List<Upcoming_Completed__c>();
        
        for(Upcoming_Completed__c sl : schedulerList){
            if(sl.Order__c != null){
                Integer upcomingScheduleOrder = integer.valueOf(sl.Order__c);
                newMap.put(upcomingScheduleOrder,sl);
            }
        }
        for(Upcoming_Completed__c scheduler : newMap.values()){
            system.debug('scheduler-->'+scheduler);
            if(scheduler.Order__c == 1 && failureDate>=invInstallDate && failureDate<String.valueOf((scheduler.Preventative_Maintenance_Date__c).addDays(gracePeriod))){
                system.debug('inside if-->'+scheduler);
                selectedSchedule.add(scheduler);
            }else{
                Upcoming_Completed__c tt = newMap.get(integer.valueOf(scheduler.Order__c - 1));
                if(tt != null){
                if(/*failureDate >= String.valueOf((tt.Preventative_Maintenance_Date__c).addDays(gracePeriod)) &&*/ /*failureDate <= String.valueOf((scheduler.Preventative_Maintenance_Date__c).addDays(gracePeriod))){
                    system.debug('inside else-->'+scheduler);
                    selectedSchedule.add(scheduler);
                }
            }
            }
        }
        return selectedSchedule;
    } 
*/
	@AuraEnabled
   	global static List<Upcoming_Completed__c> getFinalSchedule(List<Upcoming_Completed__c> schedulerList, String failureDate, String invInstallDate,Decimal claimUnitsRun) {
		WOD__c cs = WOD__c.getInstance('Preventive Maintenance Grace Period') ;
      	Integer gracePeriod = Integer.valueOf(cs.Trigger_Value__c) ;
      	List<Upcoming_Completed__c> selectedSchedule = new List<Upcoming_Completed__c>() ;
      	Boolean criteriaFound = false ;

      	for(Upcoming_Completed__c scheduler : schedulerList) {
        	if (scheduler.Order__c != null && failureDate >= invInstallDate) {
            	if (!criteriaFound) {
               		if (failureDate <= String.valueOf((scheduler.Preventative_Maintenance_Date__c).addDays(gracePeriod)) && claimUnitsRun <= scheduler.Expected_Procuct_Usage__c) {
                  		criteriaFound = true ;
                  		if(selectedSchedule.isEmpty()){
                  			selectedSchedule.add(scheduler) ;
                  		}
               		}
            	} else {
            		if(selectedSchedule.isEmpty()){
               			selectedSchedule.add(scheduler) ;
            		}
            	}
         	}
      	}
		return selectedSchedule ;
   	}
   
   	// Mahesh (2/24/17) - End
    
    @AuraEnabled
    global static Integer getGracePeriodCustomSetting(){
        WOD__c cs = WOD__c.getInstance('Preventive Maintenance Grace Period');
        Integer gracePeriod = Integer.valueOf(cs.Trigger_Value__c);
        system.debug('gracePeriod-->'+gracePeriod);
        return gracePeriod;
    }
    
    @AuraEnabled
    global static Boolean getPartByPartSettings(){
        WOD__c partSettings  = WOD__c.getValues('Part_By_Part_Settings');
        return partSettings.isTriggered__c;
        
    }
    
    @AuraEnabled
    global static Boolean isModelParentJobCodeList(){
        WOD__c cs  = WOD__c.getValues('Enable modelParentJobCodeList');
        return cs.isTriggered__c;
        
    }
    
    global class ClaimPicklist{
        
        global String key{get;set;}
        global List<Object> val{get;set;}
        
    }
    
    global class NameValue{
        
        global String label{get;set;}
        global String value{get;set;}
        
    }
    
}