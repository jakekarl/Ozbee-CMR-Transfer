@isTest
private with sharing class DailyExpectedProductionServiceTest {
  // # TEST PURPOSE: ensure the expected number of production job checklist template items are returned
  @isTest
  private static void getDailyReportExpectedProduction() {
    // Create bulk Daily Expected Production records with parent daily report and production schedule item records
    new SObjectBuilder(Daily_Expected_Production__c.sObjectType)
      .count(200)
      .create();

    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    Test.startTest();
    // Call the getDailyReportExpectedProduction() method
    List<Daily_Expected_Production__c> dailyExpectedProductionsList = DailyExpectedProductionService.getDailyReportExpectedProduction(
      dailyReport.Id
    );
    Test.stopTest();

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsReturned = 200;
    Integer actualNumberOfItemsReturned = dailyExpectedProductionsList.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfItemsReturned,
      actualNumberOfItemsReturned,
      'Number of Daily Expected Production records returned does not match expected number.'
    );
  }
}
