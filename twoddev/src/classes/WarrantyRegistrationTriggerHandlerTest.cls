/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
@IsTest
public class WarrantyRegistrationTriggerHandlerTest{
    
    static testmethod void testMethod1(){
            List<Account> acclst = new List<Account>();
            for(Integer i=0;i<=2;i++){
                Account ac = new Account();
                ac.Name= 'Test Account'+i;
                ac.Email__c = 'd@gmail.com';
                ac.Warranty_Account_Type__c = 'Dealer';
                //ac.Income_Month__c = '500-1000';
                acclst.add(ac);
            }
            insert acclst;
            
            Inventory__c inv = new Inventory__c();
            inv.Name= 'INV-6_';
            inv.Serial_Number__c = 'SRNO-6';
            inv.Account__c = acclst[0].Id;
            
            //inv.Type__c = 'Retail';
            inv.Install_Date__c = system.today();
            
            insert inv;
            
            //inv.Customer__c = acclst[1].id;
           // update inv;
            
            Policy_Definition__c policy = new Policy_Definition__c();
            policy.Name = 'M-Policy5';
            policy.Months_Covered__c =12;
            policy.Active_From__c = system.today()-10;
            policy.Active_Until__c = system.today()+365;
            policy.Type__c = 'Standard';
            policy.Status__c = 'Active';
            insert policy;
           
            List<Warranty_Registration__c> lst = new List<Warranty_Registration__c>();
            Warranty_Registration__c wr = new Warranty_Registration__c();
            wr.Name= 'a0R6F00000O30hn';
            wr.Inventory__c = inv.id;
            wr.Status__c = 'Completed';
            wr.Registration_Date__c = system.today()-1;
           // wr.origin__c = 'sms';
            insert wr;
            system.assertNotEquals(Null, wr);
            lst.add(wr);
                
            WarrantyRegistrationTriggerHandler wr1 = new WarrantyRegistrationTriggerHandler();
            
            wr1.restrictWRDeletion(lst);
            wr1.beforeDelete();
            delete wr;                   
    }
    
    static testmethod void testMethod2(){
            List<Account> acclst = new List<Account>();
            for(Integer i=0;i<=2;i++){
                Account ac = new Account();
                ac.Name= 'Test Account'+i;
                ac.Email__c = 'd@gmail.com';
                ac.Warranty_Account_Type__c = 'Dealer';
               // ac.Income_Month__c = '500-1000';
                acclst.add(ac);
            }
            insert acclst;
            
            Inventory__c inv = new Inventory__c();
            inv.Name= 'INV-6_';
            inv.Serial_Number__c = 'SRNO-6';
            inv.Account__c = acclst[0].Id;
            
            //inv.Type__c = 'Retail';
            inv.Install_Date__c = system.today();
            
            insert inv;
            
            //inv.Customer__c = acclst[1].id;
            //update inv;
            
            Policy_Definition__c policy = new Policy_Definition__c();
            policy.Name = 'M-Policy5';
            policy.Months_Covered__c =12;
            policy.Active_From__c = system.today()-10;
            policy.Active_Until__c = system.today()+365;
            policy.Type__c = 'Standard';
            policy.Status__c = 'Active';
            insert policy;
           
            List<Warranty_Registration__c> lst = new List<Warranty_Registration__c>();
            Warranty_Registration__c wr = new Warranty_Registration__c();
            wr.Name= 'a0R6F00000O30hn';
            wr.Inventory__c = inv.id;
            wr.Status__c = 'Draft';
            wr.Registration_Date__c = system.today()-1;
            //wr.origin__c = 'sms';
            insert wr;
            system.assertNotEquals(Null, wr);
            lst.add(wr);
                
            WarrantyRegistrationTriggerHandler wr1 = new WarrantyRegistrationTriggerHandler();
            wr.Status__c = 'Completed';
            update wr;
            wr1.restrictWRDeletion(lst);
            wr1.beforeDelete();
            delete wr;                   
    }
}