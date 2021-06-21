module lang::jimple::toolkit::ssa::DominanceFrontier

import analysis::graphs::Graph;
import lang::jimple::toolkit::FlowGraph;
import lang::jimple::toolkit::ssa::DominanceTree;

public map[Node, set[Node]] createDominanceFrontier(FlowGraph flowGraph, map[&T, set[&T]] dominanceTree) {
	allNodes = { origin | <origin, _> <- flowGraph } + { destination | <_, destination> <- flowGraph };
	
	dominanceFrontiers = ();
	
	for(graphNode <- allNodes) {
		for(predecessor <- predecessors(flowGraph, graphNode)) {
			tempPredecessor = predecessor;
			while(tempPredecessor != findIdom(dominanceTree, graphNode)) {
				dominanceFrontiers[tempPredecessor] = tempPredecessor in dominanceFrontiers ? dominanceFrontiers[tempPredecessor] : {};
				dominanceFrontiers[tempPredecessor] = dominanceFrontiers[tempPredecessor] + {graphNode};
				tempPredecessor = findIdom(dominanceTree, tempPredecessor);
			};
		};
	};
	
	return dominanceFrontiers;
}
