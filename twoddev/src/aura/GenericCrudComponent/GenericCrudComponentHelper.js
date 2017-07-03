({
    recordUnLockHelper : function(component,helper,event,recordId,SobjectRecord) {
        console.log('---------------inside unlock helper');
        var action = component.get("c.recordUnlock");
        action.setParams({
            "recordId"	: recordId,
            "claimRecord":SobjectRecord
        });
        action.setCallback(this, function(a) {
            console.log('---------------unlocked');
        });
        $A.enqueueAction(action);
        
    },
    recordLockHelper : function(component,helper,event,SobjectRecord) {
        console.log('---------------inside lock helper');
        var action = component.get("c.recordLock");
        action.setParams({
            "claimRecord":SobjectRecord
        });
        action.setCallback(this, function(a) {
            console.log('---------------locked');
        });
        $A.enqueueAction(action);
        
    },
    insertRaw: function(component, event, sObjectList, callbackFunction) {
        var insertAction = component.get("c.InsertSObjects");
        var errorList = [];
        var statusList = [];
        var returnableObjectList = [];
        var cloneSObjectList = this.clone(sObjectList);
        /////////////////check sobject list is array or single object/////////////////////
        if (!(cloneSObjectList.constructor === Array) && !(cloneSObjectList == undefined) && !(cloneSObjectList == null)) {
            cloneSObjectList = [cloneSObjectList];
        }
        /////////////////////////////////////////////////////////////////////////////////
        for (var key in cloneSObjectList[0]) {
            if (key.endsWith('__r')) {
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    delete cloneSObjectList[i][key];
                }
            }
        }
        insertAction.setParams({
            inputSObjectList: cloneSObjectList
        });
        
        insertAction.setCallback(this, function(response) {
            var responseValue = response.getReturnValue();
            if (response.getState() == 'SUCCESS') {
                responseValue = response.getReturnValue();
                var errorCount = 0;
                
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    
                    if (responseValue[i].success == false) {
                        errorList[errorCount] = {};
                        errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
                        errorList[errorCount]["index"] = i;
                        errorCount++;
                    } else {
                        cloneSObjectList[i]["Id"] = responseValue[i].sObjID;
                    }
                    statusList[i] = (responseValue[i].success ? "successful" : "unsuccessful");
                    returnableObjectList[i] = {
                        "sObject": cloneSObjectList[i],
                        "status": statusList[i]
                    };
                }
                responseValue = {
                    "sobjectsAndStatus": returnableObjectList,
                    "errorArrays": errorList
                };
            } else if (response.getState() == 'ERROR') {
                responseValue = "ERROR IN INSERTION....where to insert!!!";
            }
            
            callbackFunction(responseValue);
        });
        $A.enqueueAction(insertAction);
        
    },
    insertDom: function(component, event, objectVar, errorVarArray, callbackFunction) {
        var insertAction = component.get("c.InsertSObjects");
        var errorList = [];
        var statusList = [];
        var sObjectList = component.get(objectVar);
        var cloneSObjectList = this.clone(sObjectList);
        var returnableObjectList = [];
        /////////////////check sobject list is array or single object/////////////////////
        if (!(cloneSObjectList.constructor === Array) && !(cloneSObjectList == undefined) && !(cloneSObjectList == null)) {
            cloneSObjectList = [cloneSObjectList];
        }
        /////////////////////////////////////////////////////////////////////////////////
        for (var key in cloneSObjectList[0]) {
            if (key.endsWith('__r')) {
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    delete cloneSObjectList[i][key];
                }
            }
        }
        insertAction.setParams({
            inputSObjectList: cloneSObjectList
        });
        insertAction.setCallback(this, function(response) {
            var responseValue = response.getReturnValue();
            if (response.getState() == 'SUCCESS') {
                responseValue = response.getReturnValue();
                var errorCount = 0;
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    if (responseValue[i].success == false) {
                        errorList[errorCount] = {};
                        errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
                        errorList[errorCount]["index"] = i;
                        errorCount++;
                    } else {
                        cloneSObjectList[i]["Id"] = responseValue[i].sObjID;
                    }
                    statusList[i] = (responseValue[i].success ? "successful" : "unsuccessful");
                    returnableObjectList[i] = {
                        "sObject": cloneSObjectList[i],
                        "status": statusList[i]
                    };
                }
                responseValue = {
                    "sobjectsAndStatus": returnableObjectList,
                    "errorArrays": errorList
                };
                
                ////////////////////set object var on page/////////////////////////////////////////////
                if (cloneSObjectList.length == 1) {
                    component.set(objectVar, cloneSObjectList[0]);
                } else {
                    component.set(objectVar, cloneSObjectList);
                }
                ////////////////////make string array of errors and set errorVar on page///////////////
                if (errorList.length != 0) {
                    var errorString0Array = [];
                    //console.log(errorList);
                    for (var i = 0; i < errorList.length; i++) {
                        errorString0Array[i] = "Error At record [" + errorList[i]["index"] + "] : " + errorList[i]["errorMesssages"][0];
                    }
                    component.set(errorVarArray, errorString0Array);
                }
                //////////////////////////////////////////////////////////////////////////////////////
            } else if (response.getState() == 'ERROR') {
                responseValue = "ERROR IN INSERTION....where to insert!!!";
            }
            
            callbackFunction(responseValue);
        });
        $A.enqueueAction(insertAction);
        
    },
    deleteRaw: function(component, event, objectList, callbackFunction) {
        var statusArray = [];
        var errorListArray = [];
        var deleteAction = component.get("c.DeleteSObjects");
        var cloneSObjectList = this.clone(objectList);
        /////////////////check sobject list is array or single object/////////////////////
        if (cloneSObjectList.constructor === Array) {
            if (cloneSObjectList.length != 0 && (typeof(cloneSObjectList[0]) == "string")) {
                var objectListUpdated = [];
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    objectListUpdated[i] = {
                        "Id": cloneSObjectList[i]
                    }
                }
                cloneSObjectList = objectListUpdated;
            } else if (!(typeof(cloneSObjectList[0]) == "string") && !(typeof(cloneSObjectList[0]) == "object")) {
                alert("data provided in wrong format");
            }
        }
        if (!(cloneSObjectList.constructor === Array)) {
            cloneSObjectList = [cloneSObjectList];
        }
        for (var i = 0; i < cloneSObjectList.length; i++) {
            cloneSObjectList[i] = this.prepareSObject(cloneSObjectList[i]);
        }
        /////////////////////////////////////////////////////////////////////////////////
        deleteAction.setParams({
            inputSObjectList: cloneSObjectList
        });
        deleteAction.setCallback(this, function(response) {
            ////console.log('The Delete response is: ');
            ////console.log(response);
            if (response.getState() == 'SUCCESS') {
                var returnedValues = response.getReturnValue();
                //  //console.log(returnedValues);
                if (returnedValues.length > 0) {
                    var errorCount = 0;
                    for (var i = 0; i < cloneSObjectList.length; i++) {
                        
                        statusArray[i] = returnedValues[i].success;
                        if (statusArray[i] == false) {
                            errorListArray[errorCount] = {};
                            errorListArray[errorCount]["errorMessages"] = returnedValues[i].errorCodeList;
                            errorListArray[errorCount]["index"] = i;
                            errorListArray[errorCount]["sObjectId"] = cloneSObjectList[i].Id;
                            errorCount++;
                        }
                    }
                }
                callbackFunction({
                    "statusArray": statusArray,
                    "errorListArray": errorListArray
                });
            }
            ////console.log('There is no issue with delete. here.');
        });
        $A.enqueueAction(deleteAction);
    },
    deleteDom: function(component, event, objectVar, errorVarArray, callbackFunction) {
        var statusArray = [];
        var errorListArray = [];
        var objectList = component.get(objectVar);
        var cloneSObjectList = this.clone(objectList);
        var deleteAction = component.get("c.DeleteSObjects");
        ////////////////////////////////////////////////////////////////
        if (cloneSObjectList.constructor === Array) {
            if (cloneSObjectList.length != 0 && (typeof(cloneSObjectList[0]) == "string")) {
                var objectListUpdated = [];
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    objectListUpdated[i] = {
                        "Id": cloneSObjectList[i]
                    }
                }
                cloneSObjectList = objectListUpdated;
            } else if (!(typeof(cloneSObjectList[0]) == "string") && !(typeof(cloneSObjectList[0]) == "object")) {
                alert("data provided in wrong format");
            }
        }
        if (!(cloneSObjectList.constructor === Array) && !(cloneSObjectList == undefined) && !(cloneSObjectList == null) && !(typeof(cloneSObjectList) == "object")) {
            cloneSObjectList = [cloneSObjectList];
        }
        for (var i = 0; i < cloneSObjectList.length; i++) {
            //cloneSObjectList[i] = this.prepareSObject(cloneSObjectList[i]);
        }
        /////////////////////////////////////////////////////////////////////////////////
        deleteAction.setParams({
            inputSObjectList: cloneSObjectList
        });
        deleteAction.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                var returnedValues = response.getReturnValue();
                
                var errorCount = 0;
                var errorMessages = [];
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    
                    statusArray[i] = returnedValues[i].success;
                    if (statusArray[i] == false) {
                        errorListArray[errorCount] = {};
                        errorListArray[errorCount]["errorMessages"] = returnedValues[i].errorCodeList;
                        errorListArray[errorCount]["index"] = i;
                        errorListArray[errorCount]["sObjectId"] = cloneSObjectList[i].Id;
                        errorMessages[errorCount] = "Error deleting record at index [" + i + "] : " + errorListArray[errorCount]["errorMessages"][0];
                        errorCount++;
                    }
                }
                component.set(errorVarArray, errorMessages);
                callbackFunction({
                    "statusArray": statusArray,
                    "errorListArray": errorListArray
                });
            } else {
                //console.log(response.getState());
            }
        });
        $A.enqueueAction(deleteAction);
    },
    updateRaw: function(component, event, sObjectList, callbackFunction) {
        var updateAction = component.get("c.UpdateSObjects");
        var statusArray = [];
        var errorList = [];
        var returnableObjectList = [];
        var cloneSObjectList = this.clone(sObjectList);
        /////////////////check sobject list is array or single object/////////////////////
        if (!(cloneSObjectList.constructor === Array) && !(cloneSObjectList == undefined) && !(cloneSObjectList == null)) {
            cloneSObjectList = [cloneSObjectList];
        }
        /////////////////////////////////////////////////////////////////////////////////
        for (var i = 0; i < cloneSObjectList.length; i++) {
            //cloneSObjectList[i] = this.prepareSObject(cloneSObjectList[i]);
        }
        
         for (var key in cloneSObjectList[0]) {
             if (key.endsWith('__r')) {
               for (var i = 0; i < cloneSObjectList.length; i++) {
                cloneSObjectList[i][key]=undefined;
               }
            }
          }
        updateAction.setParams({
            inputSObjectList: cloneSObjectList
        });
        updateAction.setCallback(this, function(response) {
            
            if (response.getState() == 'SUCCESS') {
                var responseValue = response.getReturnValue();
                responseValue = response.getReturnValue();
                var errorCount = 0;
                
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    if (responseValue[i].success == false) {
                        errorList[errorCount] = {};
                        errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
                        errorList[errorCount]["index"] = i;
                        errorList[errorCount]["id provided"] = cloneSObjectList[i]["Id"];
                        cloneSObjectList[i]["Id"] = null;
                        errorCount++;
                    } else {
                        cloneSObjectList[i]["Id"] = responseValue[i].sObjID;
                    }
                    statusArray[i] = (responseValue[i].success ? "successful" : "unsuccessful");
                    returnableObjectList[i] = {
                        "sObject": cloneSObjectList[i],
                        "status": statusArray[i]
                    };
                }
                responseValue = {
                    "sobjectsAndStatus": returnableObjectList,
                    "errorList": errorList
                };
            } else if (response.getState() == 'ERROR') {
                responseValue = "ERROR IN UPDATION....where to UPDATE!!!";
            }
            callbackFunction(responseValue);
        });
        $A.enqueueAction(updateAction);
    },
    updateDom: function(component, event, objectVar, errorVarArray, callbackFunction) {
        var updateAction = component.get("c.UpdateSObjects");
        var statusArray = [];
        var errorList = [];
        var sObjectList = component.get(objectVar);
        var cloneSObjectList = this.clone(sObjectList);
        var returnableObjectList = [];
        /////////////////check sobject list is array or single object/////////////////////
        if (!(cloneSObjectList.constructor === Array) && !(cloneSObjectList == undefined) && !(cloneSObjectList == null)) {
            cloneSObjectList = [cloneSObjectList];
        }
        /////////////////////////////////////////////////////////////////////////////////
        for (var i = 0; i < cloneSObjectList.length; i++) {
            //  //cloneSObjectList[i] = this.prepareSObject(cloneSObjectList[i]);
        }
        for (var key in cloneSObjectList[0]) {
            if (key.endsWith('__r')) {
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    delete cloneSObjectList[i][key];
                }
            }
        }
        //console.log('Records for update :');
        //console.log(cloneSObjectList);
        updateAction.setParams({
            inputSObjectList: cloneSObjectList
        });
        updateAction.setCallback(this, function(response) {
            //console.log('Records for update response :');
            //console.log(response);
            if (response.getState() == 'SUCCESS') {
                
                var responseValue = response.getReturnValue();
                responseValue = response.getReturnValue();
                var errorCount = 0;
                
                for (var i = 0; i < cloneSObjectList.length; i++) {
                    if (responseValue[i].success == false) {
                        errorList[errorCount] = {};
                        errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
                        errorList[errorCount]["index"] = i;
                        errorList[errorCount]["id provided"] = cloneSObjectList[i]["Id"];
                        cloneSObjectList[i]["Id"] = null;
                        errorCount++;
                    } else {
                        cloneSObjectList[i]["Id"] = responseValue[i].sObjID;
                    }
                    statusArray[i] = (responseValue[i].success ? "successful" : "unsuccessful");
                    returnableObjectList[i] = {
                        "sObject": cloneSObjectList[i],
                        "status": statusArray[i]
                    };
                }
                responseValue = {
                    "sobjectsAndStatus": returnableObjectList,
                    "errorList": errorList
                };
                ////////////////////set object var on page/////////////////////////////////////////////
                //  component.set(objectVar, cloneSObjectList);
                ////////////////////make string array of errors and set errorVar on page///////////////
                if (errorList.length != 0) {
                    var errorString0Array = [];
                    //console.log(errorList);
                    for (var i = 0; i < errorList.length; i++) {
                        errorString0Array[i] = "Error At record [" + errorList[i]["index"] + "] : " + errorList[i]["errorMesssages"][0];
                    }
                    component.set(errorVarArray, errorString0Array);
                }
                //////////////////////////////////////////////////////////////////////////////////////
            } else if (response.getState() == 'ERROR') {
                responseValue = "ERROR IN UPDATION....where to UPDATE!!!";
            }
            callbackFunction(responseValue);
        });
        $A.enqueueAction(updateAction);
    },
    
    updateDomForce: function(component, event, objectVar, errorVarArray, callbackFunction) {
    console.log('Sobject value');
    console.log(objectVar);
    var updateAction = component.get("c.ForceUpdateSObjects");
    var statusArray = [];
    var errorList = [];
    var sObjectList = component.get(objectVar);
    var cloneSObjectList = this.clone(sObjectList);
    var returnableObjectList = [];
        console.log("HEYYYYYYYYYYYYY");
    /////////////////check sobject list is array or single object/////////////////////
    if (!(cloneSObjectList.constructor === Array) && !(cloneSObjectList == undefined) && !(cloneSObjectList == null)) {
      cloneSObjectList = [cloneSObjectList];
    }
    /////////////////////////////////////////////////////////////////////////////////
    for (var i = 0; i < cloneSObjectList.length; i++) {
    //  //cloneSObjectList[i] = this.prepareSObject(cloneSObjectList[i]);
    }
        
    for (var key in cloneSObjectList[0]) {
      if (key.endsWith('__r')) {
        for (var i = 0; i < cloneSObjectList.length; i++) {
           cloneSObjectList[i][key]=undefined;
        }
      }
    }
    console.log('Til here');  
    console.log(cloneSObjectList);  
    //console.log('Records for update :');
    //console.log(cloneSObjectList);
    updateAction.setParams({
      inputSObjectList: cloneSObjectList
    });
    updateAction.setCallback(this, function(response) {
      //console.log('Records for update response :');
      //console.log(response);
      console.log(response);
      if (response.getState() == 'SUCCESS') {

        var responseValue = response.getReturnValue();
        responseValue = response.getReturnValue();
        var errorCount = 0;

        for (var i = 0; i < cloneSObjectList.length; i++) {
          if (responseValue[i].success == false) {
            errorList[errorCount] = {};
            errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
            errorList[errorCount]["index"] = i;
            errorList[errorCount]["id provided"] = cloneSObjectList[i]["Id"];
            cloneSObjectList[i]["Id"] = null;
            errorCount++;
          } else {
            cloneSObjectList[i]["Id"] = responseValue[i].sObjID;
          }
          statusArray[i] = (responseValue[i].success ? "successful" : "unsuccessful");
          returnableObjectList[i] = {
            "sObject": cloneSObjectList[i],
            "status": statusArray[i]
          };
        }
        responseValue = {
          "sobjectsAndStatus": returnableObjectList,
          "errorList": errorList
        };
        ////////////////////set object var on page/////////////////////////////////////////////
      //  component.set(objectVar, cloneSObjectList);
        ////////////////////make string array of errors and set errorVar on page///////////////
        if (errorList.length != 0) {
          var errorString0Array = [];
          //console.log(errorList);
          for (var i = 0; i < errorList.length; i++) {
            errorString0Array[i] = "Error At record [" + errorList[i]["index"] + "] : " + errorList[i]["errorMesssages"][0];
          }
          component.set(errorVarArray, errorString0Array);
        }
        //////////////////////////////////////////////////////////////////////////////////////
      } else if (response.getState() == 'ERROR') {
          console.log("error coming");
          console.log(updateAction.getError());
        responseValue = "ERROR IN UPDATION....where to UPDATE!!!";
          
      }
      callbackFunction(responseValue);
    });
    $A.enqueueAction(updateAction);
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
            }else{
                
            }
        });
        $A.enqueueAction(readAction);
    },
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
                    if(!(tmpObj.constructor === Array))
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
    makeQuery: function(parameterList) {
        var query = "select ";
        for (var i = 0; i < parameterList["parameters"].length; i++) {
            if (i == (parameterList["parameters"].length) - 1) {
                query += parameterList["parameters"][i] + " ";
            } else {
                query += parameterList["parameters"][i] + ", ";
            }
        }
        query += "from " + parameterList["objectName"];
        return query;
    },
    clone: function(obj) {
        if (null == obj || "object" != typeof obj) return obj;
        var copy = obj.constructor();
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = obj[attr];
        }
        return copy;
    },
    prepareSObject: function(obj) {
        if (null == obj || "object" != typeof obj) return obj;
        var copy = {};
        var keyArr = ["sobjectType", "Id"];
        //copy.sobjectType = obj.sobjectType;
        copy.Id = obj.Id;
        for (var key in obj) {
            if (!(keyArr.includes(key))) {
                copy.key = obj.key;
            }
        }
        return copy;
    },
    renderURL: function(baseURL,idString) {
        
        console.log("get contect exist");
        console.log($A);
        console.log()
        var finalurl = baseURL + '/' + idString;
        console.log('Final URL');
        console.log(finalurl);
        return (baseURL + '/' + idString);
        /*if($A.getContext().gg != 'undefined' && typeof $A.getContext().gg != 'undefined'){  
            
            return (window.location.origin + $A.getContext().gg + '/' + idString);
            
        }else{
            
            return (window.location.origin + '/' + idString);
            
        }

  } */
  },
    
  //Dharmils code 
  totalRecordCountInReport: function(component, event, helper, reportId, callback) {
    var errorArray = [];
    var returnable = {};

    if (typeof(reportId) != "string") {
      errorArray.push("element provided should be of string type");
    }
    if ((typeof(reportId) == "string") && (reportId == "")) {
      errorArray.push("element provided should not be empty string");
    }

    if (errorArray.length == 0) {

      var readCountsAction = component.get("c.totalRecordsCount");

      readCountsAction.setParams({
        reportId: reportId
      });

      readCountsAction.setCallback(this, function(response) {
        if (response.getState() == "SUCCESS") {

          returnable.response = response.getReturnValue();
          returnable.errorsInInput = null;
          returnable.errorResponse = null;
          callback(returnable);
        } else {
          returnable.response = null;
          returnable.errorResponse = "ERROR OCCURED";
          returnable.errorsInInput = null;
          callback(returnable);
        }
      });
      $A.enqueueAction(readCountsAction);

    } else {
      returnable.response = null;
      returnable.errorsInInput = errorArray;
      returnable.errorResponse = null;
      callback(returnable);
    }
  }

})