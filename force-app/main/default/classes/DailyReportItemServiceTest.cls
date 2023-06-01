@isTest
private with sharing class DailyReportItemServiceTest {
  // * Test Purpose: ensure the query returns the expected number of daily report items
  @isTest
  private static void getDailyReportItems() {
    // Insert bulk Daily Report Items which in turn inserts a single parent daily report
    new SObjectBuilder(ozbee__Production_Job_Report_Item__c.sObjectType)
      .count(200)
      .create();

    // Query for the parent Daily Report record
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    Test.startTest();
    List<ozbee__Production_Job_Report_Item__c> dailyReportItems = DailyReportItemService.getDailyReportItems(
      dailyReport.Id
    );
    Test.stopTest();

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsReturned = 200;
    Integer actualNumberOfItemsReturned = dailyReportItems.size();

    Assert.areEqual(
      expectedNumberOfItemsReturned,
      actualNumberOfItemsReturned,
      'Number of Daily Report Item records returned does not match expected number.'
    );
  }
  // * Test Purpose: ensure the expected number of daily report items are created from a list of Daily Report Ids and Production Job Checklist Template Item Ids
  @isTest
  private static void createDailyReportItems() {
    // Insert bulk Daily Report and Produciton Job Checklist Template item records to pass as parameters to the getDailyReportItems() method
    List<ozbee__Production_Job_Report__c> dailyReportsList = new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .count(50)
      .create()
      .getRecords();
    Set<Id> dailyReportIdsSet = new Set<Id>();
    dailyReportIdsSet.addAll(Pluck.ids(dailyReportsList));
    List<ozbee__Production_Job_Checklist_Template_Item__c> checklistItems = new SObjectBuilder(
        ozbee__Production_Job_Checklist_Template_Item__c.sObjectType
      )
      .count(50)
      .create()
      .getRecords();

    Test.startTest();
    DailyReportItemService.createDailyReportItems(
      dailyReportIdsSet,
      checklistItems
    );
    Test.stopTest();

    List<ozbee__Production_Job_Report_Item__c> dailyReportItems = [
      SELECT Id
      FROM ozbee__Production_Job_Report_Item__c
    ];

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsCreated = 2500;
    Integer actualNumberOfItemsCreated = dailyReportItems.size();

    Assert.areEqual(
      expectedNumberOfItemsCreated,
      actualNumberOfItemsCreated,
      'Number of Daily Report Item records returned does not match expected number.'
    );
  }
}
