@isTest
private class ProjectCalloutServiceTest {
  //Implement mock callout tests here
  private static List<Opportunity> lOpttyRecs;
  private static ServiceTokens__c serviceToken;
  static void setupData(){
  	Account accRec = new Account(Name='Test');
    insert accRec;
    
    Opportunity successProj = new Opportunity();
  	successProj.Name = 'Test Oppty1';
    successProj.Type = 'New Project';
    successProj.Amount = 100000;
    successProj.CloseDate = Date.today().addDays(-2);
    successProj.StageName = 'Submitted Project';

    Opportunity failureProj = new Opportunity();
  	failureProj.Name = 'Test Oppty2';
    failureProj.Type = 'New Project';
    failureProj.Amount = 10000;
    failureProj.CloseDate = Date.today();
    failureProj.StageName = 'Resubmit Project';

    lOpttyRecs = new List<Opportunity>{successProj,failureProj};
    insert lOpttyRecs;

    serviceToken = new ServiceTokens__c();
    serviceToken.Name = 'ProjectServiceToken';
    serviceToken.Token__c = 'eb771fe6-ef5b-4b1e-84f8-cdf3736894cf';
    insert serviceToken;
  }

  @isTest
  static void testSuccessfulProjectCreation(){
  	setupData();
  	Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
  	ProjectCalloutService.postOpportunityToPMS(new List<Id>{lOpttyRecs[0].Id});
  	Opportunity opptyRec = [SELECT Account.Name,Amount,CloseDate,Id,Name,StageName FROM Opportunity where Id=:lOpttyRecs[0].Id];
  	System.assertEquals(opptyRec.StageName,'Submitted Project');
  }

  @isTest
  static void testProjectCreationFailure(){
  	setupData();
  	Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
  	ProjectCalloutService.postOpportunityToPMS(new List<Id>{lOpttyRecs[1].Id});
  	Opportunity opptyRec = [SELECT Account.Name,Amount,CloseDate,Id,Name,StageName FROM Opportunity where Id=:lOpttyRecs[1].Id];
  	System.assertEquals(opptyRec.StageName,'Resubmit Project');
  }

  @isTest
  static void test(){
  	setupData();
  	String opptyRecJson = '{ "opportunityId": "00641000004EKmFAAW", "opportunityName": "Super-Duper Big Deal", "accountName": "ACME Corp, Inc.", "closeDate": "2016-10-30", "amount": 1000 }';
	Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
	ProjectCalloutService.QueueablePMSCall updater = new ProjectCalloutService.QueueablePMSCall(opptyRecJson,serviceToken.Token__c,lOpttyRecs[0].Id);
        Test.startTest();        
        System.enqueueJob(updater);
        Test.stopTest();
	Opportunity opptyRec = [SELECT Account.Name,Amount,CloseDate,Id,Name,StageName FROM Opportunity where Id=:lOpttyRecs[0].Id];
	System.assertEquals(opptyRec.StageName,'Submitted Project');
  }
}