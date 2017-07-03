global with sharing class GlobalVariable {
    
    global static String get(String name){
        String returnValue = null;
        final Map<String,Lookup_Layout_Fields__c> all = Lookup_Layout_Fields__c.getAll();
        if(    name != null 
            && name.trim() != null 
            && name.trim().length() > 0 
            && all != null 
            && all.get(name) != null
        ){
            returnValue = all.get(name).Field1__c;
        }
        return returnValue;
    }

    global static String put(String name, String value){
        String returnValue = null; //the previous value
        if(    name != null 
            && name.trim() != null 
            && name.trim().length() != 0
        ){
            Lookup_Layout_Fields__c record = null;
            try{
                record = [   
                    select id,Field1__c 
                    from Lookup_Layout_Fields__c 
                    where name = :name
                ];
            }catch(QueryException e){}
            if(record == null){
                record = new Lookup_Layout_Fields__c(
                     name     = name 
                    ,Field1__c = value
                );
            } else {
            	
            	if(!Schema.sObjectType.Lookup_Layout_Fields__c.fields.Field1__c.isAccessible()){
            		
            		 record.addError(crudUtil.INSUFFICIENT_ACCESS_TGR);
            	}
            	else{
            		
            		returnValue = record.Field1__c;
            	}
                
            }
            if((record.id != null && Schema.sObjectType.Lookup_Layout_Fields__c.fields.Field1__c.isUpdateable()) ||
            	(record.id == null && Schema.sObjectType.Lookup_Layout_Fields__c.fields.Field1__c.isCreateable())
            )            
            {
            	record.Field1__c = value;
            }
            if(record.id != null){
            	if(CrudUtil.isLookUpLayoutUpdateable()){
            		update record;
            	}
                
            } else {
            	if(CrudUtil.isLookUpLayoutCreateable()){
            		insert record;
            	}
                
            }
        }
        return returnValue;
    } 

    
}