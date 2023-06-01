public with sharing class ProductionScheduleItemService {
  public static List<ProductionItemSchemaWrapper> getExportProductionItemFieldSet() {
    List<ProductionItemSchemaWrapper> returnObject = new List<ProductionItemSchemaWrapper>();

    for (
      Schema.FieldSetMember f : SObjectType.ozbee__Production_Schedule_Item__c.FieldSets.getMap()
        .get('Production_Schedule_Export')
        .getFields()
    ) {
      ProductionItemSchemaWrapper newWrapper = new ProductionItemSchemaWrapper();

      newWrapper.sObjectName = f.getFieldPath();
      returnObject.add(newWrapper);
    }

    return returnObject;
  }

  public static List<ozbee__Production_Schedule_Item__c> getProductionScheduleItems(
    Id jobId
  ) {
    String query = 'SELECT ';

    for (
      Schema.FieldSetMember f : SObjectType.ozbee__Production_Schedule_Item__c.FieldSets.getMap()
        .get('Production_Schedule_Export')
        .getFields()
    ) {
      query += f.getFieldPath() + ', ';
    }
    query +=
      'Id FROM ozbee__Production_Schedule_Item__c WHERE ozbee__Production_Job__c = \'' +
      jobId +
      '\'';

    return Database.query(query);
  }

  public static Map<Id, ozbee__Production_Job__c> getProductionScheduleItemsByJob(
    Set<Id> jobIds
  ) {
    return new Map<Id, ozbee__Production_Job__c>(
      [
        SELECT
          Id,
          (
            SELECT Id, Quantity__c, Measurement__c, Completed__c
            FROM ozbee__Production_Schedule_Items__r
          )
        FROM ozbee__Production_Job__c
        WHERE Id IN :jobIds
      ]
    );
  }

  public static void calculatePercentComplete(
    List<ozbee__Production_Schedule_Item__c> newProductionScheduleItems,
    Map<Id, ozbee__Production_Schedule_Item__c> oldProductionScheduleItemsMap
  ) {
    Set<Id> filteredProductionJobIds = new Set<Id>();

    for (
      ozbee__Production_Schedule_Item__c productionScheduleItem : newProductionScheduleItems
    ) {
      ozbee__Production_Schedule_Item__c oldProductionScheduleItem = oldProductionScheduleItemsMap.get(
        productionScheduleItem.Id
      );

      if (
        productionScheduleItem.Completed__c !=
        oldProductionScheduleItem.Completed__c
      ) {
        filteredProductionJobIds.add(
          productionScheduleItem.ozbee__Production_Job__c
        );
      }
    }

    ProductionJobService.calculatePercentComplete(filteredProductionJobIds);
  }

  public class ProductionItemSchemaWrapper {
    @AuraEnabled
    public String sobjectName;
  }
}
