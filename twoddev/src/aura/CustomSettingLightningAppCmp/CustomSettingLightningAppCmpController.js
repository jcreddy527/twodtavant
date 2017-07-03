({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        helper.getAllCustomSettingsName(component);        
    },
    customSettingChange : function(component, event, helper) {
        component.set("v.showSpinner",true);
        helper.getCustomSettingRecords(component, event);
    },
    goSelceted : function(component, event, helper) {
        helper.goSelceted(component, event);        
    },
    cancel : function(component, event, helper) {
        helper.cancel(component, event, 'Save');        
    },
    saveSelceted : function(component, event, helper) {
        component.set("v.showSpinner",true);
        helper.saveSelceted(component, event);
        helper.cancel(component, event, 'Cancel');
    },
    createNew : function(component, event, helper) {        
        var cSRecordsWrapper = component.get("v.cSRecordsWrapper");
        var sObjectrecord = {};
        var blankRecord = {};
		var fieldsApi = component.get("v.fieldsApi");
        for(var key in fieldsApi){
            sObjectrecord[fieldsApi[key]] = '';
        }        
        blankRecord['sObjectrecords'] = sObjectrecord;
        cSRecordsWrapper.unshift(blankRecord);
        component.set("v.cSRecordsWrapper", cSRecordsWrapper)
    },
    showPopupHelper: function(component, event, helper){
    	helper.showPopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.showPopupHelper(component, 'backdrop', 'slds-backdrop--'); 
        var selectedCS = $(event.currentTarget).text();           
    },
    hidePopup :  function(component, event, helper){
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');
		component.set("v.showSpinner",true);        
        var selectedCS = $(event.currentTarget).text(); 
        component.set("v.csName",selectedCS );
        helper.getCustomSettingRecords(component, selectedCS);
    },
    searchKeyChange: function(component, event, helper) {
        var searchKey; 
        if(event != undefined){
            searchKey = event.getParam("searchKey");
        }
        helper.getRecords(component, event, searchKey);        
    },    
})