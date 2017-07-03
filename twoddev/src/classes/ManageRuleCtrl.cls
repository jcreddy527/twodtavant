/**********************************************************************
 Name:  ManageRuleCtrl ()
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: For managing a rule, that includes creating,Updating and validating a rule
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        21/10/2014      INITIAL DEVELOPMENT            
***********************************************************************/
global with sharing class ManageRuleCtrl {
 
    global Warranty_Rule__c newrule {get;set;}  
    global String objType {get;set;}
    global List<SelectOption> objOptions {get;global set;}
    global boolean edit {get;set;}
    String ruleId;
    RuleManager objRuleManager;
    
    //Constructor
    global ManageRuleCtrl(Apexpages.StandardController stdcon){
            system.debug('Entering constructor:ManageRuleCtrl ');
            ruleId = stdcon.getId();
            newrule = new Warranty_Rule__c();
            objOptions = new List<SelectOption>();
            edit=false;
            objType = '';
            objRuleManager = new RuleManager();
            
            // Adding Object Type option List
            objOptions = objRuleManager.getObjectList(); 
             
            /* Edit Rule */
            if(ruleId != null){
                edit = true;
                
                //fetching current Rule details
                newrule = (Warranty_Rule__c)DatabaseUtils.query(ruleId);
                if(newrule != null){
                    objtype = newrule.Object_API_Name__c;
                }
            } 
            system.debug('Exiting constructor:ManageRuleCtrl ');
        
    }
   
    /*******************************************************************
    Purpose:  to insert/Update a Rule                                                    
    Parameters: N/A
    Returns: pagereference. to redirect to the rule detail page
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference saveRule(){
        if(CrudUtil.isWRuleUpsertable()){
            system.debug('Entering cosaveRule '+objtype); 
            if(objtype == null || objtype == '' || newrule.Logical_Grouping__c == null || newrule.Logical_Grouping__c == '' || newrule.Logical_Grouping__c == '--None--')
            {
                string msg = label.Validation_for_blank_value_in_Warranty_Rule;
                PageUtils.addError(msg);
                return null;
            }
            if (Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isUpdateable() ){
                newrule.Object_API_Name__c = objtype;
            }
            
            for(SelectOption tempOption : objOptions)
            {
                if(tempOption.getValue() == objtype && Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isUpdateable() )
                { 
                    newrule.Object_Type__c = tempOption.getLabel();
                }
            }
            pagereference pageref = objRuleManager.saveRule(newrule,'save');
            
            return pageref;
        }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
        }
    }
    
    /*******************************************************************
    Purpose:  to insert/update a Rule and simultaneously creating a new Rule                                                    
    Parameters: N/A
    Returns: pagereference. to redirect to the same VF again in order to create a new Rule
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference saveAndNewRule(){
        if(CrudUtil.isWRuleUpsertable()){
            system.debug('Entering saveAndNewRule'+objtype); 
            
            if(objtype == null || objtype == '' || newrule.Logical_Grouping__c == null || newrule.Logical_Grouping__c == '' || newrule.Logical_Grouping__c == '--None--')
            {
                string msg =label.Validation_for_blank_value_in_Warranty_Rule;
                PageUtils.addError(msg);
                return null;
            }
            if (Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isUpdateable() ){
            newrule.Object_API_Name__c = objtype;
            }
            for(SelectOption tempOption : objOptions)
            {
                if(tempOption.getValue() == objtype && Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isUpdateable())
                {
                   
                    newrule.Object_Type__c = tempOption.getLabel();
                    
                }
            }
            edit = false;
            pagereference pageref = objRuleManager.saveRule(newrule,'saveAndNew');
            pageref.setRedirect(true);
            return pageref;
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                return null;
            }
    }
    
}