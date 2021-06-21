module ssa::SSAIntegrationTests::math_problems::TestGeneratePrimes

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

// Decompiler error
test bool testGeneratePrimesMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/math_problems/GeneratePrimes.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);
	
	return !isEmpty(result);
}