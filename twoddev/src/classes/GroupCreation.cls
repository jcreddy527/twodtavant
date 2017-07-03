/**********************************************************************
 Name: GroupCreattion
 Copyright ? 2016  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:    To Test GroupCreattion apex class                                                    -------                                                             
===============================================================
without sharing explanation:
This is class used to query group data. Admin user only have full access on group object. 
Dealer/Internal users don’t have permissions for all fields on group object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Mithul      30/6/2016     INITIAL DEVELOPMENT  
1.1      Hampesh      1/7/2016
***********************************************************************/
global without sharing class GroupCreation {
       global String objectName {get;set;}
       global String ListOfIds {get;set;}
       
       global GroupCreation(){
       objectName  = ApexPages.currentPage().getParameters().get('ObjectName');
         ListOfIds = ApexPages.currentPage().getParameters().get('Ids');
       }
   /*******************************************************************
    PURPOSE:Returns the groups for a particular object                                                   
    PARAMETERS: object name 
    RETURNS: wrapper list
    
    ********************************************************************/
       @AuraEnabled
        global static List<GroupCreation.WrapperGroup> getGroups(string objectName){
         List<WrapperGroup> wrpGroupList = new List<WrapperGroup>();
         if(objectName != null){
           List<Group__c>  groupList = [Select Name,Id,Object_Name__c,Object_Label__c,Description__c,Name__c from Group__c where Object_Name__c =:objectName];
            if(groupList != null && groupList.size() > 0){
               for(Group__c grp : groupList){
                    WrapperGroup wrpobj = new WrapperGroup();
                    wrpobj.isSelected = false;
                    wrpobj.groupWr = grp;
                    wrpGroupList.add(wrpobj); 
                } 
            }
        }
        return wrpGroupList;
    }
   /*******************************************************************
    PURPOSE:Add selected records records to groups                                                 
    PARAMETERS: groupids,recordids 
    RETURNS: boolean
    
    ********************************************************************/
    @AuraEnabled
    global static boolean AddGroupMember(List<string> wrpGroupList,List<string> idsList ){
        Set<string> selectedGroupId = new Set<string>(wrpGroupList);
        system.debug('----wrpGroupList--'+wrpGroupList+'----idsList --'+idsList );
        List<Group_Member__c> groupMemberList = [Select g.Id,g.Record_Id__c, g.Group__c From Group_Member__c g where Group__c IN :wrpGroupList];
        Map<Id,Id> groupMemberAndGroupId = new Map<ID,Id>();
        for(Group_Member__c grp : groupMemberList){
            groupMemberAndGroupId.put(grp.Record_Id__c,grp.Group__c);
        }
        system.debug('---groupMemberAndGroupId---'+groupMemberAndGroupId);
        List<Group_Member__c> addGroupMemberList = new List<Group_Member__c>();
        for(string wrp : wrpGroupList){
            for(String st :idsList){
                if(groupMemberAndGroupId.size()>0){
                     if(!groupMemberAndGroupId.containsKey(st)){
                        system.debug('---st---'+groupMemberAndGroupId.containsKey(st ));
                            system.debug('---st---'+groupMemberAndGroupId.get(wrp));
                            Group_Member__c GrpMemObj = new Group_Member__c();
                            GrpMemObj.Record_Id__c = st;
                            GrpMemObj.Group__c = wrp;
                            addGroupMemberList.add(GrpMemObj);
                       }
                }
            }
            
        }
        if(groupMemberAndGroupId.isEmpty()){ 
                   for(string wrp : selectedGroupId ){
                      for(String st :idsList){
                      Group_Member__c GrpMemObj = new Group_Member__c();
                      GrpMemObj.Record_Id__c = st;
                      GrpMemObj.Group__c = wrp;
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
    PURPOSE:creates new group for a particluar object and members to that group                                                  
    PARAMETERS: group object,recordids 
    RETURNS: N/A
    
    ********************************************************************/ 
    @AuraEnabled
    global static void createNewGroup(Group__c objGroup,List<string> recordids){ 
       if(objGroup !=null){
         insert objGroup ;
        if(recordids.size()>0){
        List<Group_Member__c> addGroupMemberList = new List<Group_Member__c>();
        for(string ids:recordids){
          Group_Member__c GrpMemObj = new Group_Member__c();
          GrpMemObj.Record_Id__c = ids;
          GrpMemObj.Group__c = objGroup.id;
          addGroupMemberList.add(GrpMemObj);
          
         }
        if(addGroupMemberList.size()>0)
        {
            insert addGroupMemberList;
        }
       }
      }
       
    }
    
     /*******************************************************************
    PURPOSE:Searches the groups                                                   
    PARAMETERS: search string 
    RETURNS: wrapper list
    
    ********************************************************************/
     @AuraEnabled
    global static List<GroupCreation.WrapperGroup> groupSearch(string searchString,string objectName ){
      List<WrapperGroup> wrpGroupList = new List<WrapperGroup>();
      if(searchString !=null || searchString !=''){
      string str='%'+searchString+'%';
        if(objectName != null){
           List<Group__c>  groupList = [Select Name,Id,Object_Name__c,Object_Label__c,Description__c,Name__c from Group__c where Object_Name__c =:objectName AND Name__c Like :str];
            
            system.debug('-----groupList---'+groupList.size());
            if(groupList != null && groupList.size() > 0){
               
                for(Group__c grp : groupList){
                    WrapperGroup wrpobj = new WrapperGroup();
                    wrpobj.isSelected = false;
                    wrpobj.groupWr = grp;
                    wrpGroupList.add(wrpobj); 
                }
                system.debug('-----wrpGroupList---'+wrpGroupList.size());   
            }
           }
          }
        return wrpGroupList;
      
     
    }
     /*******************************************************************
    PURPOSE:Wrapper class                                                   
    PARAMETERS: N/A 
    RETURNS: N/A
    
    ********************************************************************/
    global class WrapperGroup{
        @AuraEnabled
        global boolean isSelected{get;set;}
        @AuraEnabled
        global Group__c groupWr{get;set;}
    }
    
         
}