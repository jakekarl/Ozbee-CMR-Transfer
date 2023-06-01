public with sharing class SOWItemTriggerHandler extends TriggerHandler {
  List<SOW_Item__c> newSOWItems;
  Map<Id, SOW_Item__c> newSOWItemsMap;
  List<SOW_Item__c> oldSOWItems;
  Map<Id, SOW_Item__c> oldSOWItemsMap;

  public SOWItemTriggerHandler() {
    this.newSOWItems = (List<SOW_Item__c>) Trigger.new;
    this.newSOWItemsMap = (Map<Id, SOW_Item__c>) Trigger.newMap;
    this.oldSOWItems = (List<SOW_Item__c>) Trigger.old;
    this.oldSOWItemsMap = (Map<Id, SOW_Item__c>) Trigger.oldMap;
  }

  public override void afterDelete() {
    SOWItemService.deleteParentProductionScheduleItems(oldSOWItems);
  }
}
