public with sharing class DailyReportPDFController {
  public Report report { get; set; }
  public ozbee__Production_Job_Report__c pjr { get; set; }
  public ozbee__Production_Job__c job { get; set; }
  private final Id recordTypeId;
  public String recordTypeName { get; set; }
  public List<reportPhoto> allPhotos { get; set; }
  public List<OpenWeatherDataTypes.WeatherForecastDaily> dailyForecast {
    get;
    set;
  }
  private static Id recordId;

  public ozbee__Ozbee_Setting__mdt getCustomSettings() {
    ozbee__Ozbee_Setting__mdt setting = ozbee__Ozbee_Setting__mdt.getInstance(
      'PRIMARY'
    );
    return setting;
  }

  public String getHeaderColor() {
    return getCustomSettings().ozbee__PDF_Header_Color__c;
  }

  public DailyReportPDFController(ApexPages.StandardController sc) {
    this.pjr = (ozbee__Production_Job_Report__c) sc.getRecord();
    recordId = pjr.Id;

    Set<String> pjrFieldsToQuery = new Set<String>{
      'Name',
      'ozbee__Production_Job__c',
      'ozbee__Project_Manager__c',
      'ozbee__Project_Manager__r.Name',
      'Superintendent__c',
      'Superintendent__r.Name',
      'Account_Manager__c',
      'Account_Manager__r.Name',
      'ozbee__Foreman__c',
      'ozbee__Safety_Manager__r.Name',
      'ozbee__Visitors_To_Site__c',
      'ozbee__Deliveries__c',
      'ozbee__Activities__c',
      'ozbee__Problems_and_Comments__c',
      'Crew_Members__c',
      'CreatedDate',
      'Show_Forecast__c',
      'Show_Visitors__c',
      'Show_Activities__c',
      'Show_Observations__c',
      'Show_Manpower__c',
      'Show_Materials__c',
      'Show_SOW__c',
      'Show_Expected_Production__c',
      'Show_Disclaimer__c'
    };

    String pjrQuery = 'SELECT ';
    for (String field : pjrFieldsToQuery) {
      pjrQuery += field + ', ';
    }
    pjrQuery += 'Id FROM ozbee__Production_Job_Report__c WHERE Id = :recordId LIMIT 1';
    pjr = Database.query(pjrQuery);

    String pjId = pjr.ozbee__Production_Job__c;

    Set<String> pjFieldsToQuery = new Set<String>{
      'Name',
      'RecordTypeId',
      'RecordType.Name',
      'ozbee__Opportunity__c',
      'ozbee__Opportunity__r.Name',
      'ozbee__Opportunity__r.ozbee__Account_Manager__r.Name',
      'Superintendent__r.Name',
      'ozbee__PM__r.Name',
      'ozbee__Building__c',
      'ozbee__Building__r.Name',
      'ozbee__Building__r.ozbee__Street__c',
      'ozbee__Building__r.ozbee__City__c',
      'ozbee__Building__r.ozbee__State__c'
    };
    String productionJobNumberOverride = ozbee__Production_Job_Setting__mdt.getInstance(
        'Primary'
      )
      .ozbee__Production_Job_Number_Override__c;
    pjFieldsToQuery.add(productionJobNumberOverride);

    String pjQuery = 'SELECT ';
    for (String field : pjFieldsToQuery) {
      pjQuery += field + ', ';
    }
    pjQuery += 'Id FROM ozbee__Production_Job__c WHERE Id = :pjId LIMIT 1';

    job = Database.query(pjQuery);

    ozbee__Daily_Report_Setting__mdt dailyReportSetting = [
      SELECT Id, ozbee__Disclaimer__c, ozbee__Header_Logo__c
      FROM ozbee__Daily_Report_Setting__mdt
      WHERE MasterLabel = 'Primary'
    ];

    report = new Report();
    report.Name = pjr.Name;
    report.OpportunityName = job.ozbee__Opportunity__r.Name;
    report.CreatedDate = pjr.CreatedDate;
    report.JobName = (String) job.get(productionJobNumberOverride);
    report.ProjectManager = job.ozbee__PM__r.Name;
    report.Foreman = pjr.ozbee__Foreman__c;
    report.BuildingName =
      job.ozbee__Building__r.Name +
      ' - ' +
      job.ozbee__Building__r.ozbee__Street__c +
      ', ' +
      job.ozbee__Building__r.ozbee__City__c +
      ', ' +
      job.ozbee__Building__r.ozbee__State__c;
    report.Superintendent = pjr.Superintendent__r.Name;
    report.AccountManager = pjr.Account_Manager__r.Name;
    report.SafetyManager = pjr.ozbee__Safety_Manager__r.Name;
    report.VisitorsToSite = pjr.ozbee__Visitors_To_Site__c;
    report.Deliveries = pjr.ozbee__Deliveries__c;
    report.Activities = pjr.ozbee__Activities__c;
    report.ObservationsAndComments = pjr.ozbee__Problems_and_Comments__c;
    report.CrewMembers = pjr.Crew_Members__c;
    report.ShowForecast = pjr.Show_Forecast__c;
    report.ShowVisitors = pjr.Show_Visitors__c;
    report.ShowActivities = pjr.Show_Activities__c;
    report.ShowObservations = pjr.Show_Observations__c;
    report.ShowManpower = pjr.Show_Manpower__c;
    report.ShowMaterials = pjr.Show_Materials__c;
    report.ShowSOW = pjr.Show_SOW__c;
    report.ShowExpectedProduction = pjr.Show_Expected_Production__c;
    report.ShowDisclaimer = pjr.Show_Disclaimer__c;
    report.Disclaimer = dailyReportSetting.ozbee__Disclaimer__c;
    report.HeaderLogo = dailyReportSetting.ozbee__Header_Logo__c;
    report.DailyExpectedProductions = DailyExpectedProductionService.getDailyReportExpectedProduction(
      recordId
    );

    Id recordTypeId = job.recordTypeId;
    recordTypeName = job.RecordType.Name;
    allPhotos = fetchReportPhotos();
    dailyForecast = getForecast(pjr.ozbee__Production_Job__c);
  }

  public class Report {
    public String Name { get; set; }
    public String OpportunityName { get; set; }
    public Datetime CreatedDate { get; set; }
    public String JobName { get; set; }
    public String ProjectManager { get; set; }
    public String Foreman { get; set; }
    public String BuildingName { get; set; }
    public String Superintendent { get; set; }
    public String AccountManager { get; set; }
    public String SafetyManager { get; set; }
    public String VisitorsToSite { get; set; }
    public String Deliveries { get; set; }
    public String Activities { get; set; }
    public String ObservationsAndComments { get; set; }
    public String CrewMembers { get; set; }
    public Boolean ShowForecast { get; set; }
    public Boolean ShowVisitors { get; set; }
    public Boolean ShowActivities { get; set; }
    public Boolean ShowObservations { get; set; }
    public Boolean ShowManpower { get; set; }
    public Boolean ShowMaterials { get; set; }
    public Boolean ShowSOW { get; set; }
    public Boolean ShowExpectedProduction { get; set; }
    public Boolean ShowDisclaimer { get; set; }
    public String Disclaimer { get; set; }
    public String HeaderLogo { get; set; }
    public List<Daily_Expected_Production__c> DailyExpectedProductions {
      get;
      set;
    }
  }

  public List<OpenWeatherDataTypes.WeatherForecastDaily> getForecast(
    String jobId
  ) {
    List<OpenWeatherDataTypes.WeatherForecastDaily> forecastData = new List<OpenWeatherDataTypes.WeatherForecastDaily>();
    String zipCode = '';

    List<ozbee__Production_Job__c> jobs = [
      SELECT Id, ozbee__Building__c, ozbee__Building__r.ozbee__Postal_Code__c
      FROM ozbee__Production_Job__c
      WHERE Id = :jobId
    ];

    if (jobs.size() > 0) {
      if (jobs[0].ozbee__Building__c != null) {
        String fullzipCode = (jobs[0]
            .ozbee__Building__r.ozbee__Postal_Code__c != null)
          ? jobs[0].ozbee__Building__r.ozbee__Postal_Code__c
          : zipcode;
        zipcode = fullzipcode.split('-')[0];
      }
    }

    try {
      List<OpenWeatherDataTypes.WeatherForecastDaily> thisData = OpenWeatherAPI.getForecast(
          zipCode
        )
        .list_x;
      Integer i = 0;
      for (OpenWeatherDataTypes.WeatherForecastDaily wfd : thisData) {
        if (i < 5) {
          forecastData.add(wfd);
          i++;
        }
      }
      return forecastData;
    } catch (Exception e) {
      return null;
    }
  }

  public List<ozbee__Production_Job_Report_Labor_Item__c> getManpowerOperations() {
    List<ozbee__Production_Job_Report_Labor_Item__c> reportItems = new List<ozbee__Production_Job_Report_Labor_Item__c>();
    reportItems = [
      SELECT
        Id,
        ozbee__Crew_Size__c,
        ozbee__Work_Category__c,
        ozbee__Work_SubCategory__c
      FROM ozbee__Production_Job_Report_Labor_Item__c
      WHERE
        ozbee__Production_Job_Report__c = :pjr.Id
        AND RecordType.Name = 'Manpower and Operations'
    ];
    return reportItems;
  }

  public List<ozbee__Production_Job_Report_Labor_Item__c> getMaterials() {
    List<ozbee__Production_Job_Report_Labor_Item__c> reportItems = new List<ozbee__Production_Job_Report_Labor_Item__c>();
    reportItems = [
      SELECT
        Id,
        ozbee__Material_Category__c,
        ozbee__Material_Subcategory__c,
        ozbee__Quantity__c,
        ozbee__Unit_of_Measure__c
      FROM ozbee__Production_Job_Report_Labor_Item__c
      WHERE
        ozbee__Production_Job_Report__c = :pjr.Id
        AND RecordType.Name = 'Materials'
    ];
    return reportItems;
  }

  public List<DataGroup> getAllItems() {
    Map<String, DataGroup> mapReportItems = new Map<String, DataGroup>();
    List<ozbee__Production_Job_Report_Item__c> reportItems = new List<ozbee__Production_Job_Report_Item__c>();
    reportItems = [
      SELECT
        Id,
        ozbee__Task_Name__c,
        ozbee__Task_Status__c,
        ozbee__Task_Comment__c,
        ozbee__Safety_Inspection_Category__c,
        (SELECT Id FROM ozbee__Daily_Report_Photos__r)
      FROM ozbee__Production_Job_Report_Item__c
      WHERE
        ozbee__Production_Job_Report__c = :pjr.Id
        AND ozbee__Task_Status__c != 'N/A'
        AND ozbee__Task_Status__c != ''
    ];

    System.debug('reportItems ::: ' + reportItems.size());

    for (ozbee__Production_Job_Report_Item__c item : reportItems) {
      System.debug('item ::: ' + item);
      if (item.ozbee__Task_Status__c <> 'N/A') {
        if (
          mapReportItems.get(item.ozbee__Safety_Inspection_Category__c) == null
        ) {
          DataGroup dg = new DataGroup();
          dg.name = item.ozbee__Safety_Inspection_Category__c;
          dg.items.add(item);
          mapReportItems.put(item.ozbee__Safety_Inspection_Category__c, dg);
        } else {
          DataGroup dg = mapReportItems.get(
            item.ozbee__Safety_Inspection_Category__c
          );
          dg.items.add(item);
          mapReportItems.put(item.ozbee__Safety_Inspection_Category__c, dg);
        }
      }
    }
    return mapReportItems.values();
  }

  public List<reportPhoto> fetchReportPhotos() {
    List<reportPhoto> groupedPhotos = new List<reportPhoto>();
    Map<Id, Id> mapLinkedEntityId = new Map<Id, Id>();
    Map<Id, Id> mapContentDocumentLink = new Map<Id, Id>();

    List<ozbee__Production_Job_Report_Photo__c> allReportPhotos = [
      SELECT
        Id,
        ozbee__Photo_Category__c,
        ozbee__Photo_Comment__c,
        ozbee__Daily_Report_Item__c,
        ozbee__URL__c
      FROM ozbee__Production_Job_Report_Photo__c
      WHERE ozbee__Production_Job_Report__c = :pjr.Id
      ORDER BY CreatedDate ASC
    ];

    for (ozbee__Production_Job_Report_Photo__c pjrp : allReportPhotos) {
      mapLinkedEntityId.put(pjrp.id, null);
    }

    if (mapLinkedEntityId.size() > 0) {
      List<ContentDocumentLink> allContentDocumentLink = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :mapLinkedEntityId.keySet()
      ];

      for (ContentDocumentLink cdl : allContentDocumentLink) {
        mapLinkedEntityId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
        mapContentDocumentLink.put(cdl.ContentDocumentId, null);
      }
    }

    List<ContentVersion> allContentVersion = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE ContentDocumentId IN :mapContentDocumentLink.keySet()
    ];

    for (ContentVersion cv : allContentVersion) {
      mapContentDocumentLink.put(cv.ContentDocumentId, cv.Id);
    }

    for (ozbee__Production_Job_Report_Photo__c pjrp : allReportPhotos) {
      reportPhoto rp = new reportPhoto();
      rp.photoGroup = pjrp.ozbee__Photo_Category__c;
      rp.photoComment = pjrp.ozbee__Photo_Comment__c;
      rp.photoReportItemId = pjrp.ozbee__Daily_Report_Item__c;
      rp.photoId = mapContentDocumentLink.get(mapLinkedEntityId.get(pjrp.Id));
      rp.photoUrl = (pjrp.ozbee__URL__c != null)
        ? pjrp.ozbee__URL__c
        : URL.getSalesforceBaseURL().toExternalForm() +
          '/sfc/servlet.shepherd/version/download/' +
          mapContentDocumentLink.get(mapLinkedEntityId.get(pjrp.Id));
      groupedPhotos.add(rp);
    }

    return groupedPhotos;
  }

  public class dailyForecast {
    public string high;
    public string low;
    public string conditions;
    public string wind;
  }

  public class DataGroup {
    public String name { get; set; }
    public List<ozbee__Production_Job_Report_Item__c> items { get; set; }

    public DataGroup() {
      items = new List<ozbee__Production_Job_Report_Item__c>();
    }
  }

  public class reportPhoto {
    public string photoGroup { get; set; }
    public string photoComment { get; set; }
    public string photoId { get; set; }
    public string photoUrl { get; set; }
    public string photoReportItemId { get; set; }
  }

  public List<reportPhoto> getAllPhotos() {
    return allPhotos;
  }

  public Integer getGeneralPhotoCount() {
    Integer count = 0;
    for (reportPhoto rp : allPhotos) {
      if (rp.photoReportItemId == null || rp.photoReportItemId == '') {
        count++;
      }
    }
    return count;
  }

  public class dailyReportSendRequest {
    @InvocableVariable
    public Id dailyReportId;

    @InvocableVariable
    public String recipients;
  }
}
