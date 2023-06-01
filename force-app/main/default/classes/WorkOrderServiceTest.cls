@isTest
public with sharing class WorkOrderServiceTest {
  @TestSetup
  static void setup() {
    // * CREATE PRODUCT
    List<Product2> products = new List<Product2>();
    Product2 product = new Product2(Name = 'Test Product');
    products.add(product);
    insert products;

    // * CREATE PRICEBOOK ENTRY
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    PricebookEntry pricebookEntry = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = products[0].Id,
      UnitPrice = 10,
      Unit_Cost__c = 5,
      IsActive = true
    );
    pricebookEntries.add(pricebookEntry);
    insert pricebookEntries;

    // * CREATE WORK ORDER
    List<WorkOrder> workOrders = new List<WorkOrder>();
    WorkOrder workOrder = new WorkOrder(
      Status = 'New',
      NTE__c = 1000,
      Pricebook2Id = Test.getStandardPricebookId(),
      Street = '300 N State St',
      City = 'Chicago',
      State = 'IL',
      PostalCode = '60606'
    );
    workorders.add(workOrder);
    insert workOrders;

    // * CREATE PRODUCT CONSUMED
    List<ProductConsumed> productsConsumed = new List<ProductConsumed>();
    ProductConsumed productConsumed = new ProductConsumed(
      WorkOrderId = workOrders[0].Id,
      PricebookEntryId = pricebookEntries[0].Id,
      QuantityConsumed = 1
    );
    productsConsumed.add(productConsumed);
    insert productsConsumed;
  }

  @isTest
  private static void convertProductsConsumed() {
    WorkOrder workOrder = [SELECT Id, Status FROM WorkOrder];

    Test.startTest();
    workOrder.Status = 'Prepare Billing';
    update workOrder;
    Test.stopTest();

    WorkOrder updatedWorkOrder = [
      SELECT Id, (SELECT Id FROM WorkOrderLineItems)
      FROM WorkOrder
      WHERE Id = :workOrder.Id
    ];
    System.assertEquals(
      1,
      updatedWorkOrder.WorkOrderLineItems.size(),
      'Exactly 1 work order line item wasnt created'
    );
  }
}
