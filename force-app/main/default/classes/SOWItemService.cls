public with sharing class SOWItemService {
  public static void deleteParentProductionScheduleItems(
    List<SOW_Item__c> oldSOWItems
  ) {
    Set<Id> productionScheduleIds = Pluck.ids(
      'Production_Schedule_Item__c',
      oldSOWItems
    );

    List<ozbee__Production_Schedule_Item__c> parentProductionScheduleItems = [
      SELECT Id
      FROM ozbee__Production_Schedule_Item__c
      WHERE Id IN :productionScheduleIds
    ];

    if (!parentProductionScheduleItems.isEmpty()) {
      delete parentProductionScheduleItems;
    }
  }
}
