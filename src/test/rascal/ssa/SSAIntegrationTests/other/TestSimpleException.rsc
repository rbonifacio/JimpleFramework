module ssa::SSAIntegrationTests::other::TestSimpleException

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

// Enters in infinite loop, since this try/catch flow isn't implemented in the decompiler yet
test bool testRunMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/other/SimpleException.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);
	
	return true;
}

test bool testRaiseExceptionMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/other/SimpleException.class|;
	int methodToTest = 2;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);

	// Doest support invokeStmt operators
	return result == {};
}