@isTest
private class ProductionScheduleItemDayServiceTest {
  @IsTest
  private static void getTodaysItemDaysByProductionJobId_NoResults() {
    new SObjectBuilder(ozbee__Production_Schedule_Item_Day__c.sObjectType)
      .create();

    ozbee__Production_Job__c productionJob = [
      SELECT Id
      FROM ozbee__Production_Job__c
      LIMIT 1
    ];

    Test.startTest();
    Map<Id, List<ozbee__Production_Schedule_Item_Day__c>> todaysItemDays = ProductionScheduleItemDayService.getTodaysItemDaysByProductionJobId(
      new Set<Id>{ productionJob.Id }
    );
    Test.stopTest();

    Assert.areEqual(
      0,
      todaysItemDays.keySet().size(),
      'Should return 1 production job'
    );
  }

  @isTest
  private static void getTodaysItemDaysByProductionJobId_ResultsReturned() {
    new SObjectBuilder(ozbee__Production_Schedule_Item_Day__c.sObjectType)
      .put(ozbee__Production_Schedule_Item_Day__c.ozbee__Date__c, Date.today())
      .create();

    ozbee__Production_Job__c productionJob = [
      SELECT Id
      FROM ozbee__Production_Job__c
      LIMIT 1
    ];

    Test.startTest();
    Map<Id, List<ozbee__Production_Schedule_Item_Day__c>> todaysItemDays = ProductionScheduleItemDayService.getTodaysItemDaysByProductionJobId(
      new Set<Id>{ productionJob.Id }
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      todaysItemDays.keySet().size(),
      'Should return 1 Production Job record'
    );
    Assert.areEqual(
      1,
      todaysItemDays.values()[0].size(),
      'Should return 1 Production Item Day record'
    );
  }
}
