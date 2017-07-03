global class SobjectRecLockUnlockUpdService
{
/*webservice static void LockUnlockBasedOnAction(sobject SobjectRecord) // you can pass parameters
{

/*       system.debug('::the Claim Record'+SobjectRecord);

//Setting Approval For the 'OnHold Status'
if(Approval.isLocked(SobjectRecord.id) == True){
//Unlock the Record
Approval.unlock(SobjectRecord);

//Update The Record
update SobjectRecord;

//Lock the Record
Approval.lock(SobjectRecord);

system.debug('::The Lock status after lock'+Approval.isLocked(SobjectRecord.id));

}else if(Approval.isLocked(SobjectRecord.id) == False){

//    SobjectRecord.Status__c = 'On Hold';

}


} */
@AuraEnabled
webservice static void LockUnlockBasedOnAction1(Id recordId,  String fieldToModify, String valueToPut) // you can pass parameters
{

    system.debug('----------'+recordId);
    system.debug('----------'+fieldToModify);
    system.debug('----------'+valueToPut);
    String EscrecordId = String.escapeSingleQuotes(recordId);
    String EscFieldToModify = String.escapeSingleQuotes(fieldToModify);
    sObject SobjectRecord = Database.Query('SELECT Id,' + EscFieldToModify + ' FROM ' + recordId.getSObjectType() + ' WHERE Id = \'' + EscrecordId + '\'');
    SobjectRecord.put(fieldToModify,valueToPut);
    //Setting Approval For the 'OnHold Status'
    if(Approval.isLocked(recordId) == True){
        //Unlock the Record
        Approval.unlock(SobjectRecord);

        //Update The Record
        update SobjectRecord;


        /************************************************************/
        /*
Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
req1.setComments('Submitting request for approval.');
req1.setObjectId(SobjectRecord.id);

// Submit on behalf of a specific submitter
req1.setSubmitterId(UserInfo.getUserId());

// Submit the record to specific process and skip the criteria evaluation
req1.setProcessDefinitionNameOrId('PTO_Request_Process');
req1.setSkipEntryCriteria(true);

// Submit the approval request for the account
Approval.ProcessResult result = Approval.process(req1);
*/

        // Approve the submitted request
        // First, get the ID of the newly created item+


        List<ProcessInstanceWorkitem > processInstanceList = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId AND ProcessInstance.Status = 'Pending'];

        if(!processInstanceList.isEmpty()){

           Id recId = processInstanceList[0].Id;
           List<Id> newWorkItemIds =  new list<Id>();//result.getNewWorkitemIds();
        newWorkItemIds.add(recId);
        // Instantiate the new ProcessWorkitemRequest object and populate it
        //  Pending a061500000XTGhBAAX

        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        if(valueToPut=='Approved')
        {
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        }

        if(valueToPut=='Rejected')
        {
        req2.setComments('Rejecting request.');
        req2.setAction('Reject');
        }


        //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(recId);

        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);

        /*********************************************************/

        //Lock the Record
        Approval.lock(SobjectRecord);

        system.debug('::The Lock status after lock'+Approval.isLocked(SobjectRecord.id));
        }else{

            system.debug('query on ProcessInstanceWorkitem object did not returned any id on ---Pending--- status, record cannot be locked further');

        }




    }else if(Approval.isLocked(SobjectRecord.id) == False){


        //Update The Record
        update SobjectRecord;
    }




}
}