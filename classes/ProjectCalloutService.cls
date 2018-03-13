public class ProjectCalloutService {
    
    @InvocableMethod(label='Insert project record in the external PMS' description='Synchronize Outbound Project Data.')
	public static void postOpportunityToPMS(List<Id> lOpportunityIds){
        Opportunity opptyRec = [SELECT Account.Name,Amount,CloseDate,Id,Name FROM Opportunity where Id=:lOpportunityIds[0]];
        String opportunityJson = getOpportunityJSON(opptyRec);
        String servicetoken = getServiceToken();
        //call the queueable apex here
        System.enqueueJob(new QueueablePMSCall(opportunityJson,serviceToken,opptyRec.Id));
    }

    private static String getServiceToken(){
    	ServiceTokens__c serviceTokenRecord = ServiceTokens__c.getInstance('ProjectServiceToken');
    	String servicetoken = serviceTokenRecord.Token__c;
    	return servicetoken;
    }

    private static String getOpportunityJSON(Opportunity opptyRec){
    	String opptyRecJson = '{\n' +
	        	' "opportunityId" : "'+opptyRec.Id+'",\n'+
	        	' "opportunityName" : "'+opptyRec.Name+'",\n'+
	        	' "accountName" : "'+opptyRec.Account.Name+'",\n'+
	        	' "closeDate" : "'+String.ValueOf(opptyRec.CloseDate).mid(0,10)+'",\n'+   
	            ' "amount" : "'+opptyRec.Amount+'"\n}';
	    return opptyRecJson;        
    }
   	
    @Future(callout=true)
    public static void postOpportunityToPMS(String opptyRecJson,String serviceToken,Id opportunityId){
        Opportunity opptyRec = [SELECT StageName,Id FROM Opportunity where Id=:opportunityId];
        Http httpCall = new Http();
        HttpRequest httpCallRequest = new HttpRequest();
        //set the end point
        httpCallRequest.setEndpoint('callout:ProjectService');
        httpCallRequest.setMethod('POST');
        httpCallRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        httpCallRequest.setHeader('token', serviceToken);
        httpCallRequest.setBody(opptyRecJson);
        //send the request and check for the status code
        HttpResponse httpCallResponse = httpCall.send(httpCallrequest);
        if(httpCallResponse.getStatusCode() == 201){
            opptyRec.StageName = 'Submitted Project';
        }else{
            opptyRec.StageName = 'Resubmit Project';
        }
        update opptyRec;
    }
    //class should implement Queueable and also Database.AllowsCallouts to make a callout using future method
    public class QueueablePMSCall implements Queueable,Database.AllowsCallouts {
        
       private String opportunityJson;
       private String servicetoken;
       private Id opportunityId;
       
        public  QueueablePMSCall(String opportunityJson,String servicetoken,Id opportunityId){
            this.opportunityJson = opportunityJson;
            this.serviceToken = serviceToken;
            this.opportunityId = opportunityId;
        }
        
        public void execute(QueueableContext context){
            ProjectCalloutService.postOpportunityToPMS(opportunityJson,servicetoken,opportunityId);
        }
    }
}