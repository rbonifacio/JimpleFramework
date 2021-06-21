package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-16.php
public class ApplyPower {
	  public static int power(int b, int e) 
	    { 
	        if (e == 0) 
	            return 1; 
	              
	        int result = b; 
	        int temp = b; 
	        int i, j; 
	          
	        for (i = 1; i < e; i++) { 
	            for (j = 1; j < b; j++) { 
	                result += temp; 
	            } 
	            temp = result; 
	        } 
	          
	        return result; 
	    } 
}
