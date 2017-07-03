({
    doInit: function(component, event, helper) {
        // Load different types of Bulk Uploads
        var action = component.get("c.getProcessType");
        var processType = component.find("processType");
        var processOpts = [{
            "class": "optionClass",
            label: "--None--",
            value: "NONE"
        }];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                processOpts.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            processType.set("v.options", processOpts);
        });
        $A.enqueueAction(action);

    },

    handleProcessType: function(component, event, helper) {
        var selectedValue = component.find("processType").get("v.value");
        if (selectedValue == "Warranty Registration") {
            component.set("v.showSection2", true);

            // Load Custom Save Location PickList
            var custSave = component.find("custSave");
            var custSaveOpts = [{
                "class": "optionClass",
                label: "Account",
                value: "ACC"
            }, {
                "class": "optionClass",
                label: "Warranty Registration",
                value: "WR"
            }];
            custSave.set("v.options", custSaveOpts);

        } else if (selectedValue == "Claim") {
        	alert("Claim Bulk Upload is still under construction!!");
            component.set("v.showSection2", false);
            component.set("v.processTypeName", "NONE");
        } else {
        	component.set("v.showSection2", false);
        }
    },

    handleCustSave: function(component, event, helper) {
        var selectedValue = component.find("custSave").get("v.value");
        if (selectedValue == "WR") {
        	alert("Saving Customer Data to Warranty Registration record is under construction!!");
        	component.set("v.customerSaveLoc", "ACC");
        }
    },
    
    handleChooseFile: function(component, event, helper) {
        component.set("v.showSection3", true);
    },

    cancel: function(component, event, helper) {
        window.history.back();
    },

    startUploadProcess: function(component, event, helper) {
        var MAX_FILE_SIZE = 750000;
        var fileInput = component.find('inputFile').getElement();
        var file1 = fileInput.files[0];
        if (file1.size > MAX_FILE_SIZE) {
            console.log('File size exceeded the maximum upload limit.');
            return false;
        }
        var fr = new FileReader();

        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            helper.createStageRec(component, fileContents, helper);
        };
        fr.readAsDataURL(file1);
    },

    backToUpload :function (component,event,helper){
		window.location.href = '/apex/BulkUploadLightning';		
	},
	
	getBtchLogId :function (component,event,helper){
		var bId = component.get("v.bLogId");
		console.log('url  :'+'/'+bId);
		window.location.href = '/'+bId+ "&output=embed";
	},

})