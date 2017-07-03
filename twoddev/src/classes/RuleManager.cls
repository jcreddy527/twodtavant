global with sharing class RuleManager{
    
    List<SelectOption> ValuePickList;
    String selectedObjectIds;
    List<SelectOption> fieldOption;
    Map<String, Schema.SObjectField> mapField;
    
    
    /*******************************************************************
    Purpose:  to get list of object Names for creating a Rule                                                    
    Parameters: N/A
    Returns: List<SelectOption>
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global List<SelectOption> getObjectList()
    {
        List<SelectOption> objOptions = new List<SelectOption>();
        objOptions.add(new SelectOption('',''));
        objOptions.add(new SelectOption('Account','Account'));
        objOptions.add(new SelectOption('Contact','Contact'));        
        //objOptions.add(new SelectOption('Product2','Product'));
         
          
        Map<String, Schema.SObjectType> mapObj = Schema.getGlobalDescribe();
        for(String objname:mapObj.keySet()){
            Schema.SObjectType sobj = mapObj.get(objname);
            Schema.DescribeSObjectResult descRes = sobj.getDescribe();
            
            if(descRes.isCustom() && !descRes.isCustomSetting()){
                String objLabel = descRes.getLabel();
                objOptions.add(new SelectOption(objName.toUpperCase(),objLabel));
            }
        }
        
        return objOptions;
    }
    
    /*******************************************************************
    Purpose:  to insert/update a Rule and simultaneously creating a new Rule based on condition                                                 
    Parameters: N/A
    Returns: pagereference. to redirect to the same VF again in order to create a new Rule
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference saveRule(Warranty_Rule__c newrule,String methodType){
        
        list<Warranty_Rule__c> WarrantyRuleList = new list<Warranty_Rule__c>();
        WarrantyRuleList.add(newrule);
        
        system.debug('Entering saveAndNewRule method'); 
        try{
            if(CrudUtil.isWRuleUpsertable() && Schema.sObjectType.Warranty_Rule__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.isUpdateable()){
                Database.upsert(WarrantyRuleList);
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
            }
            if(methodType == 'Save'){
                system.debug('Exiting saveRule '); 
                return(new PageReference('/'+newrule.id));
            }
            else{
                system.debug('Exiting saveAndNewRule'); 
                return(Page.ManageRulesPage);
            }   
        }
        catch(Exception e){
            PageUtils.addError(e.getDMLMessage(0));
            return null;
        }
        
    }
    
    
    //RulesCriteriaCtrl
       
    /*******************************************************************
    Purpose: To find the API names of the fields                                                     
    Parameters: N/A
    Returns: pagereference (redirecting to the same page)
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global List<SelectOption> setRCFieldApiName(String selectedFieldName, Warranty_Rule_Criteria__c newRuleCriteria){
        system.debug('Entering setFieldApiName:');
        ValuePickList = new List<SelectOption>();
        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_name__c.isAccessible() &&
            Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_type__c.isAccessible() &&
            Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Related_Object__c.isAccessible()){
                if(selectedFieldName != '' && selectedFieldName != null){
                    newRuleCriteria.Field_API_name__c = selectedFieldName;
                    
                    Schema.sObjectField sobjField = mapField.get(selectedFieldName);
                    Schema.DescribeFieldResult sobjFieldDesc =  sobjField.getDescribe();
                    string FType =  String.valueOf(sobjFieldDesc.getType());
                    
                    newRuleCriteria.Field_type__c = FType;
                    newRuleCriteria.Related_Object__c ='';
                    if('REFERENCE'.equals(FType)){
                        
                        //by aman
                        if(newRuleCriteria.Field_API_name__c=='OwnerId'){
                            newRuleCriteria.Related_Object__c = 'User';
                        }else{
                            newRuleCriteria.Related_Object__c = sobjFieldDesc.getReferenceTo()[0].getDescribe().getName();
                        }
                                                
                    }else if('PICKLIST'.equals(FType)){
                        ValuePickList = new List<SelectOption>();
                        for(Schema.PicklistEntry pe : sobjFieldDesc.getPicklistValues()){
                            ValuePickList.add(new SelectOption(pe.getValue(), pe.getLabel()));
                        }
                    }
                }else{
                    newRuleCriteria.Field_API_name__c='';
                    newRuleCriteria.Field_type__c =''; 
                    newRuleCriteria.Related_Object__c =''; 
                }
                system.debug('Exiting setFieldApiName:');
            }        
            return ValuePickList;
    }  
    
  
    
    /*******************************************************************
    Purpose:  to save a Rule Criteria and simultaneously creating a new Rule Criteria                                                    
    Parameters: N/A
    Returns: pagereference ( redirecting to the same page)
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global PageReference saveRuleCriteria(Warranty_Rule_Criteria__c newRuleCriteria,String methodType){
        system.debug('Entering saveAndNewRuleCriteria:');
        
        list<Warranty_Rule_Criteria__c> WRCList = new list<Warranty_Rule_Criteria__c>();
        WRCList.add(newRuleCriteria);
        
        try{
            if(CrudUtil.isWRuleCriteriaUpsertable()){
                Database.upsert(newRuleCriteria);
            }else{
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
            }
            if(methodType == 'Save'){
                if(ApexPages.hasMessages())
                {
                    PageUtils.addError('error is----'+ApexPages.getMessages());
                }
                return(new PageReference('/'+newRuleCriteria.id));
            }
            else{                               
                newRuleCriteria = new Warranty_Rule_Criteria__c(Warranty_Rule__c= newRuleCriteria.Warranty_Rule__c);
                return(Page.RuleCriteriaPage);                    
            }
        }
        catch(Exception e){
            PageUtils.addError(e.getDMLMessage(0));
            return null;
        }
    }
    
    /*******************************************************************
    Purpose: To get the Name of the selected value from the lookup window                                                    
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global string getSelectedValue(Warranty_Rule_Criteria__c newRuleCriteria,String selectedObjectIds)
    {
        system.debug('selectedObjectIds is ----> '+selectedObjectIds);
        string CValue = '';
        Id selectedObjId = selectedObjectIds;
        
        String soql = new SoqlBuilder()
        .selectx(new Set<String>{'Id','Name'})
        .fromx(newRuleCriteria.Related_Object__c)
        .wherex(new FieldCondition('id').equals(selectedObjId))
        .toSoql();
        
        list<Sobject> CurrentRecords = database.query(soql);
        
        if(CurrentRecords != null && CurrentRecords.size() > 0)
        {
            CValue = string.valueOf(CurrentRecords[0].get('Name'));
        }
        
        return CValue;
    }
    
    /*******************************************************************
    Purpose: To get the selected criteria value while editing a Rule Criteria Record                                                  
    Parameters: name of the Object
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global string getSelectedCriteriaValue(string selectedValue,string selectedFieldType,Warranty_Rule_Criteria__c newRuleCriteria)
    {
        string convertedStr = '';
        if(selectedFieldType == 'DATE')
        {
            convertedStr = string.valueOf(date.parse(selectedValue));
        }
        else if(selectedFieldType == 'DATETIME')
        {
            convertedStr = string.valueOf(datetime.parse(selectedValue));
            convertedStr = convertedStr.replace(' ','T'); // including Timezone T like 2014-11-30T12:54:01
            convertedStr = convertedStr.substring(0,convertedStr.length()-3);
        }
        else if(selectedFieldType == 'REFERENCE')
        {
            convertedStr = getSelectedValue(newRuleCriteria,selectedValue);
        }
        else
        {
            convertedStr = selectedValue;
        }
        
        return convertedStr;
    }
    
    /*******************************************************************
    Purpose: To show all the custom fields of a particular object in the "Field Name" field                                                     
    Parameters: name of the Object
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global List<SelectOption> populateFields(String objType){
        system.debug('Entering populateFields'+objType);
        List<SelectOption> fieldOption= new List<SelectOption>();
        fieldOption.add(new SelectOption('',''));
        
        mapField = DescribeSObjectUtil.getAllFieldDescription(objType);
        
        for(String fieldname:mapField.keySet()){
            Schema.SObjectField sfield = mapField.get(fieldname);
            Schema.DescribeFieldResult descResField = sfield.getDescribe();
            String FTYpe = String.valueOf(descResField.getType());
            if(!'TEXTAREA'.equals(FTYpe)){
                String fieldLabel = descResField.getLabel();
                fieldOption.add(new SelectOption(descResField.getName(),fieldLabel));
            }
        }
        
        system.debug('ExitingpopulateFields'+fieldOption);
        return fieldOption;
    }    
    
    
    
}