package samples.ssa.math_problems;

// Source: https://www.w3resource.com/java-exercises/math/java-math-exercise-17.php
public class FindArrayAverageValue {
    // Prints average of a stream of numbers 
    static float streamAvg() 
    { 
    	float arr[] = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}; 
        int n = arr.length; 
		float avg = 0; 
        for (int i = 0; i < n; i++)  
        { 
            //avg = getAvg(avg, arr[i], i); 
			avg = (avg * i + arr[i]) / (i + 1);
        } 
        return avg; 
    } 
}
