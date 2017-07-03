/**********************************************************************
Name:  ClaimManager 
Copyright � 2014  Tavant Technology Inc
==============================================================
===============================================================
Purpose: To validate a Claim and displaying all eligible Policy Definitions

-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Vinobharathy           17/11/2014      INITIAL DEVELOPMENT     
2.0      Susmita                18/11/2014      IMPLEMENTING ALL BUSINESS LOGIC FOR VALIDATING CLAIM
2.0      Santhosh                13/7/2016      ADDING ONE MORE FIELDS FOR VALIDATION
***********************************************************************/

global with sharing class ClaimManager {
global static string NameSpace = SystemUtils.getNameSpace();    
    /********************************************************************
PURPOSE:   To get Policy Definition Records for the current Claim                                                   
PARAMETERS: N/A
RETURNS: list of RuleWrapper
THROWS [EXCEPTIONS]: N/A                                                         
********************************************************************/
    global list<Policy_Definition__c> findPolicyDefinitionList(Claim__c CurrentClaim){
        //test
        //test
        list<Warranty_Coverages__c> WarrantyCoverageList = new list<Warranty_Coverages__c>();
        list<Policy_Definition__c> finalPolicyDefinitionList = new list<Policy_Definition__c>();
        set<Id> PolicyDefinitionIdSet = new set<Id>();
        Map<Id, Sobject> WRMap;       
        
        //Fetching all the Warranty Registration Records , those are related to the same account as of the current claim
        system.debug('CurrentClaim is --->>'+CurrentClaim);
        if(CurrentClaim.Account__c != null)
        {
            String WRsoql = new SoqlBuilder()
                .selectx('Id')
                .fromx(NameSpace+'Warranty_Registration__c')
                .wherex(new AndCondition()
                        .add(new FieldCondition(NameSpace+'Warranty_Start_Date__c').lessThanOrEqualTo(CurrentClaim.Date_of_Failure__c))
                        .add(new FieldCondition(NameSpace+'Warranty_End_Date__c').greaterThanOrEqualTo(CurrentClaim.Date_of_Failure__c))
                        .add(new FieldCondition(NameSpace+'Inventory__c').equals(CurrentClaim.Inventory__c))
                       )
                .toSoql();
            
            system.debug('WRsoql is ----'+WRsoql);
            WRMap = new Map<Id, Sobject>(database.query(WRsoql));
            system.debug('WRMap is ----'+WRMap.size());
        }
        
        
        //Fetching all the Warranty Coverages coming under those Warranty Registrations     
        if(WRMap != null && WRMap.size() > 0)
        {                                                               
            String WCsoql = new SoqlBuilder()
                .selectx(new Set<String>{'Id',NameSpace+'Policy_Definition__c',NameSpace+'Warranty_Registration__c'})
                .fromx(NameSpace+'Warranty_Coverages__c')
                .wherex(new AndCondition()
                        .add(new SetCondition(NameSpace+'Warranty_Registration__c').inx(new List<Id>(WRMap.keySet())))
                        .add(new FieldCondition(NameSpace+'Policy_Definition__c').notEquals(null))
                        .add(new FieldCondition(NameSpace+'Is_Active__c').Equals(true))
                        .add(new FieldCondition(NameSpace+'Warranty_Start_Date__c').lessThanOrEqualTo(CurrentClaim.Date_of_Failure__c))
                        .add(new FieldCondition(NameSpace+'Warranty_End_Date__c').greaterThanOrEqualTo(CurrentClaim.Date_of_Failure__c))                        
                        .add(new FieldCondition(NameSpace+'Maximum_Unit__c').greaterThanOrEqualTo(CurrentClaim.Units_Run__c))                        
                       )                
                .toSoql();
            
            system.debug('WCsoql with units of measure is ----'+WCsoql);
            WarrantyCoverageList = database.query(WCsoql);
            
            //Fetching Warranty Coverage without any Maxium Unit Limit
            if((WarrantyCoverageList == null || WarrantyCoverageList.size() < 1)&&(CurrentClaim.Units_Run__c==null))
            {
                WCsoql = new SoqlBuilder()
                    .selectx(new Set<String>{'Id',NameSpace+'Policy_Definition__c',NameSpace+'Warranty_Registration__c'})
                    .fromx(NameSpace+'Warranty_Coverages__c')
                    .wherex(new AndCondition()
                            .add(new SetCondition(NameSpace+'Warranty_Registration__c').inx(new List<Id>(WRMap.keySet())))
                            .add(new FieldCondition(NameSpace+'Policy_Definition__c').notEquals(null))
                            .add(new FieldCondition(NameSpace+'Is_Active__c').Equals(true))
                            .add(new FieldCondition(NameSpace+'Warranty_Start_Date__c').lessThanOrEqualTo(CurrentClaim.Date_of_Failure__c))
                            .add(new FieldCondition(NameSpace+'Warranty_End_Date__c').greaterThanOrEqualTo(CurrentClaim.Date_of_Failure__c)) 
                            .add(new FieldCondition(NameSpace+'Maximum_Unit__c').Equals(null))

                           )                
                    .toSoql();
                
                system.debug('WCsoql without units of measure is ----'+WCsoql);
                WarrantyCoverageList = database.query(WCsoql);
            }
            system.debug('WarrantyCoverageList is ----'+ WarrantyCoverageList);                                      
        }
        
        //getting all Policy Definition Ids from the Warranty Coverages
        if(WarrantyCoverageList != null && WarrantyCoverageList.size() > 0)
        {               
            for(Warranty_Coverages__c tempWC : WarrantyCoverageList){
                
                PolicyDefinitionIdSet.add(tempWC.Policy_Definition__c);
                
            }                
        }
        
        finalPolicyDefinitionList = RuleEngine.RunEligibityRules(CurrentClaim,PolicyDefinitionIdSet);
        
        system.debug('finalPolicyDefinitionList is ----->'+finalPolicyDefinitionList);
        
        return finalPolicyDefinitionList;
    }
    
}