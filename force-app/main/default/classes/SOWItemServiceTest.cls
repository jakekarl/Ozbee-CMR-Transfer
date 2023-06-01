@isTest
private class SOWItemServiceTest {
  @isTest
  private static void deleteParentProductionScheduleItems() {
    SOW_Item__c SOWItem = (SOW_Item__c) new SObjectBuilder(
        SOW_Item__c.sObjectType
      )
      .put(
        SOW_Item__c.Production_Schedule_Item__c,
        SObjectFactory.provideGenericParent(
          ozbee__Production_Schedule_Item__c.sObjectType
        )
      )
      .create()
      .getRecord();

    Assert.isNotNull(
      SOWItem.Production_Schedule_Item__c,
      'Production Schedule Item was not set'
    );

    Test.startTest();
    SOWItemService.deleteParentProductionScheduleItems(
      new List<SOW_Item__c>{ SOWItem }
    );
    Test.stopTest();

    List<ozbee__Production_Schedule_Item__c> productionScheduleItems = [
      SELECT Id
      FROM ozbee__Production_Schedule_Item__c
    ];

    Assert.areEqual(
      0,
      productionScheduleItems.size(),
      'Production Schedule Item was not deleted'
    );
  }
}
