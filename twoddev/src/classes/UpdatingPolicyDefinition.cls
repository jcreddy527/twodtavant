global with sharing class UpdatingPolicyDefinition {

        @AuraEnabled
    global static void updatePolicyDefinition(String claimId) {
            // Call the Flow
            Map<String, Object> params = new Map<String, Object>();
            params.put('VarClaimId', claimId);
           // Flow.Interview.Updating_Policy_Definition_in_Claim calcFlow = new Flow.Interview.Updating_Policy_Definition_in_Claim(params);
            //calcFlow.start();
        }
}