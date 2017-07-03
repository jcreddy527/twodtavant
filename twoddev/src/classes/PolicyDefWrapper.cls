global with sharing class PolicyDefWrapper{    
        global Policy_Definition__c pd {get; set;}
        global Boolean selected {get; set;}

        global PolicyDefWrapper(Policy_Definition__c pdw) {
            pd = pdw;
            selected = false;
        }
    }