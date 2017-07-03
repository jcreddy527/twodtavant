({
    
    render : function(component, helper) {
        var ret = this.superRender();
        var className = 'slds-';
        if(component.get('v.SObject') != undefined){
        var SObject = JSON.parse(JSON.stringify(component.get('v.SObject')));
        var FieldName = component.get('v.fieldName');
        var FieldNameMap = component.get('v.fieldNameMap');
        var inputText = component.find("inputTextId");
        var outputText = component.find("outputTextId");
        var fieldLabel;
        
        if(FieldNameMap != undefined){
            fieldLabel =FieldNameMap[FieldName];
        }
        
        if(SObject.length != 0){                      
            component.set('v.fieldValue', SObject[FieldName]);
            var modal = component.find('inputTextId'); 
            $A.util.removeClass(modal, className+'hide'); 
            $A.util.addClass(modal, className+'open');       
        }else{
            outputText.set("v.value",fieldLabel);
            var modal = component.find('outputTextId'); 
            $A.util.removeClass(modal, className+'hide'); 
            $A.util.addClass(modal, className+'open');
        }        
        }else{
            component.set('v.fieldValue', '');
            var df = component.get('v.fieldValue');
            var modal = component.find('inputTextId').getElement(); 
             component.find('inputTextId').set("v.value",'fieldLabel');
            $A.util.removeClass(modal, className+'hide'); 
            $A.util.addClass(modal, className+'open');
            //modal.set("v.disabled", true);
            modal.disabled = false;
            //var btn = modal.srcElement;
            //btn.disabled = true;
        }
        return ret;
    },
    
})