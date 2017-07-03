/**********************************************************************
 Name:  RuleCriteriaLightningCmpContrTest()
 Copyright � 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Test class for 1.RuleCriteriaLightningCmpContr
                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION     AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    shridhar        3/16/2017      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class RuleCriteriaLightningCmpContrTest{
    global static string NameSpace = SystemUtils.getNameSpace();

    /*******************************************************************
    PURPOSE:   To test RuleCriteriaLightningCmpContr
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    global static testmethod void RuleCriteriaLightningCmpContrTest() {
        CustomSettingsUtilityTest.init();
        list < Warranty_Rule_Criteria__c > testWarrantyRuleCriteriaList = TestUtility.createWarrantyRuleCriteriaTestRecords();
        String objPrefix = SObjectType.Warranty_Rule_Criteria__c.Name.substringBefore(NameSpace + 'Warranty_Rule_Criteria__c');
        Test.startTest();

        if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_Name__c.isUpdateable() &&
            Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Field_API_Name__c.isUpdateable() &&
            Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Criteria_Type__c.isUpdateable()) {
            //Preparing records for Picklist type
            testWarrantyRuleCriteriaList[0].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[0].Field_API_Name__c = objPrefix + NameSpace + 'Claim_Type__c';
            testWarrantyRuleCriteriaList[0].Criteria_Type__c = 'Contains';
            testWarrantyRuleCriteriaList[0].Minimum_Value__c = '1';
            testWarrantyRuleCriteriaList[0].Maximum_Value__c = '1';
            testWarrantyRuleCriteriaList[0].Criteria_Value__c = 'Parts';

            //Preparing records for reference type
            testWarrantyRuleCriteriaList[1].Field_Name__c = 'Account';
            testWarrantyRuleCriteriaList[1].Field_API_Name__c = objPrefix + NameSpace + 'Account__c';
            testWarrantyRuleCriteriaList[1].Criteria_Type__c = 'Equals';

            testWarrantyRuleCriteriaList[2].Field_Name__c = 'Claim Type';
            testWarrantyRuleCriteriaList[2].Field_API_Name__c = objPrefix + NameSpace + 'Claim_Type__c';
            testWarrantyRuleCriteriaList[2].Criteria_Type__c = '';
            testWarrantyRuleCriteriaList[2].Field_Type__c = '';
            testWarrantyRuleCriteriaList[2].Maximum_Value__c = '1';
            testWarrantyRuleCriteriaList[2].Criteria_Value__c = 'Parts';

            try {
                if (CrudUtil.isWRuleCriteriaCreateable()) {
                    insert testWarrantyRuleCriteriaList;
                }
            } catch (Exception e) {
                system.debug('Exception--' + e);
            }

            /*******Preparing standard constructor ********/
            ApexPages.StandardSetController stdController1 = new ApexPages.StandardSetController(testWarrantyRuleCriteriaList);
            RuleCriteriaLightningCmpContr testController1 = new RuleCriteriaLightningCmpContr(stdController1);


            List<Schema.PicklistEntry> CriteriaTypePL = Warranty_Rule_Criteria__c.sObjectType.getDescribe().fields.getMap().get('Criteria_Type__c').getDescribe().getPicklistValues();
            Warranty_Rule_Criteria__c wrc = [SELECT Sequence__c,Warranty_Rule__c, Warranty_Rule__r.Name, Warranty_Rule__r.Object_API_Name__c FROM Warranty_Rule_Criteria__c WHERE Id =: testWarrantyRuleCriteriaList[0].id];
            Map<String, Schema.SObjectField> mapField;

            /******* Test for getlistValues method ********/
            Map < string, list < string >> optionsMap = RuleCriteriaLightningCmpContr.getlistValues(testWarrantyRuleCriteriaList[0].Warranty_Rule__c);
            System.assertEquals(wrc.Warranty_Rule__r.Object_API_Name__c, optionsMap.get('Object Name')[0]);

            /******* Test for getFieldNames method ********/
            Map < string, string> fieldOption = RuleCriteriaLightningCmpContr.getFieldNames(wrc.Warranty_Rule__c);
            mapField = DescribeSObjectUtil.getAllFieldDescription(wrc.Warranty_Rule__r.Object_API_Name__c);
            list<string> keyList = new list<string>(mapField.keySet());         
            System.assertEquals(fieldOption.get(mapField.get(keyList[0]).getDescribe().getLabel()), mapField.get(keyList[0]).getDescribe().getName());
            
            /******* Test for getPicklistValues method ********/
            Map<string, string> pkValues = RuleCriteriaLightningCmpContr.getPicklistValues('Warranty_Rule_Criteria__c', 'Criteria_Type__c');
            System.assertEquals(CriteriaTypePL[0].getValue(), pkValues.get(CriteriaTypePL[0].getLabel()));

            /******* Test for getfieldDetails method ********/            
            RuleCriteriaLightningCmpContr.getfieldDetails('Claim__c', 'Claim_Status__c');
            RuleCriteriaLightningCmpContr.getfieldDetails('Claim__c', 'Date_of_Failure__c');
            RuleCriteriaLightningCmpContr.getfieldDetails('Claim__c', 'DupInventoryCheck__c');
            RuleCriteriaLightningCmpContr.getfieldDetails('Claim__c', 'Id');
            RuleCriteriaLightningCmpContr.getfieldDetails('Claim__c', 'CreatedDate');
            RuleCriteriaLightningCmpContr.getfieldDetails('Claim__c', 'Applicable_Policy__c');
            
            System.assertEquals('String', RuleCriteriaLightningCmpContr.getfieldDetails('Claim__c', 'Name'));

            /******* Test for getReferenceName method ********/            
            System.assertEquals('Policy_Definition__c', RuleCriteriaLightningCmpContr.getReferenceName('Claim__c', 'Applicable_Policy__c'));

            /******* Test for createRecord method for negative Scenario ********/
            string newRecord = RuleCriteriaLightningCmpContr.createRecord(null, 1.2, 'Name', 'Name', 'str1ing', CriteriaTypePL[0].getLabel(), 'CriteriaValue123');          
            String[] arrTest = newRecord.split('::'); 
            System.assertEquals('ERROR', arrTest[0]);       

            /******* Test for createRecord method for positive Scenario ********/
            newRecord = RuleCriteriaLightningCmpContr.createRecord(testWarrantyRuleCriteriaList[0].Warranty_Rule__c, 1.2, 'Name', 'Name', 'string', CriteriaTypePL[0].getLabel(), 'CriteriaValue123');          
            arrTest = newRecord.split('::'); 
            wrc = [SELECT Criteria_Value__c,Field_API_Name__c,Field_Name__c, Warranty_Rule__c FROM Warranty_Rule_Criteria__c WHERE Id =: arrTest[1]];
            system.debug('===='+wrc );
            System.assertEquals(testWarrantyRuleCriteriaList[0].Warranty_Rule__c, wrc.Warranty_Rule__c);
        }
        Test.stopTest();
    }
}