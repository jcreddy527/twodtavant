/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest global with sharing class CommunitiesSelfRegConfirmControllerTest {
    @IsTest(SeeAllData=true) global static void testCommunitiesSelfRegConfirmController() {
        // Instantiate a new controller with all parameters in the page
        CustomSettingsUtilityTest.init();
        CommunitiesSelfRegConfirmController controller = new CommunitiesSelfRegConfirmController();
         if(controller !=null){
         System.assertNotEquals(null,controller);
        }
      }    
}