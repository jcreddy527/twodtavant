public class customSettingsWrapper {
	@AuraEnabled
    public list<customSettingsRecordsWrapper> sObjectrecords { get;set; } 
    
    @AuraEnabled
    public  map<string, string> fieldsLabelMap { get;set; }
    
  
}