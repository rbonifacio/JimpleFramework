package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-3.php
public class ValidateDoubleIsInteger {
	 public static void main(String[] args) {
		  double d_num = 5.44444;
		  Boolean result;
		  
		  if ((d_num % 1) == 0) {
			  result = false;
		  } else {
			  result = true;
		  }
	 }
}
