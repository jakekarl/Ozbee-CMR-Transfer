public with sharing class CompanyCamPhoto {
  @AuraEnabled
  public String id { get; set; }
  @AuraEnabled
  public String company_id;
  @AuraEnabled
  public String creator_id;
  @AuraEnabled
  public String creator_type;
  @AuraEnabled
  public String creator_name;
  @AuraEnabled
  public String project_id;
  @AuraEnabled
  public Coordinates coordinates;
  @AuraEnabled
  public String status;
  @AuraEnabled
  public List<URI> uris { get; set; }
  @AuraEnabled
  public String hash;
  @AuraEnabled
  public Boolean internal;
  @AuraEnabled
  public String photo_url;
  @AuraEnabled
  public Long captured_at;
  @AuraEnabled
  public Long created_at;
  @AuraEnabled
  public Long updated_at;
  @AuraEnabled
  public String processing_status;
  @AuraEnabled
  public List<PhotoComment> comments { get; set; }
  @AuraEnabled
  public String annotatedURI { get; set; }

  // @TestVisible
  // private static String TEST_API_RESPONSE_COMMENTS =
  // 	'[ {"id": "4782987471","creator_id": "2789583992","creator_type": "User","commentable_id": "388472672",' +
  // 	'"commentable_type": "Photo","creator_name": "Shawn Spencer","status": "active","content": ' +
  // 	'"Have you seen this yet?","created_at": 1152230608,"updated_at": 1152230400}]';

  public void getAnnotatedURI() {
    String annotatedURI = '';

    for (URI uri : uris) {
      if (uri.type == 'original_annotation') {
        annotatedURI = uri.uri;
        break;
      }
    }

    this.annotatedURI = annotatedURI;
  }

  // public String getMostRecentComment() {
  // 	if (comments == null) {
  // 		comments = new List<PhotoComment>();
  // 		String commentsJSON = getProjectPhotoComments(this.id);
  // 		if (commentsJSON != null) {
  // 			try {
  // 				comments = (List<PhotoComment>) JSON.deserialize(commentsJSON, List<PhotoComment>.class);
  // 				if (comments.size() > 0) {
  // 					return comments[0].content;
  // 				}
  // 			} catch (Exception e) {
  // 			}
  // 		}
  // 	} else {
  // 		if (comments.size() > 0) {
  // 			return comments[0].content;
  // 		}
  // 	}
  // 	return '';
  // }

  // public String getProjectPhotoComments(String photoID) {
  // 	if (photoID != null && photoID != '') {
  // 		String endPoint = '/photos/' + photoID + '/comments';
  // 		String apiResponse = '';

  // 		// if (!Test.isRunningTest() && runningInASandbox != true) {
  // 		if (!Test.isRunningTest()) {
  // 			apiResponse = CompanyCam.CalloutUtility.getResponse(endPoint, 'GET', '', '20000');
  // 		} else {
  // 			apiResponse = TEST_API_RESPONSE_COMMENTS;
  // 		}
  // 		return apiResponse;
  // 	}
  // 	return '';
  // }

  // public static Boolean runningInASandbox {
  // 	get {
  // 		if (runningInASandbox == null) {
  // 			runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
  // 		}
  // 		return runningInASandbox;
  // 	}
  // 	private set;
  // }

  public class PhotoComment {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String creator_id;
    @AuraEnabled
    public String creator_type;
    @AuraEnabled
    public String commentable_id;
    @AuraEnabled
    public String commentable_type;
    @AuraEnabled
    public String creator_name;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String content;
    @AuraEnabled
    public Integer created_at;
    @AuraEnabled
    public Integer updated_at;
  }

  public class Coordinates {
    @AuraEnabled
    public Double lat;
    @AuraEnabled
    public Double lon;
  }

  public class URI {
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String uri { get; set; }
  }
}
