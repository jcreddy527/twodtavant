/**********************************************************************
 Name:  TWODLicenseManagementControllerTest 
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for TWODLicenseManagementController                      
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Sainath 10/19/2016             
***********************************************************************/
@isTest
private class LicenseManagementControllerTest {

           static testmethod void testTWODLicenseManagementController(){
            CustomSettingsUtilityTest.init();
            WOD__c objCustomSettings = new WOD__c();
            objCustomSettings.isTriggered__c = false;
            objCustomSettings.Trigger_Value__c = 'Name,Profile.Name,UserRole.Name,UserType,IsActive,LastLoginDate,Profile.UserLicense.Name';
            objCustomSettings.Name = 'License Report Fields';
            insert objCustomSettings;
            system.assertNotEquals(null,objCustomSettings);
            
              LicenseReportManagementController controller = new LicenseReportManagementController();
              controller.getlicensedUsers();
            }

}