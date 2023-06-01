@IsTest
private with sharing class DailyReportSelectChecklistControllerTest {
  // * TEST PURPOSE:
  @isTest
  private static void getChecklistTemplates() {
    // Create Production Job Checklist Templates with Default__c = false
    new SObjectBuilder(ozbee__Production_Job_Checklist_Template__c.sObjectType)
      .put(ozbee__Production_Job_Checklist_Template__c.Active__c, true)
      .put(
        ozbee__Production_Job_Checklist_Template__c.ozbee__Checklist_Type__c,
        SObjectFactory.provideUniqueString('NonDefault')
      )
      .count(2)
      .create();

    // Create a Daily Report to check against
    ozbee__Production_Job_Report__c dailyReport = (ozbee__Production_Job_Report__c) new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .create()
      .getRecord();

    Test.startTest();
    // Call the getUnusedChecklistTemplates() method
    List<ozbee__Production_Job_Checklist_Template__c> unusedChecklistTemplates = DailyReportSelectChecklistsController.getChecklistTemplates(
      dailyReport.Id
    );
    Test.stopTest();

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsReturned = 2;
    Integer actualNumberOfItemsReturned = unusedChecklistTemplates.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfItemsReturned,
      actualNumberOfItemsReturned,
      'Number of Production Job Checklist Template Item records returned does not match expected number.'
    );
  }
  // * TEST PURPOSE:
  @isTest
  private static void createDailyReportItems() {
    // Create a single Daily Report record
    ozbee__Production_Job_Report__c dailyReport = (ozbee__Production_Job_Report__c) new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .create()
      .getRecord();
    // Create a single Production Job Checklist Template record
    List<ozbee__Production_Job_Checklist_Template_Item__c> checklistTemplateItems = new SObjectBuilder(
        ozbee__Production_Job_Checklist_Template_Item__c.sObjectType
      )
      .count(50)
      .create()
      .getRecords();

    Set<Id> checklistTemplateSetIds = Pluck.ids(
      'ozbee__Production_Job_Checklist_Template__c',
      checklistTemplateItems
    );

    String checklistTemplateIdsString = JSON.serialize(checklistTemplateSetIds);

    Test.startTest();
    // Call the getDailyReportExpectedProduction() method
    DailyReportSelectChecklistsController.createDailyReportItems(
      dailyReport.Id,
      checklistTemplateIdsString
    );
    Test.stopTest();

    // Query for Daily Report Checklist records that should have been inserted into the database
    List<ozbee__Production_Job_Report_Item__c> dailyReportItems = [
      SELECT Id
      FROM ozbee__Production_Job_Report_Item__c
    ];

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsCreated = 50;
    Integer actualNumberOfItemsCreated = dailyReportItems.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfItemsCreated,
      actualNumberOfItemsCreated,
      'Number of created Daily Report Item records returned does not match expected number.'
    );
  }
  // * TEST PURPOSE:
  @isTest
  private static void createDailyReportItemsError() {
    // Create a single Daily Report record
    ozbee__Production_Job_Report__c dailyReport = (ozbee__Production_Job_Report__c) new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .create()
      .getRecord();

    String checklistTemplateIdsString = JSON.serialize(
      'forceError, asdfawefwef'
    );
    try {
      Test.startTest();
      // Call the getDailyReportExpectedProduction() method
      DailyReportSelectChecklistsController.createDailyReportItems(
        dailyReport.Id,
        checklistTemplateIdsString
      );
      Test.stopTest();
    } catch (Exception e) {
      Boolean containsExpectedException = e.getMessage()
        .contains('Script-thrown');
      Assert.areEqual(
        true,
        containsExpectedException,
        'The expected exception was not thrown.'
      );
    }
  }
}
