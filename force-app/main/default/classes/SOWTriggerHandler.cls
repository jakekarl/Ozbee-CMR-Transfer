public with sharing class SOWTriggerHandler extends TriggerHandler {
  List<SOW__c> newSOWs;
  Map<Id, SOW__c> newSOWsMap;
  List<SOW__c> oldSOWs;
  Map<Id, SOW__c> oldSOWsMap;

  public SOWTriggerHandler() {
    this.newSOWs = (List<SOW__c>) Trigger.new;
    this.newSOWsMap = (Map<Id, SOW__c>) Trigger.newMap;
    this.oldSOWs = (List<SOW__c>) Trigger.old;
    this.oldSOWsMap = (Map<Id, SOW__c>) Trigger.oldMap;
  }

  public override void beforeInsert() {
    SOWService.setProductionJob(newSOWs);
  }

  public override void afterInsert() {
    SOWService.createSOWItemsFromTemplate(newSOWs);
  }
}
