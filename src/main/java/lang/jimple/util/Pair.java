package lang.jimple.util;

import lang.jimple.internal.generated.Type;
import lang.jimple.internal.generated.Value;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Pair<First, Second> {
	
	First first; 
	Second second; 
}
