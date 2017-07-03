@isTest
global class CSVReaderTest{

    //Test Method for CSVReader
    global static testMethod void readCSVFileTest() {
      CustomSettingsUtilityTest.init();
      String data = 'abc,"def","g""h""i"' + Parser.CRLF + '"j' + Parser.CRLF + 'kl","m' + Parser.CRLF + 'n""o""",';
      
      List<List<String>> fileValues = CSVReader.readCSVFile(data);
      System.assertNotEquals(null, fileValues); 
    }
}