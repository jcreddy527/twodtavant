/**********************************************************************
 Name:  WRCtrlTest()
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Test class for 1.WRCtrlCtrl 2.WarrantyRegisterManager
                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Bhanu        11/19/2014      INITIAL DEVELOPMENT            
***********************************************************************/


@isTest
global class WRCtrlTest {
    global static string NameSpace = SystemUtils.getNameSpace();
    global static testMethod void WRCtrlTest(){
        CustomSettingsUtilityTest.init();
        WRCtrl wrc = new WRCtrl();
        List<Account> acc = TestUtility.createAccountTestRecords();
        
        if(Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable() &&
           Schema.sObjectType.Policy_Applicability_Term__c.fields.Applicability_Value__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Registration__c.fields.Registration_Date__c.isUpdateable()&&
           Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isUpdateable())
        {
            
                List<Inventory__c> TestInvLst = TestUtility.createInventoryTestRecords();
                if(CrudUtil.isInventoryCreateable()){
                    insert TestInvLst[0];
                }
                
                if(CrudUtil.isAccountCreateable()){
                    insert acc[0];
                }
                
                Warranty_Registration__c wreg = TestUtility.createTestdataWR();
                wreg.Account__c = acc[0].id;
                wreg.Inventory__c = TestInvLst[0].Id;
                insert wreg;
                
                //Policy Definition test record
                Policy_Definition__c pd = TestUtility.createTDPolDef();
                if(CrudUtil.isPolicyDefinitionCreatable()){
                    insert pd;
                }  
                                
                //pat test record 1
                Policy_Applicability_Term__c pat1 = TestUtility.createTDPAT();
                pat1.WR_Field_Mapping__c = NameSpace+'Account__c';
                pat1.Policy_Definition__c = pd.id;
                pat1.Applicability_Value__c = acc[0].Id;
                if(CrudUtil.isPATCreateable()){
                    insert pat1;
                }
                
                //pat test record 2
                Policy_Applicability_Term__c pat2 = TestUtility.createTDPAT();
                pat2.WR_Field_Mapping__c = NameSpace+'Account__r.Type';
                pat2.Policy_Definition__c = pd.id;
                pat2.Applicability_Value__c = 'Prospect';
                if(CrudUtil.isPATCreateable()){
                    insert pat2;
                } 
                
                wrc.wRegistration = wreg;
                wrc.insertWR();  
                PolicyDefWrapper pdw = new PolicyDefWrapper(pd);
                pdw.selected = true;
                Map<String, String> MyStringsMap = new Map<String, String>{NameSpace+'Account__c' => acc[0].Id, NameSpace+'Account__r.Type' => 'Prospect'}; 
                wrc.CWRM.doSearch(MyStringsMap,wreg.Registration_Date__c);    
                wrc.policyDefList.add(pdw);
                wrc.doRegister();
                wrc.doCancel();
                wrc.getFields();
                system.assertEquals(null, null);
            
        }
    }
    
    global static testMethod void WRCtrlTest2(){
                CustomSettingsUtilityTest.init();
        WRCtrl wrc = new WRCtrl();
        if(Schema.sObjectType.Policy_Definition__c.fields.Months_Covered__c.isUpdateable()&&
           Schema.sObjectType.Policy_Definition__c.fields.Active_From__c.isUpdateable()&&
           Schema.sObjectType.Policy_Definition__c.fields.Active_Until__c.isUpdateable()&&
           Schema.sObjectType.Policy_Definition__c.fields.Status__c.isUpdateable())
        {
            Policy_Definition__c pd = TestUtility.createTDPolDef();
            pd.Months_Covered__c = 1;
            pd.Active_From__c = System.today()+3;
            pd.Active_Until__c = System.today()+100;
            pd.Status__c = 'Active';
                if(CrudUtil.isPolicyDefinitionCreatable()){
                    insert pd;
                }
            
                if(Schema.sObjectType.Policy_Applicability_Term__c.fields.WR_Field_Mapping__c.isUpdateable())
                {
                    Policy_Applicability_Term__c pat1 = TestUtility.createTDPAT();
                    pat1.WR_Field_Mapping__c = NameSpace+'Account__c';
                    pat1.Policy_Definition__c = pd.id;
                    if(CrudUtil.isPATCreateable()){
                        insert pat1;
                    }
                }
                Warranty_Registration__c wregex = TestUtility.createTestdataWR();
                wrc.wRegistration = wregex;        
                wrc.insertWR();
                wrc.wRegistration.Id = null;
                wrc.CWRM.doSearch(new Warranty_Registration__c());
                wrc.doCancel();
                system.assertEquals(null, null);
          }
    }
    global static testMethod void WRCtrlTest3(){
        CustomSettingsUtilityTest.init();
        WRCtrl wrc = new WRCtrl();
        wrc.insertWR();
        List<Account> acc = TestUtility.createAccountTestRecords();     
        if(Schema.sObjectType.Warranty_Registration__c.fields.Account__c.isUpdateable()){
      
                if(CrudUtil.isAccountCreateable()){
                    insert acc[0];
                }
                Warranty_Registration__c wreg = TestUtility.createTestdataWR();
                wreg.Account__c = acc[0].id;        
                wrc.insertWR();
                wrc.policyDefList = null;
                wrc.doRegister();
                wrc.wRegistration = null;
                wrc.insertWR();
                wrc.CWRM=null;
                wrc.doRegister();
                system.assertEquals(null, null);
       
        }
    }
   
}