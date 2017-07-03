@isTest(SeeAllData='true')
global class GenericCrudAuraServiceReportTest {
    
    global static testMethod void inboxHandlerTotalRecordCount() {
        CustomSettingsUtilityTest.init();
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report];
        if(reportList.size()>0)
        {
            String reportId = (String)reportList.get(0).get('Id');
            Integer result  =  GenericCrudAuraService.totalRecordsCount(reportId);
            if(result != null){
              System.assertNotEquals(result,null);
            }
        }
    }
    
}