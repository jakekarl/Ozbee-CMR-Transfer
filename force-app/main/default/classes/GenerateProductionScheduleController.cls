public with sharing class GenerateProductionScheduleController {
  @AuraEnabled
  public static void createProductionScheduleItems(Id productionJobId) {
    try {
      List<SOW__c> SOWs = [
        SELECT
          Id,
          (
            SELECT
              Id,
              Name,
              Title__c,
              Description__c,
              Quantity__c,
              Measurement__c,
              Start_Date__c,
              End_Date__c,
              Task_Phase__c,
              Revenue__c
            FROM SOW_Items__r
            WHERE Schedule_Generated__c = FALSE
          )
        FROM SOW__c
        WHERE
          Production_Job__c = :productionJobId
          AND Ready_to_Schedule__c = TRUE
      ];

      if (SOWs.size() == 0) {
        throw new thrownException('This production job does not have a SOW');
      }

      List<ozbee__Production_Schedule_Item__c> productionScheduleItemsToInsert = new List<ozbee__Production_Schedule_Item__c>();
      List<SOW_Item__c> sowItemsToUpdate = new List<SOW_Item__c>();

      Map<Id, SOW_Item__c> sowItemIdToSOWItem = new Map<Id, SOW_Item__c>();
      for (SOW__c SOW : SOWs) {
        for (SOW_Item__c SOWItem : SOW.SOW_Items__r) {
          if (SOWItem.Start_Date__c == null || SOWItem.End_Date__c == null) {
            continue;
          }

          Integer startDay = SOWItem.Start_Date__c.day();
          Integer startMonth = SOWItem.Start_Date__c.month();
          Integer startYear = SOWItem.Start_Date__c.year();

          Integer endDay = SOWItem.End_Date__c.day();
          Integer endMonth = SOWItem.End_Date__c.month();
          Integer endYear = SOWItem.End_Date__c.year();

          productionScheduleItemsToInsert.add(
            new ozbee__Production_Schedule_Item__c(
              ozbee__Production_Job__c = productionJobId,
              Name = SOWItem.Title__c,
              ozbee__Start_Date__c = Datetime.newInstance(
                startYear,
                startMonth,
                startDay,
                7,
                0,
                0
              ),
              ozbee__End_Date__c = Datetime.newInstance(
                endYear,
                endMonth,
                endDay,
                17,
                0,
                0
              ),
              ozbee__Type__c = SOWItem.Task_Phase__c,
              ozbee__Total_Days__c = SOWItem.Start_Date__c.daysBetween(
                  SOWItem.End_Date__c
                ) + 1,
              Quantity__c = SOWItem.Quantity__c,
              Measurement__c = SOWItem.Measurement__c,
              ozbee__Total_Revenue__c = SOWItem.Revenue__c,
              SOW_Item__c = SOWItem.Id
            )
          );
          sowItemIdToSOWItem.put(SOWItem.Id, SOWItem);
          sowItemsToUpdate.add(SOWItem);
        }
      }
      if (productionScheduleItemsToInsert.size() == 0) {
        throw new thrownException('No valid SOW Items');
      } else {
        insert productionScheduleItemsToInsert;

        for (
          ozbee__Production_Schedule_Item__c productionScheduleItem : productionScheduleItemsToInsert
        ) {
          sowItemIdToSOWItem.get(productionScheduleItem.SOW_Item__c)
            .Schedule_Generated__c = true;
          sowItemIdToSOWItem.get(productionScheduleItem.SOW_Item__c)
            .Production_Schedule_Item__c = productionScheduleItem.Id;
        }
        update sowItemsToUpdate;
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class thrownException extends Exception {
  }
}
