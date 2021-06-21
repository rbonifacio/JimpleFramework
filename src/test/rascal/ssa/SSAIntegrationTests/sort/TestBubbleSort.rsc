module ssa::SSAIntegrationTests::sort::TestBubbleSort

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

test bool testBubbleSortMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/sort/BubbleSort.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);

	// Flow Graph creation error
	return !isEmpty(result);
}