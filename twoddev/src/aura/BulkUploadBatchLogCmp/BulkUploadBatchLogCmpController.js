({
  doInit: function(cmp,event, helper) {
      // Set the attribute value.      
      cmp.set("v.showSpinner",true);
      helper.getBatch(cmp);
  },
})