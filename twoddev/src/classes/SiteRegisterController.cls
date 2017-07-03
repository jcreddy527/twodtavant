/**
 * An apex class that creates a portal user
 */
global with sharing class SiteRegisterController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    global static Id PORTAL_ACCOUNT_ID = Label.SiteRegisterControllerId;
    
    global SiteRegisterController () {
    }

    global String username {get; set;}
    global String email {get; set;}
    global String password {get; set {password = value == null ? value : value.trim(); } }
    global String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    global String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
      
    global boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    global PageReference registerUser() {
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
        User u = new User();
        u.Username = username;
        u.Email = email;
        u.CommunityNickname = communityNickname;
        
        String accountId = PORTAL_ACCOUNT_ID;

        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        String userId = Site.createPortalUser(u, accountId, password);
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(username, password, null);
            }
            else {
                PageReference page = System.Page.SiteRegisterConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}