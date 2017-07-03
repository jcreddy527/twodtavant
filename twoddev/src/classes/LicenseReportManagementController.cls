/**********************************************************************
 Name:  LicenseReportManagementController
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: This class will get all information of users licenses Who have installed TWOD product                     
-------                                                             
===============================================================
without sharing explanation:This is class used to query user and user Package License data. 
Admin user only have full access on user and user Package License object. 
Dealer/Internal users don’t have permissions for all fields on user and user Package License object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Sainath 10/19/2016             
***********************************************************************/
global without sharing class LicenseReportManagementController
{
    public List<User> licensedUsers = new List<User>();
    public static Final String APP_NAMESPACE_PREFIX = 'twod';
    public List<String> customSettingVal = new List<String>();
    
    public List<User> getlicensedUsers(){
               List<WOD__c> customSettingsList = WOD__c.getall().values();
                WOD__c customSettingPay = WOD__c.getValues('License Report Fields');
                String customSettingPayConfigValues = customSettingPay.Trigger_Value__c;
                String[] arrCSPayConfig_values = customSettingPayConfigValues.split(',');   
                 for(String CustomValues : arrCSPayConfig_values ){
                            customSettingVal.add(CustomValues);      
                  }
                // Creating a Query String dynamically
                    String selectQuery = 'Select ';
                    selectQuery+= String.join(customSettingVal,',');
                    selectQuery+= ' FROM User WHERE Id in (SELECT UserId FROM UserPackageLicense WHERE (PackageLicense.NamespacePrefix = :APP_NAMESPACE_PREFIX))';
                    selectQuery = selectQuery.removeEnd(',');
                    licensedUsers = database.query(selectQuery);
      //licensedUsers = [SELECT Name,Profile.Name,UserRole.Name,UserType,IsActive,LastLoginDate,Profile.UserLicense.Name FROM User WHERE Id in (SELECT UserId FROM UserPackageLicense WHERE (PackageLicense.NamespacePrefix = :APP_NAMESPACE_PREFIX))];
      return licensedUsers;
    }

}