module ssa::SSAIntegrationTests::math_problems::TestBinomialCoefficient

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

test bool testBinomialCoefficientMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/math_problems/BinomialCoefficient.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);
	
	return !isEmpty(result);
}