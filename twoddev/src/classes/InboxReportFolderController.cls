public class InboxReportFolderController {
    
    @AuraEnabled
    public static String report(List<Report> rep)
    {
        String returnable = '';
        List<reportWrapperClass> reportWrapperList=new List<reportWrapperClass>();
        //List<Warranty_Inbox__c> WarrantyInboxCustomSettingList = new List<Warranty_Inbox__c>();//----------using custom setting
        List<Warranty_Report_Inbox__mdt> WarrantyInboxList = new List<Warranty_Report_Inbox__mdt>();//----------using custom metadata
        List<String> reportNameList=new List<String>();
        List<List<reportWrapperClass>> dataList = new List<List<reportWrapperClass>>();
        Integer MaxColumCount=0;
        
        for(report repLoop:rep){
            reportNameList.add(repLoop.DeveloperName);
        }
        system.debug('reportNameList-->'+reportNameList);
        system.debug('Logged in Users Language'+UserInfo.getLanguage());
        
        String UserLanguage ='%'+(UserInfo.getLanguage()).substringBefore('_')+'%';
        system.debug('UserLanguage -->'+UserLanguage);
        
        Id id1 = UserInfo.getProfileId();
        String profileId = String.valueOf([Select Id,Name from Profile where Id =: id1].Id).substring(0, 15);
        System.debug('******************profileId' +profileId);
        
        if(reportNameList.size()>0){
            WarrantyInboxList = [Select id,Report_Name__c,Report_Display_Name__c,Applicable_Profiles__c,Column__c,Language_Code__c,Report_Image__c from Warranty_Report_Inbox__mdt where Report_Name__c IN: reportNameList AND Language_Code__c LIKE :UserLanguage];
        }
        system.debug('WarrantyInboxList-->'+WarrantyInboxList);
        
        for(report repLoop:rep)
        {
            for(Warranty_Report_Inbox__mdt customMetaData : WarrantyInboxList){
                if(customMetaData.Applicable_Profiles__c != null){
                    system.debug('repLoop.DeveloperName-->'+repLoop.DeveloperName);
                    system.debug('customMetaData.Report_Name__c-->'+customMetaData.Report_Name__c);
                    if(repLoop.DeveloperName == customMetaData.Report_Name__c){
                        system.debug('customMetaData.Applicable_Profiles__c-->'+customMetaData.Applicable_Profiles__c);
                        if(customMetaData.Applicable_Profiles__c != null && (customMetaData.Applicable_Profiles__c).Contains(profileId)){
                            system.debug('inside if');
                            reportWrapperClass reportWrapper=new reportWrapperClass();
                            reportWrapper.Name=customMetaData.Report_Display_Name__c;
                            reportWrapper.DeveloperName=repLoop.DeveloperName;
                            reportWrapper.Id=repLoop.Id;                        
                            reportWrapper.Report_Image=customMetaData.Report_Image__c;
                            reportWrapper.columnCount=integer.valueOf(customMetaData.Column__c);
                            reportWrapperList.add(reportWrapper);
                            
                        }
                    }
                }else{
                    if(repLoop.DeveloperName == customMetaData.Report_Name__c){
                        system.debug('inside if::');
                        reportWrapperClass reportWrapper=new reportWrapperClass();
                        reportWrapper.Name=customMetaData.Report_Display_Name__c;
                        reportWrapper.DeveloperName=repLoop.DeveloperName;
                        reportWrapper.Id=repLoop.Id;                        
                        reportWrapper.Report_Image=customMetaData.Report_Image__c;
                        reportWrapper.columnCount=integer.valueOf(customMetaData.Column__c);
                        reportWrapperList.add(reportWrapper);
                    }
                }
            }
        }
        MaxColumCount=Integer.ValueOf([Select id,Column__c from Warranty_Report_Inbox__mdt ORDER BY Column__c desc LIMIT 1].Column__c);
        
        system.debug('MaxColumCount-->'+MaxColumCount);
        system.debug('reportWrapperList-->'+reportWrapperList);
        
        for(Integer i=0;i<=MaxColumCount;i++)
        {
            List<reportWrapperClass> rwl=new List<reportWrapperClass>();
            dataList.add(rwl);
        }
        for(reportWrapperClass rwl:reportWrapperList)
        {
            Integer col=Integer.valueof(rwl.columnCount);
            dataList[col-1].add(rwl);
        }
        returnable = JSON.serialize(dataList);
        return returnable;
    }
    
    public class reportWrapperClass{
        String Name{get;set;}
        String Id{get;set;}
        String DeveloperName{get;set;}
        String Report_Image{get;set;}
        Integer columnCount{get;set;}
    }
}