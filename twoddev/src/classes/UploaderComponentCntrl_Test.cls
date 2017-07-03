@isTest
public class UploaderComponentCntrl_Test {
    public static testMethod void testUploaderComponentCntrl(){
        Account accRecord = new Account();
        accRecord.Name = 'test';
        insert accRecord;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=accRecord.id;
        insert attach;
    	
        //UploaderComponentCntrl uploader = new UploaderComponentCntrl();
        Test.startTest();
        UploaderComponentCntrl.uploadChunk(accRecord.Id, 'Unit Test Attachment', 'UTF8', 'text', '');
        UploaderComponentCntrl.uploadChunk(accRecord.Id, 'Unit Test Attachment', 'UTF8', 'text', String.valueOf(attach.Id));
        UploaderComponentCntrl.deleteAttachment(attach.Id);
        Test.stopTest();
    }
    
}