/**********************************************************************
 Name:  PaymentDefinitionTriggerHandler
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Handler class for the PaymentDefinitionTrigger that redirects the 
flow to the right trigger events                                                      
-------                                                             
===============================================================
without sharing explanation:This is class used to check payment definition item data. 
Payment definition Item data is master data. Admin user only have full access on payment definition object. 
Dealer/Internal users don’t have permissions for all fields on payment definition object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        21/10/2014      INITIAL DEVELOPMENT            
   2.0 -    Neethu         31/10/2014      Added the framework
   3.0 -    Vino           06/11/2014      Added logic to validate active 
                                           and default Payment Definition
***********************************************************************/
global without sharing class PaymentDefinitionTriggerHandler extends TriggerHandler{
    global static string NameSpace = SystemUtils.getNameSpace();
    //Constructor
    global PaymentDefinitionTriggerHandler(){
        system.debug('PaymentDefinitionTriggerHandler Constructor ');  
    }

    /*******************************************************************
    Purpose: Insert all mandatory Payment configurator items as payment
             definition items for that particular payment definition                                                     
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    protected override void afterInsert() {
        system.debug('Entering afterInsert: ');
        insertPaymentDefItem(Trigger.new);
    }
    
    /*******************************************************************
    Purpose: Insert all mandatory Payment configurator items as payment
             definition items for that particular payment definition                                                     
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void insertPaymentDefItem(List<Payment_Definitions__c> paymentDefinitionList) {
        system.debug('Entering afterInsert: ');
        if(this.isEnabled('insertPaymentDefItem'))
        {
            list<Payment_Definition_Items__c> paymentDefItemsList = new list<Payment_Definition_Items__c>();
            list<Payment_Configuration__c> paymentConfigurationList = new list<Payment_Configuration__c>();
            
            //Fetching all the mandatory Payment Configurator Items
            String soql = new SoqlBuilder()
            .selectx('Id')
            .selectx(NameSpace+'Is_Mandatory__c')
            .selectx(NameSpace+'Sequence__c')
            .fromx(NameSpace+'Payment_Configuration__c')
            .wherex(new FieldCondition(NameSpace+'Is_Mandatory__c').equals(true))
            .toSoql();
            
            paymentConfigurationList = database.query(soql);

            //Creation of new Payment Definition Items
            if(!paymentConfigurationList.isEmpty())
            {
                for(Payment_Definitions__c pdef: paymentDefinitionList)
                {
                    for(Payment_Configuration__c objPaymentConfig : paymentConfigurationList )
                    {
                            Payment_Definition_Items__c newPDItem = new Payment_Definition_Items__c();
                            if (Schema.sObjectType.Payment_Definition_Items__c.fields.Payment_Configuration__c.isCreateable()){
                            newPDItem.Payment_Configuration__c = objPaymentConfig.Id;
                            }
                            if (Schema.sObjectType.Payment_Definition_Items__c.fields.Payment_Definition__c.isCreateable()){
                            newPDItem.Payment_Definition__c = pdef.Id;
                            }
                            paymentDefItemsList.add(newPDItem);
                       
                    }
                }
            }          
            if(paymentDefItemsList.size() > 0)
            {
                if(CrudUtil.isPDItemsCreateable()){
                    insert paymentDefItemsList;
                }
            } 
            system.debug('Exiting afterInsert:');  
        }
    }
    
    /*******************************************************************
    Purpose: Calls validatePaymentDefinition method before inserting 
             any record                                                
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    protected override void beforeInsert(){
        system.debug('Entering beforeInsert: ');
            validatePaymentDefinition(Trigger.new);
    }
    
    /*******************************************************************
    Purpose: Calls validatePaymentDefinition method before updating 
             any record                                                
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    protected override void beforeUpdate(){
        system.debug('Entering beforeUpdate: ');
            validatePaymentDefinition(Trigger.new);
    }
    
    /*******************************************************************
    Purpose: shows error if one more record with status 'active' and
             isDefault value 'checked' is found in insert or update list                                      
    Parameters: List of Payment_Definition__c
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void validatePaymentDefinition(List<Payment_Definitions__c> paymentDefinitionList){  
        if(this.isEnabled('validatePaymentDefinition')){
            String soql = new SoqlBuilder()
            .selectx('id')
            .fromx(NameSpace+'Payment_Definitions__c')
            .wherex(new AndCondition()
                .add(new FieldCondition(NameSpace+'status__c').equals('active'))
                .add(new FieldCondition(NameSpace+'Is_Default__c').equals(true))
            )
            .toSoql();
          
            List<Payment_Definitions__c> activePaymentDefinitions = database.query(soql);
            System.debug('activePaymentDefinitions -----> '+activePaymentDefinitions );
            if(!activePaymentDefinitions.isEmpty())
            {
                for(Payment_Definitions__c paymentDefinitions : paymentDefinitionList)
                {
                    if(Trigger.isInsert)
                    {
                        if(paymentDefinitions.status__c == 'Active' && paymentDefinitions.Is_Default__c == True)
                            paymentDefinitions.addError(System.Label.ValidatePaymentDefinitionLabel);
                    }
                    if(Trigger.isUpdate)
                    {
                        Payment_Definitions__c definitionMap = (Payment_Definitions__c)Trigger.oldMap.get(paymentDefinitions.Id);
                        if((paymentDefinitions.status__c == 'Active' &&  paymentDefinitions.Is_Default__c == True ) && (paymentDefinitions.status__c != definitionMap.Status__c || paymentDefinitions.Is_Default__c != definitionMap.Is_Default__c))
                        {
                            paymentDefinitions.addError(System.Label.ValidatePaymentDefinitionLabel);
                        }  
                    }
                }       
            }
        }
    }
}