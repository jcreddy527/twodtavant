public with sharing class BulkUploadController {

    public Bulk_Upload__c bulkUpload { get; set; }
    public List<AsyncApexJob> asyncApex { get; set; }
    public List<Bulk_Upload__c> failBulkUpload { get; set; }
    public String nameFile { get; set; }
    public String selectedProcess { get; set; }
    public String customerInfo { get; set; }
    public Boolean showProcessSelection { get; set; }
    public Boolean newUpload { get; set; }
    public Boolean existingUpload { get; set; }
    public Boolean batchStatus { get; set; }
    public Blob contentFile { get; set; }
    @AuraEnabled
    public Integer totRec { get; set; }
    @AuraEnabled
    public Integer failRec { get; set; }
    @AuraEnabled
    public Integer succRec { get; set; }
    public ID batchId ;
    public static Response resp;
    
    public BulkUploadController() {
        this.bulkUpload = new Bulk_Upload__c();
        this.showProcessSelection = false;
        this.newUpload = false;
        this.existingUpload = false;
        this.customerInfo = 'ACC';
        this.batchStatus = false;
    }
    
    public List<SelectOption> getCustInfoOptions() {
        List<SelectOption> infoOptions = new List<SelectOption>();
        infoOptions.add(new SelectOption('ACC','Account'));
        infoOptions.add(new SelectOption('WR','Warranty Registration'));
        return infoOptions;   
    }
    
    public PageReference displayProcessSelection() {
        if(this.bulkUpload.Process_Type__c == 'Warranty Registration') {
            this.showProcessSelection = true;
        }else {
            this.showProcessSelection = false;
        }
        return null;
    }
    
    public PageReference displayNewUpload() {
        if(this.selectedProcess == 'NEW') {
            this.newUpload = true;
            this.existingUpload = false;
        }else {
            this.newUpload = false;
            this.existingUpload = true;
        }
        return null;
    }

    public PageReference Upload() {
        //Validating input file
        Boolean validated = validateFile();
        if(validated) {
            //Create records in the staging object with all lines in the csv
            Boolean stageUpdated = UpdateStagingObj();
            if(stageUpdated) {
                StartBatchProcess();
            }
        }
        return null;
    }

    public PageReference Cancel() {
        return null;
    }   

    public boolean validateFile() {
        //input file validations
        //Note : Hardcoded error messages need to be added in custom label
        if(nameFile == null || nameFile.trim() == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose a file to upload'));
            return false;
        }else {
            String fileName = nameFile;
            fileName = fileName.subString(fileName.indexOf('.')+1,fileName.length());
            if(fileName != 'csv') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The file should be in a .csv format'));
                return false;
            }
        }
        return true;
    }
    
    public boolean UpdateStagingObj() {
        try {
            String[] fileLines = new String[]{};
            List<Bulk_Upload__c> bulkupload = new List<Bulk_Upload__c>();
            //Convert the Blob format uploaded file to a string
            String fileStr = contentFile.toString();
            //Sepatate every row of the excel file
            fileLines = fileStr.split('\r\n');
            //Get the Column Header
            String[] csvColumns = fileLines[0].split(',');
            JSONGenerator gen;
            for (Integer i=1;i<fileLines.size();i++) {
                gen = JSON.createGenerator(true);
                String[] lineValues = fileLines[i].split(',');
                Bulk_Upload__c bu = new Bulk_Upload__c();
                gen.writeStartObject();
                for(Integer j=0;j<csvColumns.size();j++) {
                    gen.writeStringField(csvColumns[j],lineValues[j]);                 
                }
                gen.writeEndObject();
                bu.Name = this.bulkUpload.Process_Type__c;
                bu.Process_Type__c = this.bulkUpload.Process_Type__c;
                bu.Data_JSON__c = gen.getAsString();
                bulkupload.add(bu);  
            }
        insert bulkUpload;
        } catch(Exception e) {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage());
            ApexPages.addMessage(errormsg);
            return false;
        }
        return true;
    }
    Public void StartBatchProcess() {         
        //string query = 'select Errors__c from Bulk_Upload__c where Errors__c = \'\'';
        List<Bulk_Upload__c > buList = [Select Errors__c from Bulk_Upload__c ];
        totRec = buList.size();
        string query = 'Select Data_JSON__c, Process_Type__c, Errors__c from Bulk_Upload__c';
        BulkUploadBtchClss bUpload = new BulkUploadBtchClss(this.bulkUpload.Process_Type__c, query);
        batchId = Database.executeBatch(bUpload,1); 
        GetStatus();
    }
    @AuraEnabled
    public void GetStatus() {
        this.batchStatus = true;
        asyncApex  = [SELECT NumberOfErrors,Status,TotalJobItems, JobItemsProcessed, ExtendedStatus FROM AsyncApexJob where id =: batchId] ;   
        System.debug('batchId'+batchId);
        //test ='batchId'+asyncApec;
        failBulkUpload = [select Batch_Id__c, Data_JSON__c, Errors__c from Bulk_Upload__c ];
        failRec = failBulkUpload.size();
        succRec = totRec - FailRec;
    }
    @AuraEnabled
    public static List<AsyncApexJob> GetBatchDetails(String id) {
       return [SELECT NumberOfErrors,Status,TotalJobItems, JobItemsProcessed, ExtendedStatus FROM AsyncApexJob where id =: id] ;   
      
    }
    
    @AuraEnabled
    public static List<Integer> GetBatchrecords() {
       BulkUploadController  bl = new BulkUploadController();
       bl.totRec = 10;
       bl.succRec = 5;
       bl.FailRec = 6;
       List<Integer> l = new  List<Integer>();
       l.add(bl.totRec);
       l.add(bl.succRec );
       l.add(bl.FailRec);
       System.debug('list'+l);
       return l;
    }

    
    @AuraEnabled
    Public static Response getBatchId() { 
        Batch_Log__c batchLog = new Batch_Log__c();
        List<sobject> batchList = new List<sobject>();
        List<Bulk_Upload__c> bulkUploadLst = [select Process_Type__c from Bulk_Upload__c where Error_Count__c = 0 ];
        string query = 'Select Error_Count__c, Data_JSON__c, Process_Type__c, Errors__c from Bulk_Upload__c where Error_Count__c = 0';
        BulkUploadBtchClss bUpload = new BulkUploadBtchClss('WR', query);
        Id BatchId = Database.executeBatch(bUpload,1);
        batchLog.JobID__c = BatchId;
        batchLog.Name = 'WR'+BatchId;
        batchLog.Process_Type__c = 'WR';
        batchLog.Total_Record_Count__c = bulkUploadLst.size();
        batchLog.Success_Record_Count__c = 0 ;
        batchLog.Failure_Record_Count__c = 0;
        insert batchLog;
        resp = new Response(bulkUploadLst.size(),batchId, batchLog.Id);
        return resp;
    }     

	// Gets the different types of Bulk Uploads. e.g. Warranty Registration, Claim, etc.
	@AuraEnabled
	public static List<String> getProcessType() {
		List<String> options = new List<String>();
		Schema.DescribeFieldResult fieldResult = Bulk_Upload__c.Process_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry f: ple) {
    		options.add(f.getLabel());
		}
		return options;
    }

    @AuraEnabled
    public static void saveTheFile(String bulkUploadData, String processType) {
    	Bulk_Upload__c bulkUpload;
    	List<Bulk_Upload__c> bulkUploadList = new List<Bulk_Upload__c>();
        String csvFile = (EncodingUtil.base64Decode(bulkUploadData)).toString();
        String[] fileLines = csvFile.split('\r\n');
        String[] csvColumns = fileLines[0].split(',');               
        
        JSONGenerator gen;
        
        for (Integer i=1;i<fileLines.size();i++) {
            gen = JSON.createGenerator(true);
            bulkUpload = new Bulk_Upload__c();
            fileLines[i] = fileLines[i].replaceAll('""','').replaceAll(',"','###%%').replaceAll('",','%%###').replaceAll('"','');
            String[] inputValues = fileLines[i].split('###'); 
            for(Integer j=0;j<inputValues.size();j++) {
                if(inputValues[j].startsWith('%%') || inputValues[j].endsWith('%%')) {
                    inputValues[j]=inputValues[j].replaceAll(',','###');
                    inputValues[j]=inputValues[j].replaceAll('%%','');
                }
            }               
            fileLines[i] = String.join(inputValues,',');
            String[] outputValues = fileLines[i].split(','); 
            gen.writeStartObject();
            for(Integer j=0;j<csvColumns.size();j++) {
                gen.writeStringField(csvColumns[j],outputValues[j].replaceAll('###',','));                 
            }
            gen.writeEndObject();
            bulkUpload.Name= 'Warranty Registration';
            bulkUpload.Data_JSON__c = gen.getAsString();
			bulkUpload.Error_Count__c = 0;
			bulkUpload.Process_Type__c = processType;
            bulkUploadList.add(bulkUpload);                    
        }
		upsert bulkUploadList;
	}
    
    public class Response{
        @AuraEnabled
        public Integer RecordCnt;
        @AuraEnabled
        public Id BatchId;
        @AuraEnabled
        public Id BatchLogId;

        public Response(Integer cnt, Id btchId, Id BtchLogId) {
            RecordCnt = cnt;
            BatchId = btchId;
            BatchLogId = BtchLogId;
            
        }
    }    

}