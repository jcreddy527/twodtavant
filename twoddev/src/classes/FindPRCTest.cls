/**********************************************************************
 Name:  FindPRCTest
 Copyright ? 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Class is test class for FindClaimPolServForNonSerilized apex class
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 - Hampesh             03/08/2016     INITIAL DEVELOPMENT            
***********************************************************************/
@isTest(seealldata=true)


global class FindPRCTest
{

    /*******************************************************************
    Purpose:  to test the FindClaimPolServForNonSerilized apex class                                                  
    Parameters: N/A
    Returns: none
    Throws [Exceptions]:                                                      
    ********************************************************************/
    
      global static testMethod void findPRClaimsfornonserializedTest(){
         CustomSettingsUtilityTest.init();
         Account acc=new Account();
         acc.name='abc';
         acc.Warranty_Account_Type__c = 'Dealer';
         insert acc;
         
         Warehouse__c warehousObj=new Warehouse__c();
         warehousObj.name='India';
         insert warehousObj;
         Warranty_Product__c  objProd=new Warranty_Product__c();
         objProd.Name='samsung galaxy';
         objProd.Type__c='Item';
         objProd.Track_Type__c='Serialized';
         insert objProd;
         Warranty_Product__c  objProd1=new Warranty_Product__c();
         objProd1.Name='samsung galaxy1';
         objProd1.Type__c='Part';
         objProd1.Track_Type__c='Non-Serialized';
         insert objProd1;
         
         Group__c objGrp=new Group__c();
         //objGrp.name='grp1';
         objGrp.Object_Name__c='Account';
         insert  objGrp;
         
         Group__c objGrp1=new Group__c();
         //objGrp.name='grp1';
         objGrp1.Object_Name__c=SystemUtils.getNameSpace()+'Warranty_Product__c';
         insert  objGrp1;
         Group_Member__c member=new Group_Member__c();
         member.Record_Id__c=acc.id;
         member.Group__c=objGrp.id;
         insert member;
         Group_Member__c member1=new Group_Member__c();
         member1.Record_Id__c=objProd.id;
         member1.Group__c=objGrp1.id;
         insert member1;
         Inventory__c objInv=new Inventory__c();
          objInv.Name='Inv001';
          objInv.Item__c=objProd.Id;
          objInv.Account__c=acc.id;
          objInv.Serial_Number__c='001';
          objInv.Asset_Type__c='Warrantable';
          insert objInv;
         Claim__c objClaim=new Claim__c();
         objClaim.Date_of_Failure__c=system.today();
         //objClaim..Date_Of_Purchase__c=system.today();
         //objClaim..Date_of_Repair__c=system.today();
         objClaim.Warranty_Product__c=objProd1.id;
         objClaim.Claim_Type__c='part';
         objClaim.Account__c=acc.id;
         objClaim.Inventory__c=objInv.id;
         insert objClaim;
      
        String RecType = RecordTypeUtils.getRecordTypeId('Serialized_Part',Removed_Claim_Part__c.sObjectType);
        String NonRecType = RecordTypeUtils.getRecordTypeId('Non_Serialized_Part',Removed_Claim_Part__c.sObjectType);
          
          Part_Return_Configuration__c objPRC=new Part_Return_Configuration__c();
          objPRC.Applicable_From_Date__c=system.today();
          objPRC.Applicable_To_Date__c=system.today()+1;
          objPRC.Name='test prc';
          objPRC.Payment_Condition__c='pay without return';
          objPRC.Return_Location__c=warehousObj.id;
          objPRC.Dealer__c=acc.id;
          objPRC.Claim_Type__c='part';
          objPRC.Part__c=objProd.id;
          objPRC.Priority__c=150;
          insert objPRC;
          
          Part_Return_Configuration__c objPRC1=new Part_Return_Configuration__c();
          objPRC1.Applicable_From_Date__c=system.today();
          objPRC1.Applicable_To_Date__c=system.today()+1;
          objPRC1.Name='test prc';
          objPRC1.Payment_Condition__c='pay without return';
          objPRC1.Return_Location__c=warehousObj.id;
          objPRC1.Dealer__c=acc.id;
          objPRC1.Claim_Type__c='part';
          objPRC1.Part__c=objProd.id;
          objPRC1.Priority__c=151;
          insert objPRC1;
           if(objPRC1.Id != null){
           system.assertEquals (objPRC1.Claim_Type__c, 'part');
           }
          
          List<Removed_Claim_Part__c> partList = new List<Removed_Claim_Part__c>();
          Removed_Claim_Part__c objremovedpart=new Removed_Claim_Part__c();
          objremovedpart.Inventory__c=objInv.id;
          objremovedpart.Name='part1';
          objremovedpart.RecordTypeId  =NonRecType;
          objremovedpart.Claim__c=objClaim.id;
          objremovedpart.Warranty_Product__c=objProd1.id;
          partList.add(objremovedpart);
          
         
          Removed_Claim_Part__c objremovedpart1=new Removed_Claim_Part__c();
          objremovedpart1.Inventory__c=objInv.id;
          objremovedpart1.Name='part2';
          objremovedpart1.RecordTypeId  = RecType;
          objremovedpart1.Claim__c=objClaim.id;
          objremovedpart1.Warranty_Product__c=objProd1.id;
          partList.add(objremovedpart1);
          insert partList;
           
          //Test.setCreatedDate(objremovedpart.Id, datetime.newInstance(2016, 8, 03, 12, 30, 0));
          //Test.setCreatedDate(objremovedpart.id,DateTime.newInstance(2016,08,03));  
          // update objremovedpart;
          
         // partList.add(objremovedpart);
          
          //List<Removed_Claim_Part__c> partList=[SELECT Claim__c,CreatedDate,Id,Inventory__c,Name,RecordTypeId,Warranty_Product__c FROM Removed_Claim_Part__c  Where Inventory__c != null limit 10];
          test.starttest();
          List<Removed_Claim_Part__c> ClaimPartList =FindPRC.findPRClaimsfornonserialized(partList);
          if(ClaimPartList.size()>0){
           System.assertEquals(null, ClaimPartList[0].Payment_Condition__c);
           }
          //List<Removed_Claim_Part__c> partList1=[SELECT Claim__c,CreatedDate,Id,Inventory__c,Name,RecordTypeId,Warranty_Product__c FROM Removed_Claim_Part__c where RecordTypeId=:lstRecordTypeforRemovedPart[1].id];
          //findPRClaimsforserializedTest(partList1);
          test.stoptest();          
      
     }
   //  global static  void findPRClaimsforserializedTest(List<Removed_Claim_Part__c> partList){
        
         //// FindPRC.findPRClaimsfornonserialized(partList);
          
    //}
     
   }