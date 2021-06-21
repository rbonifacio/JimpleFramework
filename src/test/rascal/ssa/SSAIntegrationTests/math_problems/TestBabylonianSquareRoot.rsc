module ssa::SSAIntegrationTests::math_problems::TestBabylonianSquareRoot

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

test bool testBabylonianSquareRootMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/math_problems/BabylonianSquareRoot.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);
	
	return !isEmpty(result);
}