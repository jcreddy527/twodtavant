({
	doInit : function(component, event, helper) {
       // component.set('v.context',$A.getContext().gg);
				//helper.visible(component,'SpinnerDiv');
				//helper.invisible(component,'ContainerDiv');
        console.log(component.get('v.claimId'));
        //helper.invisible(component,'SpinnerDiv');
								helper.visible(component,'ContainerDiv');

		console.log(':::: entered in to the doinit method');
        var action = component.get('c.checkSystemAdmin');
        action.setParams({ });
        action.setCallback(this, function(response) {
            console.log('::::: response:');
            console.log(response.getReturnValue());
            if(response.getReturnValue()=='System Administrator') {
                component.set('v.isSysAdmin',true);
            } else {
                component.set('v.isSysAdmin',false);
            }

            if(response.getReturnValue()=='Warranty Partner') {
                component.set('v.isDealer',true);

                var action2 = component.get('c.selectDealerAccount');
                action2.setParams({ });
                action2.setCallback(this, function(response) {
                    console.log('-----------------------'+response.getReturnValue());
                    console.log(response.getReturnValue());
                    component.set('v.dealerAccount',response.getReturnValue().Id);
                    component.set('v.dealerName',response.getReturnValue().Name);
                    console.log(component.get('v.dealerAccount'));
                    console.log(component.get('v.dealerName'));
                });
        		$A.enqueueAction(action2);

            } else {
                component.set('v.isDealer',false);
            }           

        });
        $A.enqueueAction(action);
	}
})