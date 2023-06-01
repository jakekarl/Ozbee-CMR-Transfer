@isTest
private with sharing class ChecklistTemplateItemsServiceTest {
  // # TEST PURPOSE: ensure the expected number of production job checklist template items are returned
  @isTest
  private static void getChecklistTemplateItemsTest() {
    // Query for parent Production Job Checklist Templates
    List<ozbee__Production_Job_Checklist_Template__c> productionJobChecklistTemplates = [
      SELECT Id
      FROM ozbee__Production_Job_Checklist_Template__c
    ];

    // Gather parent production job checklist template item Ids
    Set<Id> productionJobChecklistTemplateSetIds = Pluck.ids(
      productionJobChecklistTemplates
    );

    // Convert from a set to a list
    List<Id> productionJobChecklistTemplateListIds = new List<Id>();
    productionJobChecklistTemplateListIds.addAll(
      productionJobChecklistTemplateSetIds
    );

    Test.startTest();
    // Call the getChecklistTemplateItems method and store the results for assertion
    List<ozbee__Production_Job_Checklist_Template_Item__c> productionJobTemplateChecklistItems = ChecklistTemplateItemsService.getChecklistTemplateItems(
      productionJobChecklistTemplateListIds
    );
    Test.stopTest();

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfItemsReturned = 200;
    Integer actualNumberOfItemsReturned = productionJobTemplateChecklistItems.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfItemsReturned,
      actualNumberOfItemsReturned,
      'Number of Production Job Checklist Template Items returned does not match expected number.'
    );
  }

  @TestSetup
  static void makeData() {
    // Insert Production Job Checklist Template Items with parent Production Job Checklist Templates
    new SObjectBuilder(
        ozbee__Production_Job_Checklist_Template_Item__c.sObjectType
      )
      .count(200)
      .create();
  }
}
