package example.micronaut;

import java.math.BigInteger;

import io.micronaut.core.annotation.Introspected;


@Introspected
public class MathBigIntResponse {
	
	BigInteger result;

	
	public MathBigIntResponse(BigInteger result) {
		super();
		this.result = result;
	}

	public BigInteger getResult() {
		return result;
	}

	public void setResult(BigInteger result) {
		this.result = result;
	}

	
	
	
}
