public with sharing class ExportProductionScheduleController {
  @AuraEnabled
  public static List<ProductionScheduleItemService.ProductionItemSchemaWrapper> getExportScheduleItemsFieldSet() {
    return ProductionScheduleItemService.getExportProductionItemFieldSet();
  }

  @AuraEnabled
  public static List<ozbee__Production_Schedule_Item__c> getProductionScheduleItems(
    Id recordId
  ) {
    return ProductionScheduleItemService.getProductionScheduleItems(recordId);
  }
}
