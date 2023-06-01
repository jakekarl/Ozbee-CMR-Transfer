@isTest
public with sharing class GenerateProductionScheduleControllerTest {
  @IsTest
  private static void createProductionScheduleItems_exception() {
    ozbee__Production_Job__c productionJob = (ozbee__Production_Job__c) new SObjectBuilder(
        ozbee__Production_Job__c.sObjectType
      )
      .create()
      .getRecord();

    Boolean error = false;

    Test.startTest();
    try {
      GenerateProductionScheduleController.createProductionScheduleItems(
        productionJob.Id
      );
    } catch (Exception e) {
      error = true;
    }
    Test.stopTest();

    System.assertEquals(true, error, 'Exception was not thrown');
  }

  @IsTest
  private static void createProductionScheduleItems_success() {
    ozbee__Production_Job__c productionJob = (ozbee__Production_Job__c) new SObjectBuilder(
        ozbee__Production_Job__c.sObjectType
      )
      .create()
      .getRecord();

    SOW__c sow = (SOW__c) new SObjectBuilder(SOW__c.sObjectType)
      .put(SOW__c.Production_Job__c, productionJob.Id)
      .put(SOW__c.Ready_to_Schedule__c, true)
      .create()
      .getRecord();

    List<SOW_Item__c> sowItems = new SObjectBuilder(SOW_Item__c.sObjectType)
      .put(SOW_Item__c.SOW__c, sow.Id)
      .put(SOW_Item__c.Start_Date__c, Date.Today() + 1)
      .put(SOW_Item__c.End_Date__c, Date.Today() + 2)
      .create()
      .getRecords();

    Test.startTest();
    GenerateProductionScheduleController.createProductionScheduleItems(
      productionJob.Id
    );
    Test.stopTest();

    List<ozbee__Production_Schedule_Item__c> items = [
      SELECT Id
      FROM ozbee__Production_Schedule_Item__c
    ];

    System.AssertEquals(1, items.size(), 'No production schedule items');

    List<SOW_Item__c> updatedSOWItems = [
      SELECT Id, Schedule_Generated__c, Production_Schedule_Item__c
      FROM SOW_Item__c
    ];

    System.AssertEquals(
      1,
      updatedSOWItems.size(),
      'The updated SOW items list size is not equal to 1'
    );
    System.AssertEquals(
      true,
      updatedSOWItems[0].Schedule_Generated__c,
      'Schedule generated was not correctly set'
    );
    System.AssertEquals(
      items[0].Id,
      updatedSOWItems[0].Production_Schedule_Item__c,
      'The Production schedule item lookup was not correctly set'
    );
  }
}
