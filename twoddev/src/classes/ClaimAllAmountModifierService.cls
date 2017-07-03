/**********************************************************************
Name:  ClaimAmountModifierService
Copyright ? 2015  Tavant Technology Inc
==============================================================
===============================================================
Purpose: Class used for calculating the Amount Modifiers
         for the claim payment.
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita Behera        27/08/2015     INITIAL DEVELOPMENT            
***********************************************************************/

global  class ClaimAllAmountModifierService {

    global static string NameSpace = SystemUtils.getNameSpace();
    @InvocableMethod
    global static list<Claim__c> CalculateFinalCost(list<InputWrapper> InputWrapperList)
    {
       List<Claim__c> updatedClaims = new List<Claim__c>();
        List<String> allPaymentConfigurations = new List<String>();
        Set <Id> appPayDefIds = new Set <Id>();
        Set <Id> warrantyProductIds = new Set <Id>();
        //warrantyProductIds.add(null);
        Set <Id> dealerAccountIds = new Set <Id>();
        //dealerAccountIds.add(null);
        Map <Id,Payment_Definitions__c> IdByPayDefs = new Map <Id,Payment_Definitions__c>();
        //added by shambhvi
        Map <Id,Payment_Definitions__c> IdByPayDefs2 = new Map <Id,Payment_Definitions__c>();
        set<string> partGroupIds=new set<string>();
        Map<id,set<string>> DealerGpwithDealer=new Map<id,set<string>>();
        Set<Payment_Modifiers__c> PaymentModifiers = new Set<Payment_Modifiers__c>();     
        //Get all the payment configuration values from the custom setting
        allPaymentConfigurations.addAll((WOD__c.getInstance('All Payment Configurations').Trigger_Value__c).Split(','));
        
        //added by siva
        Boolean enablePDIGroupLogic = WOD__c.getInstance('Enable PDI Group Logic').isTriggered__c;
        
        system.debug('++++++ allPaymentConfigurations +++++'+allPaymentConfigurations);
        
        
        for(InputWrapper iw : InputWrapperList)
           {
           	system.debug('++++++ InputWrapper +++++'+ iw);
               appPayDefIds.add(iw.ApplicablePaymentDefinition);
               warrantyProductIds.add(iw.warrantyProductId);
               dealerAccountIds.add((Id)iw.Claim.get(NameSpace+'Account__c'));
               
           }
        system.debug('appPayDefIds-->' + appPayDefIds );		// claim APD
        system.debug('warrantyProductIds-->' + warrantyProductIds );	// claim WP
        system.debug('dealerAccountIds-->' + dealerAccountIds );	// claim dealer
        
        //below code is added by shambhavi
        for(Group__c gp:[Select id,(Select Account__c,Warranty_Product__c from Group_Members__r where Account__c IN:dealerAccountIds) from Group__c where Object_Name__c=:'Account']){
            set<string> gpmembersList=new set<string>();
            for(Group_Member__c gpMem:gp.Group_Members__r){
                if(gpMem.Account__c !=null){ 
                    gpmembersList.add(gpMem.Account__c);
                }
            } 
            system.debug('++++++ gpmembersList +++++'+ gpmembersList);
            system.debug('++++++ Part gpmembersList +++++'+ gpmembersList);
            if(gpmembersList.size()>0){
            	DealerGpwithDealer.put(gp.id,gpmembersList); 
            }
             
         }
         system.debug('++++++ DealerGpwithDealer +++++'+ DealerGpwithDealer);
         
        
        
        if(appPayDefIds!=null && appPayDefIds.size()>0)
        {
            IdByPayDefs = new Map <Id,Payment_Definitions__c>([SELECT Id,(SELECT Id,Dealer_Group__c,Payment_Definition__c, Name, Type__c, Value__c, Payment_Configuration__r.Claim_Field_Name__c , Dealer__c,Part__c, Priority__c,Active_From__c,Active_Until__c FROM Payment_Modifiers__r WHERE  (Dealer__c IN :dealerAccountIds OR Dealer_Group__c IN:dealerGpwithDealer.keySet()) AND Payment_Configuration__r.Claim_Field_Name__c != 'Parts' ORDER BY Priority__c) FROM Payment_Definitions__c WHERE Id IN :appPayDefIds]);
            //line is added by shambhavi
            //added if else condition
            if(enablePDIGroupLogic == true){
            	IdByPayDefs2 = new Map<Id,Payment_Definitions__c>([SELECT Id,(SELECT Id,Dealer__c,Dealer_Group__c,Payment_Definition__c, Payment_Configuration__r.Claim_Field_Name__c,Payment_Configuration__r.Name FROM Payment_Definition_Items__r WHERE  (Dealer__c IN :dealerAccountIds OR Dealer_Group__c IN:dealerGpwithDealer.keySet())) FROM  Payment_Definitions__c WHERE Id IN :appPayDefIds]);
            }else{	            	           
            	IdByPayDefs2 = new Map<Id,Payment_Definitions__c>([SELECT Id,(SELECT Id, Payment_Definition__c, Payment_Configuration__r.Claim_Field_Name__c,Payment_Configuration__r.Name FROM Payment_Definition_Items__r) FROM  Payment_Definitions__c WHERE Id IN :appPayDefIds]);
        	}
        }
        system.debug('IdByPayDefs-->' +IdByPayDefs );
        system.debug('IdByPayDefs2-->' +IdByPayDefs2 );
        
         for(InputWrapper iw : InputWrapperList)
            {    
            // line by shambhavi
            Set <string> applicablePaymentConfigurations = new Set<string>(); 
            Set <String> applicablepaymentConfigPriority = new Set<String>();
                Claim__c targetSObject = iw.Claim.Clone(true,false);
            
            for(Payment_Definition_Items__c pdi : IdByPayDefs2.get(targetSObject.Applicable_Payment_Definition__c).Payment_Definition_Items__r)
            { 
                if(Schema.sObjectType.Payment_Definition_Items__c.fields.Payment_Configuration__c.isAccessible() && Schema.sObjectType.Payment_Configuration__c.fields.Claim_Field_Name__c.isAccessible())
                {
                    applicablePaymentConfigurations.add(pdi.Payment_Configuration__r.Claim_Field_Name__c);
                }
            }
           
                for(String allpc : allPaymentConfigurations)
                {
                    if(applicablePaymentConfigurations.contains(allpc)){
                        
                        targetSObject.put(NameSpace+'Final_'+ allpc.trim() +'_Cost__c',targetSObject.get(NameSpace+'Total_' + allpc.trim() +'_Cost__c'));     
                    } else{
                        targetSObject.put(NameSpace+'Final_'+ allpc.trim() +'_Cost__c',0.0);        
                    }  
                }
          
                system.debug('targetSobject:::' +targetSObject );
                system.debug(':::iw.ApplicablePaymentDefinition:::' +iw.ApplicablePaymentDefinition );
                system.debug('*****PaymentDefinition******'+IdByPayDefs.get(iw.ApplicablePaymentDefinition));
                system.debug('*****Payment_Modifiers__r*****'+IdByPayDefs.get(iw.ApplicablePaymentDefinition).Payment_Modifiers__r);
                for(Payment_Modifiers__c pmfr : IdByPayDefs.get(iw.ApplicablePaymentDefinition).Payment_Modifiers__r)
                 {
                 	system.debug('**********pmfr-->'+pmfr);
                 	system.debug('**********DealerGpwithDealer-->'+DealerGpwithDealer);
                    // code is added by shambhvi
                     set<string> dealerGroupId=new set<string>();
                     if(DealerGpwithDealer.containsKey(pmfr.Dealer_Group__c)) {
                        dealerGroupId.addAll(DealerGpwithDealer.get(pmfr.Dealer_Group__c));
                     }
                     
                     system.debug('**********dealerGroupId-->'+dealerGroupId);
                     
                     if(Schema.sObjectType.Payment_Modifiers__c.fields.Part__c.isAccessible() &&
                           Schema.sObjectType.Payment_Modifiers__c.fields.Dealer__c.isAccessible() &&
                           // below line added by shambhvi
                           Schema.sObjectType.Payment_Modifiers__c.fields.Dealer_Group__c.isAccessible() &&
                           Schema.sObjectType.Payment_Modifiers__c.fields.Active_From__c.isAccessible() &&
                           Schema.sObjectType.Payment_Modifiers__c.fields.Active_Until__c.isAccessible()
                        )
                        {
                        	// added by chethan
                        	
                            
								if((pmfr.Active_From__c <= (Date)targetSObject.get(NameSpace+'Date_of_Repair__c')) && 
								   (pmfr.Active_Until__c >= (Date)targetSObject.get(NameSpace+'Date_of_Repair__c')) && !applicablepaymentConfigPriority.contains(pmfr.Payment_Configuration__r.Claim_Field_Name__c)
								  ){
									  
                                      applicablepaymentConfigPriority.add(pmfr.Payment_Configuration__r.Claim_Field_Name__c);	
                                      PaymentModifiers.add(pmfr);
								  }
									
                        }
                }
   
   				System.debug('***PaymentModifiers-->'+ PaymentModifiers);
                
                if(PaymentModifiers.size() > 0)
                {
                    Map<String, list<Payment_Modifiers__c>> PMByCC = new Map<String, list<Payment_Modifiers__c>>();
                    Map<double, list<Payment_Modifiers__c>> PMByPriority = new Map<double, list<Payment_Modifiers__c>>();
                    Map<String, list<Payment_Modifiers__c>> PMByType = new Map<String, list<Payment_Modifiers__c>>();
            
                    for(Payment_Modifiers__c pm : PaymentModifiers )
                    {
                    	system.debug('********:pm-->'+ pm);
                        if(Schema.sObjectType.Payment_Modifiers__c.fields.Payment_Configuration__c.isAccessible())
                        {
                        	system.debug('+++++++&&&&&&&&&&&&&********');
                            if(PMByCC.get(pm.Payment_Configuration__r.Claim_Field_Name__c) == null)
                            {
                            	system.debug('$$$$$$$$$$$********');
                                PMByCC.put(pm.Payment_Configuration__r.Claim_Field_Name__c, new List<Payment_Modifiers__c>());
                            }
                            PMByCC.get(pm.Payment_Configuration__r.Claim_Field_Name__c).add(pm);
                        }
                    }
                    
                    system.debug('****PMByCC--->>>>'+ PMByCC);
                    // Interate through each cost category
                    for(String cc : PMByCC.KeySet())
                    {
                    	system.debug('****cc--->>>>'+ cc);
                        // Put the initial values of Total CC cost into Final CC cost    
     
                        // For each Cost Category Group By Priority 
                        for(Payment_Modifiers__c pm : PMByCC.get(cc))
                        {
                        	system.debug('****cc--pm--->>>>'+ pm);
                            if(Schema.sObjectType.Payment_Modifiers__c.fields.Priority__c.isAccessible())
                            {
                                if(PMByPriority.get(pm.Priority__c) == null)
                                {
                                    PMByPriority.put(pm.Priority__c, new List<Payment_Modifiers__c>());
                                }
                                PMByPriority.get(pm.Priority__c).add(pm);
                                system.debug('****PMByPriority--->>>>'+ PMByPriority);
                            }
                       }
                       system.debug('****PMByPriority--->>>>'+ PMByPriority);
                        // Iterate through each priority
                        for(double pr : PMByPriority.keyset())
                        {
                            // For each Priority Group By Type
                             for(Payment_Modifiers__c pm : PMByPriority.get(pr))
                            {
                                if(Schema.sObjectType.Payment_Modifiers__c.fields.Type__c.isAccessible())
                                {
                                    if(PMByType.get(pm.Type__c) == null)
                                    {
                                        PMByType.put(pm.Type__c, new List<Payment_Modifiers__c>());
                                    }
                                    PMByType.get(pm.Type__c).add(pm);
                                }
                            }
                         
                            // Iterate through each Type
                            for(String type : PMByType.keyset())
                            {
                                // For each Type Modify the Amount
                                double value = 0;
                                for(Payment_Modifiers__c pm : PMByType.get(type))
                                {
                                    if(Schema.sObjectType.Payment_Modifiers__c.fields.Value__c.isAccessible())
                                    {
                                        value += pm.Value__c;
                                    }
                                }
                             
                                system.debug(cc + ' ' + pr + ' ' + type + ' ' + value);
                                
                              if(applicablePaymentConfigurations.contains(cc)){
                                    if(type == 'Percentage')
                                    {
                                        targetSObject.put(NameSpace+'Final_'+ cc +'_Cost__c', (DECIMAL.VALUEOF(DOUBLE.VALUEOF(targetSObject.get(NameSpace+'Final_' + cc +'_Cost__c')) * (1 + value/100))).setScale(2) );
                                    }
                                    else if(type == 'Flat')
                                    {
                                        targetSObject.put(NameSpace+'Final_'+ cc +'_Cost__c', (DECIMAL.VALUEOF(DOUBLE.VALUEOF(targetSObject.get(NameSpace+'Final_' + cc +'_Cost__c'))  +  value )).setScale(2) );
                                    }
                              } 
                            }

                            PMByType.clear();
                        }
    
                        PMByPriority.clear();
                    }
                }
                
                updatedClaims.add(targetSObject);
            }
        
         system.debug('updatedClaims :: ' + updatedClaims );
         ClaimFinancialControllerHelper.firstRun = true;  //added by siva      
        return updatedClaims;  
    }
    
    global class InputWrapper{
    
        @InvocableVariable(required=true)
        global id warrantyProductId;
        
        @InvocableVariable(required=true)
        global id ApplicablePaymentDefinition;
        
        @InvocableVariable(required=true)
        global Claim__c claim;
                    
    }  

}