/**
* Class name       : ClaimValidationController
* Created By       : Shambhvi Dixit
* Created Date     : 30-09-2016
* Description      : 
**/

global class ActionClaimController {
    
    public ActionClaimController(ApexPages.StandardController stdController) { 
    }  

    //get Responsiblecode for claim 
    // added new comment add
    @AuraEnabled
    public static List<String> getResponsibleCodeOption(){
        List<string> ResponsibleCodeOption = new List<string>();                
        Claim__c claimObj = new Claim__c();
        ResponsibleCodeOption = ActionClaimUtility.getPicklistValues(claimObj,ActionClaimUtility.RESPONSIBLECODE);        
        return ResponsibleCodeOption;    
    } 
    //Get the fields from custom setting
    @Auraenabled
    Public static list<string> getFields(){        
        WOD__c paymenttype = WOD__c.getInstance(ActionClaimUtility.ALLPAYMENTCONFIG);
        List<String> paymentTypeList = new List<String>();
        paymentTypeList = paymenttype.Trigger_Value__c.split(',');
        paymentTypeList.add('Parts');
        return paymentTypeList;
    }
    
    // returning claim record for particular case id 
    @Auraenabled
    public  static Claim__c getClaimDetails (id claimID){
        //system.debug('claimID'+claimID);
        try{
            string query;
            SObjectType objectSchema;
            Map<String, Schema.SObjectField> claimFieldMap;
            list<Claim__c> claimSobj = new list<Claim__c>();
            //--Getting claim object field api names dynamically
            objectSchema = schema.getGlobalDescribe().get(ActionClaimUtility.objName);
            claimFieldMap = objectSchema.getDescribe().fields.getMap();
            
            //--Construct generic query string used to query claim data dynamically
            query ='select ';
            for(Schema.SObjectField s : claimFieldMap.values()){
                     query = query + s.getDescribe().getName()+',';                   
            }
            query = query.removeEnd(','); 
            query = query + ' from Claim__c where id =: claimID limit 1'; 
            claimSobj = Database.query(query);
            if(claimSobj.size()>0){
                system.debug('Claim Result'+claimSobj);
                return claimSobj[0] ;
            }else{
                return null ;
            }  
        }catch(Exception e){
            system.debug('Exception--->'+e.getCause());
            throw e;
        }
    }
    
    //Get list of actions for approval from Custom label
    @AuraEnabled
    public  static list<string> getApprovalAction (String currentStatus){        
        Map<string, ClaimActions__c> ClaimActionsMap =  ClaimActions__c.getAll();
        List<String> lstApprovalActions = new List<String>();
        for(String str:ClaimActionsMap.keySet()){
            if(str == currentStatus){
                ClaimActions__c claimStatusList = ClaimActionsMap.get(str);
                lstApprovalActions.add('--None--');
                lstApprovalActions.addAll(claimStatusList.Status_Values__c.split(','));                
            }   
        }
        return lstApprovalActions;
    }
    
    // update the existing case record according to getting value from lighting component
    @AuraEnabled
    public static Claim__c updateClaim(Claim__c clm, string actionRequire, String currentComments, Decimal approvedClaimCost) {       
        try{
            
            //claim Action = Approved
            if(actionRequire == ActionClaimUtility.APPROVED){
                //update claim Record
                 if(approvedClaimCost!=null){
                    clm.Approved_Claim_Cost__c = approvedClaimCost;   
                }
                system.debug('the clm is'+clm);
                update clm;
                //update approval process record.
                updateApprovalProcessRequest(clm,actionRequire,currentComments);
            }            
            if(actionRequire == ActionClaimUtility.REJECTED || actionRequire == ActionClaimUtility.NEEDMOREINFO){
                //update approval process record.               
                updateApprovalProcessRequest(clm,actionRequire,currentComments);
                
                //update claim Record
                Claim__c claim = new Claim__c();
                claim.Internal_Comments__c = clm.Internal_Comments__c;
                claim.Id =  clm.Id;
                if(actionRequire == ActionClaimUtility.NEEDMOREINFO){
                    claim.Claim_Status__c = ActionClaimUtility.NEEDMOREINFO;    
                }
                
                update claim;
            }
            if(actionRequire == ActionClaimUtility.ONHOLD){
                //update claim Record
                clm.Claim_Status__c = ActionClaimUtility.ONHOLD;
                update clm;
            }
            if(actionRequire == ActionClaimUtility.OPEN){
                //update claim Record
                clm.Claim_Status__c = ActionClaimUtility.OPEN;
                if(clm.Internal_Comments__c!='' && clm.Internal_Comments__c!=null){
                    clm.Internal_Comments__c = clm.Internal_Comments__c+','+currentComments;    
                }
                else{
                    clm.Internal_Comments__c = currentComments;       
                }
                
                update clm;
            }
        }
        catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());        
        }
        return clm;      
    } 
    
    // Upate Approval process records
    public static void updateApprovalProcessRequest(Claim__c cm,String action, String currentComments){
         system.debug(Cm+'--'+action);
       
        //get id of current claim record
        Id reqObjId=getWorkItemId(cm.Id);
            //[SELECT Id FROM ProcessInstanceWorkitem WHERE TargetObjectId =: cm.Id limit 1].id;  
        system.debug(reqObjId+'id');
        
        //Instantiate the new ProcessWorkitemRequest object and populate it
        if(reqObjId!=null){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(currentComments);
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setWorkitemId(reqObjId);
        
            //check the action
            if(action== ActionClaimUtility.APPROVED){
                req.setAction('Approve'); 
            }
            if(action == ActionClaimUtility.REJECTED || action == ActionClaimUtility.NEEDMOREINFO){
                req.setAction('Reject');  
            } 
        
            //Approve/Reject the request for approval
            Approval.ProcessResult result2 =  Approval.process(req);
            system.debug(result2);               
        }
               
    }
    
    //returning work item Id
    public static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }
        return retVal;
    }
    
    //return the current approver same as logged user.
    @AuraEnabled
    public static boolean getCurrentApproverId(Id targetObjectId){
        Boolean accessAvailable = false;
        Id userId = UserInfo.getUserId();
        Id loggedprofileId = UserInfo.getProfileId();
        List<Id> groupIds = new List<Id>();
        List<Id> groupUserIds = new List<Id>();
        
        List<ProcessInstanceWorkitem> workItemList = new List<ProcessInstanceWorkitem>();
        workItemList  = [Select p.Id,OriginalActorId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId];       
        if(!workItemList.isEmpty()){
            for(ProcessInstanceWorkitem workItem:workItemList){
                String s1 = workItem.OriginalActorId;
                if(s1.startsWith('00G')){                  
                    groupIds.add(s1);    
                }
                else{
                    if(workItem.OriginalActorId == userId){
                        accessAvailable = true;
                    }    
                }
            }  
        }
        if(!groupIds.isEmpty()){
            groupUserIds = getUserList(groupIds);
            for(Id groupUserId :groupUserIds){
                if(groupUserId == userId){
                    accessAvailable = true;
                }
            }
            
        }
        
        //Profile checking        
        List<String> profileIds = new List<String>();                         
        WOD__c profileIdList = WOD__c.getInstance('Allowed Ids');
        profileIds = profileIdList.Trigger_Value__c.split(',');                                              
        if(!profileIds.isEmpty()){
            for(Id profileId : profileIds){
                if(profileId == loggedprofileId){
                    accessAvailable = true;
                }
            }
        }
        
        return accessAvailable;
    }
    
    
    //variable
    public static List<Id> userIds = new List<Id>();
    public static List<Id> getUserList(List<Id> Ids){
        List<Id> groupIds = new List<Id>();
        List<GroupMember> queueList = [Select UserOrGroupId From GroupMember where GroupId IN:Ids];
        for(GroupMember gm: queueList){
            String s2 = gm.UserOrGroupId;
                if(s2.startsWith('00G')){
                    groupIds.add(s2); 
                }
                else{
                    userIds.add(s2);
                }       
         }
        if(!groupIds.isEmpty()){
            getUserList(groupIds);
        }
        return userIds;
    }
}