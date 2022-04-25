package example.micronaut;

import java.math.BigInteger;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonValue;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;

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
