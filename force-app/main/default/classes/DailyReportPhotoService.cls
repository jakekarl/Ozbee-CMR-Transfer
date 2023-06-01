public with sharing class DailyReportPhotoService {
  public static void deleteDailyReportPhotos(Set<Id> dailyReportIds) {
    delete [
      SELECT Id
      FROM ozbee__Production_Job_Report_Photo__c
      WHERE ozbee__Production_Job_Report__c IN :dailyReportIds
    ];
  }
}
