@isTest(SeeAllData=true)
global class InboxReportFolderController_Test {
    static testmethod void testInboxReportFolder(){
    	
    	List<Report> reportList = [Select id,DeveloperName FROM Report WHERE DeveloperName = 'Warranty_Expense_by_Fault'];
    	system.debug('reportList-->'+reportList);
    	InboxReportFolderController.report(reportList);
    }
}