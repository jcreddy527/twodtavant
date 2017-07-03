/**********************************************************************
 Name:  LicenseReportEmailHandler
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: This class will send email of list of details to mail given in custom setting                   
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Sainath 10/19/2016             
***********************************************************************/
global class LicenseReportEmailHandler{
  
  global LicenseReportEmailHandler(){
      EmailTemplate emailTemplate = [select Id, Body  from EmailTemplate where DeveloperName = 'License_Report_Email'];
      WOD__c Licensereport = WOD__c.getValues('LicenseReportEmail');
      String ToEmail = Licensereport.Trigger_Value__c;
     
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
         email.setToAddresses(new String[] {ToEmail});
         email.setSaveAsActivity(false);
         email.setTargetObjectId(UserInfo.getUserId());
         email.setTemplateId(emailTemplate.Id);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
         }
       
}