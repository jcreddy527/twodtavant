/**********************************************************************
 Name:  ClaimAmountModifierService
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Class used for calculating the Amount Modifiers for the claim payment.
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Arun Kumar Anala        27/08/2015     INITIAL DEVELOPMENT            
***********************************************************************/

global  class ClaimPartAmountModifierService {
    global static string NameSpace = SystemUtils.getNameSpace();
    @InvocableMethod
    global static list<Claim_Part__c> CalculateFinalCost(list<InputWrapper> InputWrapperList)
    {
        List<String> allPaymentConfigurations = new List<String>();
        Set <Id> appPayDefIds = new Set <Id>();
        Set <Id> warrantyProductIds = new Set <Id>();
        //warrantyProductIds.add(null);
        Set <Id> dealerAccountIds = new Set <Id>();
        //dealerAccountIds.add(null);
        Map <Id,Payment_Definitions__c> IdByPayDefs = new Map <Id,Payment_Definitions__c>();
        Set<Payment_Modifiers__c> PaymentModifiers = new Set<Payment_Modifiers__c>();
        List<Claim_Part__c> updatedClaimParts = new List<Claim_Part__c>();
        // variable added by chethan
        Map <Id,Payment_Definitions__c> IdByPayDefs2 = new Map <Id,Payment_Definitions__c>();
        Map<id,set<string>> partGpwithPart=new Map<id,set<string>>();
        Map<id,set<string>> dealerGpwithDealer=new Map<id,set<string>>();
        String pdId;
        
        //Get all the payment configuration values from the custom setting
        allPaymentConfigurations.add('Parts');
        system.debug('++++++ allPaymentConfigurations +++++'+ allPaymentConfigurations);
        
        //added by siva
        Boolean enablePDIGroupLogic = WOD__c.getInstance('Enable PDI Group Logic').isTriggered__c;
        
        
        for(InputWrapper iw : InputWrapperList)
        {
               appPayDefIds.add(iw.ApplicablePaymentDefinition);
               warrantyProductIds.add(iw.warrantyProductId);
               dealerAccountIds.add((Id)iw.claimPart.get(NameSpace+'Account__c'));
        }
        system.debug('input warpper'+InputWrapperList);
        system.debug('Parts appPayDefIds-->' + appPayDefIds );      // claim APD
        system.debug('Parts warrantyProductIds-->' + warrantyProductIds );  // claim WP
        system.debug('Parts dealerAccountIds-->' + dealerAccountIds );  // claim dealer
        
        // code is added by chethan       
        for(Group__c gp:[Select id,(Select Account__c,Warranty_Product__c from Group_Members__r where Warranty_Product__c IN:warrantyProductIds) from Group__c where Object_Name__c=:'Warranty_Product__c']){
            set<string> gpmembersList=new set<string>();
            for(Group_Member__c gpMem:gp.Group_Members__r){
                system.debug('$$$$$$$$$$$==Parts gpMem ##'+gpMem);
                if(gpMem.Warranty_Product__c !=null){ 
                    gpmembersList.add(gpMem.Warranty_Product__c);
                }
            } 
            system.debug('++++++ Part gpmembersList +++++'+ gpmembersList);
            if(gpmembersList.size()>0){
                partGpwithPart.put(gp.id,gpmembersList);   
            }
            
        }
        system.debug('++++++ Part partGpwithPart +++++'+ partGpwithPart);
        
        //Added by siva
        for(Group__c gp:[Select id,(Select Id,Account__c,Warranty_Product__c from Group_Members__r where Account__c IN:dealerAccountIds) from Group__c where Object_Name__c=:'Account']){
            set<string> gpmembersList=new set<string>();            
            for(Group_Member__c gpMem:gp.Group_Members__r){
                system.debug('$$$$$$$$$$$==Parts gpMem ##'+gpMem);
                if(gpMem.Account__c !=null){ 
                    gpmembersList.add(gpMem.Account__c);
                }
            }
            system.debug('++++++ Part gpmembersList +++++'+ gpmembersList);
            if(gpmembersList.size()>0){
                dealerGpwithDealer.put(gp.id,gpmembersList);   
            }
            
            
        }
        system.debug('++++++ Dealer group with dealer +++++'+ dealerGpwithDealer);        
           
        
        
        if(appPayDefIds!=null && appPayDefIds.size()>0)
        {
            IdByPayDefs = new Map <Id,Payment_Definitions__c>([SELECT Id,(SELECT Id, Name, Type__c, Value__c, Payment_Configuration__r.Claim_Field_Name__c , Dealer__c,Dealer_Group__c,Part__c, Priority__c,Active_From__c,Active_Until__c,Part_Group__c FROM Payment_Modifiers__r WHERE (Part__c IN :warrantyProductIds OR Part_Group__c IN:partGpwithPart.keySet()) AND (Dealer__c IN :dealerAccountIds OR Dealer_Group__c IN:dealerGpwithDealer.keySet()) AND Payment_Configuration__r.Claim_Field_Name__c = 'Parts' ORDER BY Priority__c) FROM Payment_Definitions__c WHERE Id IN :appPayDefIds]);
            //line is added by chethan
            //added if else condition
            if(enablePDIGroupLogic == true){
                IdByPayDefs2 = new Map<Id,Payment_Definitions__c>([SELECT Id,(SELECT Id, Payment_Definition__c,Dealer__c,Dealer_Group__c, Payment_Configuration__r.Claim_Field_Name__c,Payment_Configuration__r.Name FROM Payment_Definition_Items__r WHERE  (Dealer__c IN :dealerAccountIds OR Dealer_Group__c IN:dealerGpwithDealer.keySet())) FROM  Payment_Definitions__c WHERE Id IN :appPayDefIds]);
            }
            else{                          
                IdByPayDefs2 = new Map<Id,Payment_Definitions__c>([SELECT Id,(SELECT Id, Payment_Definition__c, Payment_Configuration__r.Claim_Field_Name__c,Payment_Configuration__r.Name FROM Payment_Definition_Items__r) FROM  Payment_Definitions__c WHERE Id IN :appPayDefIds]);
            }
        }
        system.debug('Parts IdByPayDefs-->' + IdByPayDefs );
        system.debug('Parts IdByPayDefs2-->' + IdByPayDefs2 );
        
        for(InputWrapper iw : InputWrapperList)
        {   
            
                 system.debug('++++++++++++12345'+iw);
                 PaymentModifiers.clear(); 
                // line by chethan
                Set <string> applicablePaymentConfigurations = new Set<string>();
                Set <String> applicablepaymentConfigPriority = new Set<String>();
                Claim_Part__c targetSObject = iw.claimPart.Clone(true,false);
                system.debug('targetSObject-%%%->'+targetSObject);
                
                //changed for test class on 17th March 2017
                if(Test.isRunningTest()){
                    pdId = String.valueOf(targetSObject.Applicable_Payment_Definition__c).substring(0, 15);
                }else{
                    pdId = targetSObject.Applicable_Payment_Definition__c;
                }
                
                for(Payment_Definition_Items__c pdi : IdByPayDefs2.get(pdId).Payment_Definition_Items__r)
                { 
                    System.debug('--->Parts pdi -->'+ pdi);
                    if(Schema.sObjectType.Payment_Definition_Items__c.fields.Payment_Configuration__c.isAccessible() && Schema.sObjectType.Payment_Configuration__c.fields.Claim_Field_Name__c.isAccessible())
                    {
                        applicablePaymentConfigurations.add(pdi.Payment_Configuration__r.Claim_Field_Name__c);
                        System.debug('*****Parts applicablePaymentConfigurations ******'+ applicablePaymentConfigurations);
                    }
                }
            
                System.debug('+++++ Parts applicablePaymentConfigurations ******'+ applicablePaymentConfigurations);
                
                System.debug('---> Parts allPaymentConfigurations -->'+ allPaymentConfigurations);
                for(String allpc : allPaymentConfigurations)
                {
                    System.debug('---> Parts allpc -->'+ allpc);
                    if(applicablePaymentConfigurations.contains(allpc)){
                        system.debug('********* Parts exists!');
                        // Put the initial values of Total CC cost into Final CC cost
                        targetSObject.put(NameSpace+'Final_'+ allpc.trim() +'_Cost__c',targetSObject.get(NameSpace+'Total_' + allpc.trim() +'_Cost__c'));
                    } else{
                        targetSObject.put(NameSpace+'Final_'+ allpc.trim() +'_Cost__c',0.0);        
                    }     
                }
           
                system.debug('Parts targetSobject:::' +targetSObject );   //installed part
                system.debug('*****Payment_Modifiers__r*****'+IdByPayDefs.get(iw.ApplicablePaymentDefinition).Payment_Modifiers__r);
                for(Payment_Modifiers__c pmfr : IdByPayDefs.get(iw.ApplicablePaymentDefinition).Payment_Modifiers__r)
                {
                    System.debug('***===============*** '+pmfr) ;
                    System.debug('***===============*** '+partGpwithPart) ;
                    System.debug('***===============*** '+pmfr.Part_Group__c) ;
                    
                    // code is added by chethan
                    set<string> partGroupId=new set<string>();
                    if(partGpwithPart.containsKey(pmfr.Part_Group__c)) {
                       partGroupId.addAll(partGpwithPart.get(pmfr.Part_Group__c));
                    }
                    
                    System.debug('+++++ partGroupId ---> '+partGroupId) ;   //Group Account Ids
                    
                    if(Schema.sObjectType.Payment_Modifiers__c.fields.Part__c.isAccessible() &&
                       // below line added by chethan
                       Schema.sObjectType.Payment_Modifiers__c.fields.Part_Group__c.isAccessible() &&
                       Schema.sObjectType.Payment_Modifiers__c.fields.Dealer__c.isAccessible() &&
                       Schema.sObjectType.Payment_Modifiers__c.fields.Active_From__c.isAccessible() &&
                       Schema.sObjectType.Payment_Modifiers__c.fields.Active_Until__c.isAccessible()
                    )
                    {
                        system.debug('++++++++++++'+iw.warrantyProductId); 
                        set<String> gpmemberids = new set<String>();
                        if(pmfr.Part_Group__c!=null){
                            if(partGpwithPart.get(pmfr.Part_Group__c) != null){
                            gpmemberids.addAll(partGpwithPart.get(pmfr.Part_Group__c));
                            system.debug('++++++++++++123'+gpmemberids); 
                            }
                        }
                        
                        set<String> gpDealermemberids = new set<String>();
                        if(pmfr.Dealer_Group__c!=null){
                            if(dealerGpwithDealer.get(pmfr.Dealer_Group__c) != null){
                            gpDealermemberids.addAll(dealerGpwithDealer.get(pmfr.Dealer_Group__c));
                            system.debug('++++++++++++123'+gpDealermemberids);      
                            }
                        }
                                                                 
                        // added by chethan                       
                        if((pmfr.Active_From__c <= (Date)targetSObject.get(NameSpace+'Date_of_Repair__c')) && 
                           (pmfr.Active_Until__c >= (Date)targetSObject.get(NameSpace+'Date_of_Repair__c')) &&
                           (((pmfr.Part__c == iw.warrantyProductId)) ||
                            gpmemberids.contains(iw.warrantyProductId)) &&
                            ((pmfr.Dealer__c==(Id)targetSObject.get(NameSpace+'Account__c')) ||
                            (gpDealermemberids.contains((Id)targetSObject.get(NameSpace+'Account__c')))) &&
                           !applicablepaymentConfigPriority.contains(pmfr.Payment_Configuration__r.Claim_Field_Name__c) && iw.claimPart.Type__c!='Miscellaneous Part'){
                                applicablepaymentConfigPriority.add(pmfr.Payment_Configuration__r.Claim_Field_Name__c);
                                PaymentModifiers.add(pmfr);
                                system.debug('pmfr applied1 ' + pmfr.Id);
                        }     
                    }
                    //PaymentModifiers = IdByPayDefs.get((Id)targetSObject.get('Applicable_Payment_Definition__c')).Payment_Modifiers__r;
                }
                System.debug('***Parts PaymentModifiers-->'+PaymentModifiers);
                
                System.debug('+++++ Parts Payment Modifiers size : ' + PaymentModifiers.size());
                if(PaymentModifiers.size() > 0)
                {
                    Map<String, list<Payment_Modifiers__c>> PMByCC = new Map<String, list<Payment_Modifiers__c>>();
                    Map<double, list<Payment_Modifiers__c>> PMByPriority = new Map<double, list<Payment_Modifiers__c>>();
                    Map<String, list<Payment_Modifiers__c>> PMByType = new Map<String, list<Payment_Modifiers__c>>();
            
                    for(Payment_Modifiers__c pm : PaymentModifiers )
                    {
                        //system.Debug(pm.Payment_Configuration__r.Claim_Field_Name__c);
                        //system.Debug(PMByCC.get(pm.Payment_Configuration__r.Claim_Field_Name__c) );
                        if(Schema.sObjectType.Payment_Modifiers__c.fields.Payment_Configuration__c.isAccessible())
                        {
                            if(PMByCC.get(pm.Payment_Configuration__r.Claim_Field_Name__c) == null)
                            {
                                PMByCC.put(pm.Payment_Configuration__r.Claim_Field_Name__c, new List<Payment_Modifiers__c>());
                            }
                            PMByCC.get(pm.Payment_Configuration__r.Claim_Field_Name__c).add(pm);
                        }
                    }

                    //System.debug(PMByCC.KeySet());
                    //System.debug(PMByCC.Values());

                    // Interate through each cost category
                    for(String cc : PMByCC.KeySet())
                    {
                        // Put the initial values of Total CC cost into Final CC cost    
                
                       // system.debug('Total Cost -->' + targetSObject.get('Total_' + cc +'_Cost__c') );
                       // system.debug('Final Cost -->' + targetSObject.get('Final_' + cc +'_Cost__c') );
                        // For each Cost Category Group By Priority 
                        for(Payment_Modifiers__c pm : PMByCC.get(cc))
                        {
                            if(Schema.sObjectType.Payment_Modifiers__c.fields.Priority__c.isAccessible())
                            {
                                if(PMByPriority.get(pm.Priority__c) == null)
                                {
                                    PMByPriority.put(pm.Priority__c, new List<Payment_Modifiers__c>());
                                }
                                PMByPriority.get(pm.Priority__c).add(pm);
                            }
                       }
                        //System.debug(cc);
                        //System.debug(PMByPriority.keyset());
        
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
                            //System.debug(cc + '  ' +pr);
                            //System.debug(PMByType.keyset());

                            // Iterate through each Type
                            for(String type : PMByType.keyset())
                            {
                                // For each Type Modify the Amount
                                double value = 0;
                                for(Payment_Modifiers__c pm : PMByType.get(type))
                                {
                                    value += pm.Value__c;
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
                updatedClaimParts.add(targetSObject);
            }
        system.debug('the claim parst'+updatedClaimParts);
        ClaimFinancialControllerHelper.firstRun = true;  //added by siva      
        return updatedClaimParts;
        
        
    }
    
    global class InputWrapper{
    
        @InvocableVariable(required=false)
        global id warrantyProductId;
        
        @InvocableVariable(required=true)
        global id ApplicablePaymentDefinition;
        
        @InvocableVariable(required=true)
        global Claim_Part__c claimPart;
                    
    }  

}