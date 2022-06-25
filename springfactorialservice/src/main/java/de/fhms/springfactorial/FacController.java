package de.fhms.springfactorial;

import java.math.BigInteger;

import org.springframework.cloud.circuitbreaker.resilience4j.Resilience4JCircuitBreakerFactory;
import org.springframework.cloud.client.circuitbreaker.CircuitBreaker;
import org.springframework.cloud.client.circuitbreaker.CircuitBreakerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class FacController {

	private static final String DELIBERATELY_EXCEPTION_MESSAGE = "Deliberately Exception (RuntimeException)";
	private final CircuitBreaker cb;
	private String result;

	public FacController(CircuitBreakerFactory cbFactory) {
		super();
		this.cb = cbFactory.create("fac");
	}

	/**
	 * Berechnet die Fakultät zur übergebendenen Zahl. Der Circuit-Breaker ist bei
	 * dieser Methode aktiviert. Im OPEN-Zustand wird im "Fallback" eine 503er
	 * Antwort ausgegeben.
	 * 
	 * @param num
	 * @return Fakultät als Json-String
	 */
	@GetMapping(value="/fac-with-cb/{num}")
	public String facWithCB(@PathVariable long num) {
		return cb.run(() -> {this.result = factorial(BigInteger.valueOf(num)).toString(); return result;}, (T) -> {
			throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE);
		});

	}
	
	/**
	 * Die Methode löst eine RuntimeException aus. Hierbei ist der Circuit-Breaker
	 * aktiviert. Im CLOSED-Zustand, wird eine 500er Antwort ausgegeben. Im
	 * OPEN-Zustand, wird eine 503er Antwort ausgegeben.
	 * 
	 * Kommentar: Die Unterscheidung der Exception im "Fallback" ist notwendig, da
	 * R4J im OPEN-Zustand auch eine Exception
	 * (io.github.resilience4j.circuitbreaker.CallNotPermittedException) auslöst.
	 * 
	 * @return
	 * @throws Exception
	 */
	@GetMapping("/throw-error-with-cb")
	public String throwErrorWithCB() throws Exception {
		return cb.run(() -> {
			throw new RuntimeException(DELIBERATELY_EXCEPTION_MESSAGE);
		}, (T) -> {
			if (T.getMessage().equals(DELIBERATELY_EXCEPTION_MESSAGE)) {
				throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR);
			} else {
				throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE);
			}
		});
	}

	/**
	 * Die Methode löst eine RuntimeException aus. Der Circuit-Breaker ist hierbei
	 * nicht aktiviert.
	 * 
	 * @return
	 * @throws Exception
	 */
	@GetMapping("/throw-error-without-cb")
	public String throwErrorWithoutCB() throws Exception {
		throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	/**
	 * Berechnet die Fakultät zur übergebendenen Zahl. Der Circuit-Breaker ist bei
	 * dieser Methode nicht aktiviert.
	 * 
	 * @param num
	 * @return Fakultät als Json-String
	 */
	@GetMapping(value="/fac-without-cb/{num}")
	public String facWithoutCB(@PathVariable long num) {
		return String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString());

	}

	/**
	 * Diese Methode ermöglicht ein zeitlich gesteuerte "FaultInjection". Je nach
	 * akuteller Systemzeit werden entweder erfolgreiche oder nicht-erfolgreiche
	 * Antworten zurückgegeben.
	 * 
	 * @param num
	 * @param isCB  Angabe, ob Circuit-Breaker verwendet werden soll oder nicht
	 * @param from  Startzeitpunkt (Systemzeit in Millis), ab wann Exceptions (5xx)
	 *              zurückgegeben werden
	 * @param until Endzeitpunkt (Systemzeit in Millis), bis wann Exceptions (5xx)
	 *              zurückgegeben werden
	 * @return
	 * @throws Exception
	 */
	@GetMapping("/fac-with-config/{num}")
	public String facWithConfig(@PathVariable long num, @RequestParam boolean isCB, @RequestParam long from,
			@RequestParam long until) throws Exception {
		if (isCB) {
			if (System.currentTimeMillis() > from && System.currentTimeMillis() < until) {
				return throwErrorWithCB();
			} else {
				return facWithCB(num);
			}
		} else {
			if (System.currentTimeMillis() > from && System.currentTimeMillis() < until) {
				return throwErrorWithoutCB();
			} else {
				return facWithoutCB(num);
			}
		}
	}

	/**
	 * Diese Methode ermöglicht ein zeitlich gesteuerte "DelayInjection". Je nach
	 * akuteller Systemzeit werden entweder direkte oder verzögerte erfolgreiche
	 * Antworten zurückgegeben.
	 * 
	 * @param num
	 * @param isCB  Angabe, ob Circuit-Breaker verwendet werden soll oder nicht
	 * @param from  Startzeitpunkt (Systemzeit in Millis), ab wann Exceptions (5xx)
	 *              zurückgegeben werden
	 * @param until Endzeitpunkt (Systemzeit in Millis), bis wann Exceptions (5xx)
	 *              zurückgegeben werden
	 * @param delay	Verzögerung in Millis (zusätzlich zum eigentlichen Workload)
	 * @return
	 * @throws Exception
	 */
	// TODO: Delay durch Kopieren der andern Methoden eingefügt. Ändern durch
	// optionale RequestParam "delay"
	@GetMapping("/delay-with-config/{num}")
	public String delayWithConfig(@PathVariable long num, @RequestParam boolean isCB, @RequestParam long from,
			@RequestParam long until, @RequestParam long delay) throws Exception {
		if (isCB) {
			return cb.run(() -> {
				if (System.currentTimeMillis() > from && System.currentTimeMillis() < until) {
					try {
						Thread.sleep(delay);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				return String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString());
			}, (T) -> {
				throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE);
			});

		} else {
			if (System.currentTimeMillis() > from && System.currentTimeMillis() < until) {
				try {
					Thread.sleep(delay);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString());

		}
	}
	
	@GetMapping("/sporadic-error-with-config/{num}")
	public String sporadicErrorWithConfig(@PathVariable long num,@RequestParam boolean isCB,  @RequestParam double failureRate) throws Exception {
		if (isCB) {
			if (Math.random() < failureRate) {
				return throwErrorWithCB();
			} else {
				return facWithCB(num);
			}
		} else {
			if (Math.random() < failureRate) {
				return throwErrorWithoutCB();
			} else {
				return facWithoutCB(num);
			}
		}
	}
	
	@GetMapping("/sporadic-delay-with-config/{num}")
	public String sporadicDelayWithConfig(@PathVariable long num,@RequestParam boolean isCB,  @RequestParam double failureRate,  @RequestParam long delay) throws Exception {
		if (isCB) {
			return cb.run(() -> {
				if (Math.random() < failureRate) {
					try {
						Thread.sleep(delay);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				return String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString());
			}, (T) -> {
				throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE);
			});

		} else {
			if (Math.random() < failureRate) {
				try {
					Thread.sleep(delay);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return String.format("{\"result\"=%s}", factorial(BigInteger.valueOf(num)).toString());

		}
	}

	/**
	 * Workload-Methode, die die Fakulät berechnet. Quelle: vgl.
	 * https://stackoverflow.com/a/7879559
	 * 
	 * @param number
	 * @return Fakultät n!
	 */
	private BigInteger factorial(BigInteger number) {
		BigInteger result = BigInteger.valueOf(1);

		for (long factor = 2; factor <= number.longValue(); factor++) {
			result = result.multiply(BigInteger.valueOf(factor));
		}

		return result;
	}
}
