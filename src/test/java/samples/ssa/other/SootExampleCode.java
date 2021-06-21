package samples.ssa.other;

public class SootExampleCode {
	
	// https://github.com/soot-oss/soot/tree/master/src/main/java/soot/shimple
	public int test() {
	    int x = 100;
	        
	    while(x == 100){
	        if(x < 200)
	            x = 100;
	        else
	            x = 200;
	    }

	    return x;
	}
}
