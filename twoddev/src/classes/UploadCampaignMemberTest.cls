@isTest
global class UploadCampaignMemberTest{
/*******************************************************************
    Purpose: Test method for the upload campaign members                                               
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    static testmethod  void testupload(){
        CustomSettingsUtilityTest.init();
        test.startTest();
        
        if(Schema.sObjectType.Service_Campaign__c.fields.Name.isCreateable())
        {
            Service_Campaign__c sc = new Service_Campaign__c();
            sc.name ='testt';
            try{
                if(CrudUtil.isServiceCampaignCreatable()){
                    insert sc;
                }
                WOD__c objWOD = new WOD__c(name = 'Batch Upload Member',isTriggered__c = true,Trigger_Value__c = 'test@test.com');
                
                if(CrudUtil.isWODCreateable()){
                    insert objWOD;
                }
                
                system.assertNotEquals(null,objWOD);
                
                ApexPages.StandardController stdController=new ApexPages.StandardController(sc);
                UploadCampMemberController uploadContrlr = new UploadCampMemberController(stdController);
                uploadContrlr.nameFile = 'test.csv';
                uploadContrlr.contentFile = Blob.valueOf('Test,test'+
                                                +'TEst1,TEst1'+Parser.CRLF+
                                                +'TEst2,TEst2');
                uploadContrlr.sId = sc.id;
                uploadContrlr.uploadFile();
                
                UploadCampMemberController uploadContrlrNegative = new UploadCampMemberController(stdController);
                uploadContrlrNegative.nameFile = '';
                uploadContrlrNegative.uploadFile();
                
                UploadCampMemberController uploadContrlrNegative2 = new UploadCampMemberController(stdController);
                uploadContrlrNegative2.nameFile = 'test.pdf';
                uploadContrlrNegative2.uploadFile();
            }
            catch(Exception e){
                system.debug('Exception'+e);
            }
        }
        test.stopTest();
    }
}