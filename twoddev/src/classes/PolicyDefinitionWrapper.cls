/****************************************************************
    PURPOSE: Wrapper Class to store the Policy Definition and the corresponding selection information
****************************************************************/
global with sharing class PolicyDefinitionWrapper
    {
        @AuraEnabled global Policy_Definition__c ObjPolicyDefinition{get; set;}
        @AuraEnabled global Boolean selected{get; set;}
        @AuraEnabled global boolean isDisabled {get;set;}
        global PolicyDefinitionWrapper(Policy_Definition__c objPD)
        {
            ObjPolicyDefinition = objPD;
            selected = false;
            isDisabled = false;
        }
    }