/**********************************************************************
 Name:  PATCreationCtrl ()
 Copyright ? 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Controller class that handles creation of PAT record                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -   Abhishek        17/11/2014      INITIAL DEVELOPMENT
***********************************************************************/
global with sharing class PATCreationCtrl {

    global PolicyApplicabilityWrapper PDAppsWrapr{get;set;}
    global String selectedObjectIds{get;set;}
    Id patId;
    global boolean isRendered{get;set;}
    global Map<String, String> mapApiNameLabel{get;set;}
    global List<SObjectFieldValueWrapper> fieldValueWrapperRecordList {get;set;}
    global List<String> fieldList{get;set;}
    global PATCreationManager PATManager;
    
    //Constructor
    global PATCreationCtrl (ApexPages.StandardSetController stdController){
            PATManager = new PATCreationManager();
            patId = PageUtils.get('id');
            PDAppsWrapr = new PolicyApplicabilityWrapper(new Policy_Applicability_Term__c());
            isRendered= false;
            fieldValueWrapperRecordList = new List<SObjectFieldValueWrapper>();
    }
    
    global PATCreationCtrl (ApexPages.StandardController stdController){
  
        PATManager = new PATCreationManager();
        PDAppsWrapr = new PolicyApplicabilityWrapper(new Policy_Applicability_Term__c());
        PDAppsWrapr.PolicyAppTerm = [select name,Applicability_SubType__c,Applicability_Term_Type__c,Applicability_Label__c,Policy_Definition__c,WR_Field_Mapping__c,Applicability_Value__c 
                                        from Policy_Applicability_Term__c where id=:PageUtils.get('id')];

        patId = PDAppsWrapr.PolicyAppTerm.Policy_Definition__c;
        PDAppsWrapr.name = PDAppsWrapr.PolicyAppTerm.Applicability_Label__c;
        system.debug('Exiting StandardController Constructor:PATCreationController'+stdController);  
    }
    
    
    /*******************************************************************
    Purpose: Get the selected records from the lookup window                                               
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void addNewObjectRecord() {
       fieldList = new List<String>();
       String objName = PDAppsWrapr.PolicyAppTerm.Applicability_SubType__c;
       mapApiNameLabel = new Map<String, String>();
       mapApiNameLabel = CustomSettingFactory.getLookUpFieldsWithLabel(objName);
       Set<String> setOfFields = new Set<String>();
       setOfFields.addAll(mapApiNameLabel.keySet());
       setOfFields.remove('Name');
       setOfFields.remove('Limit');
       fieldList.add('Name');
       fieldList.addAll(setOfFields);
       setOfFields.add('Name');
       setOfFields.add('id');  
       fieldValueWrapperRecordList= PATManager.addNewObjectRecordMngr(selectedObjectIds,setOfFields,String.escapeSingleQuotes(objName));  
       system.debug('fieldValueWrapperRecordList is ------>>>>'+fieldValueWrapperRecordList.size() +'---'+fieldValueWrapperRecordList);           
       if(fieldValueWrapperRecordList!= null && fieldValueWrapperRecordList.size() >0) {
           isRendered = true;
            PDAppsWrapr.name = fieldValueWrapperRecordList[0].objMap.get('Name');
       }
       
    }
    
    /*******************************************************************
    Purpose: Renders the pageblock for the selected records                                                  
    Parameters: N/A
    Returns: pageReference 
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global pageReference renderPage(){
        if(StringUtils.equals(PDAppsWrapr.policyAppTerm.Applicability_Term_Type__c, 'Referred by Text') ){
            isRendered= false;
        }else if(!fieldValueWrapperRecordList.isEmpty()){
            isRendered = true;
        }
        return null;        
    }

    /*******************************************************************
    Purpose: Call the Manager class to save the Policy Applicability Term
    Parameters: N/A
    Returns: Pagereference 
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global Pagereference SavePDRecord(){
        if(CrudUtil.isPATUpsertable()){
            try{
                set<String> selectedValSet = new set<String>();
                boolean isExist = false;
                system.debug('fieldValueWrapperRecordList is --->>>'+fieldValueWrapperRecordList);
                system.debug('PAT Id value..--...>'+selectedObjectIds  );
                If(fieldValueWrapperRecordList != null && fieldValueWrapperRecordList.size() > 0)
                {
                        if(fieldValueWrapperRecordList.size() == 1)
                        {
                                fieldValueWrapperRecordList[0].isSelected = true;
                        }
                        isExist = true;
                    for(SObjectFieldValueWrapper sobjPATWrpr : fieldValueWrapperRecordList)
                    {
                        if(sobjPATWrpr.isSelected)
                        {
                            selectedValSet.add(sobjPATWrpr.objectId);
                        }
                    }
                }
                system.debug('selectedValSet is ---->>>'+selectedValSet);
                system.debug('PDAppsWrapr is ---->>>'+PDAppsWrapr);
                return PATManager.savePDRecordMngr(PDAppsWrapr,patId,selectedValSet,isExist);
            } catch(Exception e) {
                PageUtils.addError('Error'+e.getMessage());
                return null;
            }
        }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
        }
    }
    
    /*******************************************************************
    Purpose: Call the Manager class to delete selected Policy Applicability Term
    Parameters: N/A
    Returns: Pagereference 
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global pagereference deletePDRecord(){
        if(CrudUtil.isPATDeletable()){
            try{
                
                list<SObjectFieldValueWrapper>  newfieldValueWrapperRecordList = new list<SObjectFieldValueWrapper>();
                If(fieldValueWrapperRecordList != null && fieldValueWrapperRecordList.size() > 0)
                {
                    system.debug('fieldValueWrapperRecordList is---->>>'+fieldValueWrapperRecordList);
                    integer countSelection = 0;
                    for(SObjectFieldValueWrapper sobjPATWrpr : fieldValueWrapperRecordList)
                    {
                        system.debug('sobjPATWrpr is ------->>>'+sobjPATWrpr);
                        if(sobjPATWrpr.isSelected == true)
                        {
                            countSelection++;
                        }
                        else
                        {
                            newfieldValueWrapperRecordList.add(sobjPATWrpr);
                        }
                    }
                    system.debug('countSelection is --->>>'+countSelection);
                    if(countSelection == 0)
                    {
                        isRendered = true;
                        PageUtils.addError(label.NoRecordSelected);
                        return null;
                    }
                }
                fieldValueWrapperRecordList = new list<SObjectFieldValueWrapper>();
                fieldValueWrapperRecordList.addAll(newfieldValueWrapperRecordList);
                system.debug('fieldValueWrapperRecordList is --->>>>'+fieldValueWrapperRecordList.size()+'---'+fieldValueWrapperRecordList);
                if(fieldValueWrapperRecordList != null && fieldValueWrapperRecordList.size() > 0)
                    isRendered = true;
                else
                    isRendered = false;
                return null;
                
            } catch(Exception e) {
                PageUtils.addError('Error'+e.getMessage());
                return null;
            }
        }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
        }
    }
      
    
}