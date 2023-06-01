public with sharing class CompanyCamCalloutUtility {
  public static String getProjectPhotos(String projectID) {
    if (projectID != null && projectID != '') {
      String endPoint = '/projects/' + projectID + '/photos/?per_page=100'; //&start_date=' + (datetime.newInstance(photoDate.year(), photoDate.month(), photoDate.day()).getTime() / 1000);

      String apiResponse = '';
      if (!Test.isRunningTest()) {
        apiResponse = CompanyCam.CalloutUtility.getResponse(
          endPoint,
          'GET',
          '',
          '20000'
        );
      } else {
        apiResponse = '[{"id": "8392884992","company_id": "12345","creator_id": "2789583992","creator_type": "User","creator_name": "Shawn Spencer","project_id": "94772883","status": "active","coordinates": {  "lat": 34.398307,  "lon": -119.712367},"uris": [  {    "type": "original",    "url": "https://static.companycam.com/VuS0rPvrnNA1490797262.jpg"  },  {    "type": "web",    "url": "https://static.companycam.com/VuS0rPvrnNA1490797262web.jpg"  },  {    "type": "thumbnail",    "url": "https://static.companycam.com/VuS0rPvrnNA1490797262small.jpg"  },  {    "type": "original_annotation",    "url": "https://static.companycam.com/PDmEK6be15108718182ceadd9danno.jpg?junkdata"  },  {    "type": "web_annotation",    "url": "https://static.companycam.com/PDmEK6be15108718182ceadd9danno-web.jpg"  },  {    "type": "thumbnail_annotation",    "url": "https://static.companycam.com/PDmEK6be15108718182ceadd9danno-small.jpg"  }],"hash": "00ab337b7399151e5d4aa3bd4226e8dd","internal": false,"photo_url": "https://app.companycam.com/photos/8675309","captured_at": 1152230396,"created_at": 1152230608,"updated_at": 1152230400}]';
      }

      return apiResponse;
    }
    return '';
  }

  public static List<CompanyCamPhoto> loadCompanyCamPhotos(String projectId) {
    String photoString = getProjectPhotos(projectId);

    List<CompanyCamPhoto> companyCamPhotos = new List<CompanyCamPhoto>();

    if (photoString != null && photoString != '') {
      companyCamPhotos = (List<CompanyCamPhoto>) JSON.deserialize(
        photoString,
        List<CompanyCamPhoto>.class
      );
    }

    for (CompanyCamPhoto photo : companyCamPhotos) {
      photo.getAnnotatedURI();
    }

    return companyCamPhotos;
  }
}
