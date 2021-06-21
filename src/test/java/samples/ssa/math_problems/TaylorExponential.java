package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-25.php
public class TaylorExponential {
	   static float taylorExponential(int n, float x) 
	    { 
	        float exp_sum = 1;  
	   
	        for (int i = n - 1; i > 0; --i ) 
	            exp_sum = 1 + x * exp_sum / i; 
	   
	        return exp_sum; 
	    }
}
