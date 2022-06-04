package de.fhms.springfactorial;

import java.math.BigInteger;
import java.util.Optional;
import java.util.function.Supplier;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.circuitbreaker.resilience4j.Resilience4JCircuitBreakerFactory;
import org.springframework.cloud.circuitbreaker.resilience4j.Resilience4JConfigBuilder;
import org.springframework.cloud.client.circuitbreaker.CircuitBreaker;
import org.springframework.cloud.client.circuitbreaker.CircuitBreakerFactory;
import org.springframework.cloud.client.circuitbreaker.Customizer;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;

@SpringBootApplication
@RestController
public class SpringfactorialApplication {
	
	private final  CircuitBreaker cb; 
	private static volatile long counter = 0;

	public static void main(String[] args) {
		SpringApplication.run(SpringfactorialApplication.class, args);
	}
	
	/*@Bean
	public Customizer<Resilience4JCircuitBreakerFactory> defaultCustomizer() {
		return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
				.circuitBreakerConfig(CircuitBreakerConfig.custom().failureRateThreshold(failureRateThreshold))
				.build());
	}*/

	public SpringfactorialApplication(CircuitBreakerFactory cbFactory) {
		super();
		this.cb = cbFactory.create("fac");
	}

	@GetMapping("/fac-with-cb/{num}")
	public String facWithCB(@PathVariable long num) {
		return cb.run(() -> String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString()), (T) -> {throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE);});
	
	}
	
	@GetMapping("/fac-without-cb/{num}")
	public String facWithoutCB(@PathVariable long num) {
		return String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString());
	
	}
	
	@GetMapping("/fac-with-config/{num}")
	@Deprecated
	//TODO: Funktioniert nur bei Replica = 1
	//Example: /fac-with-config/5?isCB=true&consFails=2&successCalls=3
	public String facWithConfig(@PathVariable long num, @RequestParam boolean isCB, @RequestParam long consFails , @RequestParam long successCalls) throws Exception {	
		if(isCB) {
			if(isError(consFails,successCalls)) {
				return throwError();
			} else {
				return facWithCB(num);
			}
		} else {
			if(isError(consFails,successCalls)) {
				return throwErrorWithoutCB();
			} else {
				return facWithoutCB(num);
			}
		}
	}
	
	@Deprecated
	//TODO: Counter verzählt sich, um einen?
	private synchronized boolean isError(long consFails, long successCalls) {
		counter++;
		if(counter <= successCalls) {
			return false;
		} else if (counter <= (successCalls + consFails)){
			return true;
		} else {
			counter = 1;
			return false;
		}
	}
	
    @GetMapping("/throw-error")
	public String throwError() throws Exception {
    	cb.run(() -> {throw new RuntimeException("Evoked internal error (RuntimeException)");});
    	throw new ResponseStatusException(HttpStatus.BAD_REQUEST); 
    }
	
    @GetMapping("/throw-error-without-cb")
   	public String throwErrorWithoutCB() throws Exception {
       	throw new ResponseStatusException(HttpStatus.BAD_REQUEST); 
       }
    private BigInteger factorial(BigInteger number) {
      	 BigInteger result = BigInteger.valueOf(1);

      	    for (long factor = 2; factor <= number.longValue(); factor++) {
      	        result = result.multiply(BigInteger.valueOf(factor));
      	    }

      	    return result;
      }
    

}
