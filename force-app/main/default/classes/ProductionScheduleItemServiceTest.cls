@isTest
private class ProductionScheduleItemServiceTest {
  @isTest
  private static void getExportProductionItemFieldSet() {
    List<ProductionScheduleItemService.ProductionItemSchemaWrapper> fieldSetMembers = ProductionScheduleItemService.getExportProductionItemFieldSet();

    List<Map<String, String>> listOfFieldSetMembers = new List<Map<String, String>>();

    for (
      Schema.FieldSetMember fieldset : SObjectType.ozbee__Production_Schedule_Item__c.FieldSets.getMap()
        .get('Production_Schedule_Export')
        .getFields()
    ) {
      Map<String, String> labelFieldSetMap = new Map<String, String>();
      labelFieldSetMap.put(fieldset.getLabel(), fieldset.getFieldPath());

      listOfFieldSetMembers.add(labelFieldSetMap);
    }

    String expectedFieldSetMemberString = JSON.serialize(listOfFieldSetMembers);

    System.assertEquals(
      listOfFieldSetMembers.size(),
      fieldSetMembers.size(),
      'Expected the same fieldset to be returned'
    );
  }
  @isTest
  private static void getProductionScheduleItems() {
    new SObjectBuilder(ozbee__Production_Schedule_Item__c.sObjectType)
      .count(5)
      .create();

    ozbee__Production_Job__c productionJob = [
      SELECT Id
      FROM ozbee__Production_Job__c
    ];

    Test.startTest();
    List<ozbee__Production_Schedule_Item__c> productionScheduleItems = ProductionScheduleItemService.getProductionScheduleItems(
      productionJob.Id
    );
    Test.stopTest();

    Assert.areEqual(
      5,
      productionScheduleItems.size(),
      'Exactly 5 Production Schedule Item records were not returned'
    );
  }
}
