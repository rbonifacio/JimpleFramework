module ssa::SSAIntegrationTests::math_problems::TestTaylorExponential

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

test bool testTaylorExponentialMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/math_problems/TaylorExponential.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);
	
	return !isEmpty(result);
}