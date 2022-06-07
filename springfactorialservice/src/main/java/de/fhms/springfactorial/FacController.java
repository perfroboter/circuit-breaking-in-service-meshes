package de.fhms.springfactorial;

import java.math.BigInteger;

import org.springframework.cloud.client.circuitbreaker.CircuitBreaker;
import org.springframework.cloud.client.circuitbreaker.CircuitBreakerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class FacController {
	
	private static final String DELIBERATELY_EXCEPTION_MESSAGE = "Deliberately Exception (RuntimeException)";
	private final  CircuitBreaker cb; 
	
	private static volatile long counter = 0;
	
	public FacController(CircuitBreakerFactory cbFactory) {
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
				return throwErrorWithCB();
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
	
    @GetMapping("/throw-error-with-cb")
	public String throwErrorWithCB() throws Exception {
		return cb.run(() -> {throw new RuntimeException(DELIBERATELY_EXCEPTION_MESSAGE);}, 
				(T) -> {
					if (T.getMessage().equals(DELIBERATELY_EXCEPTION_MESSAGE)) {
						throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR);
					} else {
						throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE);
					}
				});
    }
	
    @GetMapping("/throw-error-without-cb")
   	public String throwErrorWithoutCB() throws Exception {
       	throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR); 
       }
    
    private BigInteger factorial(BigInteger number) {
      	 BigInteger result = BigInteger.valueOf(1);

      	    for (long factor = 2; factor <= number.longValue(); factor++) {
      	        result = result.multiply(BigInteger.valueOf(factor));
      	    }

      	    return result;
      }
}
