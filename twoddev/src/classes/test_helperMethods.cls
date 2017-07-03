/**********************************************************************
Name:  test_helperMethods
Purpose: To provide test date with or without insertions for test class execution
************************************************************************/
global with sharing class test_helperMethods {

                /*
                Purpose : This method dynamically creates a name prefix that will make ensure name uniqueness.
                Insert : NA
                Return : A unique string
                */
                global static String getUniquePrefix(){
                                //Return the concatenation of the organization id and the systems current time in millisecond
                                return UserInfo.getOrganizationId() + System.now().millisecond();
                }

                /*
                Purpose : This method prepares collaboration groups for testing with or without insertion
                Input : number of collaboration groups, insert now boolean flag
                Return : List of collaboration groups
                */
                global static List<Contact> prepareContacts(Integer numGroups, Boolean insertNow){
                                //List variable of collaboration group to be returned
                                List<Contact> retVal = new List<Contact>();
                                //Iterate n (numGroups) number of time to create and add the test collaboration group to the list variable
                                for(Integer i=0; i<numGroups; i++)
                                {
                                                retVal.add (new Contact(
                                                //set the name Ex: TestGroup_0
                                                FirstName = 'FirstName' + i,
                                                //set the collaboration type to global
                                                LastName='LastName'+i
                                                ));
                                }
                                //If insertnow is true, insert the records and return the record
                                //If insertnw is false, return the record with out insertion
                                if(insertNow)
                                insert retVal;
                                return retVal;
                }

                /*
                Purpose : This method prepares list of users for testing with or without insertion
                Input : profile id, number of users, insert now boolean flag
                Return : List of users
                */
                global static List<User> prepareStandardUsers(Id standardProfileId, Integer numUsers, Boolean insertNow){
                                //List variable of users to be returned
                                List<User> retVal = new List<User>();
                                //Iterate n (numUsers) number of time to create and add the test user to the list variable
                                for(Integer i=0; i<numUsers; i++)
                                {
                                                retVal.add(new User(
                                                //set the username to a unique value by calling getUniquePrefix method
                                                //this ensure that we never accidently query any existing user for test purpose
                                                //since salesforce allows to query all existing users in test execution context
                                                Username = getUniquePrefix() + '_TESTUSER_' + i + 'standarduser@testorg.com',
                                                //set the alian
                                                Alias = 'standt',
                                                //set the email
                                                email = 'standarduser@testorg.com',
                                                //set the emailencodingkey
                                                emailencodingkey = 'UTF-8',
                                                //set the LastName
                                                LastName = 'LastName',
                                                //set the FirstName
                                                FirstName = 'FirstName',
                                                //set the LanguageLocaleKey
                                                LanguageLocaleKey = 'en_US',
                                                //set the LocaleSidKey
                                                LocaleSidKey = 'en_US',
                                                //set the ProfileId
                                                ProfileId = standardProfileId,
                                                //set the TimeZoneSidKey
                                                TimeZoneSidKey = 'America/Los_Angeles')
                                                );
                                }
                                //If insertnow is true, insert the records and return the record
                                //If insertnw is false, return the record with out insertion
                                if(insertNow)
                                insert retVal;
                                return retVal;
                }


}