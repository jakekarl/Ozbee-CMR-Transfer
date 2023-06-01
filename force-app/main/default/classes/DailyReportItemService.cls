public with sharing class DailyReportItemService {
  @AuraEnabled
  public static List<ozbee__Production_Job_Report_Item__c> getDailyReportItems(
    Id dailyReportId
  ) {
    return [
      SELECT
        Id,
        Name,
        ozbee__Task_Name__c,
        ozbee__Task_Status__c,
        ozbee__Task_Comment__c,
        ozbee__Safety_Inspection_Category__c,
        ozbee__Production_Job_Report__c,
        Checklist__c,
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
      WHERE ozbee__Production_Job_Report__c = :dailyReportId
      ORDER BY Order__c ASC
    ];
  }

  public static void createDailyReportItems(
    Set<Id> dailyReportIds,
    List<ozbee__Production_Job_Checklist_Template_Item__c> checklistTemplateItems
  ) {
    List<ozbee__Production_Job_Report_Item__c> dailyReportItemsToInsert = new List<ozbee__Production_Job_Report_Item__c>();

    for (Id dailyReportId : dailyReportIds) {
      for (
        ozbee__Production_Job_Checklist_Template_Item__c item : checklistTemplateItems
      ) {
        dailyReportItemsToInsert.add(
          new ozbee__Production_Job_Report_Item__c(
            ozbee__Production_Job_Report__c = dailyReportId,
            Name = item.Name,
            ozbee__Task_Name__c = item.ozbee__Task_Name__c,
            Checklist__c = item.ozbee__Production_Job_Checklist_Template__r.ozbee__Checklist_Type__c,
            Order__c = item.Order__c
          )
        );
      }
    }

    if (dailyReportItemsToInsert.size() > 0) {
      insert dailyReportItemsToInsert;
    }
  }
}
