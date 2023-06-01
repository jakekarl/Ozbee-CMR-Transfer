@isTest
public class SOWServiceTest {
  @isTest
  private static void setProductionJob() {
    List<SOW__c> sowList = new SObjectBuilder(SOW__c.sObjectType)
      .count(1)
      .create()
      .getRecords();

    ozbee__Production_Job__c productionJob = (ozbee__Production_Job__c) new SObjectBuilder(
        ozbee__Production_Job__c.sObjectType
      )
      .create()
      .getRecord();

    Test.startTest();
    SOWService.setProductionJob(sowList);
    Test.stopTest();

    List<SOW__c> updateSOWs = [SELECT Id, Production_Job__c FROM SOW__c];

    Assert.areEqual(
      1,
      updateSOWs.size(),
      'Exactly 1 SOW record was not retuend'
    );
    Assert.areEqual(
      productionJob.Id,
      updateSOWs[0].Production_Job__c,
      'Incorrect production job was assigned'
    );
  }

  @isTest
  private static void createSOWItemsFromTemplate_WithTemplate() {
    List<SOW_Item_Template__c> sowItemTemplates = new SObjectBuilder(
        SOW_Item_Template__c.sObjectType
      )
      .put(
        SOW_Item_Template__c.SOW_Template__c,
        SObjectFactory.provideGenericParent(
          SOW_Template__c.sObjectType,
          SOW_Template__c.Name,
          'Template 1'
        )
      )
      .count(5)
      .create()
      .getRecords();

    Test.startTest();
    List<SOW__c> sowList = new SObjectBuilder(SOW__c.sObjectType)
      .put(SOW__c.Type__c, 'Template 1')
      .count(1)
      .create()
      .getRecords();
    Test.stopTest();

    List<SOW__c> updatedSOWs = [
      SELECT Id, (SELECT Id FROM SOW_Items__r)
      FROM SOW__c
    ];

    Assert.areEqual(1, updatedSOWs.size(), 'Not exactly 1 SOW was created');
    Assert.areEqual(
      5,
      updatedSOWs[0].SOW_Items__r.size(),
      'Not exactly 5 SOW Items were created'
    );
  }

  @isTest
  private static void createSOWItemsFromTemplate_WithoutTemplate() {
    Test.startTest();
    List<SOW__c> sowList = new SObjectBuilder(SOW__c.sObjectType)
      .count(1)
      .create()
      .getRecords();
    Test.stopTest();

    List<SOW__c> updatedSOWs = [
      SELECT Id, (SELECT Id FROM SOW_Items__r)
      FROM SOW__c
    ];

    Assert.areEqual(1, updatedSOWs.size(), 'Not exactly 1 SOW was created');
    Assert.areEqual(
      0,
      updatedSOWs[0].SOW_Items__r.size(),
      '0 SOW Items should have been created'
    );
  }
}
