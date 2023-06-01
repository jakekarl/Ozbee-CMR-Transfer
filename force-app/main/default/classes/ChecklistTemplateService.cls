public with sharing class ChecklistTemplateService {
  public static List<ozbee__Production_Job_Checklist_Template__c> getUnusedChecklistTemplates(
    Id dailyReportId
  ) {
    return [
      SELECT Id, ozbee__Checklist_Type__c
      FROM ozbee__Production_Job_Checklist_Template__c
      WHERE
        Id NOT IN (
          SELECT Production_Job_Checklist_Template__c
          FROM Daily_Report_Checklist__c
          WHERE Daily_Report__c = :dailyReportId
        )
        AND Active__c = TRUE
    ];
  }

  public static List<ozbee__Production_Job_Checklist_Template__c> getActiveChecklistTemplates() {
    return [
      SELECT Id, ozbee__Checklist_Type__c
      FROM ozbee__Production_Job_Checklist_Template__c
      WHERE Active__c = TRUE
    ];
  }

  public static List<ozbee__Production_Job_Checklist_Template__c> getDefaultChecklistTemplates() {
    return [
      SELECT
        Id,
        ozbee__Checklist_Type__c,
        (
          SELECT
            Id,
            Name,
            ozbee__Task_Name__c,
            ozbee__Production_Job_Checklist_Template__r.ozbee__Checklist_Type__c,
            Order__c
          FROM ozbee__Production_Job_Checklist_Items__r
        )
      FROM ozbee__Production_Job_Checklist_Template__c
      WHERE Default__c = TRUE AND Active__c = TRUE
    ];
  }
}
