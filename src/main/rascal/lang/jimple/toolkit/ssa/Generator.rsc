module lang::jimple::toolkit::ssa::Generator

import List;

import lang::jimple::toolkit::FlowGraph;
import lang::jimple::core::Syntax;

import lang::jimple::toolkit::ssa::DominanceTree;
import lang::jimple::toolkit::ssa::PhiFunctionInsertion;
import lang::jimple::toolkit::ssa::DominanceFrontier;
import lang::jimple::toolkit::ssa::VariableRenaming;

public FlowGraph applySSATransformation(MethodBody methodBody) {
	FlowGraph flowGraph = forwardFlowGraph(methodBody);
	
	if(hasUnsupportedInstruction(flowGraph)) // Doest not support invokeStmt and fieldRef rename 
		return {};
	
	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);
	result = applyVariableRenaming(phiFunctionFlowGraph);
	
	return result;
}

public bool hasUnsupportedInstruction(FlowGraph flowGraph) {
	unsupportedList = [ <origin, destination> | <origin, destination> <- flowGraph, unspportedStatement(origin) || unspportedStatement(destination)];
	
	return size(unsupportedList) != 0;
}

public bool unspportedStatement(Node nodeStatement) {
	switch(nodeStatement) {
		case stmtNode(invokeStmt(_)): return true;
		case stmtNode(assign(fieldRef(_, _), _)): return true;
		default: return false; 
	}
}