/**********************************************************************
Name:  ExtendedWRMaxDaysExceed
Copyright ? 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose: check inventory's install date with today and check number of days between                                                                                                                
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION     AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Bikram         20/10/2016      INITIAL DEVELOPMENT            
***********************************************************************/
global class ExtendedWRMaxDaysExceed {
  /*******************************************************************
    PURPOSE:   check inventory's install date with today and check number of days between                                                
    PARAMETERS: integer
    RETURNS: inventory id
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    webService static integer checkDaysBetweenInstallAndTodayDate(Id inventoryId){ 
      system.debug('inventoryId--  '+inventoryId);
      integer daysBetween;
        Inventory__c inv = [SELECT Id, Install_Date__c FROM Inventory__c WHERE Id = :inventoryId];
        if(inv != null){
          system.debug('inv install date- '+inv.Install_Date__c);
          daysBetween = inv.Install_Date__c.daysBetween(system.today());
          system.debug('daysBetween- '+daysBetween);
        }
        return daysBetween;
    }
}