package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-24.php
public class BinomialCoefficient {
	  public static long binomial_Coefficient(int n, int k)
	    {
	        if (k>n-k)
	            k=n-k;

	        long result = 1;
	        for (int i=1, m=n; i<=k; i++, m--)
	            result = result*m/i;
	        return result;
	    }
}
