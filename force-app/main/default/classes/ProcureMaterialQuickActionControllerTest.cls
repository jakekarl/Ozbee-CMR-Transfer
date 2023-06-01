@isTest
public class ProcureMaterialQuickActionControllerTest {
  @isTest
  private static void createProcureMaterialTask_Success() {
    // * CREATE OPPORTUNITY
    List<Opportunity> opportunities = new List<Opportunity>();

    opportunities.add(
      new Opportunity(
        Name = 'Test Opportunity',
        CloseDate = Date.today(),
        StageName = 'New'
      )
    );

    insert opportunities;

    Test.startTest();
    ProcureMaterialsQuickActionController.createProcureMaterialTask(
      opportunities[0].Id
    );
    Test.stopTest();

    List<Task> tasks = [
      SELECT Id, OwnerId, WhatId
      FROM Task
      WHERE Subject = 'Procure Materials'
    ];
    User taskUser = [SELECT Id FROM User WHERE Name = 'Michelle Cutlip'];

    System.assertEquals(1, tasks.size(), 'Exactly 1 task was not created');
    System.assertEquals(
      taskUser.Id,
      tasks[0].OwnerId,
      'The incorrect user was assigned to the task'
    );
    System.assertEquals(
      opportunities[0].Id,
      tasks[0].WhatId,
      'The incorrect opportunity was assigned to the task'
    );
  }

  @isTest
  private static void createProcureMaterialTask_Error() {
    User taskUser = [SELECT Id FROM User WHERE Name = 'Michelle Cutlip'];

    Exception thrownException;

    Test.startTest();
    try {
      ProcureMaterialsQuickActionController.createProcureMaterialTask(
        taskUser.Id
      );
    } catch (Exception ex) {
      thrownException = ex;
    }
    Test.stopTest();

    System.assert(thrownException != null, 'An exception was not thrown');
  }
}
