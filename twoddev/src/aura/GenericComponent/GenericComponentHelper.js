({
readDom: function(component, event, query, objectVar, errorVar, callbackFunction) {
        var readAction = component.get("c.ReadSObjects");
        readAction.setParams({
            query: query
        });
        readAction.setCallback(this, function(response) {
            var returnableValue;
            console.log('generic');  
            console.log(response.getReturnValue());  
            if (response.getState() == 'SUCCESS') {
                
                if (response.getReturnValue().success == false) {
                    returnableValue = response.getReturnValue().errorMsg;
                    component.set(objectVar, null);
                    component.set(errorVar, returnableValue);
                } else {
                    console.log('rohittt');
                    returnableValue = response.getReturnValue().sObjList;
                    var tmpObj = component.get(objectVar);
                    if(!(Array.isArray(tmpObj)))
                    {  
                        console.log('rohittt1');
                        component.set(objectVar, returnableValue[0]);
                    } else {
                        console.log('rohittt2');
                        component.set(objectVar, returnableValue);
                        console.log('Mounuika');
                    }
                    component.set(errorVar, null);
                }
                console.log(returnableValue);
                callbackFunction(returnableValue);
            }
        });
        $A.enqueueAction(readAction);
    },
    readRaw: function(component, event, query, callbackFunction) {
        var readAction = component.get("c.ReadSObjects");
        readAction.setParams({
            query: query
        });
        readAction.setCallback(this, function(response) {
            
            var returnableValue;
            if (response.getState() == 'SUCCESS') {
                
                if (response.getReturnValue().success == false) {
                    returnableValue = response.getReturnValue().errorMsg;
                } else {
                    returnableValue = response.getReturnValue().sObjList;
                }
                callbackFunction(returnableValue);
            }
        });
        $A.enqueueAction(readAction);
    }
})