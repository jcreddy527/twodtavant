({
    helperMethod : function() {
    },
    
    INBOX_REPORT_QUERY : "SELECT Id, Name, DeveloperName FROM Report WHERE OwnerId = ",
    INBOX_FOLDER_QUERY : "SELECT Id, Name, DeveloperName FROM Folder WHERE DeveloperName IN ",
    fetchReportData : function(component,event,reportOwnerId) {
        var query = this.INBOX_REPORT_QUERY +'\''+reportOwnerId+'\'';        
        console.log(this.INBOX_REPORT_QUERY);
        console.log($A.get("{!$Label.c.InboxReportFolders}"));
        this.readRaw(component, event,query,function(returnedValues) {
            var action = component.get('c.report');
            action.setParams({ rep : returnedValues });            
            action.setCallback(this, function(response) {
                console.log('response.getReturnValue()::::');
                var res=JSON.parse(response.getReturnValue());
                console.log(res);
                
                component.set("v.columnCount",res.length);
                component.set("v.sObjectReports",res);
                       
            });
            $A.enqueueAction(action);
            //component.set("v.sObjectReports",returnedValues);
        });
        
    },
    
    fetchFolderData : function(component,event) {
        
        var query = (this.INBOX_FOLDER_QUERY + "(" + $A.get("{!$Label.c.ReportFolderId}") + ")"); 
        this.readRaw(component, event,query,function(response) {
            var spinner = component.find('spinnerID1');
                console.log('spinner-->' + spinner);
                $A.util.removeClass(spinner,'slds-show');
                $A.util.addClass(spinner,'slds-hide'); 
            component.set("v.sObjectFolders",response); 
            
        });
        
    }
})