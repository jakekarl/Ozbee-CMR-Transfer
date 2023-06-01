@isTest
public with sharing class ProductionJobServiceTest {
  @isTest
  private static void setSOWProductionJob() {
    List<ozbee__Production_Job__c> productionJobs = (List<ozbee__Production_Job__c>) new SObjectBuilder(
        ozbee__Production_Job__c.sObjectType
      )
      .create()
      .getRecords();

    List<SOW__c> sows = (List<SOW__c>) new SObjectBuilder(SOW__c.sObjectType)
      .create()
      .getRecords();

    Test.startTest();
    ProductionJobService.setSOWProductionJob(productionJobs);
    Test.stopTest();

    List<SOW__c> updatedSows = [SELECT Production_Job__c FROM SOW__c];

    System.assertEquals(
      productionJobs[0].Id,
      updatedSows[0].Production_Job__c,
      'Production job Ids are not equal'
    );
  }
}
