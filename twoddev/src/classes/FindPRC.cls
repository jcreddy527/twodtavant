/**********************************************************************
 Name:  FindPRC
 Copyright ? 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Class used to find part return claims for the removed claim
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 - Hampesh             27/07/2016     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class FindPRC
{

    /*******************************************************************
    Purpose:  to update the Policy Definition for the claim                                                   
    Parameters: N/A
    Returns: none
    Throws [Exceptions]:                                                      
    *****************()***************************************************/
    global static boolean prcFound= false;
    @InvocableMethod
    global static List<Removed_Claim_Part__c> findPRClaimsfornonserialized(List<Removed_Claim_Part__c> partList){
       //global static Boolean prcFound=false;
      

       system.debug('--part details--'+partList.size()+'--id--'+partList[0].CreatedDate+'prod'+partList[0].recordTypeid);
       List<Removed_Claim_Part__c> updateRemovedPartList=new List<Removed_Claim_Part__c> ();
      
        
          for(Removed_Claim_Part__c part:partList){
          if(part !=null){
           Removed_Claim_Part__c removedPart=findPRCforRemovedPart(part);
           system.debug('bool value'+prcFound);
           updateRemovedPartList.add(removedPart);
          }
       }
   
        if(!prcFound){
            partList[0].Payment_Condition__c='';
            partList[0].Return_Location__c=null;
            partList[0].Part_Return_Configuration__c =null;
            updateRemovedPartList=partList;
        }
        return updateRemovedPartList;
       
      }
    
      global  static Removed_Claim_Part__c findPRCforRemovedPart(Removed_Claim_Part__c part){ 
          List<Claim__c> objClaim=[SELECT id, Account__c,Claim_Type__c,Inventory__c,Inventory__r.Item__c,Date_of_Failure__c,recordtype.developername FROM Claim__c WHERE Id =:part.claim__C];
          system.debug('claim delaer'+objClaim);
          string  accid;
          string inventoryid;
          string productid;
          if(!objClaim.isEmpty()){
          if(objClaim[0].recordtype.developername !='Claim_Template'){
            string recordTypeName=[select DeveloperName from recordtype where id=:part.recordtypeid].DeveloperName;
            List<Part_Return_Configuration__c> lstPRC=new List<Part_Return_Configuration__c>();
            List<Group_Member__c> grpList;
            List<Id> grpIds=new List<Id>();
            if(recordTypeName =='Non_Serialized_Part'){
           
              accid=string.valueof(objClaim[0].Account__c).substring(0,15);
           
            
             productid=string.valueof(part.Warranty_Product__c).substring(0,15); 
                     
            grpList =[select id,group__c from group_member__c where record_id__c =:accid OR record_id__c =:productid  ];
            for(Group_Member__c grp:grpList)
             {
                grpIds.add(grp.group__c);
             }
         
            lstPRC=[SELECT RecordType.DeveloperName,Applicable_From_Date__c,Applicable_To_Date__c,Claim_Type__c,Comments__c,Days_Due_Within__c,Dealer_Group__c,Dealer__c,Description__c,Id,Name,Part_Group__c,Part__c,Priority__c,RecordTypeId,Return_Location__c,Shippers__c,Payment_Condition__c FROM Part_Return_Configuration__c
            where (Applicable_From_Date__c <=:objClaim[0].Date_of_Failure__c AND Applicable_To_Date__c >=:objClaim[0].Date_of_Failure__c  AND Claim_Type__c=:objClaim[0].Claim_Type__c AND Dealer__c=:objClaim[0].Account__c AND Part__c=:part.Warranty_Product__c AND  RecordType.DeveloperName='Individual')
            OR (Applicable_From_Date__c <=:objClaim[0].Date_of_Failure__c AND Applicable_To_Date__c >=:objClaim[0].Date_of_Failure__c  AND Claim_Type__c=:objClaim[0].Claim_Type__c  AND Dealer_Group__c in:grpIds AND Part_Group__c in:grpIds AND RecordType.DeveloperName='Group') order by Priority__c asc nulls last];
           
           if(lstPRC.size()>0){
             prcFound=true;
             part.Part_Return_Configuration__c =lstPRC[0].Id;
             part.Payment_Condition__c=lstPRC[0].Payment_Condition__c;
             part.Return_Location__c=lstPRC[0].Return_Location__c;
             part.Quantity__c=part.Quantity__c;
             part.Is_Inspected__c =part.Is_Inspected__c;
            part.claim__c=part.claim__c;
                       
           }
          }
          
          if(recordTypeName =='Serialized_Part'){
            prcFound=true; 
            system.debug('inventory id'+part.Inventory__c);
            List<Inventory__c> objInv=[select id,Item__c from Inventory__c where id=:part.Inventory__c];
            //if(objClaim[0].Account__c !=null && objClaim[0].Account__c !='' ){
              accid=string.valueof(objClaim[0].Account__c).substring(0,15);
           // }
           
              inventoryid=string.valueof(objInv[0].id).substring(0,15);
           
            
              productid=string.valueof(objInv[0].Item__c).substring(0,15);
            
            system.debug('account&product'+accid+productid);
           
            grpList =[select id,group__c from group_member__c where record_id__c =:accid OR  record_id__c =:inventoryid OR  record_id__c =:productid  ];
            for(Group_Member__c grp:grpList)
             {
               grpIds.add(grp.group__c);
             }
            lstPRC=[SELECT RecordType.DeveloperName ,Applicable_From_Date__c,Applicable_To_Date__c,Claim_Type__c,Comments__c,Days_Due_Within__c,Dealer_Group__c,Dealer__c,Description__c,Id,Name,Part_Group__c,Part__c,Priority__c,RecordTypeId,Return_Location__c,Shippers__c,Payment_Condition__c FROM Part_Return_Configuration__c
             where 
            (Applicable_From_Date__c <=:objClaim[0].Date_of_Failure__c AND Applicable_To_Date__c >=:objClaim[0].Date_of_Failure__c  AND Claim_Type__c=:objClaim[0].Claim_Type__c AND Dealer__c=:objClaim[0].Account__c AND Part__c=:objInv[0].Item__c AND RecordType.DeveloperName='Individual')
             OR (Applicable_From_Date__c <=:objClaim[0].Date_of_Failure__c AND Applicable_To_Date__c >=:objClaim[0].Date_of_Failure__c  AND Claim_Type__c=:objClaim[0].Claim_Type__c  AND Dealer_Group__c in:grpIds AND Part_Group__c in:grpIds AND RecordType.DeveloperName='Group') order by Priority__c asc nulls last];
             system.debug('Prc list'+lstPRC);
            if(lstPRC.size()>0){
             part.Part_Return_Configuration__c =lstPRC[0].Id;
             part.Payment_Condition__c=lstPRC[0].Payment_Condition__c;
             part.Return_Location__c=lstPRC[0].Return_Location__c;
             part.Quantity__c=part.Quantity__c;
             part.Is_Inspected__c =part.Is_Inspected__c;
             part.claim__c=part.claim__c;
            }
          }
         }
        }
          return part;
          
      }
      
  
         
  }