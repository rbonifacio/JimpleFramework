package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-20.php
// This code trigges a decompiler bug, issue https://github.com/PAMunb/JimpleFramework/issues/37
public class GeneratePrimes {
	public static int [] generatePrimes(int num) {
	    boolean[] temp = new boolean[num + 1];
	    for (int i = 2; i * i <= num; i++) {
	        if (!temp [i]) {
	            for (int j = i; i * j <= num; j++) {
	                temp [i*j] = true;
	            }
	        }
	    }
	    int prime_nums = 0;
	    for (int i = 2; i <= num; i++) {
	        if (!temp [i]) prime_nums++;
	    }
	    int [] all_primes = new int [prime_nums];
	    int index = 0; 
	    for (int i = 2; i <= num; i++) {
	        if (!temp [i]) all_primes [index++] = i;
	    }
	    return all_primes;
	}
}
