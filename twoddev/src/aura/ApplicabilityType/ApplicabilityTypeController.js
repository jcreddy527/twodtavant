({
    doInit : function(component, event, helper) { 
        helper.getApplicabilityTypes(component);
        helper.getWRFieldMappings(component);
        
    },
    onATypeChange : function(component, event, helper) { 
        helper.getApplicabilitySubTypes(component);
        helper.removeNoneOption(component);
        helper.selectedRecordsblockHideAndShow(component);
    },
    onASTChange : function(component, event, helper) {                
        component.set("v.RelatedTo", document.getElementById("ApplicabilitySubType").value);        
    },    
    relatedToPopUp :  function(component, event, helper){
        var searchBarInput = document.getElementById("SearchKey");
        searchBarInput.value = '';        
        helper.getRecords(component, undefined, undefined);
        helper.showPopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.showPopupHelper(component,'backdrop','slds-backdrop--');
    },
    hidePopup :  function(component, event, helper){
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');
        helper.displaySelected(component);
    },
    searchKeyChange: function(component, event, helper) {
        var searchKey; 
        if(event != undefined){
            searchKey = event.getParam("searchKey");
        }
        helper.getRecords(component, event, searchKey);        
    },
    saveRecord: function(component, event, helper) { 
        helper.saveRecord(component, event, helper);
    },
    deleteRecords: function(component, event, helper) {
        helper.deleteRecords(component);
    },
    cancel: function(component, event, helper) {
        helper.cancel(component);
    },
})