@isTest
global class changeCustomerNameTest {
    
    global static testMethod void changeCustomerNameTest(){
        CustomSettingsUtilityTest.init();
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        
        Inventory__c inv=new Inventory__c();
        inv.Account__c=acc.Id;
        inv.Serial_Number__c='123';
        inv.Type__c='Retail';
        inv.Transfer_Initiated__c='Completed';        
        insert inv;
        
        Warranty_Registration__c wr=new Warranty_Registration__c();
        wr.Account__c=acc.Id;
        wr.Inventory__c=inv.Id;
        wr.Registration_Date__c=system.today();       
        insert wr;
        
        Policy_Definition__c policy=new Policy_Definition__c();
        policy.Name='test';
        policy.Active_From__c=system.today();
        policy.Active_Until__c=system.today();
        policy.Status__c='Active';
        insert policy;
        
        Warranty_Coverages__c wc=new Warranty_Coverages__c();
        wc.Warranty_Registration__c=wr.Id;
        wc.ERT_Selected__c=true;
        wc.Is_Active__c=true;
        wc.Warranty_Start_Date__c=system.today();
        wc.Warranty_End_Date__c=system.today();
        wc.Policy_Definition__c=policy.Id;
        insert wc;
        
        Inventory_Transaction_History__c ith=new Inventory_Transaction_History__c();
        ith.From__c=acc.Id;
        ith.To__c=acc.Id;
        ith.Transaction_Type__c='D2D Pending for Approval';
        ith.Inventory__c=inv.Id;
        insert ith;
        if(ith.Id != null){
        system.assertEquals (ith.Transaction_Type__c, 'D2D Pending for Approval');
        }
        
        inv.Type__c='Retail';
        inv.Transfer_Initiated__c='Completed'; 
        inv.Latest_Transaction__c=ith.Id;
        update inv;               
        
        inv.Transfer_Initiated__c='Rejected'; 
        update inv;
        if(inv.Id != null){
        system.assertEquals (inv.Transfer_Initiated__c, 'Rejected');
        }
        
        inv.Type__c='Stock';
        inv.Transfer_Initiated__c='Completed'; 
        inv.Latest_Transaction__c=ith.Id;
        update inv;               
        
        inv.Transfer_Initiated__c='Rejected'; 
        update inv;
        
        ith.Transaction_Type__c='RMT Pending for Approval';
        update ith;
     
        inv.Transfer_Initiated__c='Completed';
        update inv;

        inv.Transfer_Initiated__c='Rejected'; 
        update inv;
                
        
    }
}