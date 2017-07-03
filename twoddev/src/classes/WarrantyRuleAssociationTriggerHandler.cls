/**********************************************************************
 Name:  WarrantyRuleAssociationTriggerHandler()
 Copyright � 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Handler class for the WarrantyRuleAssociationTrigger that redirects the flow to the
right trigger events                                                      
-------                                                             
===============================================================
without sharing explanation:
This is class used to check warranty rule association data. 
Admin user only have full access on warranty rule association object. 
Dealer/Internal users don’t have permissions for all fields on warranty rule association object.

===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Bhanu         25/11/2014      INITIAL DEVELOPMENT            
***********************************************************************/
global without sharing class WarrantyRuleAssociationTriggerHandler extends TriggerHandler{
    //Constructor
    global static string NameSpace = SystemUtils.getNameSpace();
    global WarrantyRuleAssociationTriggerHandler(){
        system.debug('WarrantyRuleAssociationTriggerHandler Constructor ');   
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
        validateWarrantyRuleAssociation(Trigger.new);
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
        validateWarrantyRuleAssociation(Trigger.new);
    }
    
    /*******************************************************************
    Purpose: validate not to link the Warranty Rule record to a single policy defination record more than once 
             
    Parameters: list of Warranty Rule Association
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/  
    global void validateWarrantyRuleAssociation(List<Warranty_Rule_Association__c> wra){  
        if(this.isEnabled('validateWarrantyRuleAssociation')){
            Set<String> setOfWRAFields = new Set<String>{'Id','Name',NameSpace+'Policy_Definition__c',NameSpace+'Warranty_Rule__c'};
            List<String> pdId = new List<String>();
            List<String> wrId = new List<String>();
            for(Warranty_Rule_Association__c wran : wra){
                wrId.add(wran.Warranty_Rule__c);
                pdid.add(wran.Policy_Definition__c);
            }
            System.debug(pdId+'<<<====>>>'+wrId);
            if(ArrayUtils.isEmpty(pdId))
                pdId.add('');
                
            if(ArrayUtils.isEmpty(wrId))
                wrId.add('');
            String soql = new SoqlBuilder()
            .selectx(setOfWRAFields)
            .fromx(NameSpace+'Warranty_Rule_Association__c')
            .wherex(new AndCondition()
                .add(new SetCondition(NameSpace+'Policy_Definition__c').inx(pdId))
                .add(new SetCondition(NameSpace+'Warranty_Rule__c').inx(wrId))
            )
            .toSoql();
            List<Warranty_Rule_Association__c> resultList = database.query(soql);
            System.debug('========>'+resultList);
            for(Warranty_Rule_Association__c wr : wra){
                 if(Trigger.isInsert){
                        if (!resultList.isEmpty()) {    
                            wr.addError(System.Label.ValidateWarrantyRuleAssociationLabel);
                        }  
                    }            
                if(Trigger.isUpdate){
                        Warranty_Rule_Association__c definitionMap = (Warranty_Rule_Association__c)Trigger.oldMap.get(wr.Id);
                        System.debug('the defMap'+definitionMap);
                    for(Warranty_Rule_Association__c rl : resultList){
                        System.debug('the wr-------------->'+wr);
                        System.debug('the rl-------------->'+rl);
                        if(((rl.Policy_Definition__c == wr.Policy_Definition__c) && (rl.Warranty_Rule__c == wr.Warranty_Rule__c)) && (rl.Policy_Definition__c != definitionMap.Policy_Definition__c || rl.Warranty_Rule__c != definitionMap.Warranty_Rule__c)){
                            wr.addError(System.Label.ValidateWarrantyRuleAssociationLabel);
                        }
                    }
                }
            }
        }   
    }
}