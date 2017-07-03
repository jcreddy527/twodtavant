/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest global with sharing class ForgotPasswordControllerTest {
     @IsTest(SeeAllData=true) global static void testForgotPasswordController() {
         CustomSettingsUtilityTest.init();
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';        
    
        System.assertEquals(controller.forgotPassword(),null); 
    }
}