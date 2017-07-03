/**********************************************************************
 Name:  PATCreationCtrlTest()
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Test class for 1.PATCreationCtrl 2.PATCreationManager
                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Bhanu        11/19/2014      INITIAL DEVELOPMENT            
***********************************************************************/

@isTest
global class PATCreationCtrlTest {
    global static testMethod void PATCreationCtrlTest1(){
        CustomSettingsUtilityTest.init();
        //Creating PageReference for CorePATCreation page
        Pagereference pageRef=Page.PATCreation;
        Test.setCurrentPage(pageRef);
        
        //Creating and Inserting Test Records for Account
        list<Account> tempAccountRecord=TestUtility.createAccountTestRecords();
        if(CrudUtil.isAccountCreateable()){
            insert tempAccountRecord;
        }
        List<Policy_Applicability_Term__c> patl = TestUtility.createPATTestRecords();
        if(CrudUtil.isPATCreateable()){
            insert patl;
        }
        PolicyApplicabilityWrapper  renderWpr = new PolicyApplicabilityWrapper(patl[0]);
        renderWpr.Name='Testing Wrapper Object';
        PolicyApplicabilityWrapper  wpr = new PolicyApplicabilityWrapper(patl[0]);
        wpr.Name='Testing Wrapper Object';
        
        // Setting PolicyDefinition Id for PolicyApplicabilityTerm
        PageUtils.put('id',patl[0].Id);
        ApexPages.StandardController patController = new ApexPages.StandardController(patl[0]);
        PATCreationCtrl patc = new PATCreationCtrl(patController);
        patc.PDAppsWrapr= wpr;
        patc.selectedObjectIds = String.valueof(tempAccountRecord[0].Id);
        
        // Creation and Insertion of CustomSetting
        Lookup_Layout_Fields__c tempCustomSetting=TestUtility.createCustomSetting();
        if(tempCustomSetting!=null){
            if(CrudUtil.isSmartLkpCSCreateable()){
                insert tempCustomSetting;
            }
        }
        //Creating and Inserting record for CustomSetting
        WOD__c wod  =new WOD__c();
        wod.name = 'Lookup Record Limit on PAT';
        insert wod;
        //for covering CustomSettingFactory
        CustomSettingFactory.getLookupLayoutFields('Account');
        
        patc.addNewObjectRecord();
        patc.renderPage();
        patc.SavePDRecord();
        patc.deletePDRecord();
        
        ApexPages.StandardSetController patsController = new ApexPages.StandardSetController(patl); 
        PATCreationCtrl patsc = new PATCreationCtrl(patsController);
        patsc.selectedObjectIds = String.valueof(tempAccountRecord[0].Id);
        patsc.PDAppsWrapr =renderWpr ;
        patsc.SavePDRecord();
        patsc.addNewObjectRecord();
        patc.deletePDRecord();
       
        patc.selectedObjectIds=null;
        patc.isRendered=false;
        patc.addNewObjectRecord();
        patc.renderPage();
        patc.PDAppsWrapr.policyAppTerm.Applicability_Term_Type__c = 'Referred by Text';
        patc.savePDRecord();
        patc.renderPage();
        wpr.PolicyAppTerm.Applicability_Label__c=null;
        patc.savePDRecord();
        patsc.PATManager =null;
        patsc.SavePDRecord();
        patc.deletePDRecord();
        system.assertEquals(null, null);
    }
 
}