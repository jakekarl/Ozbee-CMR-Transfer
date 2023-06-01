public with sharing class UpdateDailyReportController {
  @AuraEnabled
  public static void updateDailyReportItems(
    String dailyReportItemsString,
    String dailyReportPhotosString
  ) {
    try {
      List<ozbee__Production_Job_Report_Item__c> dailyReportItems = (List<ozbee__Production_Job_Report_Item__c>) JSON.deserialize(
        dailyReportItemsString,
        List<ozbee__Production_Job_Report_Item__c>.class
      );

      List<ozbee__Production_Job_Report_Photo__c> dailyReportItemPhotos = (List<ozbee__Production_Job_Report_Photo__c>) JSON.deserialize(
        dailyReportPhotosString,
        List<ozbee__Production_Job_Report_Photo__c>.class
      );

      update dailyReportItems;

      DailyReportPhotoService.deleteDailyReportPhotos(
        new Set<Id>{ dailyReportItems[0].ozbee__Production_Job_Report__c }
      );
      insert dailyReportItemPhotos;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void updateDailyExpectedProductions(
    String dailyExpectedProductionsString
  ) {
    try {
      List<Daily_Expected_Production__c> dailyExpectedProductions = (List<Daily_Expected_Production__c>) JSON.deserialize(
        dailyExpectedProductionsString,
        List<Daily_Expected_Production__c>.class
      );

      update dailyExpectedProductions;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<CompanyCamPhoto> getProjectPhotos(String companyCamId) {
    try {
      return CompanyCamCalloutUtility.loadCompanyCamPhotos(companyCamId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static DailyReportData getDailyReportData(Id dailyReportId) {
    ozbee__Production_Job_Report__c dailyReport = DailyReportService.getDailyReports(
        new List<Id>{ dailyReportId }
      )
      .get(dailyReportId);

    return new DailyReportData(
      dailyReport,
      DailyReportItemService.getDailyReportItems(dailyReportId),
      DailyExpectedProductionService.getDailyReportExpectedProduction(
        dailyReportId
      ),
      CompanyCamCalloutUtility.loadCompanyCamPhotos(
        dailyReport.CompanyCam_Project_ID__c
      )
    );
  }

  public class DailyReportData {
    @AuraEnabled
    public ozbee__Production_Job_Report__c dailyReport { get; set; }
    @AuraEnabled
    public List<ozbee__Production_Job_Report_Item__c> dailyReportItems {
      get;
      set;
    }
    @AuraEnabled
    public List<Daily_Expected_Production__c> dailyExpectedProduction {
      get;
      set;
    }
    @AuraEnabled
    public List<CompanyCamPhoto> projectPhotos { get; set; }

    public DailyReportData(
      ozbee__Production_Job_Report__c dailyReport,
      List<ozbee__Production_Job_Report_Item__c> dailyReportItems,
      List<Daily_Expected_Production__c> dailyExpectedProduction,
      List<CompanyCamPhoto> projectPhotos
    ) {
      this.dailyReport = dailyReport;
      this.dailyReportItems = dailyReportItems;
      this.dailyExpectedProduction = dailyExpectedProduction;
      this.projectPhotos = projectPhotos;
    }
  }
}
