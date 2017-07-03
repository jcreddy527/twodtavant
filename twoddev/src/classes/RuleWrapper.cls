/**********************************************************************
 Name:  RuleWrapper
 Copyright © 2014  Tavant Technology Inc
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
***********************************************************************/
global with sharing class RuleWrapper {
  
    // Id of the warranty rule
    global string RuleId{get;set;}
    //Name of the warranty rule
    global string RuleName{get;set;}
    //Is the warranty rule enabled
    global boolean Enabled{get;set;}
    //Type of warranty rule
    global string RuleType{get;set;}
    // Object type associated with the warranty rule ex: Claim__c
    global string ObjectType{get;set;}
    // Logical Grouping of the warranty rule
    global string LogicalGrouping{get;set;}
    //To hold the warranty rule criteria of the warranty rule by Sequence.
    global Map<Integer, RuleCriteriaWrapper > RuleCriteriaMap{get;set;} 
    
    global boolean isPassed{get;set;} 
  
    //Constructor
    global RuleWrapper (Warranty_Rule__c rule, list<Warranty_Rule_Criteria__c> RuleCriteriaList){
        if(rule!=null){
            // Id of the warranty rule
            this.RuleId = rule.Id;
            //Name of the warranty rule
            if (Schema.sObjectType.Warranty_Rule__c.fields.name.isAccessible())            
                this.RuleName = rule.Name;
            //Is the warranty rule enabled
            if (Schema.sObjectType.Warranty_Rule__c.fields.Enabled__c.isAccessible()) 
                this.Enabled = rule.Enabled__c;
            //Type of warranty rule
            if (Schema.sObjectType.Warranty_Rule__c.fields.Rule_Type__c.isAccessible()) 
                this.RuleType = rule.Rule_Type__c;
            // Object type associated with the warranty rule
            if (Schema.sObjectType.Warranty_Rule__c.fields.Object_Type__c.isAccessible()) 
                this.ObjectType = rule.Object_Type__c;
            // Logical Grouping of the warranty rule
            if (Schema.sObjectType.Warranty_Rule__c.fields.Logical_Grouping__c.isAccessible()) 
                this.LogicalGrouping = rule.Logical_Grouping__c; 
            //To hold the warranty rule criteria of the warranty rule by Sequence.
            //Hopefully the sequence associated with the warranty rule are unique.
            this.RuleCriteriaMap = new Map<Integer, RuleCriteriaWrapper>();
            for(Warranty_Rule_Criteria__c rc : RuleCriteriaList){
                RuleCriteriaWrapper rcw = new RuleCriteriaWrapper(rc);
                RuleCriteriaMap.put(rcw.Sequence, rcw);
            }
        }
       
    }
}