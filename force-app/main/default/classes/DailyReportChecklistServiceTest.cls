@isTest
private with sharing class DailyReportChecklistServiceTest {
  // * TEST PURPOSE:
  @isTest
  private static void createDailyReportChecklists() {
    // Create bulk Production Job Report records
    List<ozbee__Production_Job_Report__c> dailyReports = new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .count(50)
      .create()
      .getRecords();
    // Create bulk Production Job Checklist Template records
    List<ozbee__Production_Job_Checklist_Template__c> checklistTemplates = new SObjectBuilder(
        ozbee__Production_Job_Checklist_Template__c.sObjectType
      )
      .count(50)
      .create()
      .getRecords();

    Set<Id> dailyReportSetIds = new Set<Id>();
    dailyReportSetIds.addAll(Pluck.ids(dailyReports));
    Set<Id> checklistTemplateSetIds = new Set<Id>();
    checklistTemplateSetIds.addAll(Pluck.ids(checklistTemplates));

    Test.startTest();
    // Call the getDailyReportExpectedProduction() method
    DailyReportChecklistService.createDailyReportChecklists(
      dailyReportSetIds,
      checklistTemplateSetIds
    );
    Test.stopTest();

    // Query for Daily Report Checklist records that should have been inserted into the database
    List<Daily_Report_Checklist__c> dailyReportChecklists = [
      SELECT Id
      FROM Daily_Report_Checklist__c
    ];

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsCreated = 2500;
    Integer actualNumberOfItemsCreated = dailyReportChecklists.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfItemsCreated,
      actualNumberOfItemsCreated,
      'Number of created Daily Report Checklist records returned does not match expected number.'
    );
  }
}
