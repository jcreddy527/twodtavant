public without sharing class BulkUploadMappertemp{
    
    // getting json object from staging object
    String jsonstring='{"AccCountry":"india","Hour Meter Reading":"10","Purchase Date":"03/17/2017","AccName":"Pradeep","AccEmail":"pradeep.ks@tavant.com","AccZipCode":"423567","AccWebsite":"erer","AccStreet":"dfdsfdsf","AccState":"Ap","AccPhone":"89787567657567567","Comments":"dfgdfg","SrNo":"1245","UsageType":"dDemo"}';
   //
    Account  acc;
    Inventory__c inv;
    Warranty_registration__c wr;
    //Bulk_Upload__c BulkUploadData;
  
    //public BulkUploadMappertemp(Bulk_Upload__c bulkUploadRec){
    public BulkUploadMappertemp()
    {
        //BulkUploadData = bulkUploadRec;
        //system.debug('BulkUploadData '+BulkUploadData );
        acc = new Account();
        inv = new Inventory__c();
        wr = new Warranty_registration__c();
        
    
    }
    
    public Map<String,Object> getMapperObjects(){
    
       // String jsonstring = BulkUploadData.Row_Detail__c; 
        //converting json to Map for iteration
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonstring);
        Map<String, Object> m1 = new Map<String, Object>();
        
        // getting all custom fields of Bulk upload
        Map<String, Bulk_Upload_Field_Mapping__c> mcs = Bulk_Upload_Field_Mapping__c.getAll();
        List<Bulk_Upload_Field_Mapping__c> bu =  Bulk_Upload_Field_Mapping__c.getAll().values();
        
        // mapping csv records with Account, inventory and warranty objects
        for(Bulk_Upload_Field_Mapping__c b : bu){
        
          
            if((b.Field_API_Name__c).contains('Account')){
            
                acc.put((b.Field_API_Name__c).substringAfter('.'),m.get(b.Excel_Column_Name__c));
 
            }else if((b.Field_API_Name__c).contains('Inventory')){
            
                  Schema.SObjectType t = Schema.getGlobalDescribe().get('Inventory__c');
 
                    Schema.DescribeSObjectResult r = t.getDescribe();
                    Schema.DescribeFieldResult f = r.fields.getMap().get((b.Field_API_Name__c).substringAfter('.')).getDescribe();
            
                    system.debug('type'+f.getType());
                    if(f.getType()==Schema.DisplayType.Double){
                        
                        inv.put((b.Field_API_Name__c).substringAfter('.'),integer.valueof(m.get(b.Excel_Column_Name__c)));
                    }else if(f.getType()==Schema.DisplayType.Date){
                        //   System.debug('datee'+date.valueOf(m.get(b.Excel_Column_Name__c)));
                       // String dayOrDate = (String)m.get(b.Excel_Column_Name__c);
//List<String> dateParts = dayOrDate.split('-');
//Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
//dayOrDate = dateWithTime.format('dd- MMM-yy');
//System.debug(dayOrDate);
                        String str = (String)m.get(b.Excel_Column_Name__c);
                        if(str != null)
                        {
                        Date mydate = Date.parse(str);
                        
                       // System.debug(mydate);
                         inv.put((b.Field_API_Name__c).substringAfter('.'),mydate);
                         }
                
                    }else{
                        
                           inv.put((b.Field_API_Name__c).substringAfter('.'),m.get(b.Excel_Column_Name__c));
     
                    }
            
                  }else{
            
                 wr.put((b.Field_API_Name__c).substringAfter('.'),m.get(b.Excel_Column_Name__c));
  
            }
        
        }
        
     // adding three objects into map and returning   
      m1.put('AccountMapObj',acc);
      m1.put('InventoryMapObj',inv);  
      m1.put('WRMapObj',wr);
      system.debug('mapper obj'+m1);
      
      return m1;
    
    }

  




}