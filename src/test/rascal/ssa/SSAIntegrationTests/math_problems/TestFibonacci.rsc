module ssa::SSAIntegrationTests::math_problems::TestFibonacci

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

test bool testFibonacciRunMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/math_problems/Fibonacci.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);
	
	return !isEmpty(result);
}