({
    doInit : function(component, event, helper) {
    	// Initialize input select options
    	//var option	=	
        var opts = [
            { "label": "--None--", "value":" " , "selected" : true }
        ];
        var fieldName	= component.get("{!v.fieldName}");
        var objectName	= component.get("{!v.objectName}");
        console.log(objectName);
        console.log(fieldName);
        var action = component.get("c.generatePicklistValues");
        action.setParams({
            "fieldName": fieldName,
            "objectName" : objectName
        });
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            var returnedPicklistValues	=	response.getReturnValue();
            for(var pickListValue in response.getReturnValue()){
                console.log(response.getReturnValue()[pickListValue]);
                opts.push({"class": "optionClass","label":response.getReturnValue()[pickListValue],"value":response.getReturnValue()[pickListValue], "selected" : false});
            }
            component.find("InputSelectDynamic").set("v.options", opts);
            console.log(opts);
        });
        $A.enqueueAction(action);
        
        
        
        /*
        opts.push({'label':'value3','value':'value3'});
        console.log('::::: opts:');
        console.log(opts);*/
        
        
    },

	onSingleSelectChange: function(cmp) {
         var selectCmp = cmp.find("InputSelectSingle");
         var resultCmp = cmp.find("singleResult");
         resultCmp.set("v.value", selectCmp.get("v.value"));
	 },

	 onMultiSelectChange: function(cmp) {
         var selectCmp = cmp.find("InputSelectMultiple");
         var resultCmp = cmp.find("multiResult");
         resultCmp.set("v.value", selectCmp.get("v.value"));
	 },
	 
	 onChange: function(component, event, helper) {
		 var dynamicCmp = component.find("InputSelectDynamic");
		 var resultCmp = component.find("dynamicResult");
         
         var selectedVal	=	dynamicCmp.get("v.value");
         console.log(selectedVal);
		 //resultCmp.set("v.value", dynamicCmp.get("v.value"));
         component.set('v.selectedValue', selectedVal);
         console.log(component.get("v.selectedValue"));
	 }
	 
})