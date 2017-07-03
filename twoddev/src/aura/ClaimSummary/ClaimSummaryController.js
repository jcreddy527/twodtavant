({
    doInit : function(component, event, helper) {
        //component.set('v.context',$A.getContext().gg);
        helper.visible(component,'SpinnerDiv');
        helper.invisible(component,'GridDiv');
        console.log('------------------ in claim summary doinit');
        console.log(component.get('v.claimId'));
        helper.validateClaim = component.get('v.validateClicked');
        if(component.get('v.claimId') != null && typeof component.get('v.claimId') !='undefined' && component.get('v.claimId') != '' && helper.validateClaim == true)
        {
            
            var query = helper.CLAIM_QUERY + '\'' + component.get('v.claimId') + '\'';
            
            helper.readDom(component, event, query, 'v.claimRecord', 'v.dmlErrors', function(response){
                console.log('------------------response----First');
                console.log(response);
                console.log('-------reddom response-------First-----');
                
                
                if(component.get('v.claimRecord.RecordType.DeveloperName') == 'Field_Modification')
                {
                    var query = helper.CLAIM_QUERY + '\'' + component.get('v.claimId') + '\'';
                    helper.readDom(component, event, query, 'v.claimRecord', 'v.dmlErrors', function(response){
                        console.log('------------------response----claimchanged----first');
                        console.log(component.get('v.claimRecord'));
                        console.log('-------reddom response-------claimchanged----first-----');
                        helper.validateClaim = false;
                        helper.invisible(component,'SpinnerDiv');
                        helper.visible(component,'GridDiv');
                    });
                }
                else
                {
                    var action1 = component.get('c.updatePolicyDefinition');
                    action1.setParams({
                        claimId :component.get('v.claimId')
                    });
                    action1.setCallback(this, function(a) {
                        var query = helper.CLAIM_QUERY + '\'' + component.get('v.claimId') + '\'';
                        console.log('------112-----query---'+query);
                        helper.readDom(component, event, query, 'v.claimRecord', 'v.dmlErrors', function(response){
                            console.log('------------------response ---------claimchanged-');
                            //console.log(response);
                            console.log(component.get('v.claimRecord'));
                            console.log('-------reddom response-----claimchanged-------');
                            helper.validateClaim = false;
                            helper.invisible(component,'SpinnerDiv');
                            helper.visible(component,'GridDiv');
                        });
                    });
                    $A.enqueueAction(action1);
                    
                } 
                
            });
        }
        
        
    },
    claimchanged : function(component, event, helper) {
        helper.visible(component,'SpinnerDiv');
        helper.invisible(component,'GridDiv');
        helper.validateClaim = component.get('v.validateClicked');
        if(component.get('v.claimId') != null && typeof component.get('v.claimId') !='undefined' && component.get('v.claimId') != ''  && helper.validateClaim == true)
        {
            console.log('------claim---changed---')
            console.log(component.get('v.claimRecord'));
            console.log(component.get('v.claimRecord.RecordType'));
            
            var query = helper.CLAIM_QUERY + '\'' + component.get('v.claimId') + '\'';
            
            helper.readDom(component, event, query, 'v.claimRecord', 'v.dmlErrors', function(response){
                console.log('------------------response----First');
                console.log(response);
                console.log('-------reddom response-------First-----');
                
                
                if(component.get('v.claimRecord.RecordType.DeveloperName') == 'Field_Modification')
                {
                    var query = helper.CLAIM_QUERY + '\'' + component.get('v.claimId') + '\'';
                    helper.readDom(component, event, query, 'v.claimRecord', 'v.dmlErrors', function(response){
                        console.log('------------------response----claimchanged----first');
                        console.log(component.get('v.claimRecord'));
                        console.log('-------reddom response-------claimchanged----first-----');
                        helper.validateClaim = false;
                        helper.invisible(component,'SpinnerDiv');
                        helper.visible(component,'GridDiv');
                    });
                }
                else
                {
                    var action1 = component.get('c.updatePolicyDefinition');
                    action1.setParams({
                        claimId :component.get('v.claimId')
                    });
                    action1.setCallback(this, function(a) {
                        var query = helper.CLAIM_QUERY + '\'' + component.get('v.claimId') + '\'';
                        console.log('------112-----query---'+query);
                        helper.readDom(component, event, query, 'v.claimRecord', 'v.dmlErrors', function(response){
                            console.log('------------------response ---------claimchanged-');
                            //console.log(response);
                            console.log(component.get('v.claimRecord'));
                            console.log('-------reddom response-----claimchanged-------');
                            helper.validateClaim = false;
                            helper.invisible(component,'SpinnerDiv');
                            helper.visible(component,'GridDiv');
                        });
                    });
                    $A.enqueueAction(action1);
                    
                } 
                
            });
            
            
        }
        
    }
})