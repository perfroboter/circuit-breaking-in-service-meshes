package example.micronaut;

import java.io.IOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.function.BiFunction;
import java.util.function.Function;

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
import reactor.core.publisher.Mono;

@Controller
public class NCRController {
	
	private final FactorialLowLevelClient facClient;
	
	
    public NCRController(FactorialLowLevelClient facClient) {
		super();
		this.facClient = facClient;
	}

	@Get("/ncr/{n}/{r}")
    @Produces(MediaType.APPLICATION_JSON) 
    public Mono<HttpResponse<?>> nCr(@PathVariable long n, @PathVariable long r) {
		
		Mono<BigInteger> mono = Flux.concat(facClient.getFactorial(r).map(result -> result.getResult()), 
				facClient.getFactorial(n-r).map(result -> result.getResult()))
				.reduce((fac_r,fac_n_r) -> fac_r.multiply(fac_n_r)).concatWith(facClient.getFactorial(n).map(result -> result.getResult())).reduce((nenner,zaehler) -> zaehler.divide(nenner));
				
		Function<BigInteger,HttpResponse<?>> mapper = bi -> HttpResponse.status(HttpStatus.OK).body("{ \"result\":" + bi.toString() + "}");
		
		Mono<HttpResponse<?>> httpResp = mono.map(mapper);
		
		
		
		//TODO: Ungültige Werte abfangen
		/*
    	BigInteger facN = facClient.getFactorial(n).block().getResult();
    	System.out.println("BigInt: " + facN);
    	facClient.
    	BigInteger facR = facClient.getFactorial(r).block().getResult();
    	System.out.println("BigInt: " + facR);
    	BigInteger facNSubR = facClient.getFactorial(n-r).block().getResult();
    	System.out.println("BigInt: " + facNSubR);
    	BigInteger result = facN.divide(facR.multiply(facNSubR));
    	*/
    	//TODO: Fix Json-Represantation of BigInt with Jackson
    	/*String body = "{ \"result\":" + result.toString() + "}";
    	
    	return HttpResponse.status(HttpStatus.OK).body(body);*/
		return httpResp;
    } 	
	
	
}
