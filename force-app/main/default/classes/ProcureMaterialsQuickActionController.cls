public with sharing class ProcureMaterialsQuickActionController {
  @AuraEnabled
  public static void createProcureMaterialTask(Id recordId) {
    try {
      User taskUser = [SELECT Id FROM User WHERE Name = 'Michelle Cutlip'];

      insert new Task(
        Subject = 'Procure Materials',
        OwnerId = taskUser.Id,
        ActivityDate = Date.today().addDays(3),
        Status = 'Not Started',
        WhatId = recordId
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
