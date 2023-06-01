public with sharing class ProductionScheduleItemDayService {
  public static Map<Id, List<ozbee__Production_Schedule_Item_Day__c>> getTodaysItemDaysByProductionJobId(
    Set<Id> productionJobIds
  ) {
    Map<Id, List<ozbee__Production_Schedule_Item_Day__c>> productionJobToItemDaysMap = new Map<Id, List<ozbee__Production_Schedule_Item_Day__c>>();

    List<ozbee__Production_Schedule_Item_Day__c> itemDays = [
      SELECT
        Id,
        Expected_Production__c,
        Measurement__c,
        ozbee__Production_Schedule_Item__c,
        ozbee__Production_Schedule_Item__r.ozbee__Production_Job__c
      FROM ozbee__Production_Schedule_Item_Day__c
      WHERE
        ozbee__Date__c = TODAY
        AND ozbee__Production_Schedule_Item__r.ozbee__Production_Job__c IN :productionJobIds
    ];

    for (ozbee__Production_Schedule_Item_Day__c itemDay : itemDays) {
      if (
        productionJobToItemDaysMap.get(
          itemDay.ozbee__Production_Schedule_Item__r.ozbee__Production_Job__c
        ) == null
      ) {
        productionJobToItemDaysMap.put(
          itemDay.ozbee__Production_Schedule_Item__r.ozbee__Production_Job__c,
          new List<ozbee__Production_Schedule_Item_Day__c>{ itemDay }
        );
      } else {
        productionJobToItemDaysMap.get(
            itemDay.ozbee__Production_Schedule_Item__r.ozbee__Production_Job__c
          )
          .add(itemDay);
      }
    }

    return productionJobToItemDaysMap;
  }
}
