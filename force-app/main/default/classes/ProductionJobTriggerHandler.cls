public with sharing class ProductionJobTriggerHandler extends TriggerHandler {
  List<ozbee__Production_Job__c> newProductionJobs;
  Map<Id, ozbee__Production_Job__c> newProductionJobsMap;
  List<ozbee__Production_Job__c> oldProductionJobs;
  Map<Id, ozbee__Production_Job__c> oldProductionJobsMap;

  public ProductionJobTriggerHandler() {
    this.newProductionJobs = (List<ozbee__Production_Job__c>) Trigger.new;
    this.newProductionJobsMap = (Map<Id, ozbee__Production_Job__c>) Trigger.newMap;
    this.oldProductionJobs = (List<ozbee__Production_Job__c>) Trigger.old;
    this.oldProductionJobsMap = (Map<Id, ozbee__Production_Job__c>) Trigger.oldMap;
  }

  public override void afterInsert() {
    ProductionJobService.setSOWProductionJob(newProductionJobs);
  }
}
