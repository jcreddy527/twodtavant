/**********************************************************************
 Name:  WRCtrl
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:  To create Warranty Registration and Warranty Coverages
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Bhanu        15/11/2014      INITIAL DEVELOPMENT            
***********************************************************************/


global with sharing class WRCtrl {
    global boolean isRegisterButtonDisabled { get; set; }
    global Warranty_Registration__c wRegistration{get; set;}
    global Boolean showBlock{get; set;}
    global List<PolicyDefWrapper> policyDefList {get; set;}
    global WarrantyRegisterManager CWRM;
    global List<Policy_Definition__c> pdlist;
    /*******************************************************************
    Purpose: constructor of the class                                       
    Parameters: N/A
    Returns: N/A
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global WRCtrl() {
        policyDefList = new List<PolicyDefWrapper>();
        wRegistration = new Warranty_Registration__c(); 
        pdlist = new List<Policy_Definition__c>();
        isRegisterButtonDisabled = true;
        CWRM = new WarrantyRegisterManager();
    }
    /*******************************************************************
    Purpose: Insert warranty Register and call search method                                       
    Parameters: N/A
    Returns: N/A
    Throws [Exceptions]: yes                                                      
    ********************************************************************/
    global void insertWR(){
        try{
                if(CrudUtil.isWRUpsertable()){
                    Upsert wRegistration; 
                }else{
                    ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                }
                policyDefList = new List<PolicyDefWrapper>();
                pdlist = CWRM.doSearch(wRegistration);
                for(Policy_Definition__c ePD : pdlist) {
                    policyDefList.add(new PolicyDefWrapper(ePD));
                }
                System.debug('=====>'+pdlist);
                if(pdlist.size()>0){
                    showBlock = true;
                    isRegisterButtonDisabled = false;                
                }else{
                    PageUtils.addError('Sorry, No policy definition matching !!');               
                }
        }catch(Exception e) {
            system.debug('Inside catch : '+e.getMessage());
        }
    }
    /*******************************************************************
    Purpose: Insert Warranty Coverage with selected list of Policy Definitions                                      
    Parameters: N/A
    Returns: page - Warranty Register Page
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference doRegister(){
    system.debug('****** doRegister WRCtrl ******');
    try{
        CWRM.doRegisterManager(wRegistration, policyDefList);
         return new Pagereference('/'+wRegistration.id);
        } catch(Exception e) {
            system.debug(e);
            return null;
        }
    }
    /*******************************************************************
    Purpose: Delete Warranty Register                                      
    Parameters: N/A
    Returns: null
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference doCancel() {
        if(wRegistration.id != null){
            if(CrudUtil.isWRDeletable()){
                Delete wRegistration;
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
            }
            wRegistration = new Warranty_Registration__c();
            policyDefList = new List<PolicyDefWrapper>();
            showBlock = false;
        }
        return null;
    }
 
    
    /*******************************************************************
    Purpose: methods to dynamically get all the fields in the WarrantyCreationFS field set for the Warranty Registration custom object                                     
    Parameters: N/A
    Returns: Field Set Members
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global List<Schema.FieldSetMember> getFields() {
        return SObjectType.Warranty_Registration__c.FieldSets.WarrantyCreationFS.getFields();
    }
    
}