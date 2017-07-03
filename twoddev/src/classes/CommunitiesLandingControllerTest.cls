/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest global with sharing class CommunitiesLandingControllerTest {
    @IsTest(SeeAllData=true) global static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CustomSettingsUtilityTest.init();
        CommunitiesLandingController controller = new CommunitiesLandingController();
         if(controller !=null){
         System.assertNotEquals(null,controller);
        }
      }
}