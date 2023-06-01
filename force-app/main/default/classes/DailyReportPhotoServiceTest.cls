@isTest
private with sharing class DailyReportPhotoServiceTest {
  // * Test purpose: ensure all photos are deleted when the deleteDailyReportPhotos() is called from the DailyReportPhotoService
  @isTest
  private static void deleteDailyReportPhotos() {
    // Create daily report photos
    List<ozbee__Production_Job_Report_Photo__c> dailyReportPhotos = new SObjectBuilder(
        ozbee__Production_Job_Report_Photo__c.sObjectType
      )
      .count(200)
      .create()
      .getRecords();

    Set<Id> dailyReportIds = Pluck.ids(
      [SELECT Id FROM ozbee__Production_Job_Report__c]
    );

    Test.startTest();
    // Delete photos
    DailyReportPhotoService.deleteDailyReportPhotos(dailyReportIds);
    Test.stopTest();

    List<ozbee__Production_Job_Report_Photo__c> updatedDailyReportPhotos = [
      SELECT Id
      FROM ozbee__Production_Job_Report_Photo__c
    ];

    // Store expected and actual values for readability and comparison
    Integer expectedNumberOfPhotos = 0;
    Integer actualNumberOfPhotos = updatedDailyReportPhotos.size();

    // ASSERTION
    Assert.areEqual(
      expectedNumberOfPhotos,
      actualNumberOfPhotos,
      'Actual number of daily report photos exceeds the expected number of daily report photos.'
    );
  }
}
