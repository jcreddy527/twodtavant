/**********************************************************************
 Name:  RecordTypeUtils
 Copyright ? 2017  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Class is used to get recordType Id using developer name.                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          11/21/2016     INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class RecordTypeUtils {
	
    //variable declaration
    private static List<sObject> results;
    private static Map<Id,Schema.RecordTypeInfo> recordTypeInfos;
    private static string recordTypeId;
    //static method to return recordtypeId as a return type
    global static string getRecordTypeId(string developerName,Schema.SObjectType token){
        
        //Initialization
        results = new List<sObject>();
        recordTypeId = '';
        recordTypeInfos = new Map<Id,Schema.RecordTypeInfo>();
        
    	// Get the Describe Result
    	Schema.DescribeSObjectResult obj = token.getDescribe();
		
        // Obtain the RecordTypeInfos for this SObjectType token
        recordTypeInfos = obj.getRecordTypeInfosByID();
        
        
    	//Check if we already queried all recordtypes.
    	if (results == null || results.isEmpty()) {
    	// Obtain ALL Active Record Types
            String soql = 'SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE and DeveloperName=:developerName';
            try {
                results = Database.query(soql);
            } catch (Exception ex) {
                results = new List<SObject>();
            }
    	}
        
       
    	// Loop through all of the Record Types we found,
    	// and weed out those that are unavailable to the Running User
    	for (SObject rt : results) { 
            if (recordTypeInfos.get(rt.Id) != null) {
                if (recordTypeInfos.get(rt.Id).isAvailable()) {
                	recordTypeId = rt.Id;
                }
                else {
                    System.debug('The record type is not availiable for the user.');
                }
            }
    	}
        system.debug('the id'+recordTypeId);
        return recordTypeId;
    }
}