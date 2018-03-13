trigger ProjectTrigger on Project__c (after update) {
    //Call the Billing Service callout logic here
    if(trigger.isUpdate){
    	if(trigger.isAfter){
    		BillingCalloutService.callBillingService(trigger.new,trigger.oldMap);
    	}
    }
}