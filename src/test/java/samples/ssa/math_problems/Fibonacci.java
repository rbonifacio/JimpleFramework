package samples.ssa.math_problems;

public class Fibonacci {
	public void run(int maxNumber) {
		int previousNumber = 0;
		int nextNumber = 1;

		for (int i = 1; i <= maxNumber; ++i) {
		  int sum = previousNumber + nextNumber;
		  previousNumber = nextNumber;
		  nextNumber = sum;
		}
	}
}
