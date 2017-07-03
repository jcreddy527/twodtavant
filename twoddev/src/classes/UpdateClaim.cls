/**********************************************************************
Name:  UpdateClaim
Copyright ? 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose: Class used find policy definition for non serilzied items

-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -     AKR                 12/14/2016     INITIAL DEVELOPMENT            
***********************************************************************/
global class UpdateClaim{
  @InvocableMethod()
  global static List<Claim__c> recurssionHandler(List<Claim__c> claimList) {
    ClaimFinancialControllerHelper.firstRun = true;     
    try{
    update claimList;}
    catch(Exception e){
    System.debug('Exception in UpdateClaim:'+e);
    }
    return claimList;
  }
}