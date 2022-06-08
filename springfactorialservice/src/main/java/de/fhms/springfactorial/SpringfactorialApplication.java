package de.fhms.springfactorial;

import java.math.BigInteger;
import java.time.Duration;
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
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig.SlidingWindowType;

@SpringBootApplication
public class SpringfactorialApplication {
	//see: https://github.com/spring-cloud-samples/spring-cloud-circuitbreaker-demo/tree/main/spring-cloud-circuitbreaker-demo-resilience4j/src/main/java/org/springframework/cloud/circuitbreaker/demo/resilience4jcircuitbreakerdemo
	

	public static void main(String[] args) {
		SpringApplication.run(SpringfactorialApplication.class, args);
	}
	
	
	/**
	 * Default-Konfiguration des Circuit-Breakers (wird auch bei keinem angegebenen Bean verwendet)
	 */
	/*
	@Bean
	public Customizer<Resilience4JCircuitBreakerFactory> defaultCustomizer() {
		return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
				.circuitBreakerConfig(CircuitBreakerConfig.ofDefaults())
				.build());
	}*/
	
	
	
	/**
	 * Konfigration eines CircuitBreakers:
	 * Fehler erkennen: Bei 5 aufeinander folgenden Fehlern, geht der CB für 30s in den OPEN-Zustand
	 * Überlast erkennen: Bei 5 aufeinander folgenden Anfragen von über 200 ms Dauer, geht der CB für 30s in den OPEN-Zustand
	 * 
	 */
	@Bean
	public Customizer<Resilience4JCircuitBreakerFactory> cbConfig2() {
		return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
				.circuitBreakerConfig(CircuitBreakerConfig.custom()
						  .slidingWindowSize(5)
						  .failureRateThreshold(100)
						  .waitDurationInOpenState(Duration.ofSeconds(30))
						  .minimumNumberOfCalls(5)
						  .slowCallDurationThreshold(Duration.ofMillis(200))
						  .slowCallRateThreshold(100)
						.build())
				.build());
	}
	

}
