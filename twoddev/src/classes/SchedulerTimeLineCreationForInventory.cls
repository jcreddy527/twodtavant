/**********************************************************************
Name:  SchedulerTimeLineCreationForInventory
Copyright ? 2017  Tavant Technology Inc
===============================================================
===============================================================
Purpose: Class used for creating Upcoming_Completed__c scheduler Record for Inventory

-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR                DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Shambhvi Dixit        03/01/2017     INITIAL DEVELOPMENT            
***********************************************************************/
global class SchedulerTimeLineCreationForInventory {
    Static String strMonths='Months';
    Static String strDays='Days';
    static Id MSId = null;
    
    @InvocableMethod
    public static void createUpcoming_Completed(List<Inventory__c> inv){
        
        if(inv.size() > 0 && inv.size() != null){
            try{
                MSId=Scheduler_RuleEngine.RunEligibityRules(inv[0])[0].id;
                /*List<Master__c> masterList = Scheduler_RuleEngine.RunEligibityRules(inv[0]);
                system.debug('masterList-->'+masterList);
                if(masterList != null){
                    for(Master__c master : masterList){
                        MSId.add(master.Id);
                    }
                    system.debug('MSId-->'+MSId);
                }*/
            }
            catch(Exception e){
                system.debug('Exception--'+e);
            }
            if(MSId !=null){
                system.debug(MSId);
                List<Master__c> lstMaster=new list<Master__c>([SELECT name,Description__c,Id,Priority__c,Warranty_Rule__c,(SELECT name,Description__c,Units_Allowed_Usage__c,Master_Scheduler__c,Scheduler_Time__c,Time_Unit__c,Claim_Template__c,Order__c FROM Scheduler_Timeline__r) FROM Master__c where Id =: MSId limit 1]);
                if(lstMaster.size() >0 && lstMaster.size() != null){
                    list<Upcoming_Completed__c> lstInvComp=new list<Upcoming_Completed__c>();
                    Date InstallDate=inv[0].Install_Date__c;
                    Schema.SObjectField extId = Upcoming_Completed__c.Fields.External_ID__c;
                    
                    for(Scheduler_Timeline__c scTimeLine:lstMaster[0].Scheduler_Timeline__r){   
                        Upcoming_Completed__c up=new Upcoming_Completed__c();
                        up.name=scTimeLine.name;
                        up.Inventory__c=inv[0].id;
                        up.Master_Scheduler__c=scTimeLine.Master_Scheduler__c;  
                        up.Description__c=scTimeLine.Description__c;
                        up.External_ID__c=scTimeLine.name+'-'+inv[0].id;
                        if(scTimeLine.Order__c != null){
                            up.Order__c = scTimeLine.Order__c;
                        }
                        if(scTimeLine.Claim_Template__c != null){
                            up.Claim_Template__c = scTimeLine.Claim_Template__c;
                        }
                        
                        if(Integer.valueof(scTimeLine.Scheduler_Time__c)!=null){
                            if(scTimeLine.Time_Unit__c== strMonths){
                                up.Preventative_Maintenance_Date__c=InstallDate.addMonths(Integer.valueof(scTimeLine.Scheduler_Time__c));
                            } else if (scTimeLine.Time_Unit__c== strDays){
                                up.Preventative_Maintenance_Date__c= InstallDate.addDays(Integer.valueof(scTimeLine.Scheduler_Time__c));
                            }
                            if(scTimeLine.Units_Allowed_Usage__c != null){
                                up.Expected_Procuct_Usage__c = scTimeLine.Units_Allowed_Usage__c;
                            }
                            
                        } 
                        
                        lstInvComp.add(up); 
                        
                    }   
                    if(lstInvComp.size() > 0 && lstInvComp.size() != null){
                        Database.UpsertResult[] claimUpdateList = database.upsert(lstInvComp,extId,false);
                    } 
                }
            }
        }
    }
}