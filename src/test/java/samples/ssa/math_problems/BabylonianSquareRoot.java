package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-14.php
public class BabylonianSquareRoot {
	public static float square_Root(float num) { 
	    float a = num; 
	    float b = 1; 
	    double e = 0.000001; 
	    while (a - b > e) { 
	        a = (a + b) / 2; 
	        b = num / a; 
	    } 
	    return a; 
	}
}
