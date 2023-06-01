public with sharing class DailyExpectedProductionService {
  @AuraEnabled
  public static List<Daily_Expected_Production__c> getDailyReportExpectedProduction(
    Id dailyReportId
  ) {
    return [
      SELECT
        Id,
        Name,
        Expected_Total__c,
        Previously_Completed__c,
        Completed_Today__c,
        Expected__c,
        Completed__c,
        Measurement__c,
        Production_Schedule_Item__r.Name
      FROM Daily_Expected_Production__c
      WHERE Daily_Report__c = :dailyReportId
    ];
  }
}
