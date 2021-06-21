// https://github.com/UnB-CIC/sle-course/blob/master/sample-code/oberon/src/lang/util/Maybe.rsc
module lang::jimple::util::Maybe

data Maybe[&T] = nothing()
		       | just(&T v);
		       
bool isJust(nothing()) = false; 
bool isJust(just(_)) = true; 