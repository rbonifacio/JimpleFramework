package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-2.php
public class GetFractionalPart {
	  public static void main(String[] args) {
		  double value = 12.56;
		  double fractional_part = value % 1;
		  double integral_part = value - fractional_part;
	  }
}
