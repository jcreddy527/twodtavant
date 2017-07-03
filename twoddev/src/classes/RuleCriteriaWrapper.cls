/**********************************************************************
 Name:  RuleCriteriaWrapper
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Wrapper class for Rule criteria
                                           
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        21/10/2014      INITIAL DEVELOPMENT  
***********************************************************************/

global with sharing class RuleCriteriaWrapper {

    // Id of the warranty rule criteria
    global string RCId{get;set;}
    // Name of the warranty rule criteria
    global string RCName{get;set;}
    // Sequence of the warranty rule criteria under the warranty rule
    global Integer Sequence{get;set;}
    // Field Api Name on the warranty rule criteria
    global string FieldAPIName{get;set;}
    // Field Name on the warranty rule criteria
    global string FieldName{get;set;}
    global string FieldRelation{get;set;}
    //Field Type like NUMBER, DOUBLE, INTEGER, CURRENCY, DATE
    global string FieldType{get;set;}
    // Incase of NUMBER, DOUBLE, INTEGER, CURRENCY, Criteria type like equals, Not Equal To, Greater Than, Greater Or Equal, Less Than, Less Or Equal, Between
    // In case of DATE, criteria type like Equals, Not Equal To, Greater Than, Greater Or Equal, Less Than, Less Or Equal, Between
    global string CriteriaType{get;set;}
    global string CriteriaValue{get;set;}
    global string MaximumValue{get;set;}
    global string MinimumValue{get;set;}
    global string RelatedObject{get;set;}
    global string Rule{get;set;}
    global string RuleObjectType{get;set;} 
    global boolean isPassed{get;set;} 
  
    //Constructor
    global RuleCriteriaWrapper(Warranty_Rule_Criteria__c rc){
        if(rc != null && rc.Id != null){
            this.RCId = rc.Id;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Name.isAccessible())
                this.RCName = rc.Name;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isAccessible())
                this.Sequence = Integer.valueOf(rc.Sequence__c);
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isAccessible())
                this.FieldAPIName = rc.Field_API_Name__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isAccessible())
                this.FieldName = rc.Field_Name__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Relation__c.isAccessible())
                this.FieldRelation = rc.Field_Relation__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Type__c.isAccessible())
                this.FieldType = rc.Field_Type__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Type__c.isAccessible())
                this.CriteriaType = rc.Criteria_Type__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Value__c.isAccessible())
                this.CriteriaValue = rc.Criteria_Value__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Maximum_Value__c.isAccessible())
                this.MaximumValue = rc.Maximum_Value__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Minimum_Value__c.isAccessible())
                this.MinimumValue = rc.Minimum_Value__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Related_Object__c.isAccessible())
                this.RelatedObject = rc.Related_Object__c;            
            this.Rule = rc.Warranty_Rule__c;
            if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.RULE_OBJECT_TYPE__c.isAccessible())
                this.RuleObjectType = rc.RULE_OBJECT_TYPE__c;  
            this.isPassed = false;
        }  
    }
}