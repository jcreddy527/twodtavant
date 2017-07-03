({
    Recovery_Claim_Record : 'SELECT Id,Name,Status__c, Total_Approved_Amount__c,Supplier_Contract__r.Minimum_recoverable_percent__c,Comments__c,Final_Claim_Cost__c from Supplier_Recovery_Claim__c where id = ',
	
    RedirectToTheDetailPage : function(component,RecordId) {
        var ReturnUrl = component.get("v.baseURL") + '/' + RecordId;
        window.location.href = ReturnUrl;
	}
})