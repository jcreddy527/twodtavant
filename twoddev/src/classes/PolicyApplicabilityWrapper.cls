//Wrappr class
     global with sharing class PolicyApplicabilityWrapper{
        global Policy_Applicability_Term__c PolicyAppTerm{get;set;}
        global String Name{get;set;}
        global PolicyApplicabilityWrapper(Policy_Applicability_Term__c policyAppTerm){
            this.PolicyAppTerm = policyAppTerm;
        }
        
    }