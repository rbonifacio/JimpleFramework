module lang::jimple::util::Stack

import lang::jimple::util::Maybe;

// Source:  https://github.com/UnB-CIC/sle-course/blob/master/sample-code/oberon/src/lang/util/Stack.rsc

data Stack[&T] = emptyStack() | push(&T v, Stack[&T] s);      

int size(emptyStack()) = 0;
int size(push(v,r)) = 1 + size(r);

Maybe[&T] peek(emptyStack()) = nothing();
Maybe[&T] peek(push(v, r)) = just(v);

tuple[Maybe[&T] v, Stack[&T] stack] pop(Stack[&T] s) {
  switch(s) {
    case emptyStack() : return <nothing(), emptyStack()>; 
    case push(v, r) : return <just(v), r>;  
  }
   
  return <nothing(), emptyStack()>;
}

public int peekIntValue(Stack[int] stack) {
	switch(peek(stack)[0]) {
		case int stackValue: return stackValue;
	}
}