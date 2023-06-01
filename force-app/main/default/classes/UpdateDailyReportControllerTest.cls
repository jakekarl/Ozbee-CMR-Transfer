@isTest
private class UpdateDailyReportControllerTest {
  @isTest
  private static void updateDailyReportItems_Success() {
    List<ozbee__Production_Job_Report_Photo__c> dailyReportPhotos = new SObjectBuilder(
        ozbee__Production_Job_Report_Photo__c.sObjectType
      )
      .put(
        ozbee__Production_Job_Report_Photo__c.ozbee__Daily_Report_Item__c,
        SObjectFactory.provideGenericParent(
          ozbee__Production_Job_Report_Item__c.sObjectType
        )
      )
      .count(5)
      .create()
      .getRecords();

    List<ozbee__Production_Job_Report_Item__c> dailyReportItems = [
      SELECT
        Id,
        ozbee__Task_Status__c,
        ozbee__Production_Job_Report__c,
        (
          SELECT
            Id,
            Company_Cam_Photo_Id__c,
            ozbee__Daily_Report_Item__c,
            ozbee__Production_Job_Report__c,
            ozbee__URL__c,
            ozbee__Photo_Comment__c
          FROM ozbee__Daily_Report_Photos__r
        )
      FROM ozbee__Production_Job_Report_Item__c
    ];
    Assert.areEqual(
      1,
      dailyReportItems.size(),
      'More than 1 daily report item was returned'
    );
    Assert.areEqual(
      5,
      dailyReportItems[0].ozbee__Daily_Report_Photos__r.size(),
      'More than 5 daily report photos were returned'
    );

    String status = 'YES';
    dailyReportItems[0].ozbee__Task_Status__c = status;

    List<ozbee__Production_Job_Report_Photo__c> photos = dailyReportItems[0]
      .ozbee__Daily_Report_Photos__r;
    photos.remove(photos.size() - 1);

    for (ozbee__Production_Job_Report_Photo__c photo : photos) {
      photo.Id = null;
    }

    Test.startTest();
    UpdateDailyReportController.updateDailyReportItems(
      JSON.serialize(dailyReportItems),
      JSON.serialize(photos)
    );
    Test.stopTest();

    List<ozbee__Production_Job_Report_Item__c> updateDailyReportItems = [
      SELECT
        Id,
        ozbee__Task_Status__c,
        (SELECT Id FROM ozbee__Daily_Report_Photos__r)
      FROM ozbee__Production_Job_Report_Item__c
    ];

    Assert.areEqual(
      1,
      updateDailyReportItems.size(),
      'More than 1 daily report item was returned'
    );
    Assert.areEqual(
      status,
      updateDailyReportItems[0].ozbee__Task_Status__c,
      'Item status was not updated correctly'
    );
    Assert.areEqual(
      4,
      updateDailyReportItems[0].ozbee__Daily_Report_Photos__r.size(),
      'Daily Report Photo was not removed correctly'
    );
  }

  @isTest
  private static void updateDailyReportItems_Failure() {
    Account account = (Account) new SObjectBuilder(Account.sObjectType)
      .create()
      .getRecord();

    Exception thrownException;
    Test.startTest();
    try {
      UpdateDailyReportController.updateDailyReportItems(
        JSON.serialize(account),
        JSON.serialize(account)
      );
    } catch (Exception ex) {
      thrownException = ex;
    }
    Test.stopTest();

    Assert.isNotNull(thrownException, 'An exception was not thrown');
  }

  @isTest
  private static void updateDailyExpectedProductions_Success() {
    List<Daily_Expected_Production__c> expectedProductions = new SObjectBuilder(
        Daily_Expected_Production__c.sObjectType
      )
      .put(Daily_Expected_Production__c.Expected__c, 10)
      .count(5)
      .create()
      .getRecords();

    expectedProductions[0].Completed__c = 10;
    expectedProductions[1].Completed__c = 5;

    Test.startTest();
    UpdateDailyReportController.updateDailyExpectedProductions(
      JSON.serialize(expectedProductions)
    );
    Test.stopTest();

    List<Daily_Expected_Production__c> updatedDailyExpectedProductions = [
      SELECT Id, Completed__c
      FROM Daily_Expected_Production__c
      ORDER BY CreatedDate DESC
    ];

    Assert.areEqual(
      10,
      updatedDailyExpectedProductions[0].Completed__c,
      'The completed value was not updated'
    );
    Assert.areEqual(
      5,
      updatedDailyExpectedProductions[1].Completed__c,
      'The completed value was not updated'
    );
    Assert.isNull(
      updatedDailyExpectedProductions[2].Completed__c,
      'The completed value should not have been updated'
    );
    Assert.isNull(
      updatedDailyExpectedProductions[3].Completed__c,
      'The completed value should not have been updated'
    );
    Assert.isNull(
      updatedDailyExpectedProductions[4].Completed__c,
      'The completed value should not have been updated'
    );
  }

  @isTest
  private static void updateDailyExpectedProductions_Failure() {
    Account account = (Account) new SObjectBuilder(Account.sObjectType)
      .create()
      .getRecord();

    Exception thrownException;
    Test.startTest();
    try {
      UpdateDailyReportController.updateDailyExpectedProductions(
        JSON.serialize(account)
      );
    } catch (Exception ex) {
      thrownException = ex;
    }
    Test.stopTest();

    Assert.isNotNull(thrownException, 'An exception was not thrown');
  }

  @isTest
  private static void getProjectPhotos() {
    String companyCamId = '12345678';

    Test.startTest();
    List<CompanyCamPhoto> companyCamPhotos = UpdateDailyReportController.getProjectPhotos(
      companyCamId
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      companyCamPhotos.size(),
      'Exactly 1 photo should be returned'
    );
  }

  @isTest
  private static void getDailyReportData() {
    List<ozbee__Production_Job_Report_Photo__c> dailyReportPhotos = new SObjectBuilder(
        ozbee__Production_Job_Report_Photo__c.sObjectType
      )
      .put(
        ozbee__Production_Job_Report_Photo__c.ozbee__Daily_Report_Item__c,
        SObjectFactory.provideGenericParent(
          ozbee__Production_Job_Report_Item__c.sObjectType
        )
      )
      .count(5)
      .create()
      .getRecords();

    List<Daily_Expected_Production__c> expectedProductions = new SObjectBuilder(
        Daily_Expected_Production__c.sObjectType
      )
      .put(Daily_Expected_Production__c.Expected__c, 10)
      .count(5)
      .create()
      .getRecords();

    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    Test.startTest();
    UpdateDailyReportController.DailyReportData data = UpdateDailyReportController.getDailyReportData(
      dailyReport.Id
    );
    Test.stopTest();

    Assert.areEqual(
      data.dailyReport.Id,
      dailyReport.Id,
      'The incorrect daily report was returned'
    );
    Assert.areEqual(
      1,
      data.dailyReportItems.size(),
      'Exactly 1 Daily Report Item record was not returned'
    );
    Assert.areEqual(
      5,
      data.dailyExpectedProduction.size(),
      'Exactly 5 Daily Expected Production records were not returned'
    );
    Assert.areEqual(
      0,
      data.projectPhotos.size(),
      'Exactly 1 project photo record was not returnned'
    );
  }
}
