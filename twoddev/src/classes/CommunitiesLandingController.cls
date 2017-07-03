/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
global with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    global PageReference forwardToStartPage() {
        return Network.communitiesLanding();
    }
    
    global CommunitiesLandingController() {}
}