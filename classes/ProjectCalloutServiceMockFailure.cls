public class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   //Implement http mock callout failure here
   public HttpResponse respond(HttpRequest request){

   	HttpResponse response = new HttpResponse();
   	response.setHeader('Content-Type', 'application/json');
   	response.setStatusCode(500);
   	response.setStatus('Project Creation failed');
   	return response;
   } 
}