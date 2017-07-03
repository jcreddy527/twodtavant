/*************************************************************
Name:  DateOfFailureChangesOnClaim_Class 
Copyright © 2016  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Class is being called by Trigger on claim i.e "onPolicyChange "                                                   
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION    AUTHOR              DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -   Shambhavi         27/12/2016       INITIAL DEVELOPMENT            
    
**************************************************************************************************/
public with sharing class DateOfFailureChangesOnClaim_Class {
    
      public void checkRemovedPart (Claim__c newClaim){
     
	     Map<String, Object> myMap = new Map<String, Object>();
	    List<Removed_Claim_Part__c> rclaim=new list<Removed_Claim_Part__c>();
	    rclaim=[Select id,Claim__c,Inventory__c,Is_Approved__c,Is_Inspected__c,Part_Return_Configuration__c,Part_Return_Requested__c,Payment_Condition__c From Removed_Claim_Part__c where Claim__c =:newClaim.id];
	    
	    for(Removed_Claim_Part__c rc:rclaim){
	        myMap.put('RemovedPart',rc);
	        Flow.Interview.FindPRC findPrcFlow= new Flow.Interview.FindPRC(myMap);
	        findPrcFlow.start();
	  }
   }
}