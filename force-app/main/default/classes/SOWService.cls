public with sharing class SOWService {
  public static void setProductionJob(List<SOW__c> SOWs) {
    Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(
      [
        SELECT Id, (SELECT Id FROM ozbee__Production_Centers__r)
        FROM Opportunity
        WHERE Id IN :Pluck.ids('Opportunity__c', SOWs)
      ]
    );

    for (SOW__c SOW : SOWs) {
      List<ozbee__Production_Job__c> productionJobs = opportunities.get(
          SOW.Opportunity__c
        )
        .ozbee__Production_Centers__r;
      if (productionJobs.size() > 0) {
        SOW.Production_Job__c = productionJobs[0].Id;
      }
    }
  }

  public static void createSOWItemsFromTemplate(List<SOW__c> SOWs) {
    List<SOW__c> filteredSOWs = new List<SOW__c>();

    for (SOW__C SOW : SOWs) {
      if (SOW.Type__c != null) {
        filteredSOWs.add(SOW);
      }
    }

    if (filteredSOWs.size() == 0) {
      return;
    }

    List<SOW_Template__c> SOWTemplates = [
      SELECT
        Id,
        Name,
        (SELECT Id, Title__c, Description__c FROM SOW_Item_Templates__r)
      FROM SOW_Template__c
      WHERE Name IN :Pluck.strings('Type__c', filteredSOWs)
    ];

    Map<String, SOW_Template__c> SOWTemplateMap = new Map<String, SOW_Template__c>();

    for (SOW_Template__c SOWTemplate : SOWTemplates) {
      SOWTemplateMap.put(SOWTemplate.Name, SOWTemplate);
    }

    List<SOW_Item__c> SOWItemsToInsert = new List<SOW_Item__c>();

    for (SOW__c SOW : filteredSOWs) {
      for (
        SOW_Item_Template__c SOWItemTemplate : SOWTemplateMap.get(SOW.Type__c)
          .SOW_Item_Templates__r
      ) {
        SOWItemsToInsert.add(
          new SOW_Item__c(
            SOW__c = SOW.Id,
            Title__c = SOWItemTemplate.Title__c,
            Description__c = SOWItemTemplate.Description__c,
            Status__c = 'Not Started'
          )
        );
      }
    }

    if (SOWItemsToInsert.size() > 0) {
      insert SOWItemsToInsert;
    }
  }
}
