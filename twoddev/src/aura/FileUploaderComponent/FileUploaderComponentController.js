({
  readAndUpdateAllAttachments: function(component, event, helper) {
   // component.set('v.context',$A.getContext().gg);
    helper.readAndUpdateAllAttachments(component);
  },

  save: function(component, event, helper) {
    helper.save(component, event, helper,helper);
    if (component.get("v.show")) {
      document.getElementById("fileUploader").value = '';
    }
  },

  deleteAttachment: function(component, event, helper) {
    helper.invisible(component,'filesTable');
    helper.visible(component,'SpinnerDiv');
    helper.deleteAttachment(component,helper);
  },
    display:function(component, event, helper) {
       var files = component.find("file").getElement().files;
        if(files.length>0){
            document.getElementById("saveButtonHider1").style.display="block";
        } else{
            document.getElementById("saveButtonHider1").style.display="none";
        }
    }
})