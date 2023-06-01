@isTest
private with sharing class ChecklistTemplateServiceTest {
  // # TEST PURPOSE: ensure the expected number of production job checklist template items are returned
  @isTest
  private static void getUnusedChecklistTemplates() {
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
    List<ozbee__Production_Job_Checklist_Template__c> unusedChecklistTemplates = ChecklistTemplateService.getUnusedChecklistTemplates(
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
      'Number of Production Job Checklist Template Items returned does not match expected number.'
    );
  }
  // # TEST PURPOSE: ensure the expected number of production job checklist templates are returned
  //     			   where Active = true
  @isTest
  private static void getActiveChecklistTemplates() {
    Test.startTest();
    // Call the getActiveChecklistTemplates() method
    List<ozbee__Production_Job_Checklist_Template__c> activeChecklistTemplates = ChecklistTemplateService.getActiveChecklistTemplates();
    Test.stopTest();

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsReturned = 200;
    Integer actualNumberOfItemsReturned = activeChecklistTemplates.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfItemsReturned,
      actualNumberOfItemsReturned,
      'Number of Production Job Checklist Template Items returned does not match expected number.'
    );
  }
  // # TEST PURPOSE: ensure the expected number of production job checklist template items are returned
  @isTest
  private static void getDefaultChecklistTemplates() {
    Test.startTest();
    // Call the getActiveChecklistTemplates() method
    List<ozbee__Production_Job_Checklist_Template__c> defaultChecklistTemplates = ChecklistTemplateService.getDefaultChecklistTemplates();
    Test.stopTest();

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsReturned = 200;
    Integer actualNumberOfItemsReturned = defaultChecklistTemplates.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfItemsReturned,
      actualNumberOfItemsReturned,
      'Number of Production Job Checklist Templates returned does not match expected number.'
    );
  }

  @TestSetup
  static void makeData() {
    // Insert Production Job Checklist Templates where Active__c and Default__c = true
    new SObjectBuilder(ozbee__Production_Job_Checklist_Template__c.sObjectType)
      .put(ozbee__Production_Job_Checklist_Template__c.Active__c, true)
      .put(ozbee__Production_Job_Checklist_Template__c.Default__c, true)
      .count(200)
      .create();
  }
}
