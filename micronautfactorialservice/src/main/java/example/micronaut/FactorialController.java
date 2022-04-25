package example.micronaut;

import java.math.BigInteger;

import io.micronaut.http.HttpResponse;
import io.micronaut.http.HttpStatus;
import io.micronaut.http.MediaType;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;
import io.micronaut.http.annotation.PathVariable;
import io.micronaut.http.annotation.Produces;

@Controller
public class FactorialController {
	
    @Get("/fac/{num}")
    @Produces(MediaType.APPLICATION_JSON)
    public HttpResponse<MathBigIntResponse> fac(@PathVariable long num) {
    	MathBigIntResponse facResp = new MathBigIntResponse(factorial(BigInteger.valueOf(num)));
    	
    	return HttpResponse.status(HttpStatus.OK).body(facResp);
    }
    
  
    @Get("/facstring/{num}")
    @Produces(MediaType.TEXT_PLAIN)
    public String facString(@PathVariable long num) {
        return "Calculation: fac(" + num + ") = " + factorial(BigInteger.valueOf(num));
    }
    
    private BigInteger factorial(BigInteger number) {
   	 BigInteger result = BigInteger.valueOf(1);

   	    for (long factor = 2; factor <= number.longValue(); factor++) {
   	        result = result.multiply(BigInteger.valueOf(factor));
   	    }

   	    return result;
   }
}
