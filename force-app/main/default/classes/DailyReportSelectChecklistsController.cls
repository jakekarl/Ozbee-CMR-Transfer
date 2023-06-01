public with sharing class DailyReportSelectChecklistsController {
  @AuraEnabled(cacheable=true)
  public static List<ozbee__Production_Job_Checklist_Template__c> getChecklistTemplates(
    Id dailyReportId
  ) {
    try {
      return ChecklistTemplateService.getUnusedChecklistTemplates(
        dailyReportId
      );
      // return ChecklistTemplateService.getActiveChecklistTemplates();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void createDailyReportItems(
    Id dailyReportId,
    String checklistTemplateIdsString
  ) {
    try {
      List<Id> checklistTemplateIds = (List<Id>) JSON.deserialize(
        checklistTemplateIdsString,
        List<Id>.class
      );

      DailyReportChecklistService.createDailyReportChecklists(
        new Set<Id>{ dailyReportId },
        new Set<Id>(checklistTemplateIds)
      );

      List<ozbee__Production_Job_Checklist_Template_Item__c> checklistTemplateItems = ChecklistTemplateItemsService.getChecklistTemplateItems(
        checklistTemplateIds
      );
      DailyReportItemService.createDailyReportItems(
        new Set<Id>{ dailyReportId },
        checklistTemplateItems
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
