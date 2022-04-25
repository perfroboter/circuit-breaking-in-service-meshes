package example.micronaut;

import java.io.IOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


import com.fasterxml.jackson.databind.JsonDeserializer;


import io.micronaut.core.type.Argument;
import io.micronaut.http.HttpMethod;
import io.micronaut.http.HttpRequest;
import io.micronaut.http.HttpResponse;
import io.micronaut.http.HttpStatus;
import io.micronaut.http.MediaType;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;
import io.micronaut.http.annotation.PathVariable;
import io.micronaut.http.annotation.Produces;
import io.micronaut.http.client.BlockingHttpClient;
import io.micronaut.http.client.HttpClient;
import io.micronaut.http.client.annotation.Client;
import io.micronaut.http.uri.UriBuilder;
import io.micronaut.retry.annotation.Retryable;
import jakarta.inject.Inject;
import reactor.core.publisher.Flux;

@Controller
public class NCRController {
	
	private final FactorialLowLevelClient facClient;
	
	
	
    public NCRController(FactorialLowLevelClient facClient) {
		super();
		this.facClient = facClient;
	}

	@Get("/ncr/{n}/{r}")
    @Produces(MediaType.APPLICATION_JSON) 
    public HttpResponse<?> nCr(@PathVariable long n, @PathVariable long r) {
		
		//TODO: Ungültige Werte abfangen
		
    	BigInteger facN = facClient.getFactorial(n).block().getResult();
    	BigInteger facR = facClient.getFactorial(r).block().getResult();
    	BigInteger facNSubR = facClient.getFactorial(n-r).block().getResult();
    	BigInteger result = facN.divide(facR.multiply(facNSubR));
    	
    	//TODO: Fix Json-Represantation of BigInt with Jackson
    	String body = "{ \"result\":" + result.toString() + "}";
    	
    	return HttpResponse.status(HttpStatus.OK).body(body);
    } 	
}
