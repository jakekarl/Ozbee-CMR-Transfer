trigger DailyReportTrigger on ozbee__Production_Job_Report__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new DailyReportTriggerHandler().run();
}
