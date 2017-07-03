/**********************************************************************
 Name:  Scheduler_RuleEngine
 Copyright Â© 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:
                                           
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION      AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Shambhavi         1/6/2017      INITIAL DEVELOPMENT  
***********************************************************************/
global with sharing class Scheduler_RuleEngine {
      global static string NameSpace = SystemUtils.getNameSpace();  
      static Date DateOfInstallation;
      
      global static list<sObject> RunEligibityRules(sObject currentObject){
        list<RuleWrapper> allRuleWrappers = new list<RuleWrapper>();
        String inventoryId= string.valueOf(currentObject.get('Id'));
        map<Id,set<Id>> RulesToMasterSchIdMap = new map<Id,set<Id>>();
        set<Id> allRuleAssociatedMasterIdSet = new set<Id>();
        string currentObjectType = DatabaseUtils.retrieveObjectName(currentObject.Id);
        
        Inventory__c invList =[SELECT Account__c,Contact__c,Customer__c,Install_Date__c,Inventory__c,Item__c,Model_Number__c,Name,Pre_Owned__c,RecordTypeId,Scrapped__c,Serial_Number__c,Shipment_Date__c,Stolen_inventory__c,Type__c,Units_Run__c,Warranty_End_Date__c,Warranty_Start_Date__c FROM Inventory__c where id=:inventoryId limit 1];                     
        if(invList.Install_Date__c !=null)DateOfInstallation=invList.Install_Date__c;
      
        system.debug('DateOfInstallation--------'+DateOfInstallation);
        List<Master__c> masterSchedular=new List<Master__c>();
        //  if(masterSchedularSet.size() > 0)
        //   {
            String Mastersoql = new SoqlBuilder()
            .selectx(new Set<String>{'Id','Name',+NameSpace+'Active__c',NameSpace+'Warranty_Rule__c'})
            .fromx(NameSpace+'Master__c')
            .wherex(new AndCondition()
            .add(new FieldCondition(NameSpace+'Active__c').Equals(true))
            )
            .toSoql();
            
            system.debug('WRAsoql is ----'+Mastersoql);
            masterSchedular = database.query(Mastersoql); 
            system.debug('masterSchedular is ----'+masterSchedular);   
      //  }
            // Mapping a Rule and the related list of Master__c 
            if(masterSchedular.size() > 0)
            {
                for(Master__c objMaster : masterSchedular)
                {    
                    allRuleAssociatedMasterIdSet.add(objMaster.id);
                    if(RulesToMasterSchIdMap.containsKey(objMaster.Warranty_Rule__c))
                    {
                        RulesToMasterSchIdMap.get(objMaster.Warranty_Rule__c).add(objMaster.id);
                    }
                    else
                    {
                        RulesToMasterSchIdMap.put(objMaster.Warranty_Rule__c,new set<Id>{objMaster.id});
                    }
                }       
            }
             system.debug('sham0---RulesToMasterSchIdMap---'+RulesToMasterSchIdMap);
            //Getting all the Rules using the keySet of the Map
            if(RulesToMasterSchIdMap.size() > 0)
            {
                 //Ex RulesToMasterSchIdMap.keySet() --> set of warranty rule Ids
                //currentObjectType --> Inventory
             
                allRuleWrappers = getRulesList(RulesToMasterSchIdMap.keySet(),currentObjectType);
                system.debug('sham1---'+allRuleWrappers);
            }
          system.debug('currentObject----->'+currentObject+'allRuleWrappers-------->'+allRuleWrappers+'currentObjectType------>'+currentObjectType);
          list<RuleWrapper> validatedRulelist = executeRule(currentObject,allRuleWrappers,currentObjectType);    
          system.debug('sham2---'+validatedRulelist);     
         
           // Fetching all valid Master Scheduler
             set<Id> finalMasterSchedulerIdSet = new set<Id>();
             list<Master__c> finalMasterSchedulerList = new list<Master__c>();
             
              if(validatedRulelist != null && validatedRulelist.size() > 0)
                {
                    for(RuleWrapper objRuleWrapper : validatedRulelist)
                    {  
                        finalMasterSchedulerIdSet.addAll(RulesToMasterSchIdMap.get(objRuleWrapper.RuleId));
                    }
                }
                  system.debug('finalMasterSchedulerIdSet is ------'+finalMasterSchedulerIdSet);
                  
                  if(finalMasterSchedulerIdSet != null && finalMasterSchedulerIdSet.size() > 0)
                        {
                            list<Id> validMSIdList = new list<Id>();
                            validMSIdList.addAll(finalMasterSchedulerIdSet);
                            
                            /*
                                MasterSchedulerFields is a field set defined in MasterScheduler custom object
                            */
                            List<Schema.FieldSetMember> MSFieldSetMemberList= SObjectType.Master__c.FieldSets.MasterSchedulerFields.getFields();
                            set<string> MSFieldSet = new set<String>();
                            
                            for(Schema.FieldSetMember f : MSFieldSetMemberList) {
                                MSFieldSet.add(f.getFieldPath());
                            }
                            
                            
                            /*
                            Now we have all the MasterScheduler, and we have to determine the priority of each MasterScheduler definitions.
                            Query all the MasterScheduler with the fields mentioned in the field set, and order it by the Priority
                            */
                            String MSsoql = new SoqlBuilder()
                            .selectx(MSFieldSet)
                            .fromx(NameSpace+'Master__c')
                            .orderByx(new OrderBy(NameSpace+'Priority__c'))
                            .limitx(1)
                            .wherex(new AndCondition()
                            .add(new SetCondition('Id').inx(validMSIdList))
                            .add(new FieldCondition(NameSpace+'Active_From__c').lessThanOrEqualTo(DateOfInstallation))
                            .add(new FieldCondition(NameSpace+'Active_Until__c').greaterThanOrEqualTo(DateOfInstallation))
                            .add(new FieldCondition(NameSpace+'Active__c').Equals(true))
                            
                            )
                            .toSoql();
                            
                            system.debug('MSsoql is%$%$% ----'+MSsoql);
                            finalMasterSchedulerList = database.query(MSsoql);
                            //This will always return 1, since the limit is given 1
                            system.debug('finalMasterSchedulerList is%$%$% ----'+finalMasterSchedulerList);
                        }
             return finalMasterSchedulerList;
      }
      
    /*******************************************************************
    PURPOSE:   To get all the active Rules and corressponding Rule Criterias                                                   
    PARAMETERS: N/A
    RETURNS: list of CoreRuleWrapper
    THROWS [EXCEPTIONS]: N/A                                                         
    ********************************************************************/
    
    global static list<RuleWrapper> getRulesList(set<Id> RuleIdSet,string objectType){
         system.debug('getRulesList------------');
        list<RuleWrapper> RuleWrapperList = new list<RuleWrapper>();
                                      
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
        system.debug('AllRules'+AllRules);
        
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
    global static list<RuleWrapper> executeRule(sObject CurrentInv,list<RuleWrapper> RuleWrapperList, string objectType)
    {
        system.debug('executeRule--------');
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
        
        system.debug('sham3------'+sObjectFieldSet);
        //Prepare Query to fetch the claim record.
        // with all the field values that are determined from all the warranty rule criterias accross all warranty rules.
        String Soql = new SoqlBuilder()
        .selectx(sObjectFieldSet)
        .fromx(objectType)
        .wherex(new FieldCondition('Id').equals(CurrentInv.Id))
        .toSoql();                                  
        
        system.debug('Soql is------>'+Soql);
        //Store the query result in the Current Claim varible
        CurrentInv = database.query(Soql);
        
        system.debug('CurrentInv---'+CurrentInv);
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
                if(objRuleCriteriaWrap != null && CurrentInv.get(objRuleCriteriaWrap.FieldAPIName) != null && CurrentInv.get(objRuleCriteriaWrap.FieldAPIName) != '')
                {
                    // ValidateRule -> Current Claim Object, and the Warranty Rule Criteria Wrapper
                    // If the warranty rule satifies with the field values on the claim record, then return TRUE
                    system.debug('Sham4----'+CurrentInv);
                    system.debug('Sham5----'+objRuleCriteriaWrap);
                    boolean isPassed = validateRule(CurrentInv,objRuleCriteriaWrap);
                    system.debug('sham6---'+isPassed);
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
    global static boolean validateRule(sObject CurrentInvObj , RuleCriteriaWrapper CurrentRuleCriteriaVal)
    {
        string conditionType = CurrentRuleCriteriaVal.CriteriaType;
        string RCFieldValue = CurrentRuleCriteriaVal.CriteriaValue;
        string MinValue = CurrentRuleCriteriaVal.MinimumValue;
        string MaxValue = CurrentRuleCriteriaVal.MaximumValue;
        string FieldType = CurrentRuleCriteriaVal.FieldType;
        
        // Set the ClaimFieldValue with the value of the claim field value
        string ClaimFieldValue = string.valueOf(CurrentInvObj.get(CurrentRuleCriteriaVal.FieldAPIName));
                
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