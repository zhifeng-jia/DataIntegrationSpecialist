public class ProjectCalloutServiceMock implements HttpCalloutMock {
   //Implement http mock callout here

   public HttpResponse respond(HttpRequest request){

   	HttpResponse response = new HttpResponse();
   	response.setHeader('Content-Type', 'application/json');
   	response.setStatusCode(201);
   	response.setStatus('Project Created');
   	return response;
   }
}