({

    render : function(component, helper) {
        var ret = this.superRender();

        var SObject = component.get('v.SObject');
        var FieldName = component.get('v.fieldName');
        var outputText = component.find("outputTextId");
        outputText.set("v.value",SObject[FieldName]);
        return ret;
    },

})