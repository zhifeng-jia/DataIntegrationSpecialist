public class BillingCalloutService {
    //Implement business and callout logic methods here
    //trigger method here
    public static void callBillingService(List<Project__c> lNewProjects,Map<Id,Project__c> mOldProjects){
    	Project__c newProjectRec = lNewProjects[0];
    	ServiceCredentials__c token = getCredentials();
    	//update
    	if(!mOldProjects.isEmpty()){
    		Project__c oldProjectRec = mOldProjects.get(newProjectRec.Id);
    		if(oldProjectRec.Status__c != 'Billable' && newProjectRec.Status__c == 'Billable'){
    			billingServiceCallout(token.Username__c,token.Password__c,newProjectRec.ProjectRef__c,newProjectRec.Billable_Amount__c);
    		}
    	}else{
    	//Insert
    		if(newProjectRec.Status__c == 'Billable'){
    			billingServiceCallout(token.Username__c,token.Password__c,newProjectRec.ProjectRef__c,newProjectRec.Billable_Amount__c);
    		}
    	}

    }
    
    private static ServiceCredentials__c getCredentials(){
    	return ServiceCredentials__c.getInstance('BillingServiceCredential');
    }

    private static void updateProject(String projectRef){
    	Project__c projRecord = [SELECT Billable_Amount__c,End_Date__c,Name,Opportunity__c,ProjectRef__c,Start_Date__c,Status__c FROM Project__c where ProjectRef__c=:projectRef];
    	projRecord.Status__c = 'Billed';
    	update projRecord;
    }

    @future(callout=true)
    private static void billingServiceCallout(String username,String password,String projectRef,Decimal billAmount){
    	BillingServiceProxy.project billingProject = new BillingServiceProxy.project();
    	//set the project attributes
    	billingProject.username = username;
    	billingProject.password = password;
    	billingProject.projectRef = projectRef;
    	billingProject.billAmount = billAmount;

    	BillingServiceProxy.InvoicesPortSoap11 projectInvoice = new BillingServiceProxy.InvoicesPortSoap11();
    	String response = projectInvoice.billProject(billingProject);
    	if(response == 'OK'){
    		updateProject(projectRef);
    	}
    }
}