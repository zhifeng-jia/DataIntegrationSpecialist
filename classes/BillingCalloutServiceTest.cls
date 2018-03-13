@isTest
private class BillingCalloutServiceTest {
  
  private static Project__c projRecord;

  private static void setupData(){
  	Opportunity opptyRec = new Opportunity();
  	opptyRec.Name = 'Test Oppty1';
    opptyRec.Type = 'New Project';
    opptyRec.Amount = 100000;
    opptyRec.CloseDate = Date.today().addDays(-2);
    opptyRec.StageName = 'Submitted Project';
    insert opptyRec;
    
    projRecord = new Project__c();
    projRecord.Start_Date__c = Date.today();
  	projRecord.End_Date__c 	 = Date.today().addDays(7);
  	projRecord.Status__c 	 = 'Running';
  	projRecord.Name			 = 'Test Project';
  	projRecord.ProjectRef__c = 'Test1234';
  	projRecord.Opportunity__c = opptyRec.Id;
  	projRecord.Billable_Amount__c = 1200;
  	insert projRecord;
  	ServiceCredentials__c servCred = new ServiceCredentials__c();
    servCred.Name = 'BillingServiceCredential';
    servCred.Username__c = 'user1';
    servCred.Password__c = 'pass1';
    insert servCred;
  }

  @isTest
  static void testSuccessCallout(){
  	setupData();
  	Test.setMock(WebserviceMock.class, new BillingCalloutServiceMock());
  	Test.startTest();
  	projRecord.Status__c = 'Billable';
  	update projRecord;
  	Test.stopTest();
  	projRecord = [SELECT ProjectRef__c,Status__c FROM Project__c where ProjectRef__c='Test1234'];
  	System.assertEquals(projRecord.Status__c,'Billed');
  }

  @isTest
  static void testFailureCallout(){
  	setupData();
  	Test.setMock(WebserviceMock.class, new BillingCalloutServiceMockFailure());
  	Test.startTest();
  	projRecord.Status__c = 'Running';
  	update projRecord;
  	Test.stopTest();
  	projRecord = [SELECT ProjectRef__c,Status__c FROM Project__c where ProjectRef__c='Test1234'];
  	System.assert(projRecord.Status__c != 'Billed');
  }
}