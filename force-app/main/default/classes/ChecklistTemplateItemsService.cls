public with sharing class ChecklistTemplateItemsService {
  public static List<ozbee__Production_Job_Checklist_Template_Item__c> getChecklistTemplateItems(
    List<Id> checklistTemplateIds
  ) {
    return [
      SELECT
        Id,
        Name,
        ozbee__Task_Name__c,
        ozbee__Safety_Inspection_Category__c,
        Order__c,
        ozbee__Production_Job_Checklist_Template__r.ozbee__Checklist_Type__c
      FROM ozbee__Production_Job_Checklist_Template_Item__c
      WHERE ozbee__Production_Job_Checklist_Template__c IN :checklistTemplateIds
      ORDER BY Order__c ASC
    ];
  }
}
