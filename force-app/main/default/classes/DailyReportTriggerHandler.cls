public with sharing class DailyReportTriggerHandler extends TriggerHandler {
  List<ozbee__Production_Job_Report__c> newDailyReports;
  Map<Id, ozbee__Production_Job_Report__c> newDailyReportsMap;
  List<ozbee__Production_Job_Report__c> oldDailyReports;
  Map<Id, ozbee__Production_Job_Report__c> oldDailyReportsMap;

  public DailyReportTriggerHandler() {
    this.newDailyReports = (List<ozbee__Production_Job_Report__c>) Trigger.new;
    this.newDailyReportsMap = (Map<Id, ozbee__Production_Job_Report__c>) Trigger.newMap;
    this.oldDailyReports = (List<ozbee__Production_Job_Report__c>) Trigger.old;
    this.oldDailyReportsMap = (Map<Id, ozbee__Production_Job_Report__c>) Trigger.oldMap;
  }

  public override void afterInsert() {
    DailyReportService.createDefaultChecklistItems(newDailyReports);
    DailyReportService.createDailyExpectedProductions(newDailyReports);
    DailyReportService.addSafetyManagerToOpportunityTeam(
      newDailyReports,
      new Map<Id, ozbee__Production_Job_Report__c>()
    );
  }

  public override void afterUpdate() {
    DailyReportService.addSafetyManagerToOpportunityTeam(
      newDailyReports,
      oldDailyReportsMap
    );
  }
}
