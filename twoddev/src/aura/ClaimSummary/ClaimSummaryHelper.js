({

	validateClaim :true,
	visible : function(component,Element) {
									var pageElement = component.find(Element);
									console.log(pageElement);
								 $A.util.removeClass(pageElement, 'slds-hide');
	},
	invisible: function(component,Element){
									 var pageElement = component.find(Element);
									 console.log(pageElement);
									 $A.util.addClass(pageElement, 'slds-hide');
	},
	CLAIM_QUERY : 'Select Units_Run__c,Id, Name,Total_Parts_Cost__c,Claim_Status__c,RecordTypeId,RecordType.DeveloperName,Delay_Reason__c,Date_Of_Purchase__c,Invoice_Number__c, RecordType.Name,Service_Ticket__c,Work_order__c, Account__r.Name, Inventory__r.Name, Campaign_Members__r.Name, Warranty_Product__r.Name,Fault_Code__r.Name,Fault_Code__r.Description__c, Causal_Part_Number__r.Name,Causal_Part_Number__r.Description__c, Applicable_Policy__r.Name,Account__c,Inventory__c,Warranty_Product__c,Campaign_Members__c,Host_NonHost__c,Serial_Number__c,Date_of_Failure__c,Date_of_Repair__c,Applicable_Policy__c,Fault_Code__c,Causal_Part_Number__c,Request_SMR__c,Claim_Parts_Pending_Approval__c,SMR_Reason__c,Override_Policy__c,TravelByHours__c,TravelByDistance__c,Total_Labor_Cost__c,Final_Labor_Cost__c,Total_TravelByDistance_Cost__c,Final_TravelByDistance_Cost__c,Final_Parts_Cost__c,Total_TravelByHours_Cost__c,Final_TravelByHours_Cost__c,Total_Meals_Cost__c,Final_Meals_Cost__c,Total_Parking_Cost__c,Final_Parking_Cost__c,Percent_Labor_Cost__c,Approved_Labor_Cost__c,Percent_TravelByDistance_Cost__c,Approved_TravelByDistance_Cost__c,Percent_TravelByHours_Cost__c,Approved_TravelByHours_Cost__c,Percent_Parts_Cost__c,Approved_Parts_Cost__c,Percent_Meals_Cost__c,Approved_Meals_Cost__c,Percent_Parking_Cost__c,Approved_Parking_Cost__c,Percent_Claim_Cost__c,Approved_Ignore_Sum__c,Final_Claim_Cost__c,Approved_Claim_Cost__c,Description__c,TravelByLocation__c,Fault_Code_Comment__c,CasualPart_Comments__c,work_Performed_comments__c,(Select Id,Name,Shipment_Due_Days__c,Return_Location__r.Name from Removed_Claim_Parts__r where Return_Location__c!=null)  from Claim__c Where Id= ',


})