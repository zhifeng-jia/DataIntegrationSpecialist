@isTest
private class ProjectRESTServiceTest {
  //Implement Apex REST service tests here
  private static Opportunity opptyRec;
  private static Project__c projRecord;

  private static void setupData(Boolean insertProject){

  	opptyRec = new Opportunity();
  	opptyRec.Name = 'Test Oppty1';
    opptyRec.Type = 'New Project';
    opptyRec.Amount = 100000;
    opptyRec.CloseDate = Date.today().addDays(-2);
    opptyRec.StageName = 'Submitted Project';
    insert opptyRec;
    if(insertProject){
    	projRecord = new Project__c();
    	projRecord.Start_Date__c = Date.today();
  		projRecord.End_Date__c 	 = Date.today().addDays(7);
  		projRecord.Status__c 	 = 'Running';
  		projRecord.Name			 = 'Test Project';
  		projRecord.ProjectRef__c = 'Test1234';
  		projRecord.Opportunity__c = opptyRec.Id;
  		projRecord.Billable_Amount__c = 1200;
  		insert projRecord;
    }
  }

  @isTest
  private static void testProjectCreation(){
  	setupData(false);
  	String serviceStatus = ProjectRESTService.postProjectData('Test123456','projectName',opptyRec.Id,Date.today(),Date.today().addDays(7),2000,'Running');
  	List<Project__c> lProjRecords = [SELECT Billable_Amount__c,End_Date__c,Name,Opportunity__c,ProjectRef__c,Start_Date__c,Status__c FROM Project__c where ProjectRef__c=:'Test123456'];
  	System.assertEquals(serviceStatus,'OK');
  	System.assertEquals(lProjRecords.size(),1);
  	System.assertEquals(lProjRecords[0].Start_Date__c,Date.today());
  	System.assertEquals(lProjRecords[0].End_Date__c,Date.today().addDays(7));
  	System.assertEquals(lProjRecords[0].Status__c,'Running');
  	System.assertEquals(lProjRecords[0].Name,'projectName');
  	System.assertEquals(lProjRecords[0].ProjectRef__c,'Test123456');
  	System.assertEquals(lProjRecords[0].Opportunity__c,opptyRec.Id);
  	System.assertEquals(lProjRecords[0].Billable_Amount__c,2000);
  }

  @isTest
  private static void testProjectUpdate(){
  	setupData(true);
  	String serviceStatus = ProjectRESTService.postProjectData('Test1234','projectName',opptyRec.Id,Date.today(),Date.today().addDays(7),2000,'Running');
  	List<Project__c> lProjRecords = [SELECT Billable_Amount__c,End_Date__c,Name,Opportunity__c,ProjectRef__c,Start_Date__c,Status__c FROM Project__c where ProjectRef__c=:'Test1234'];
  	System.assert(serviceStatus.contains('Field is not writeable'));
  }
}