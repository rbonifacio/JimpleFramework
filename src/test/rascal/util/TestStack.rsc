module util::TestStack

import lang::jimple::util::Maybe;
import lang::jimple::util::Stack;

Stack[int] stack = push(1, push(2, emptyStack()));

test bool emptySizeTest() = 0 == size(emptyStack());
test bool sizeTest() = 2 == size(stack);

test bool emptyPopTest() = <nothing(), emptyStack()> == pop(emptyStack());
test bool popTest() = <just(1), push(2, emptyStack())> == pop(stack);

test bool emptyPeekTest() = nothing() == peek(emptyStack());
test bool peekTest() = just(1) == peek(stack);