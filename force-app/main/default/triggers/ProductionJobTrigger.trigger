trigger ProductionJobTrigger on ozbee__Production_Job__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new ProductionJobTriggerHandler().run();
}
