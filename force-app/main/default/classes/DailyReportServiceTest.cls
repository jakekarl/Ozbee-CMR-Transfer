@isTest
private class DailyReportServiceTest {
  @TestSetup
  static void setup() {
    Opportunity opportunity = (Opportunity) new SObjectBuilder(
        Opportunity.sObjectType
      )
      .put(Opportunity.CloseDate, Date.today() - 7)
      .create()
      .getRecord();

    ozbee__Production_Job__c productionJob = (ozbee__Production_Job__c) new SObjectBuilder(
        ozbee__Production_Job__c.sObjectType
      )
      .put(ozbee__Production_Job__c.ozbee__Opportunity__c, opportunity.Id)
      .create()
      .getRecord();

    ozbee__Production_Job_Report__c dailyReport = (ozbee__Production_Job_Report__c) new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .put(
        ozbee__Production_Job_Report__c.ozbee__Production_Job__c,
        productionJob.Id
      )
      .put(ozbee__Production_Job_Report__c.Opportunity__c, opportunity.Id)
      .create()
      .getRecord();

    new SObjectBuilder(ozbee__Production_Job_Report_Photo__c.sObjectType)
      .put(
        ozbee__Production_Job_Report_Photo__c.ozbee__Production_Job_Report__c,
        dailyReport.Id
      )
      .count(10)
      .create();
  }

  @isTest
  private static void getDailyReports() {
    List<ozbee__Production_Job_Report__c> dailyReports = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
    ];

    Test.startTest();
    Map<Id, ozbee__Production_Job_Report__c> dailyReportIdsToDailyReports = DailyReportService.getDailyReports(
      new List<Id>(Pluck.ids(dailyReports))
    );
    Test.stopTest();

    Integer actualDailyReportsReturned = dailyReportIdsToDailyReports.keySet()
      .size();
    Integer expectedDailyReportsReturned = 1;

    Assert.areEqual(
      expectedDailyReportsReturned,
      actualDailyReportsReturned,
      'Actual number of daily reports returned does not match the expected number'
    );

    Integer actualDailyReportPhotosReturned = dailyReportIdsToDailyReports.get(
        dailyReports[0].Id
      )
      .ozbee__Production_Job_Report_Photos__r.size();
    Integer expectedDailyReportPhotosReturned = 10;

    Assert.areEqual(
      actualDailyReportPhotosReturned,
      expectedDailyReportPhotosReturned,
      'Actual number of daily report photos returned does not match the expected number'
    );
  }

  @isTest
  private static void createDefaultChecklistItems() {
    List<ozbee__Production_Job_Report__c> dailyReports = new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .put(
        ozbee__Production_Job_Report__c.ozbee__Production_Job__c,
        [SELECT Id FROM ozbee__Production_Job__c LIMIT 1].Id
      )
      .put(
        ozbee__Production_Job_Report__c.Opportunity__c,
        [SELECT Id FROM Opportunity LIMIT 1].Id
      )
      .count(5)
      .create()
      .getRecords();

    ozbee__Production_Job_Checklist_Template__c checklistTemplate = (ozbee__Production_Job_Checklist_Template__c) new SObjectBuilder(
        ozbee__Production_Job_Checklist_Template__c.sObjectType
      )
      .put(ozbee__Production_Job_Checklist_Template__c.Active__c, true)
      .put(ozbee__Production_Job_Checklist_Template__c.Default__c, true)
      .count(5)
      .create()
      .getRecord();

    new SObjectBuilder(
        ozbee__Production_Job_Checklist_Template_Item__c.sObjectType
      )
      .put(
        ozbee__Production_Job_Checklist_Template_Item__c.ozbee__Production_Job_Checklist_Template__c,
        checklistTemplate.Id
      )
      .count(10)
      .create();

    Test.startTest();
    DailyReportService.createDefaultChecklistItems(dailyReports);
    Test.stopTest();

    Integer expectedNumberOfDailyReportChecklists = 250;
    Integer actualNumberOfDailyReportChecklists = [
      SELECT COUNT()
      FROM Daily_Report_Checklist__c
    ];

    Assert.areEqual(
      actualNumberOfDailyReportChecklists,
      actualNumberOfDailyReportChecklists,
      'Number of daily report checklist records returned does not match expected number.'
    );

    Integer expectedNumberOfDailyReportItems = 50;
    Integer actualNumberOfDailyReportItems = [
      SELECT COUNT()
      FROM ozbee__Production_Job_Report_Item__c
    ];

    Assert.areEqual(
      expectedNumberOfDailyReportItems,
      actualNumberOfDailyReportItems,
      'Number of daily report checklist records returned does not match expected number.'
    );
  }

  @isTest
  private static void createDailyExpectedProductions() {
    ozbee__Production_Job__c productionJob = [
      SELECT Id
      FROM ozbee__Production_Job__c
      LIMIT 1
    ];

    ozbee__Production_Schedule_Item__c productionScheduleItem = (ozbee__Production_Schedule_Item__c) new SObjectBuilder(
        ozbee__Production_Schedule_Item__c.sObjectType
      )
      .put(
        ozbee__Production_Schedule_Item__c.ozbee__Production_Job__c,
        productionJob.Id
      )
      .put(
        ozbee__Production_Schedule_Item__c.ozbee__Start_Date__c,
        Date.today()
      )
      .put(
        ozbee__Production_Schedule_Item__c.ozbee__End_Date__c,
        Date.today() + 1
      )
      .create()
      .getRecord();

    // new SObjectBuilder(ozbee__Production_Schedule_Item_Day__c.sObjectType)
    // 	.put(ozbee__Production_Schedule_Item_Day__c.ozbee__Production_Schedule_Item__c, productionScheduleItem.Id)
    // 	.put(ozbee__Production_Schedule_Item_Day__c.ozbee__Date__c, Date.today())
    // 	.count(10)
    // 	.create();

    List<ozbee__Production_Job_Report__c> dailyReports = [
      SELECT Id, ozbee__Production_Job__c
      FROM ozbee__Production_Job_Report__c
    ];

    Test.startTest();
    DailyReportService.createDailyExpectedProductions(dailyReports);
    Test.stopTest();

    Integer expectedDailyExpectedProduction = 1;
    Integer actualDailyExpectedProduction = [
      SELECT COUNT()
      FROM Daily_Expected_Production__c
    ];

    Assert.areEqual(
      expectedDailyExpectedProduction,
      actualDailyExpectedProduction,
      'Number of daily expected production records returned does not match expected number.'
    );
  }

  @isTest
  private static void addSafetyManagerToOpportunityTeam() {
    User user = (User) new SObjectBuilder(User.sObjectType)
      .create()
      .getRecord();

    List<ozbee__Production_Job_Report__c> dailyReports = [
      SELECT Id, ozbee__Safety_Manager__c, Opportunity__c
      FROM ozbee__Production_Job_Report__c
    ];
    Map<Id, ozbee__Production_Job_Report__c> oldDailyReportsMap = new Map<Id, ozbee__Production_Job_Report__c>(
      dailyReports
    );

    Assert.areEqual(
      1,
      dailyReports.size(),
      'Should have returned exactly 1 Daily Report record'
    );

    List<ozbee__Production_Job_Report__c> newDailyReports = new List<ozbee__Production_Job_Report__c>{
      dailyReports[0]
    };
    newDailyReports[0].ozbee__Safety_Manager__c = user.Id;

    Test.startTest();
    DailyReportService.addSafetyManagerToOpportunityTeam(
      newDailyReports,
      oldDailyReportsMap
    );
    Test.stopTest();

    OpportunityTeamMember opportunityTeamMember = [
      SELECT Id
      FROM OpportunityTeamMember
      WHERE UserId = :user.Id
    ];

    Assert.isNotNull(
      opportunityTeamMember,
      'User was not added as an opportunity team member'
    );
  }
}
