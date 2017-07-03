/**
* Class name       : ActionClaimUtility
* Created By       : Shambhvi Dixit
* Created Date     : 10-13-2016
* Description      : 
**/
public class ActionClaimUtility {
    
     public static final String RESPONSIBLECODE = 'Responsible_Code__c';
     //public static final String APPROVALACTIONS = 'Claim approval actions';    
     public static final String ALLPAYMENTCONFIG = 'All Payment Configurations';
     public static final String APPROVED = label.Calim_Action_Status_As_Approved;
     public static final String REJECTED = label.Calim_Action_Status_As_Rejected;
     public static final String ONHOLD = label.Calim_Action_Status_As_On_hold;
     public static final String OPEN = label.Calim_Action_Status_As_Open;
     public static final String NEEDMOREINFO = label.Calim_Action_Status_As_Additional_Information_Required;
     //public static final String SETACTIONAPPROVED = 'Approved';
     //public static final String SETACTIONREJECT = 'Reject';
     public static final String objName = 'Claim__c';
    
     //get Picklist values from a field in a Select List
     @AuraEnabled 
    public static list<String> getPicklistValues(SObject obj, String fld){
        list<string> options = new list<string>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
         Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
        fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        { 
            options.add(a.getLabel()); 
        }
        return options;
    }
}