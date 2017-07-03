/**********************************************************************
 Name:  RulesCriteriaCtrl
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: For creating and updating a Rule Criteria
                                           
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        21/10/2014      INITIAL DEVELOPMENT  
***********************************************************************/
global with sharing class RulesCriteriaCtrl {

    global Warranty_Rule_Criteria__c newRuleCriteria{get;set;}
    global boolean edit {get;global set;}
    global List<SelectOption> fieldOption{get;global set;}
    global String selectedfieldName {get;set;}
    global String CValue {get;set;}
    global List<SelectOption> ValuePickList{get;global set;}
    global String selectedObjectIds{get;set;}
    global String MinValue {get;set;}
    global string MaxValue {get;set;}
    
    String ruleCriteriaId;
    Map<String, Schema.SObjectField> mapField;
    RuleManager objRuleManager;
    //Constructor
    global RulesCriteriaCtrl(Apexpages.StandardController stdcon){
    
        system.debug('Entering constructor RulesCriteriaController:');
        ruleCriteriaId = stdcon.getId();
        fieldOption= new List<SelectOption>();
        MinValue = '';
        MaxValue = '';
        newRuleCriteria = (Warranty_Rule_Criteria__c)stdcon.getRecord();
        edit=false;
        objRuleManager = new RuleManager();
        
        if(ruleCriteriaId != null){
            edit=true;
            newRuleCriteria = (Warranty_Rule_Criteria__c)DatabaseUtils.query(String.escapeSingleQuotes(ruleCriteriaId));
        }
        
        getRelatedObjectName();
              
        if(ruleCriteriaId != null)
        {
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isAccessible() &&
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isAccessible() && 
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isAccessible() && 
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isAccessible() && 
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Type__c.isAccessible()){
                        selectedfieldName = newRuleCriteria.Field_API_Name__c;
                        ValuePickList = objRuleManager.setRCFieldApiName(String.escapeSingleQuotes(selectedfieldName), newRuleCriteria);
                        MinValue = newRuleCriteria.Minimum_Value__c == null ? '' : objRuleManager.getSelectedCriteriaValue(newRuleCriteria.Minimum_Value__c,newRuleCriteria.Field_Type__c,newRuleCriteria);
                        MaxValue = newRuleCriteria.Maximum_Value__c == null ? '' : objRuleManager.getSelectedCriteriaValue(newRuleCriteria.Maximum_Value__c,newRuleCriteria.Field_Type__c,newRuleCriteria);
                        CValue = newRuleCriteria.Criteria_Value__c == null ? ''  : objRuleManager.getSelectedCriteriaValue(newRuleCriteria.Criteria_Value__c,newRuleCriteria.Field_Type__c,newRuleCriteria);
                }
        }
        
        system.debug('CValue is---'+CValue);
    }
    
    
   
    /*******************************************************************
    Purpose: To find the API names of the fields                                                     
    Parameters: N/A
    Returns: pagereference (redirecting to the same page)
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference setFieldApiName(){
        system.debug('Entering setFieldApiName:');
        selectedfieldName = PageUtils.get('fieldName');
        
        ValuePickList = objRuleManager.setRCFieldApiName(selectedfieldName,newRuleCriteria);
        
        CValue = null;
        return null;
    }
    
    /*******************************************************************
    Purpose:  to save(insert/update) a Rule Criteria                                                    
    Parameters: N/A
    Returns: pagereference (redirecting to the same page)
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference saveRuleCriteria(){
        system.debug('Entering saveRuleCriteria:');
        
        pagereference pageref = null;
        string errorMsg = validateCriteria();
        if(errorMsg != null)
        {
            PageUtils.addError(errorMsg);
            return null;
        }
        else
        {
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isUpdateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isCreateable() &&
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isCreateable() &&
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isCreateable() &&
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isUpdateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isCreateable()){
                    if(newRuleCriteria.Field_Type__c == 'REFERENCE')
                        newRuleCriteria.Criteria_Value__c = selectedObjectIds;
                    else
                        newRuleCriteria.Criteria_Value__c = CValue;
                    if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isCreateable()){  
                    newRuleCriteria.Minimum_Value__c = MinValue;
                    }
                    if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isCreateable()){  
                    newRuleCriteria.Maximum_Value__c = MaxValue;
                    }
                    
                    for(SelectOption tempOption : fieldOption)
                    {
                        if(tempOption.getValue() == selectedfieldName && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isCreateable())
                        {
                            newRuleCriteria.Field_Name__c = tempOption.getLabel();
                        }
                    }
                    
                    pageref = objRuleManager.saveRuleCriteria(newRuleCriteria,'save');
                    if(pageref != null)
                        pageref.setRedirect(true);
                    else
                        pageref = null;
            }
        }
        return pageref;
    }
    
    /*******************************************************************
    Purpose:  to save a Rule Criteria and simultaneously creating a new Rule Criteria                                                    
    Parameters: N/A
    Returns: pagereference ( redirecting to the same page)
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference saveAndNewRuleCriteria(){
        
        pagereference pageref = null;
        string errorMsg = validateCriteria();
        if(errorMsg != null)
        {
            PageUtils.addError(errorMsg);
            return null;
        }
        else
        {
             if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isUpdateable() &&
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Type__c.isUpdateable() && 
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isUpdateable() && 
                Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isUpdateable() ){
                    if(newRuleCriteria.Field_Type__c == 'REFERENCE')
                        newRuleCriteria.Criteria_Value__c = selectedObjectIds;
                    else
                        newRuleCriteria.Criteria_Value__c = CValue;
                    if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isCreateable()){     
                    newRuleCriteria.Minimum_Value__c = MinValue;
                    }
                    if(Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isCreateable()){
                    newRuleCriteria.Maximum_Value__c = MaxValue;
                    }
                    
                    for(SelectOption tempOption : fieldOption)
                    {
                        if(tempOption.getValue() == selectedfieldName && Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isUpdateable() &&  Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isCreateable())
                        {
                            newRuleCriteria.Field_Name__c = tempOption.getLabel();
                        }
                    }
                    
                    pageref = objRuleManager.saveRuleCriteria(newRuleCriteria,'saveAndNew');
                    if(pageref != null)
                        pageref.setRedirect(true);
                    else
                        pageref = null;
            }
        }
        return pageref;
        
    }
    
    /*******************************************************************
    Purpose: To get the Name of the selected value                                                    
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global string validateCriteria()
    {
        string msg = null;
        
        
        if(newRuleCriteria.Criteria_Type__c == null || newRuleCriteria.Criteria_Type__c == '' || selectedfieldName == null || selectedfieldName == '')
        {
            msg = label.Validation_for_invalid_Field_Type_and_Criteria_type_in_Rule_Criteria;
        }
        
        else if((CValue == null || CValue == '') && (MinValue == null || MinValue == '' || MaxValue == null || MaxValue == ''))
        {
            msg = Label.Validation_for_invalid_Criteria_Value_in_Rule_Criteria;
        }

        else if(newRuleCriteria.Criteria_Type__c != '' && newRuleCriteria.Criteria_Type__c != null && newRuleCriteria.Field_Type__c != '' && newRuleCriteria.Field_Type__c != null)
        {
            if((newRuleCriteria.Field_Type__c == 'CURRENCY' || newRuleCriteria.Field_Type__c == 'INTEGER' || newRuleCriteria.Field_Type__c == 'NUMBER' || newRuleCriteria.Field_Type__c == 'DOUBLE' || newRuleCriteria.Field_Type__c == 'DATE' || newRuleCriteria.Field_Type__c == 'DATETIME') && (newRuleCriteria.Criteria_Type__c == 'Contains' || newRuleCriteria.Criteria_Type__c == 'Does Not Contain' || newRuleCriteria.Criteria_Type__c == 'Starts With' || newRuleCriteria.Criteria_Type__c == 'Ends With'))
            {
                msg = string.format(Label.Validation_for_invalid_criteria_type_for_a_Field_Type_in_Rule_Criteria, new list<string> {string.valueOf(newRuleCriteria.Criteria_Type__c),string.valueOf(newRuleCriteria.Field_Type__c)});
            }
            else if((newRuleCriteria.Field_Type__c == 'PICKLIST' || newRuleCriteria.Field_Type__c == 'REFERENCE' || newRuleCriteria.Field_Type__c == 'BOOLEAN') && (newRuleCriteria.Criteria_Type__c != 'Equals' && newRuleCriteria.Criteria_Type__c != 'Not Equal To'))
            {
                msg = string.format(Label.Validation_for_invalid_criteria_type_for_a_Field_Type_in_Rule_Criteria, new list<string> {string.valueOf(newRuleCriteria.Criteria_Type__c),string.valueOf(newRuleCriteria.Field_Type__c)});
            }
            else if((newRuleCriteria.Field_Type__c == 'PHONE' || newRuleCriteria.Field_Type__c == 'STRING' || newRuleCriteria.Field_Type__c == 'ADDRESS' || newRuleCriteria.Field_Type__c == 'URL' || newRuleCriteria.Field_Type__c == 'ID') && (newRuleCriteria.Criteria_Type__c == 'Greater Than' || newRuleCriteria.Criteria_Type__c == 'Greater Or Equal' || newRuleCriteria.Criteria_Type__c == 'Less Than' || newRuleCriteria.Criteria_Type__c == 'Less Or Equal' || newRuleCriteria.Criteria_Type__c == 'Between' ))
            {
                msg = string.format(Label.Validation_for_invalid_criteria_type_for_a_Field_Type_in_Rule_Criteria, new list<string> {string.valueOf(newRuleCriteria.Criteria_Type__c),string.valueOf(newRuleCriteria.Field_Type__c)});
            }
    
            if((newRuleCriteria.Field_Type__c == 'NUMBER' || newRuleCriteria.Field_Type__c == 'DOUBLE' || newRuleCriteria.Field_Type__c == 'CURRENCY' || newRuleCriteria.Field_Type__c == 'INTEGER'))
            {
                try{
                    if(CValue != '' && CValue != null)
                        decimal fldval = decimal.valueOf(CValue);
                    
                    if(MaxValue != '' && MaxValue != null && MinValue != '' && MinValue != null)
                    {
                        decimal maxval = decimal.valueOf(MaxValue);
                        decimal minval = decimal.valueOf(MinValue);
                    }
                }
                catch(exception ex)
                {
                    msg = Label.Valid_Number_Check;
                }
            }
        }
           
        return msg;
    }
    
    
    /*******************************************************************
    Purpose: To get the Name of the selected value                                                    
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void getSelectedValue()
    {
        system.debug('selectedObjectIds is ----> '+selectedObjectIds);
        
        if(selectedObjectIds != null)
        {
            CValue = objRuleManager.getSelectedValue(newRuleCriteria,selectedObjectIds);
        }
    }
    
    
    /*******************************************************************
    Purpose: To get the object type from Rule, to create a Rule Criteria                                                    
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void getRelatedObjectName()
    {
        system.debug('newRuleCriteria is----->'+newRuleCriteria);
        if (Schema.sObjectType.Warranty_Rule__c.fields.Object_API_Name__c.isAccessible()){
            if(newRuleCriteria.Warranty_Rule__c != null)
            {
                Warranty_Rule__c SelectedRule = (Warranty_Rule__c)DatabaseUtils.query(newRuleCriteria.Warranty_Rule__c);
                system.debug('Related Object Name is :::>>>> '+SelectedRule.Object_API_Name__c);
                fieldOption = objRuleManager.populateFields(SelectedRule.Object_API_Name__c);
            }
            else
            {
                fieldOption= new List<SelectOption>();
            }
        }
    }
}