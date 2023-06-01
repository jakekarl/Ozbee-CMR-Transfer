public with sharing class WorkOrderService {
  public static void convertProductsConsumed(
    List<WorkOrder> newWorkOrders,
    Map<Id, WorkOrder> oldWorkOrdersMap
  ) {
    List<WorkOrder> prepareBillingWorkOrders = new List<WorkOrder>();

    Set<String> workOrderStatus = new Set<String>{
      'New',
      'Scheduled',
      'In Progress',
      'On Hold'
    };

    for (WorkOrder workOrder : newWorkOrders) {
      if (
        workOrder.Status == 'Prepare Billing' &&
        workOrderStatus.contains(oldWorkOrdersMap.get(workOrder.Id).Status)
      ) {
        prepareBillingWorkOrders.add(workOrder);
      }
    }

    if (prepareBillingWorkOrders.size() == 0)
      return;

    List<WorkOrderLineItem> existingWorkOrderLineItems = [
      SELECT Id
      FROM WorkOrderLineItem
      WHERE WorkOrderId IN :Pluck.ids(prepareBillingWorkOrders)
    ];
    delete existingWorkOrderLineItems;

    List<ProductConsumed> productsConsumed = [
      SELECT
        Id,
        WorkOrderId,
        PricebookEntryId,
        PricebookEntry.UnitPrice,
        PricebookEntry.Unit_Cost__c,
        QuantityConsumed,
        Product2.Category__c
      FROM ProductConsumed
      WHERE WorkOrderId IN :Pluck.ids(prepareBillingWorkOrders)
    ];

    Map<Id, WorkOrderLineItem> workOrderLineItemsToInsert = new Map<Id, WorkOrderLineItem>();

    for (ProductConsumed productConsumed : productsConsumed) {
      WorkOrderLineItem workOrderLineItem = workOrderLineItemsToInsert.get(
        productConsumed.PricebookEntryId
      );
      if (workOrderLineItem != null) {
        workOrderLineItem.Quantity += productConsumed.QuantityConsumed;
      } else {
        workOrderLineItemsToInsert.put(
          productConsumed.PricebookEntryId,
          new WorkOrderLineItem(
            WorkOrderId = productConsumed.WorkOrderId,
            PricebookEntryId = productConsumed.PricebookEntryId,
            UnitPrice = productConsumed.PricebookEntry.UnitPrice,
            Unit_Cost__c = productConsumed.PricebookEntry.Unit_Cost__c,
            Quantity = productConsumed.QuantityConsumed,
            Category__c = productConsumed.Product2.Category__c
          )
        );
      }
    }

    insert workOrderLineItemsToInsert.values();
  }
}
