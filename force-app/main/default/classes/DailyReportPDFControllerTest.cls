@isTest
public with sharing class DailyReportPDFControllerTest {
  @TestSetup
  static void setup() {
    ozbee__Building__c building = (ozbee__Building__c) new SObjectBuilder(
        ozbee__Building__c.sObjectType
      )
      .put(ozbee__Building__c.Name, 'Test Building')
      .put(ozbee__Building__c.ozbee__Postal_Code__c, '12345')
      .create()
      .getRecord();

    Opportunity opportunity = (Opportunity) new SObjectBuilder(
        Opportunity.sObjectType
      )
      .put(Opportunity.ozbee__Building__c, building.Id)
      .create()
      .getRecord();

    ozbee__Production_Job__c productionJob = (ozbee__Production_Job__c) new SObjectBuilder(
        ozbee__Production_Job__c.sObjectType
      )
      .put(ozbee__Production_Job__c.ozbee__Building__c, building.Id)
      .put(ozbee__Production_Job__c.ozbee__Opportunity__c, opportunity.Id)
      .create()
      .getRecord();

    ozbee__Production_Job_Report__c dailyReport = (ozbee__Production_Job_Report__c) new SObjectBuilder(
        ozbee__Production_Job_Report__c.sObjectType
      )
      .put(ozbee__Production_Job_Report__c.Opportunity__c, opportunity.Id)
      .put(
        ozbee__Production_Job_Report__c.ozbee__Production_Job__c,
        productionJob.Id
      )
      .create()
      .getRecord();

    List<ozbee__Production_Job_Report_Item__c> dailyReportItems = new SObjectBuilder(
        ozbee__Production_Job_Report_Item__c.sObjectType
      )
      .put(
        ozbee__Production_Job_Report_Item__c.ozbee__Production_Job_Report__c,
        dailyReport.Id
      )
      .put(
        ozbee__Production_Job_Report_Item__c.ozbee__Safety_Inspection_Category__c,
        'General'
      )
      .put(ozbee__Production_Job_Report_Item__c.ozbee__Task_Status__c, 'YES')
      .count(5)
      .create()
      .getRecords();

    List<ozbee__Production_Job_Report_Photo__c> dailyReportPhotos = new SObjectBuilder(
        ozbee__Production_Job_Report_Photo__c.sObjectType
      )
      .put(
        ozbee__Production_Job_Report_Photo__c.ozbee__Daily_Report_Item__c,
        dailyReportItems[0].Id
      )
      .put(
        ozbee__Production_Job_Report_Photo__c.ozbee__Production_Job_Report__c,
        dailyReport.Id
      )
      .count(5)
      .create()
      .getRecords();

    new SObjectBuilder(ozbee__Production_Job_Report_Labor_Item__c.sObjectType)
      .put(
        ozbee__Production_Job_Report_Labor_Item__c.ozbee__Production_Job_Report__c,
        dailyReport.Id
      )
      .put(
        ozbee__Production_Job_Report_Labor_Item__c.RecordTypeId,
        Schema.SObjectType.ozbee__Production_Job_Report_Labor_Item__c.getRecordTypeInfosByDeveloperName()
          .get('Manpower_and_Operations')
          .getRecordTypeId()
      )
      .count(5)
      .create()
      .getRecord();

    new SObjectBuilder(ozbee__Production_Job_Report_Labor_Item__c.sObjectType)
      .put(
        ozbee__Production_Job_Report_Labor_Item__c.ozbee__Production_Job_Report__c,
        dailyReport.Id
      )
      .put(
        ozbee__Production_Job_Report_Labor_Item__c.RecordTypeId,
        Schema.SObjectType.ozbee__Production_Job_Report_Labor_Item__c.getRecordTypeInfosByDeveloperName()
          .get('Materials')
          .getRecordTypeId()
      )
      .count(5)
      .create()
      .getRecord();
  }

  @isTest
  private static void controller() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );

    Test.startTest();
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);
    Test.stopTest();

    Assert.areEqual(
      dailyReport.Id,
      pdfController.pjr.Id,
      'Daily Report was not set properly'
    );
  }

  @IsTest
  private static void getCustomSettings() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    ozbee__Ozbee_Setting__mdt setting = pdfController.getCustomSettings();
    Test.stopTest();

    Assert.isNotNull(setting, 'Ozbee setting was not returned');
  }

  @isTest
  private static void getHeaderColor() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    String headerColor = pdfController.getHeaderColor();
    Test.stopTest();

    Assert.isNotNull(headerColor, 'Header color was not returned');
  }

  @isTest
  private static void getForecast() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id, ozbee__Production_Job__c
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    List<OpenWeatherDataTypes.WeatherForecastDaily> forecast = pdfController.getForecast(
      dailyReport.ozbee__Production_Job__c
    );
    Test.stopTest();

    Assert.isNotNull(forecast, 'Weather forecast was not returned');
  }

  @isTest
  private static void getManpowerOperations() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    List<ozbee__Production_Job_Report_Labor_Item__c> manpower = pdfController.getManpowerOperations();
    Test.stopTest();

    Assert.areEqual(
      5,
      manpower.size(),
      'Did not return exactly 5 Labor Item records'
    );
  }

  @isTest
  private static void getMaterials() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    List<ozbee__Production_Job_Report_Labor_Item__c> materials = pdfController.getMaterials();
    Test.stopTest();

    Assert.areEqual(
      5,
      materials.size(),
      'Did not return exactly 5 Labor Item records'
    );
  }

  @isTest
  private static void getAllItems() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    List<DailyReportPDFController.DataGroup> items = pdfController.getAllItems();
    Test.stopTest();

    System.debug('items ::: ' + items);

    Assert.areEqual(1, items.size(), 'Did not return exactly 1 item group');
    Assert.areEqual(
      'General',
      items[0].Name,
      'Did not return the correct data group'
    );
    Assert.areEqual(5, items[0].items.size(), 'Did not return exactly 5 items');
  }

  @isTest
  private static void fetchReportPhotos() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    List<DailyReportPDFController.reportPhoto> reportPhotos = pdfController.fetchReportPhotos();
    Test.stopTest();

    Assert.areEqual(
      5,
      reportPhotos.size(),
      'Did not return exactly 5 report photos'
    );
  }

  @isTest
  private static void getGeneralPhotoCount() {
    ozbee__Production_Job_Report__c dailyReport = [
      SELECT Id
      FROM ozbee__Production_Job_Report__c
      LIMIT 1
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      dailyReport
    );
    DailyReportPDFController pdfController = new DailyReportPDFController(sc);

    Test.startTest();
    Integer photoCount = pdfController.getGeneralPhotoCount();
    Test.stopTest();

    Assert.areEqual(0, photoCount, 'Did not return exactly 0');
  }
}
