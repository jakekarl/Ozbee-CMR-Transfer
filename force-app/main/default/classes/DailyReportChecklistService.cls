public with sharing class DailyReportChecklistService {
  public static void createDailyReportChecklists(
    Set<Id> dailyReportIds,
    Set<Id> checklistTemplateIds
  ) {
    List<Daily_Report_Checklist__c> dailyReportChecklists = new List<Daily_Report_Checklist__c>();

    for (Id dailyReportId : dailyReportIds) {
      for (Id checklistTemplateId : checklistTemplateIds) {
        dailyReportChecklists.add(
          new Daily_Report_Checklist__c(
            Daily_Report__c = dailyReportId,
            Production_Job_Checklist_Template__c = checklistTemplateId
          )
        );
      }
    }

    insert dailyReportChecklists;
  }
}
