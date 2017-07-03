({
    initialize : function(component, event, helper) {

        var isResetRequest = component.get("v.isReset");
        if(isResetRequest){
            helper.showAlert(component,{});
            helper.reset(component,event);
        }else{
            helper.showAlert(component,{});
            helper.initialize(component, event);
        }


    },

    next : function(component, event, helper) {
        helper.next(component, event, false);
    },

    markAnswer : function(component, event, helper){
        helper.markAnswer(component, event);
    },

    redirectToTarget : function(component, event, helper){
        helper.redirectToTarget(component, event);
    },

    updateReportingStatus : function(component,event,helper){
        helper.updateReportingStatus(component,event);
    },

    saveAsDraft : function(component,event,helper){

      helper.saveAsDraft(component,event);

    },

    closeAlert : function(component,event,helper){

      var body=component.get('v.body');
      body.pop();
      component.set('v.body',body);

    }

})