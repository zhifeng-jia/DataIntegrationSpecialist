@RestResource(urlMapping='/project/*')
global with sharing class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(String projectRef,String projectName,String opportunityId,Date startDate,Date endDate,Double amount,String status){
    	String requestStatus;
    	Savepoint sp = Database.setSavepoint();
    	try{
    		createProject(projectRef,projectName,opportunityId,startDate,endDate,amount,status);
    		updateOpportunity(opportunityId);
    		requestStatus = 'OK';
    	}catch(Exception ex){
    		Database.rollback(sp);
    		requestStatus = ex.getMessage();
    	}
    	System.debug('requestStatus==='+requestStatus);
    	return requestStatus;
    }

    public static void updateOpportunity(String opportunityId){
    	Opportunity opptyRec = [SELECT StageName,Id,DeliveryInstallationStatus__c FROM Opportunity where Id=:opportunityId];
    	opptyRec.DeliveryInstallationStatus__c = 'In progress';
    	update opptyRec;
    }

    public static void createProject(String projectRef,String projectName,String opportunityId,Date startDate,Date endDate,Double amount,String status){
    	List<Project__c> lProjRecords = [SELECT Billable_Amount__c,End_Date__c,Name,Opportunity__c,ProjectRef__c,Start_Date__c,Status__c FROM Project__c where ProjectRef__c=:projectRef];
    	Project__c projRecord = new Project__c();
    	if(lProjRecords.size() > 0)
    		projRecord = lProjRecords[0];
    	System.debug('projRecord==='+projRecord);	
    	System.debug('here======');	
		projRecord.Start_Date__c = startDate;
		projRecord.End_Date__c 	 = endDate;
		projRecord.Status__c 	 = status;
		projRecord.Name			 = projectName;
		projRecord.ProjectRef__c = projectRef;
		projRecord.Opportunity__c = opportunityId;
		projRecord.Billable_Amount__c = amount;
		System.debug('projRecord===='+projRecord);
		upsert projRecord;
	}
}