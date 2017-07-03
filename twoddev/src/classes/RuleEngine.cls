/**********************************************************************
 Name:  RuleEngine
 Copyright Â© 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:
                                           
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        21/10/2014      INITIAL DEVELOPMENT  
   2.0 -    Susmita        27/08/2015      ADDED orderByx and LimitX clause to Policy Definition query 
***********************************************************************/
global with sharing class RuleEngine {
    global static string NameSpace = SystemUtils.getNameSpace();
    
    /*******************************************************************
    PURPOSE:   To get all the Eligible Policy Definitions for a particular objectType                                                   
    PARAMETERS: Current Claim Record, which needs to be validated with the Rules
    RETURNS: list of Validated CoreRuleWrapper
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    global static list<sObject> RunEligibityRules(sObject currentObject,set<Id> PolicyDefinitionIdSet)
    {
        Date DateOfFailure;
        String ClaimId= string.valueOf(currentObject.get('Id'));
        List<Claim__c> ClaimList= [Select id,inventory__c,Date_Of_Purchase__c from Claim__c where id =:ClaimId limit 1];     
        system.debug('ClaimList-->'+ClaimList);
        
        if(ClaimList != null && ClaimList[0].Date_Of_Purchase__c != null && ClaimList[0].inventory__c==null){
             DateOfFailure= Date.valueof(currentObject.get(NameSpace+'Date_of_Purchase__c'));
        }
        else{
            DateOfFailure= Date.valueof(currentObject.get(NameSpace+'Date_of_Failure__c'));
        }
        
        //Date DateOfFailure= Date.valueof(currentObject.get(NameSpace+'Date_of_Failure__c'));
        list<Warranty_Rule_Association__c> RuleAssociationList = new list<Warranty_Rule_Association__c>();
        map<Id,set<Id>> RulesToPolicyDefinitionIdMap = new map<Id,set<Id>>();
        list<RuleWrapper> allRuleWrappers = new list<RuleWrapper>();
        string currentObjectType = DatabaseUtils.retrieveObjectName(currentObject.Id);
        set<Id> allRuleAssociatedPDIdSet = new set<Id>();
        
        // from Policy Definition Id set, getting all Rule Associations
        if(PolicyDefinitionIdSet.size() > 0)
        {
            String WRAsoql = new SoqlBuilder()
            .selectx(new Set<String>{'Id','Name',+NameSpace+'Is_Active__c',NameSpace+'Policy_Definition__c',NameSpace+'Warranty_Rule__c'})
            .fromx(NameSpace+'Warranty_Rule_Association__c')
            .wherex(new AndCondition()
            .add(new SetCondition(NameSpace+'Policy_Definition__c').inx(new list<Id>(PolicyDefinitionIdSet)))
            .add(new FieldCondition(NameSpace+'Is_Active__c').Equals(true))
            )
            .toSoql();
            
            system.debug('WRAsoql is ----'+WRAsoql);
            RuleAssociationList = database.query(WRAsoql);
            system.debug('RuleAssociationList is ----'+RuleAssociationList.size()); 
        }
        
        // Mapping a Rule and the related list of Policy Definitions
        if(RuleAssociationList.size() > 0)
        {
            for(Warranty_Rule_Association__c objWRA : RuleAssociationList)
            {
                allRuleAssociatedPDIdSet.add(objWRA.Policy_Definition__c);
                if(RulesToPolicyDefinitionIdMap.containsKey(objWRA.Warranty_Rule__c))
                {
                    RulesToPolicyDefinitionIdMap.get(objWRA.Warranty_Rule__c).add(objWRA.Policy_Definition__c);
                }
                else
                {
                    RulesToPolicyDefinitionIdMap.put(objWRA.Warranty_Rule__c,new set<Id>{objWRA.Policy_Definition__c});
                }
            }
        }
        
        system.debug('RuleToPolicyDefinitionIdMap is ::::>>>>>'+RulesToPolicyDefinitionIdMap);
                
        //Getting all the Rules using the keySet of the Map
        if(RulesToPolicyDefinitionIdMap.size() > 0)
        {
            //Ex RulesToPolicyDefinitionIdMap.keySet() --> set of warranty rule Ids
            // currentObjectType --> Claim__c
            allRuleWrappers = RuleEngine.getRulesList(RulesToPolicyDefinitionIdMap.keySet(),currentObjectType);
        }
        
        //get all validated Rules
        //currentObject -> Claim Object
        // All Rule Wrappers -> List of Warranty Rule along with the Warranty Rule Criteria by sequence map
        //currentyObjectType --> Claim__c
        list<RuleWrapper> validatedRulelist =RuleEngine.executeRule(currentObject,allRuleWrappers,currentObjectType);
        
        // Fetching all valid Policy Definitions
        set<Id> finalPolicyDefinitionIdSet = new set<Id>();
        list<Policy_Definition__c> finalPolicyDefinitionList = new list<Policy_Definition__c>();
        
        /*
        If the list of warranty rules that are validated against the claim and passed, i.e. the logical grouping and the warranty rule criterias are satisfied
        with the claim values.
        */
        if(validatedRulelist != null && validatedRulelist.size() > 0)
        {	system.debug('i am here');
            for(RuleWrapper objRuleWrapper : validatedRulelist)
            {
                //Add all the policy definition Ids of the passed warranty rules into a set 
                finalPolicyDefinitionIdSet.addAll(RulesToPolicyDefinitionIdMap.get(objRuleWrapper.RuleId));
            }
        }
        
        system.debug('finalPolicyDefinitionIdSet is ------>>>'+finalPolicyDefinitionIdSet);
        //If there are any policy definitions returned by the passed warranty rules
        if(finalPolicyDefinitionIdSet != null && finalPolicyDefinitionIdSet.size() > 0)
        {
            list<Id> validPDIdList = new list<Id>();
            validPDIdList.addAll(finalPolicyDefinitionIdSet);
            
            /*
                PolicyFields is a field set defined in policy definition custom object
            */
            List<Schema.FieldSetMember> PDFieldSetMemberList= SObjectType.Policy_Definition__c.FieldSets.PolicyFields.getFields();
            set<string> PDFieldSet = new set<String>();
            
            for(Schema.FieldSetMember f : PDFieldSetMemberList) {
                PDFieldSet.add(f.getFieldPath());
            }
            
            PDFieldSet.add('Id');
            PDFieldSet.add('Name');
            
            
            /*
            Now we have all the policy defintions, and we have to determine the priority of each policy definitions.
            Query all the policy definitions with the fields mentioned in the field set, and order it by the Priority
            */
            String PDsoql = new SoqlBuilder()
            .selectx(PDFieldSet)
            .fromx(NameSpace+'Policy_Definition__c')
            .orderByx(new OrderBy(NameSpace+'Priority__c'))
            .limitx(1)
            .wherex(new AndCondition()
            .add(new SetCondition('Id').inx(validPDIdList))
            .add(new FieldCondition(NameSpace+'Active_From__c').lessThanOrEqualTo(DateOfFailure))
            .add(new FieldCondition(NameSpace+'Active_Until__c').greaterThanOrEqualTo(DateOfFailure))
            .add(new FieldCondition(NameSpace+'Status__c').Equals('Active'))
            
            )
            .toSoql();
            
            system.debug('PDsoql is ----'+PDsoql);
            finalPolicyDefinitionList = database.query(PDsoql);
            //This will always return 1, since the limit is given 1
            system.debug('finalPolicyDefinitionList is ----'+finalPolicyDefinitionList.size());
        }
        /*
        If the warranty rules has not returned any policy definitions.
        Find out all the policy definitions that have no warranty rules
        And find out the high priority policy among those
        */
        else
        {
            
            set<Id> finalPDIdSet = new set<Id>();
            for(Id pdId : PolicyDefinitionIdSet)
            {
                //if this policy definition have warranty rules
                if(allRuleAssociatedPDIdSet != null && allRuleAssociatedPDIdSet.size() > 0 && allRuleAssociatedPDIdSet.contains(pdId))
                {}
                else
                {
                    //If the policy definition has no warranty rules
                    finalPDIdSet.add(pdId);
                }
            }
            
            //If there are policy definitions that have no warranty rules.
            //Find out the high priority policy
            If(finalPDIdSet != null && finalPDIdSet.size() > 0)
            {	system.debug('------i am ------');
                list<Id> validPDIdList = new list<Id>();
                validPDIdList.addAll(finalPDIdSet);
                
                List<Schema.FieldSetMember> PDFieldSetMemberList= SObjectType.Policy_Definition__c.FieldSets.PolicyFields.getFields();
                set<string> PDFieldSet = new set<String>();
                
                for(Schema.FieldSetMember f : PDFieldSetMemberList) {
                    PDFieldSet.add(f.getFieldPath());
                }
                
                PDFieldSet.add('Id');
                PDFieldSet.add('Name');
                String PDsoql = new SoqlBuilder()
                .selectx(PDFieldSet)
                .fromx(NameSpace+'Policy_Definition__c')
                .orderByx(new OrderBy(NameSpace+'Priority__c'))
                .limitx(1)
                .wherex(new AndCondition()
                .add(new SetCondition('Id').inx(validPDIdList))
                /*.add(new FieldCondition(NameSpace+'Active_From__c').lessThanOrEqualTo(DateOfFailure))
                .add(new FieldCondition(NameSpace+'Active_Until__c').greaterThanOrEqualTo(DateOfFailure))*/
                .add(new FieldCondition(NameSpace+'Status__c').Equals('Active'))
                
                )
                .toSoql();
                
                system.debug('PDsoql is ----'+PDsoql);
                finalPolicyDefinitionList = database.query(PDsoql);
            }
            system.debug('finalPolicyDefinitionList is ----'+finalPolicyDefinitionList.size());
        }
        // Return the policy definition.
        return finalPolicyDefinitionList;
        
    }
     
    /*******************************************************************
    PURPOSE:   To get all the active Rules and corressponding Rule Criterias                                                   
    PARAMETERS: N/A
    RETURNS: list of CoreRuleWrapper
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    
    global static list<RuleWrapper> getRulesList(set<Id> RuleIdSet,string objectType){
    
        list<RuleWrapper> RuleWrapperList = new list<RuleWrapper>();
                                       
        // Build a soql to fetch all warranty rule criteria 
        // using the warranty rule ID.
        /*
        Find all the Warranty Rule Criterias for the given Warranty Rule Id
        Where the warranty rule is enabled, and the object_API_Name is equal to the 
        api type of the object in question. Here it is claim__c.
        */                             
        String WRsoql = new SoqlBuilder()
        .selectx(new set<String> {'Id','Name',NameSpace+'Enabled__c',NameSpace+'Logical_Grouping__c',NameSpace+'No_Of_Rule_Criteria__c',NameSpace+'Object_API_Name__c',NameSpace+'Object_Type__c',NameSpace+'Rule_Type__c'})
        .selectx(
          new SoqlBuilder()
          .selectx(new Set<String>{'Name', NameSpace+'Sequence__c',NameSpace+'Field_API_Name__c', NameSpace+'Field_Name__c', NameSpace+'Field_Relation__c', NameSpace+'Field_Type__c',NameSpace+'Criteria_Type__c', NameSpace+'Criteria_Value__c', NameSpace+'Maximum_Value__c', NameSpace+'Minimum_Value__c', NameSpace+'Related_Object__c', NameSpace+'Warranty_Rule__c', NameSpace+'RULE_OBJECT_TYPE__c'})
          .fromx(NameSpace+'Warranty_Rule_Criterias__r'))
        .fromx(NameSpace+'Warranty_Rule__c')
        .wherex(new AndCondition()
        .add(new SetCondition('Id').inx(new list<Id>(RuleIdSet)))
        .add(new FieldCondition(NameSpace+'Enabled__c').Equals(true))
        .add(new FieldCondition(NameSpace+'Object_API_Name__c').Equals(objectType))
        )
        .toSoql();                                  
        
        system.debug('WRsoql is------>'+WRsoql);
        list<Warranty_Rule__c> AllRules = database.query(WRsoql);
        
        for(Warranty_Rule__c objRule: AllRules )
        {
            RuleWrapper objRuleWrap= new RuleWrapper(objRule, objRule.Warranty_Rule_Criterias__r);
            RuleWrapperList.add(objRuleWrap);
        }
        
        system.debug('Value of RuleWrapperList is ----->'+RuleWrapperList);
        
        return RuleWrapperList;
    }
    
    /*******************************************************************
    PURPOSE:   To get all the validated Rules for a particular Claim                                                   
    PARAMETERS: Current Claim Record, which needs to be validated with the Rules
    RETURNS: list of Validated CoreRuleWrapper
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    global static list<RuleWrapper> executeRule(sObject CurrentClaim,list<RuleWrapper> RuleWrapperList, string objectType)
    {
        
        list<RuleWrapper> ValidatedRuleList = new list<RuleWrapper>();
        set<string> sObjectFieldSet = new set<string>{'Id','Name'};
        
        //Iterate through each warranty rule
        for(RuleWrapper objRuleWrap : RuleWrapperList)
        {
            //Iterate through each warranty rule criteria of warranty rule
            for(RuleCriteriaWrapper objRuleCriteriaWrap : objRuleWrap.RuleCriteriaMap.values())
            {
                //If the field api name on the Warranty rule criteria is not null
                if(objRuleCriteriaWrap.FieldAPIName != null && objRuleCriteriaWrap.FieldAPIName != '')
                    //Add that field api name in the field set
                    //note: Id and Name are pre-added above.
                    sObjectFieldSet.add(objRuleCriteriaWrap.FieldAPIName);
            }
        }
        
        //Prepare Query to fetch the claim record.
        // with all the field values that are determined from all the warranty rule criterias accross all warranty rules.
        String Soql = new SoqlBuilder()
        .selectx(sObjectFieldSet)
        .fromx(objectType)
        .wherex(new FieldCondition('Id').equals(CurrentClaim.Id))
        .toSoql();                                  
        
        system.debug('Soql is------>'+Soql);
        //Store the query result in the Current Claim varible
        CurrentClaim = database.query(Soql);
        
        for(RuleWrapper objRuleWrap : RuleWrapperList)
        {
            string LogicalCondition = objRuleWrap.LogicalGrouping;
            integer totalCounter = 0;
            integer CheckCounter = 0; 
            system.debug('Total no of Rule Criteria is :::::>>> '+objRuleWrap.RuleCriteriaMap.values().size());
            system.debug('Warranty Rule Criterias by sequence :::::>>> '+objRuleWrap.RuleCriteriaMap);
            
            //Iterate through all the warranty rule criteria 
            //Here sequence doesnot matter.
            for(RuleCriteriaWrapper objRuleCriteriaWrap : objRuleWrap.RuleCriteriaMap.values())
            {
                // Increment totalcounter
                totalCounter++;
                /*
                if Warranty Rule Criteria is not null, which is impossible. AND
                If the field value of the claim that is mentioned on the warranty rule criteria is not null AND
                If the field value of the claim that is mentioned on the warranty rule criteria is blank 
                */
                if(objRuleCriteriaWrap != null && CurrentClaim.get(objRuleCriteriaWrap.FieldAPIName) != null && CurrentClaim.get(objRuleCriteriaWrap.FieldAPIName) != '')
                {
                    // ValidateRule -> Current Claim Object, and the Warranty Rule Criteria Wrapper
                    // If the warranty rule satifies with the field values on the claim record, then return TRUE
                    boolean isPassed = validateRule(CurrentClaim,objRuleCriteriaWrap);
                    //If it is TRUE, that increment the checkcounter by 1
                    // Obviously, check counter will be either less or equal to the total counter of the warranty rule criteria
                        if(isPassed)
                           CheckCounter++;
                }
                
            }
            system.debug('totalCounter is ::::>>> '+totalCounter+'<<<<:::: CheckCounter is ::::>>>>'+CheckCounter);
            /*If the logical condition on the warranty rule is AND
                CheckCounter is greater than 0, means there are few warranty rule criterias that is passed or satisfies with the claim AND
                total counter is greater than 0, means there are warranty rule criterias that we have evaluated AND
                Checkcounter is equal to the total counter, means all warranty rule criterias are satisfied with the field values on the claim record
            */
            if(LogicalCondition == 'AND' && CheckCounter > 0 && totalCounter > 0 && CheckCounter == totalCounter  )
            {
                // add the warranty rule into that validated Rule List, since all the warranty rule criteria has been satisfied and the logical grouping on the 
                // warranty rule is 'AND' 
                ValidatedRuleList.add(objRuleWrap);
            }
            /*
            if the logical condition of the warranty rule is 'OR' AND
            checkcounter is greater than 0, means there is atleast on warranty rule criteria that satisfied/matches with the claim record field values AND
            CheckCounter is less than or equal to the total counter, (This is useless, because it will always be true)
            */
            else if(LogicalCondition == 'OR' && CheckCounter > 0 && CheckCounter <= totalCounter)
            {
                //Add the warranty rule into the validated rule list
                ValidatedRuleList.add(objRuleWrap);
            }
        }
        
        system.debug('value of ValidatedRuleList is :::::>>> '+ValidatedRuleList);
        //Return the list of validated warranty rules
        return ValidatedRuleList;
    }
    
    /*******************************************************************
    PURPOSE: To check the condition mentioned in the rule criteria with the current Claim                                                    
    PARAMETERS: A particular Fieldvalue of the Current Claim, condition/Operation Type,Criteriavalue mentioned in the RuleCriteria, Type of the Field
    RETURNS: True, if both the values will meet the condition. Else returns false.
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    global static boolean validateRule(sObject CurrentClaimObj , RuleCriteriaWrapper CurrentRuleCriteriaVal)
    {
        string conditionType = CurrentRuleCriteriaVal.CriteriaType;
        string RCFieldValue = CurrentRuleCriteriaVal.CriteriaValue;
        string MinValue = CurrentRuleCriteriaVal.MinimumValue;
        string MaxValue = CurrentRuleCriteriaVal.MaximumValue;
        string FieldType = CurrentRuleCriteriaVal.FieldType;
        
        // Set the ClaimFieldValue with the value of the claim field value
        string ClaimFieldValue = string.valueOf(CurrentClaimObj.get(CurrentRuleCriteriaVal.FieldAPIName));
                
        //intialize the boolean isPassed variable with the value set to false 
        boolean isPassed = false;
        
        //if the Field Type on the Warranty rule criteria is either number, double, integer or currency
        if(FieldType == 'NUMBER' || FieldType == 'DOUBLE' || FieldType == 'INTEGER' || FieldType == 'CURRENCY')
        {
            // Convert the claim field value to decimal
            decimal ClaimFieldDecValue = decimal.valueOf(ClaimFieldValue);
            
            //If the condition type is equal & the decimal value of warranty rule criteria value is same as the claim field value
            // set the isPassed to true.
            if('Equals'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDecValue != null){
                    if(decimal.valueOf(RCFieldValue) == ClaimFieldDecValue){
                        isPassed = true;
                    }
                }
            }
            //If the condition type is Not Equal To & the decimal value of warranty rule criteria value is not same as the claim field value
            // set the isPassed to true.
            else if('Not Equal To'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDecValue != null){
                    if(decimal.valueOf(RCFieldValue) != ClaimFieldDecValue){
                        isPassed = true;
                    }
                }
            }
            //If the condition type is Greater Than & the decimal value of warranty rule criteria value is Greater Than the claim field value
            // set the isPassed to true.
            else if('Greater Than'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDecValue != null){
                    if(ClaimFieldDecValue > decimal.valueOf(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            //If the condition type is Greater Or Equal & the decimal value of warranty rule criteria value is Greater Or Equal to the claim field value
            // set the isPassed to true.
            else if('Greater Or Equal'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDecValue != null){
                    if(ClaimFieldDecValue >= decimal.valueOf(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            //If the condition type is Less Than & the decimal value of warranty rule criteria value is Less Than to the claim field value
            // set the isPassed to true.
            else if('Less Than'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDecValue != null){
                    if(ClaimFieldDecValue < decimal.valueOf(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            //If the condition type is Less Or Equal & the decimal value of warranty rule criteria value is Less Or Equal to the claim field value
            // set the isPassed to true.
            else if('Less Or Equal'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDecValue != null){
                    if(ClaimFieldDecValue <= decimal.valueOf(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            //If the condition type is between & the decimal value of claim field value is in-between the minimum value and the maximum value
            // of the warranty rule criteria
            // set the isPassed to true.
            else if('Between'.equals(conditionType)){
                if(MinValue != null && MaxValue != null && ClaimFieldDecValue != null){
                    if(ClaimFieldDecValue >= decimal.valueOf(MinValue) && ClaimFieldDecValue <= decimal.valueOf(MaxValue)){
                        isPassed = true;
                    }
                }
            }
            
        }
        else if(FieldType == 'DATE')
        {
            system.debug('ClaimFieldValue is----'+ClaimFieldValue);
            date ClaimFieldDateValue = date.valueOf(ClaimFieldValue);
            
            system.debug('two dates are :::>>'+RCFieldValue+'-------'+ClaimFieldDateValue);
            if('Equals'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(date.parse(RCFieldValue) == ClaimFieldDateValue){
                        isPassed = true;
                    }
                }
            }
            else if('Not Equal To'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(date.parse(RCFieldValue) != ClaimFieldDateValue){
                        isPassed = true;
                    }
                }
            }
            else if('Greater Than'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue > date.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Greater Or Equal'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue >= date.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Less Than'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue < date.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Less Or Equal'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue <= date.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Between'.equals(conditionType)){
                if(MinValue != null && MaxValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue >= date.parse(MinValue) && ClaimFieldDateValue <= date.parse(MaxValue)){
                        isPassed = true;
                    }
                }
            }
            
        }
        else if(FieldType == 'DATETIME')
        {
            system.debug('ClaimFieldValue is----'+ClaimFieldValue);
            datetime ClaimFieldDateValue = datetime.valueOf(ClaimFieldValue);
            
            system.debug('two dates are :::>>'+RCFieldValue+'-------'+ClaimFieldDateValue);
            if('Equals'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(datetime.parse(RCFieldValue) == ClaimFieldDateValue){
                        isPassed = true;
                    }
                }
            }
            else if('Not Equal To'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(datetime.parse(RCFieldValue) != ClaimFieldDateValue){
                        isPassed = true;
                    }
                }
            }
            else if('Greater Than'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue > datetime.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Greater Or Equal'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue >= datetime.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Less Than'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue < datetime.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Less Or Equal'.equals(conditionType)){
                if(RCFieldValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue <= datetime.parse(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Between'.equals(conditionType)){
                if(MinValue != null && MaxValue != null && ClaimFieldDateValue != null){
                    if(ClaimFieldDateValue >= datetime.parse(MinValue) && ClaimFieldDateValue <= datetime.parse(MaxValue)){
                        isPassed = true;
                    }
                }
            }
            
        }
        else //if(FieldType == 'STRING' || FieldType == 'REFERENCE' || FieldType == 'PICKLIST')
        {
            if('Equals'.equals(conditionType)){
                if(RCFieldValue!=null && ClaimFieldValue!=null){
                    if(RCFieldValue.equals(ClaimFieldValue) || RCFieldValue.equalsIgnoreCase(ClaimFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Not Equal To'.equals(conditionType)){
                if(RCFieldValue!=null && ClaimFieldValue!=null){
                    if(!RCFieldValue.equals(ClaimFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Contains'.equals(conditionType)){
                if(RCFieldValue!=null && ClaimFieldValue!=null){
                    system.debug(RCFieldValue + '<--contains check-->'+ClaimFieldValue);
                    if(ClaimFieldValue.contains(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Does not Contain'.equals(conditionType)){
                if(RCFieldValue!=null && ClaimFieldValue!=null){
                    if(!ClaimFieldValue.contains(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Starts With'.equals(conditionType)){
                if(RCFieldValue!=null && ClaimFieldValue!=null){
                    if(ClaimFieldValue.startsWith(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
            else if('Ends With'.equals(conditionType)){
                if(RCFieldValue!=null && ClaimFieldValue!=null){
                    if(ClaimFieldValue.endsWith(RCFieldValue)){
                        isPassed = true;
                    }
                }
            }
        }
        
        system.debug('value of isPassed is :::::: >>>'+isPassed);
        return isPassed;
    }
    
}