/**********************************************************************
 Name: Service Campaign Creation
 Copyright ? 2016  Tavant Technology Inc
 ==============================================================
 without sharing explanation:
 This is class used to query service campaign data. Admin user only have full access on service campaign object. 
 Dealer/Internal users don’t have permissions for all fields on service campaign object.
===============================================================

History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Deeptarup      26/10/2016     INITIAL DEVELOPMENT  
***********************************************************************/
Global without sharing class CampaignMember {
       Global String objectName {get;set;}
       Global String ListOfIds {get;set;}
       
       Global CampaignMember (){
            ListOfIds = ApexPages.currentPage().getParameters().get('Ids');
       }
   /*******************************************************************
    PURPOSE: Returns the Service Campaign                                                 
    RETURNS: wrapper list
    
    ********************************************************************/
       @AuraEnabled
        Global static List<CampaignMember.WrapperGroup> getCampaignServices(){
        List<WrapperGroup> wrpGroupList = new List<WrapperGroup>();
        
            List<Service_Campaign__c>  groupList = [Select Name,Id,Campaign_Descrip__c,Start_Date__c,End_Date__c,Campaign_Type__c,Status__c from Service_Campaign__c where Status__c = 'Draft'];
            if(groupList != null && groupList.size() > 0){
                for(Service_Campaign__c grp : groupList){
                    WrapperGroup wrpobj = new WrapperGroup();
                    wrpobj.isSelected = false;
                    wrpobj.groupWr = grp;
                    wrpGroupList.add(wrpobj); 
                } 
            }
        return wrpGroupList;
    }
   /*******************************************************************
    PURPOSE:Add selected Inventory records to Service Campaign                                                 
    PARAMETERS: serviceCampaignids,recordids 
    RETURNS: boolean
    
    ********************************************************************/
    @AuraEnabled
    Global static boolean AddGroupMember(List<string> wrpGroupList,List<string> idsList ){
        Set<string> selectedGroupId = new Set<string>(wrpGroupList);
        system.debug('----wrpGroupList--'+wrpGroupList+'----idsList --'+idsList );
        List<Campaign_Members__c> groupMemberList = [Select g.Id,g.Inventory__c, g.Service_Campaign__c From Campaign_Members__c g where Service_Campaign__c IN :wrpGroupList];
        Map<Id,Id> groupMemberAndGroupId = new Map<ID,Id>();
        for(Campaign_Members__c grp : groupMemberList){
            groupMemberAndGroupId.put(grp.Inventory__c,grp.Service_Campaign__c);
        }
        system.debug('---groupMemberAndGroupId---'+groupMemberAndGroupId);
        List<Campaign_Members__c> addGroupMemberList = new List<Campaign_Members__c>();
        for(string wrp : wrpGroupList){
            for(String st :idsList){
                if(groupMemberAndGroupId.size()>0){
                     if(!groupMemberAndGroupId.containsKey(st)){
                        system.debug('---st---'+groupMemberAndGroupId.containsKey(st ));
                            system.debug('---st---'+groupMemberAndGroupId.get(wrp));
                            Campaign_Members__c GrpMemObj = new Campaign_Members__c();
                            GrpMemObj.Inventory__c = st;
                            GrpMemObj.Service_Campaign__c = wrp;
                            addGroupMemberList.add(GrpMemObj);
                       }
                }
            }
            
        }
        if(groupMemberAndGroupId.isEmpty()){ 
                   for(string wrp : selectedGroupId ){
                      for(String st :idsList){
                      Campaign_Members__c GrpMemObj = new Campaign_Members__c();
                      GrpMemObj.Inventory__c = st;
                      GrpMemObj.Service_Campaign__c = wrp;
                      addGroupMemberList.add(GrpMemObj); 
                     system.debug('---st---'+st);
                }
               }
              }
        system.debug('----addGroupMemberList-----'+addGroupMemberList);
        if(!addGroupMemberList.isEmpty()){
            insert addGroupMemberList;
            return true;
        }
        else{
            return false;
        }
    }
    /*******************************************************************
    PURPOSE:creates new Service Campaign                                                 
    PARAMETERS: Service Campaign,recordids 
    RETURNS: N/A
    
    ********************************************************************/ 
    @AuraEnabled
    Global static void createNwGroup(Service_Campaign__c objGroup,List<string> recordids){ 
    system.debug('------1st-------');
       if(objGroup !=null){
       system.debug('--------2nd------------------------'+objGroup);
         insert objGroup ;
        if(recordids.size()>0){
        system.debug('--------3rd--------');
        List<Campaign_Members__c> addGroupMemberList = new List<Campaign_Members__c>();
        for(string ids:recordids){
          Campaign_Members__c GrpMemObj = new Campaign_Members__c();
          GrpMemObj.Inventory__c = ids;
          GrpMemObj.Service_Campaign__c = objGroup.id;
          addGroupMemberList.add(GrpMemObj);
         
         }
        system.debug('-------4th--------'+addGroupMemberList);
        if(addGroupMemberList.size()>0)
        {
            insert addGroupMemberList;
        }
       }
      }
       
    }
      /************************************************************
     PURPOSE:Fetch picklist value for Status                                                   
     PARAMETERS: Service Campaign Object.Status field 
     RETURNS: List od picklist value

       ************************************************************/
    @AuraEnabled
    Global static List<String> getServiceCampaignStatus(){
    List<String> options = new List<String>();
    options.add('--None--');
    Schema.DescribeFieldResult fieldResult = Service_Campaign__c.Status__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f: ple) {
    options.add(f.getLabel());
        system.debug('------CampaignStatus-----------'+options);
    }
    return options;
    }
    
    /************************************************************
     PURPOSE:Fetch picklist value for Campaign type                                                   
     PARAMETERS: Service Campaign Object.Status field 
     RETURNS: List od picklist value

       ************************************************************/
    @AuraEnabled
    Global static List<String> getServiceCampaignType(){
    List<String> options = new List<String>();
    options.add('--None--');
    Schema.DescribeFieldResult fieldResult = Service_Campaign__c.Campaign_Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f: ple) {
    options.add(f.getLabel());
        system.debug('------CampaignType-----------'+options);
    }
    return options;
    }
    
     /*******************************************************************
    PURPOSE:Searches the Service Campaign                                                   
    PARAMETERS: search string 
    RETURNS: wrapper list
    
    ********************************************************************/
     @AuraEnabled
      Global static List<CampaignMember.WrapperGroup> groupSearch(string searchString){
      List<WrapperGroup> wrpGroupList = new List<WrapperGroup>();
      if(searchString !=null || searchString !=''){
      string str='%'+searchString+'%';

           List<Service_Campaign__c>  groupList = [Select Name,Id,Campaign_Descrip__c from Service_Campaign__c where Name Like :str];
            
            system.debug('-----groupList---'+groupList.size());
            if(groupList != null && groupList.size() > 0){
               
                for(Service_Campaign__c grp : groupList){
                    WrapperGroup wrpobj = new WrapperGroup();
                    wrpobj.isSelected = false;
                    wrpobj.groupWr = grp;
                    wrpGroupList.add(wrpobj); 
                }
                system.debug('-----wrpGroupList---'+wrpGroupList.size());   
            }
           }
        return wrpGroupList;
      
     
    }
     /*******************************************************************
    PURPOSE:Wrapper class                                                   
    PARAMETERS: N/A 
    RETURNS: N/A
    
    ********************************************************************/
    Global class WrapperGroup{
        @AuraEnabled
        public boolean isSelected{get;set;}
        @AuraEnabled
        public Service_Campaign__c groupWr{get;set;}
    }
    
         
}