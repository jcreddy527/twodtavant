/**
 * An apex page controller that exposes the site forgot password functionality
 */
global with sharing class ForgotPasswordController {
    global String username {get; set;}   
       
    global ForgotPasswordController() {}
	
  	global PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
}