trigger SOWItemTrigger on SOW_Item__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new SOWItemTriggerHandler().run();
}
