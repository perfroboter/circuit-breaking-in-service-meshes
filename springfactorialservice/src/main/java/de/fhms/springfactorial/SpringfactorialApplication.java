package de.fhms.springfactorial;

import java.math.BigInteger;
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
import org.springframework.web.bind.annotation.RestController;

import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;

@SpringBootApplication
@RestController
public class SpringfactorialApplication {
	
	private final  CircuitBreaker cb; 

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



	@GetMapping("/fac/{num}")
	public String fac(@PathVariable long num) {
		return cb.run(() -> String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString()));
	
	}
	
    private BigInteger factorial(BigInteger number) {
      	 BigInteger result = BigInteger.valueOf(1);

      	    for (long factor = 2; factor <= number.longValue(); factor++) {
      	        result = result.multiply(BigInteger.valueOf(factor));
      	    }

      	    return result;
      }
	
    
    @GetMapping("/error/")
	public String error() throws Exception {
    	return cb.run(() -> {throw new RuntimeException("Evoked internal error (RuntimeException)");});
    }
}
