/**********************************************************************
 Name: GroupCreattionTest
 Copyright ? 2016  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:    To Test GroupCreattion apex class                                                    -------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Hampesh      19/07/2016     INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class GroupCreationTest {

  /*******************************************************************
    PURPOSE:   To Test GroupCreattion apex class                                                    
    PARAMETERS: N/A 
    RETURNS: N/A 
    
    ********************************************************************/
    
     static testmethod void testGroupCreation(){
         CustomSettingsUtilityTest.init();
         List<Group__c> groupList=new List<Group__c>();
         Group__c grp1=new Group__c();
         grp1.Name__c='grp1';
         grp1.Object_Name__c='Account';
         groupList.add(grp1);
         Group__c grp2=new Group__c();
         grp1.Name__c='grp2';
         grp1.Object_Name__c='Account';
         groupList.add(grp2);
         insert groupList;
         
         List<Account> accList=new List<Account>();
         Account acc1=new Account();
         acc1.Name='acc1';
         accList.add(acc1);
         Account acc2=new Account();
         acc2.Name='acc2';
         accList.add(acc2);
         insert accList;
         if(acc2.Id != null){
          System.assertEquals('acc2',acc2.Name);
         }
         
         List<Group_Member__c> memberList=new List<Group_Member__c>();
         Group_Member__c member1=new Group_Member__c();
         member1.Group__c=grp1.Id;
         member1.Record_Id__c=acc1.Id;
         memberList.add(member1);
         Group_Member__c member2=new Group_Member__c();
         member2.Group__c=grp2.Id;
         member2.Record_Id__c=acc2.Id;
         memberList.add(member2);
         insert memberList;
         
         
         List<String> grplst=new List<String>();
         grplst.add(string.valueof(grp1.id));
         List<String> recordIds=new List<String>();
         recordIds.add(string.valueof(acc2.id));
         
         Group__c objGroup=new  Group__c();
         objGroup.Name__c='group';
         objGroup.Object_Name__c='Account';
         
         test.startTest();
         //GroupCreation objgrp=new GroupCreation ();
         List<GroupCreation.WrapperGroup> GroupAccountList = GroupCreation.getGroups('Account');
         if(GroupAccountList != null){
         System.assertEquals(false, GroupAccountList[0].isSelected);
         }
         GroupCreation.AddGroupMember(grplst,recordIds);
         GroupCreation.createNewGrup(objGroup,recordIds);
         GroupCreation.groupSearch('gr','Account');
         test.stopTest();
     
      }
     }