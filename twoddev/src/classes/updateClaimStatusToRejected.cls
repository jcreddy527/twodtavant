global class updateClaimStatusToRejected{
   @InvocableMethod
   public static void callActionClaim(List<Claim__c> claimRecord) {
       ActionClaimController.updateClaim(claimRecord[0],'Rejected',null,null);
      }
      
   }