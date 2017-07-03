/**********************************************************************
 Name:  WarrantyRuleAssociationTriggerHandler()
 Copyright � 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Handler class for the WarrantyRuleCriteria Trigger that redirects the flow to the
right trigger events                                                      
-------                                                             
===============================================================
without sharing explanation:
This is class used to check warranty rule criteria data. 
Admin user only have full access on warranty rule criteria object. 
Dealer/Internal users don’t have permissions for all fields on warranty rule criteria object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita         25/11/2014      INITIAL DEVELOPMENT            
***********************************************************************/

global without sharing class WarrantyRuleCriteriaTriggerHandler extends TriggerHandler{
    global static string NameSpace = SystemUtils.getNameSpace();
    //Constructor
    global WarrantyRuleCriteriaTriggerHandler(){
        system.debug('WarrantyRuleCriteriaTriggerHandler Constructor ');   
    }
    
    /*******************************************************************
    Purpose: Calls validateWarrantyRuleAssociation method before inserting 
             any record                                                
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
   protected override void beforeInsert(){
        system.debug('Entering beforeInsert: ');
        validateWarrantyRuleCriteria(Trigger.new);
    }
    
    /*******************************************************************
    Purpose: Calls validateWarrantyRuleAssociation method before updating 
             any record                                                
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    protected override void beforeUpdate(){
        system.debug('Entering beforeUpdate: ');
        validateWarrantyRuleCriteria(Trigger.new);
    }
    
    /*******************************************************************
    Purpose: validate not to link the Warranty Rule record to a single policy defination record more than once 
             
    Parameters: list of Warranty Rule Association
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/  
    global void validateWarrantyRuleCriteria(List<Warranty_Rule_Criteria__c> objWarrantyRuleCriteriaList){  
        
        if(this.isEnabled('validateWarrantyRuleCriteria')){
         
            Set<String> FieldSet = new Set<String>();
            Set<Id> RelatedWRId = new Set<Id>();
            map<Id,set<string>> RuleToFieldsMap = new map<Id,set<string>>();
            for(Warranty_Rule_Criteria__c tempWRC : objWarrantyRuleCriteriaList)
            {
                RelatedWRId.add(tempWRC.Warranty_Rule__c);
            }
            
            if(FieldSet.size() == 0)
            {
                FieldSet.add('');
            }
            
            String WRCsoql = new SoqlBuilder()
            .selectx(new set<String>{'Id','Name',NameSpace+'Field_API_Name__c',NameSpace+'Criteria_Type__c',NameSpace+'Criteria_Value__c',NameSpace+'Maximum_Value__c','Minimum_Value__c',NameSpace+'Warranty_Rule__c'})
            .fromx(NameSpace+'Warranty_Rule_Criteria__c ')
            .wherex(new AndCondition()
                .add(new SetCondition(NameSpace+'Warranty_Rule__c').inx(new list<Id>(RelatedWRId)))
            )
            .toSoql();
            
            list<Warranty_Rule_Criteria__c> WRCList = database.query(WRCsoql);
            
            if(WRCList != null && WRCList.size() > 0)
            {
                for(Warranty_Rule_Criteria__c tmpwrc : WRCList)
                {
                    string keyValue = '';
                    if(tmpwrc.Criteria_Value__c != null && tmpwrc.Criteria_Value__c != '')
                    {
                        keyValue = tmpwrc.Field_API_Name__c + '-'+ tmpwrc.Criteria_Type__c +'-'+ tmpwrc.Criteria_Value__c;
                    }
                    else if(tmpwrc.Maximum_Value__c != null && tmpwrc.Maximum_Value__c != '' && tmpwrc.Minimum_Value__c != null && tmpwrc.Minimum_Value__c != '')
                    {
                        keyValue = tmpwrc.Field_API_Name__c + '-'+ tmpwrc.Criteria_Type__c +'-'+ tmpwrc.Maximum_Value__c +'-'+ tmpwrc.Minimum_Value__c;
                    }
                    
                    if(RuleToFieldsMap.containsKey(tmpwrc.Warranty_Rule__c))
                    {
                        RuleToFieldsMap.get(tmpwrc.Warranty_Rule__c).add(keyValue);
                    }
                    else
                    {
                        RuleToFieldsMap.put(tmpwrc.Warranty_Rule__c,new set<string>{keyValue});
                    }
                }
            }
            
            for(Warranty_Rule_Criteria__c objWRC : objWarrantyRuleCriteriaList)
            {
                string keyValue = '';
                if(objWRC.Criteria_Value__c != null && objWRC.Criteria_Value__c != '')
                {
                    keyValue = objWRC.Field_API_Name__c + '-'+ objWRC.Criteria_Type__c +'-'+ objWRC.Criteria_Value__c;
                }
                else if(objWRC.Maximum_Value__c != null && objWRC.Maximum_Value__c != '' && objWRC.Minimum_Value__c != null && objWRC.Minimum_Value__c != '')
                {
                    keyValue = objWRC.Field_API_Name__c + '-'+ objWRC.Criteria_Type__c +'-'+ objWRC.Maximum_Value__c +'-'+ objWRC.Minimum_Value__c;
                }
                    
                if(Trigger.isInsert)
                {
                    if(RuleToFieldsMap.get(objWRC.Warranty_Rule__c) != null && RuleToFieldsMap.get(objWRC.Warranty_Rule__c).contains(keyValue))
                    {
                        objWRC.addError(string.format(Label.Validation_for_Duplicate_Rule_Criteria_Insertion, new list<string>{string.valueOf(objWRC.Field_API_Name__c)}));
                    }
                }
                if(Trigger.isUpdate)
                {
                    Warranty_Rule_Criteria__c oldWRCRec = (Warranty_Rule_Criteria__c)Trigger.oldMap.get(objWRC.Id);
                    string OldKeyValue = '';
                    if(oldWRCRec.Criteria_Value__c != null && oldWRCRec.Criteria_Value__c != '')
                    {
                        OldKeyValue = oldWRCRec.Field_API_Name__c + '-'+ oldWRCRec.Criteria_Type__c +'-'+ oldWRCRec.Criteria_Value__c;
                    }
                    else if(oldWRCRec.Maximum_Value__c != null && oldWRCRec.Maximum_Value__c != '' && oldWRCRec.Minimum_Value__c != null && oldWRCRec.Minimum_Value__c != '')
                    {
                        OldKeyValue = oldWRCRec.Field_API_Name__c + '-'+ oldWRCRec.Criteria_Type__c +'-'+ oldWRCRec.Maximum_Value__c +'-'+ oldWRCRec.Minimum_Value__c;
                    }
                
                    if(keyValue != OldKeyValue && RuleToFieldsMap.get(objWRC.Warranty_Rule__c) != null && RuleToFieldsMap.get(objWRC.Warranty_Rule__c).contains(keyValue))
                    {
                        objWRC.addError(string.format(Label.Validation_for_Duplicate_Rule_Criteria_Insertion, new list<string>{string.valueOf(objWRC.Field_API_Name__c)}));
                    }  
                }
            }
        }
    }
}