public without sharing class BulkUploadValidate 
{
map<string,object> mapObj = new map<string,object>();
Warranty_Registration__c WRC = new Warranty_Registration__c();
Inventory__c Inv = new Inventory__c();
Account Acc = new Account();
BulkUploadMappertemp parserMap;
public String Err;

    public BulkUploadValidate()
    {
      parserMap = new BulkUploadMappertemp();
    }                                  
    public Void validate()
    {
        Err = '';
        Inventory__c invValue = null;  
        mapObj = parserMap.getMapperObjects();
        Acc = (Account)mapObj.get('AccountMapObj');
        Inv = (Inventory__c)mapObj.get('InventoryMapObj');
        WRC = (Warranty_Registration__c)mapObj.get('WRMapObj');
          
        List<Inventory__c> invRec = [Select id,Name,Model_Number__c,Account__c,Inventory__c.Type__c,Serial_Number__c,Units_Run__c,Stolen_inventory__c,Scrapped__c,Visual_Checklist_Completed__c from Inventory__c where Serial_Number__c =: Inv.Serial_Number__c];
        if(invRec.isEmpty())
         {
        
      //  Err = 'Inventory isnot Available';
       // return Err;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Inventory Not Available '));
         }
         else
         {
           invValue = invRec[0];
           if(invValue.type__c == 'Retail'){
           //     err = 'Already WR done' ;
           //     return err;      
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Warranty Registration Already completed for this Inventory.')); 
           }
           if(Inv.Units_Run__c < invValue.Units_Run__c)
           {
            // Err = 'Hour Meter Reading cannot be less than specified in inventory';
            //  return Err;
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Hour Meter Reading cannot be less than specified in inventory '+ invValue.Units_Run__c));            
           }
           if(invValue.Stolen_inventory__c || invValue.Scrapped__c)
           {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This inventory is scrapped or stolen. Kindly refer your admin.'));
           }
           if(!(invValue.Visual_Checklist_Completed__c))
           {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please complete the pen paper checklist and check the checkbox before doing warranty registration.'));
           }
           if(Inv.Install_Date__c > Date.today())
           {
            // Err = 'Purchase Date Cannot be Greather than Today';
            //return Err;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Purchase date cannot be Greather than Today ... '));            
           }
           if(Inv.Install_Date__c == null)
           {
            // Err = 'Purchase Date Cannot be Greather than Today';
            //return Err;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Purchase date cannot Empty ... '));            
           }
           if(Inv.Units_Run__c < 0)
           {
            // Err = 'Hour Meter Reading cannot be negative ';
            // return Err;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Hour Meter Reading cannot be negative '));            
           }
           Set<String> usageTypePickListValues = new Set<String>();
           Schema.DescribeFieldResult fieldResult = Warranty_Registration__c.Usage_Type__c.getDescribe();
           List<Schema.PicklistEntry> pickListEntryValue = fieldResult.getPicklistValues();
           for( Schema.PicklistEntry f : pickListEntryValue)
            {
            UsageTypePickListValues.add(f.getValue());
            }       
           if(!(usageTypePickListValues.contains(WRC.Usage_Type__c)))
           {
             // Err = 'Invalid Usage Type';
             // return Err;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Invalid Usage Type '));      
           }
           if(Acc.Name == '' || Acc.Name == null)
           {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Customer Name is Mandatory '));      
           }
           if(Acc.Email__c == '' || Acc.Email__c == null)
           {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Customer Email is Mandatory '));      
           }
        
        }
             
      //  return Err;
        
    }


}