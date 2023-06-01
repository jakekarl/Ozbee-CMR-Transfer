public class DailyReportRecipientWrapper {
  @AuraEnabled
  public String Name;

  @AuraEnabled
  public String Email;

  public DailyReportRecipientWrapper(String name, String email) {
    this.Name = name;
    this.Email = email;
  }
}
