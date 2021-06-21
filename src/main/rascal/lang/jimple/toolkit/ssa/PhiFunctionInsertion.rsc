module lang::jimple::toolkit::ssa::PhiFunctionInsertion

import demo::Dominators;
import Set;
import Relation;
import Type;
import IO;
import Node;
import List;

import analysis::graphs::Graph;
import lang::jimple::toolkit::FlowGraph;
import lang::jimple::core::Syntax;
import lang::jimple::toolkit::ssa::Helpers;

public FlowGraph insertPhiFunctions(FlowGraph flowGraph, map[&T, set[&T]] dominanceFrontier) {
	variableList = { getStmtVariable(graphNode) | <graphNode, _> <- flowGraph, isVariable(graphNode) };
	
	for(V <- variableList) {
		DomFromPlus = ();
		Work = ();
		W = {};
	
		for(X <- blocksWithVariable(flowGraph, V)) {
			Work[X] = 1;
			W = W + {X};
		};
		
		while(W != {}) {
			<X, newSet> = takeOneFrom(W);
			W = newSet;
			
			if(X in dominanceFrontier) {
				for(Y <- dominanceFrontier[X]) {
					if(!(Y in DomFromPlus)) {
						flowGraph = insertPhiFunction(flowGraph, Y, V); // add v←φ(...) at entry of Y
						DomFromPlus[Y] = 1;
						if(!(Y in DomFromPlus)) {
							Work(Y) = 1;
							W = W + {Y};
						};
					};
				};
			};
		};
	};
	
	return flowGraph;

}

public list[Node] blocksWithVariable(FlowGraph flowGraph, Variable variable) {
	return [graphNode | <graphNode, _> <- flowGraph, isSameVariable(graphNode, variable)];;
}

public bool isVariable(Node graphNode) {
	if (size(graphNode[..]) == 0) return false;

	assignStatement = returnStmtNodeBody(graphNode);
	if (size(assignStatement[..]) == 0) return false;

	variableArg = assignStatement[0];
	typeOfVariableArg = typeOf(variableArg);

	if (size(typeOfVariableArg[..]) == 0) return false;

	return typeOfVariableArg.name == "Variable";
}

public &T getStmtVariable(Node graphNode) {
	assignStatement = returnStmtNodeBody(graphNode);
	variableArg = assignStatement[0];

	return variableArg;
}

public bool isSameVariable(Node graphNode, Variable variable) {
	if (size(graphNode[..]) == 0) return false;

	assignStatement = returnStmtNodeBody(graphNode);
	if (size(assignStatement[..]) == 0) return false;

	variableArg = assignStatement[0];
	typeOfVariableArg = typeOf(variableArg);

	if (size(typeOfVariableArg[..]) == 0) return false;

	return variableArg == variable;
}

public FlowGraph insertPhiFunction(FlowGraph flowGraph, Node childNode, Variable variable) {
	if (childNode == exitNode()) return flowGraph;
	
	fatherNodes = predecessors(flowGraph, childNode);
	phiFunctionStmt = stmtNode(assign(variable, phiFunction(variable, [])));

	phiFunctionRelations = { <fatherNode, phiFunctionStmt> | fatherNode <- fatherNodes };
	filteredFlowGraph = { <origin, destination> | <origin, destination> <- flowGraph, !(origin in fatherNodes) || !(childNode == destination) };

	flowGraphWithPhiFunction = phiFunctionRelations + filteredFlowGraph + {<phiFunctionStmt, childNode>};

	return flowGraphWithPhiFunction;
}
