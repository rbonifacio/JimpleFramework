package samples.ssa.other;

public class SimpleException {
	public SimpleException() {
	}
	
	public static void run() {
    try {
      raiseException();
    } catch(Exception e) {
      System.out.println(e);
    }
  }

  public static void raiseException() throws Exception {
    throw new Exception("An exception");
  }
}
