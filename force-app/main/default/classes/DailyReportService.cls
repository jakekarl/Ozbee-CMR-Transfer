public with sharing class DailyReportService {
  @AuraEnabled
  public static Map<Id, ozbee__Production_Job_Report__c> getDailyReports(
    List<Id> dailyReportIds
  ) {
    return new Map<Id, ozbee__Production_Job_Report__c>(
      [
        SELECT
          Id,
          CompanyCam_Project_ID__c,
          (
            SELECT
              Id,
              Company_Cam_Photo_Id__c,
              ozbee__Daily_Report_Item__c,
              ozbee__Production_Job_Report__c
            FROM ozbee__Production_Job_Report_Photos__r
          )
        FROM ozbee__Production_Job_Report__c
        WHERE Id = :dailyReportIds
      ]
    );
  }

  public static void createDefaultChecklistItems(
    List<ozbee__Production_Job_Report__c> dailyReports
  ) {
    List<ozbee__Production_Job_Checklist_Template__c> defaultChecklistTemplates = ChecklistTemplateService.getDefaultChecklistTemplates();

    List<ozbee__Production_Job_Checklist_Template_Item__c> checklistTemplateItems = new List<ozbee__Production_Job_Checklist_Template_Item__c>();
    for (
      ozbee__Production_Job_Checklist_Template__c checklistTemplate : defaultChecklistTemplates
    ) {
      for (
        ozbee__Production_Job_Checklist_Template_Item__c item : checklistTemplate.ozbee__Production_Job_Checklist_Items__r
      ) {
        checklistTemplateItems.add(item);
      }
    }

    DailyReportChecklistService.createDailyReportChecklists(
      Pluck.ids(dailyReports),
      Pluck.ids(defaultChecklistTemplates)
    );
    DailyReportItemService.createDailyReportItems(
      Pluck.ids(dailyReports),
      checklistTemplateItems
    );
  }

  public static void createDailyExpectedProductions(
    List<ozbee__Production_Job_Report__c> dailyReports
  ) {
    Map<Id, ozbee__Production_Job__c> productionScheduleItemsByJob = ProductionScheduleItemService.getProductionScheduleItemsByJob(
      Pluck.ids('ozbee__Production_Job__c', dailyReports)
    );

    List<Daily_Expected_Production__c> dailyExpectedProductionsToInsert = new List<Daily_Expected_Production__c>();

    for (ozbee__Production_Job_Report__c dailyReport : dailyReports) {
      List<ozbee__Production_Schedule_Item__c> productionScheduleItems = productionScheduleItemsByJob.get(
          dailyReport.ozbee__Production_Job__c
        )
        .ozbee__Production_Schedule_Items__r;

      if (
        productionScheduleItems == null ||
        productionScheduleItems.size() == 0
      ) {
        continue;
      }

      for (
        ozbee__Production_Schedule_Item__c productionScheduleItem : productionScheduleItems
      ) {
        dailyExpectedProductionsToInsert.add(
          new Daily_Expected_Production__c(
            Daily_Report__c = dailyReport.Id,
            Production_Schedule_Item__c = productionScheduleItem.Id,
            Date__c = Date.today(),
            Expected_Total__c = productionScheduleItem.Quantity__c,
            Previously_Completed__c = productionScheduleItem.Completed__c,
            Measurement__c = productionScheduleItem.Measurement__c
          )
        );
      }

      if (dailyExpectedProductionsToInsert.size() > 0) {
        insert dailyExpectedProductionsToInsert;
      }
    }
  }

  public static void addSafetyManagerToOpportunityTeam(
    List<ozbee__Production_Job_Report__c> newDailyReports,
    Map<Id, ozbee__Production_Job_Report__c> oldDailyReportsMap
  ) {
    List<ozbee__Production_Job_Report__c> filteredDailyReports = new List<ozbee__Production_Job_Report__c>();

    for (ozbee__Production_Job_Report__c dailyReport : newDailyReports) {
      if (
        oldDailyReportsMap.size() > 0 &&
        dailyReport.ozbee__Safety_Manager__c !=
        oldDailyReportsMap.get(dailyReport.Id).ozbee__Safety_Manager__c
      ) {
        filteredDailyReports.add(dailyReport);
      } else if (dailyReport.ozbee__Safety_Manager__c != null) {
        filteredDailyReports.add(dailyReport);
      }
    }

    Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(
      [
        SELECT
          Id,
          (SELECT Id, UserId, TeamMemberRole FROM OpportunityTeamMembers)
        FROM Opportunity
        WHERE Id IN :Pluck.ids('Opportunity__c', filteredDailyReports)
      ]
    );

    List<OpportunityTeamMember> opportunityTeamMembers = new List<OpportunityTeamMember>();

    for (ozbee__Production_Job_Report__c dailyReport : filteredDailyReports) {
      Opportunity opportunity = opportunities.get(dailyReport.Opportunity__c);

      Set<Id> teamMemberUserIds = Pluck.ids(
        'UserId',
        opportunity.OpportunityTeamMembers
      );

      if (!teamMemberUserIds.contains(dailyReport.ozbee__Safety_Manager__c)) {
        opportunityTeamMembers.add(
          new OpportunityTeamMember(
            OpportunityId = opportunity.Id,
            OpportunityAccessLevel = 'Edit',
            UserId = dailyReport.ozbee__Safety_Manager__c,
            TeamMemberRole = 'Safety Manager'
          )
        );
      }
    }

    if (opportunityTeamMembers.size() > 0) {
      insert opportunityTeamMembers;
    }
  }
}
