package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-6.php
public class ReverseInteger {
   public static void main(String[] args) {
		int num =1287; 
		int is_positive = 1;
        if (num < 0) {
            is_positive = -1;
            num = -1 * num;
        }
        
        int sum  = 0;

        while (num > 0) {
            int r = num % 10;
            
            int maxDiff = Integer.MAX_VALUE - sum * 10;
            if (sum > Integer.MAX_VALUE / 10 || r > maxDiff);
        
	        sum = sum * 10 + r;
	        num /= 10;
        }
	        
	    int result = is_positive * sum;
   }
}
