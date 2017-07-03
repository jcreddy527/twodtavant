public without sharing class BulkUploadMapper{
    
    // getting json object from staging object
    String jsonstring='{"AccCountry":"india","Hour Meter Reading":"8","AccZipCode":"423567","AccWebsite":"erer","AccStreet":"dfdsfdsf","AccState":"Ap","AccPhone":"89787567657567567","AccEmail":"pradeep.ks@tavant.com","Accname":"Tavant","Comments":"dfgdfg","SrNo":"1234","Purchase Date":"04/04/2017","UsageType":"blaDemo"}';
   
    Account  acc;
    Inventory__c inv;
    Warranty_registration__c wr;
    Bulk_Upload__c BulkUploadData;
  
    public BulkUploadMapper(Bulk_Upload__c bulkUploadRec){
        bulkUploadData = bulkUploadRec;
        acc = new Account();
        inv = new Inventory__c();
        wr = new Warranty_registration__c(); 
    
    }
    
    public Map<String,Object> getMapperObjects(){
        String jsonstring = bulkUploadData.Data_JSON__c;
        //converting json to Map for iteration
        Map<String, Object> StagingMap = (Map<String, Object>)JSON.deserializeUntyped(jsonstring);
        Map<String, Object> WarrantyObjectsMap = new Map<String, Object>();
        
        // getting all custom fields of Bulk upload
        Map<String, Bulk_Upload_Field_Mapping__c> mcs = Bulk_Upload_Field_Mapping__c.getAll();
        List<Bulk_Upload_Field_Mapping__c> bu =  Bulk_Upload_Field_Mapping__c.getAll().values();
        
        // mapping csv records with Account, inventory and warranty objects
        for(Bulk_Upload_Field_Mapping__c b : bu){
        
            if((b.Field_API_Name__c).contains('Account')){
            
                acc.put((b.Field_API_Name__c).substringAfter('.'),StagingMap.get(b.Excel_Column_Name__c));
 
            }else if((b.Field_API_Name__c).contains('Inventory')){
            
                  Schema.SObjectType t = Schema.getGlobalDescribe().get('Inventory__c');
                  Schema.DescribeSObjectResult r = t.getDescribe();
                  Schema.DescribeFieldResult f = r.fields.getMap().get((b.Field_API_Name__c).substringAfter('.')).getDescribe();
            
                    if(f.getType()==Schema.DisplayType.Double){
                        
                        inv.put((b.Field_API_Name__c).substringAfter('.'),integer.valueof(StagingMap.get(b.Excel_Column_Name__c)));
                        
                    }else if(f.getType()==Schema.DisplayType.Date){
                      
                       String str = (String)StagingMap.get(b.Excel_Column_Name__c);
                       if(str != null)
                       {
                       Date mydate = Date.parse(str);
                       inv.put((b.Field_API_Name__c).substringAfter('.'),mydate );
                       }
                
                    }else{
                        
                           inv.put((b.Field_API_Name__c).substringAfter('.'),StagingMap.get(b.Excel_Column_Name__c));
     
                    }
            
                  }else{
            
                 wr.put((b.Field_API_Name__c).substringAfter('.'),StagingMap.get(b.Excel_Column_Name__c));
  
            }
        
        }
        
     // adding three objects into map and returning   
      WarrantyObjectsMap.put('AccountMapObj',acc);
      WarrantyObjectsMap.put('InventoryMapObj',inv);  
      WarrantyObjectsMap.put('WRMapObj',wr);
         
      return WarrantyObjectsMap;
    
    }

  




}