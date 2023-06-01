public with sharing class ProductionJobService {
  public static void setSOWProductionJob(
    List<ozbee__Production_Job__c> productionJobs
  ) {
    Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(
      [
        SELECT Id, (SELECT Id, Production_Job__c FROM SOWs__r)
        FROM Opportunity
        WHERE Id IN :Pluck.ids('ozbee__Opportunity__c', productionJobs)
      ]
    );

    List<SOW__c> SOWToUpdate = new List<SOW__c>();

    for (ozbee__Production_Job__c productionJob : productionJobs) {
      List<SOW__c> SOWs = opportunities.get(productionJob.ozbee__Opportunity__c)
        .SOWs__r;
      for (SOW__c SOW : SOWs) {
        SOW.Production_Job__c = productionJob.Id;
        SOWToUpdate.add(SOW);
      }
    }

    update SOWToUpdate;
  }

  public static void calculatePercentComplete(Set<Id> productionJobIds) {
    List<ozbee__Production_Job__c> productionJobs = [
      SELECT
        Id,
        Percent_Complete__c,
        (
          SELECT Id, Quantity__c, Completed__c, Measurement__c
          FROM ozbee__Production_Schedule_Items__r
        )
      FROM ozbee__Production_Job__c
      WHERE Id IN :productionJobIds
    ];

    for (ozbee__Production_Job__c productionJob : productionJobs) {
      Decimal total = 0;
      Decimal completed = 0;

      for (
        ozbee__Production_Schedule_Item__c productionScheduleItem : productionJob.ozbee__Production_Schedule_Items__r
      ) {
        if (productionScheduleItem.Measurement__c == 'Squares') {
          total += productionScheduleItem.Quantity__c;
          completed += productionScheduleItem.Completed__c;
        }
      }

      productionJob.Percent_Complete__c = completed / total * 100;
    }

    update productionJobs;
  }
}
