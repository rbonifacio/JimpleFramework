module ssa::SSAIntegrationTests::sort::TestQuickSort

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

test bool testQuickSortPartitionMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/sort/QuickSort.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);

	// Flow Graph creation error
	return !isEmpty(result);
}

test bool testQuickSortSortMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/sort/QuickSort.class|;
	int methodToTest = 2;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);

	// Doest support invokeStmt operators
	return result == {};
}

test bool testQuickSortPrintMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/sort/QuickSort.class|;
	int methodToTest = 3;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);

	// Doest support invokeStmt operators
	return result == {};
}

test bool testQuickSortMainMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/sort/QuickSort.class|;
	int methodToTest = 4;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);

	// Doest support invokeStmt operators
	return result == {};
}