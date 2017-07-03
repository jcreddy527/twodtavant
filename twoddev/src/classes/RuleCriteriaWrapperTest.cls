@isTest
private class RuleCriteriaWrapperTest 
{
    static testMethod void testRuleCriteriaWrapper() 
    {
        Warranty_Rule__c testWarrantyRuleRecords = new Warranty_Rule__c();  
        testWarrantyRuleRecords.Name='TestingWarrantyRule';
        insert testWarrantyRuleRecords;
         
                      
        Warranty_Rule_Criteria__c  tempWRC = new Warranty_Rule_Criteria__c();
        //tempWRC.Name = 'testWRC';
        tempWRC.Minimum_Value__c = 'Min';
        tempWRC.Maximum_Value__c = 'Max';
        tempWRC.Criteria_Value__c = 'criteria';
        tempWRC.Criteria_Type__c = 'criteriaType';
        tempWRC.Field_Type__c = 'Ftype';
        //tempWRC.Field_Relation__c = 'FRelation';
        tempWRC.Field_Name__c = 'Fname';
        tempWRC.Field_API_Name__c = 'FApiName';
        tempWRC.Sequence__c = 12;
        tempWRC.Warranty_Rule__c = testWarrantyRuleRecords.Id;
        insert tempWRC;
        
        System.assertNotEquals(null,tempWRC);

        RuleCriteriaWrapper rcw = new RuleCriteriaWrapper(tempWRC);
        
    }
}