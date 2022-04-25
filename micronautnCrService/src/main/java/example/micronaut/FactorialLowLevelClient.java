package example.micronaut;

import io.micronaut.core.type.Argument;
import io.micronaut.http.HttpRequest;
import io.micronaut.http.client.HttpClient;
import io.micronaut.http.client.annotation.Client;
import io.micronaut.http.uri.UriBuilder;
import io.micronaut.retry.annotation.CircuitBreaker;
import io.micronaut.retry.annotation.Retryable;
import jakarta.inject.Singleton;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.util.Collections;
import java.util.List;

import static io.micronaut.http.HttpHeaders.ACCEPT;
import static io.micronaut.http.HttpHeaders.USER_AGENT;

@Singleton // <1>
public class FactorialLowLevelClient {
	
    private final HttpClient httpClient;


    public FactorialLowLevelClient(@Client HttpClient httpClient) { 
        this.httpClient = httpClient;
        //TODO: URIBuilder benutzen, damit IP und Port übergeben werden kann. (vgl. Mircornaut-Tutorial)
    }

    //@Retryable(attempts = "1", delay = "1s")
    Mono<MathBigIntResponse> getFactorial(long num) {
    	//TODO: URIBuilder benutzen s.o.
    	String uriString = "http://localhost:8080/fac/" + num;
        HttpRequest<?> req = HttpRequest.GET(uriString)
                .header(USER_AGENT, "Micronaut HTTP Client")
                .header(ACCEPT, "application/json");
        return Mono.from(httpClient.retrieve(req, MathBigIntResponse.class));
    }
}
