/**********************************************************************
 Name:  ManageRuleLightningCtrlTest()
 Copyright � 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Test class for 1.ManageRuleLightningCtrl
                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION     AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    shridhar        3/17/2017      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class ManageRuleLightningCtrlTest {
    global static string NameSpace = SystemUtils.getNameSpace();

    /*******************************************************************
    PURPOSE:   To test ManageRuleLightningCtrl                                                
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    global static testmethod void ManageRuleLightningCtrlTest() {
        Map < string, list < string >> pkValues;
        map < string, string > objectType;
        Map < String, Schema.SObjectField > mapField;


        Test.startTest();
        /******* Test for getPicklistValues method ********/
        pkValues = ManageRuleLightningCtrl.getPicklistValues();
        set < string > pkOptionSet = new set < string > (pkValues.get('Logical_Grouping__c'));
        List < Schema.PicklistEntry > LogicalGroupingPL = Warranty_Rule__c.sObjectType.getDescribe().fields.getMap().get('Logical_Grouping__c').getDescribe().getPicklistValues();
        string lGroup = LogicalGroupingPL[0].getValue();
        System.assertEquals(true, pkOptionSet.contains(lGroup));

        set < string > rTypeSet = new set < string > (pkValues.get('Rule_Type__c'));
        LogicalGroupingPL = Warranty_Rule__c.sObjectType.getDescribe().fields.getMap().get('Rule_Type__c').getDescribe().getPicklistValues();
        string rType = LogicalGroupingPL[0].getValue();
        System.assertEquals(true, rTypeSet.contains(rType));

        /******* Test for getObjectType method ********/
        objectType = ManageRuleLightningCtrl.getObjectType();
        string obName = new list < string > (objectType.keySet())[0];
        System.assertEquals(true, objectType.keySet().contains('Account'));

        /******* Test for createRecord method ********/
        string newrule = ManageRuleLightningCtrl.createRecord('WarrantyRuleName', lGroup, obName, objectType.get(obName), rType);
        Warranty_Rule__c wr = [SELECT Logical_Grouping__c, Object_API_Name__c, Object_Type__c FROM Warranty_Rule__c WHERE Id =: newrule];
        System.assertEquals(lGroup, wr.Logical_Grouping__c);
        Test.stopTest();
    }
}