trigger changeCustomerName on Inventory__c (before update) {
    
      // Get all 'CustomSettings' records
        WOD__c enableChangeCustomerName = WOD__c.getValues('Enable changeCustomerName');
        
 if(enableChangeCustomerName.isTriggered__c == true){
        
    set<Id> Inventory=new set<id>();
    for(Inventory__c Inv: Trigger.new)
    {
        Inventory.add(Inv.Id);
    }
    
    set<Id> warrantyRegistration=new set<id>();
    List<Warranty_Registration__c> warrantyRegistrationList=[select Id,Inventory__c,Account__c from Warranty_Registration__c where Inventory__c IN: Inventory]; 
    for(Warranty_Registration__c wr: warrantyRegistrationList)
    {
        warrantyRegistration.add(wr.Id);
    }
    List<Warranty_Coverages__c  > warrantyCoverageList=[select Id,Warranty_Registration__c,ERT_Selected__c,Is_Active__c from Warranty_Coverages__c where Warranty_Registration__c IN: warrantyRegistration];
    
    List<Inventory_Transaction_History__c> InvTran=[select Id,From__c,Inventory__c,To__c,Units_Run__c,Transaction_Type__c from Inventory_Transaction_History__c where Inventory__c IN: Inventory]; 
    
    
    
    
    for(Inventory__c newInv : Trigger.new)
    {
        for(Inventory_Transaction_History__c InvLoop : InvTran)
        {
            if(InvLoop.Transaction_Type__c=='RMT Pending for Approval' || InvLoop.Transaction_Type__c=='RMT')
            {
                if(newInv.Transfer_Initiated__c == 'Rejected')
                {
                    newInv.Transfer_Initiated__c = 'new';
                    InvLoop.Transaction_Type__c = 'RMT Rejected';
                }
                else
                {
                    newInv.Account__c = InvLoop.To__c ;
                    newInv.Transfer_Initiated__c = 'new';
                    InvLoop.Transaction_Type__c = 'RMT';
                    for(Warranty_Registration__c wr: warrantyRegistrationList)
                    {
                        if(wr.Inventory__c==newInv.Id)
                        {
                            wr.Account__c=InvLoop.To__c;                               
                        }
                    }
                }
                system.debug(warrantyRegistrationList);                        
            }
            else if(((newInv.Transfer_Initiated__c == 'Completed')||(newInv.Transfer_Initiated__c == 'Rejected')) && (newInv.Latest_Transaction__c == InvLoop.Id))
            {
                if(newInv.Type__c=='Retail')
                {
                    system.debug('InvLoop');
                    
                    if(newInv.Transfer_Initiated__c == 'Rejected')
                    {
                        newInv.Transfer_Initiated__c = 'new';
                        InvLoop.Transaction_Type__c = 'ETR Rejected';
                        for(Warranty_Coverages__c warrantyCoverage: warrantyCoverageList)
                        {
                            warrantyCoverage.ERT_Selected__c=false;
                        }
                    }
                    else
                    {
                        for(Warranty_Coverages__c warrantyCoverage: warrantyCoverageList)
                        {
                            warrantyCoverage.Is_Active__c=warrantyCoverage.ERT_Selected__c;
                            warrantyCoverage.ERT_Selected__c=false;
                        }
                        newInv.Customer__c= InvLoop.To__c ;
                        newInv.Units_Run__c= InvLoop.Units_Run__c ;                        
                        newInv.Transfer_Initiated__c = 'new';
                        InvLoop.Transaction_Type__c = 'ETR';
                        
                    }    
                }
                if(newInv.Type__c=='Stock')
                {
                    
                    if(newInv.Transfer_Initiated__c == 'Rejected')
                    {
                        newInv.Transfer_Initiated__c = 'new';
                        InvLoop.Transaction_Type__c = 'D2D Rejected';
                    }
                    
                    else 
                    {
                        newInv.Account__c = InvLoop.To__c ;
                        newInv.Transfer_Initiated__c = 'new';
                        InvLoop.Transaction_Type__c = 'D2D';
                    }    
                }
                
            }
            
        }
    }
    Update InvTran;
    update warrantyCoverageList;
    update warrantyRegistrationList;
    }
}