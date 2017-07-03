/**
 * An apex page controller that exposes the change password functionality
 */
global with sharing class ChangePasswordController {
    global String oldPassword {get; set;}
    global String newPassword {get; set;}
    global String verifyNewPassword {get; set;}        
    
    global PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
   	global ChangePasswordController() {}
}