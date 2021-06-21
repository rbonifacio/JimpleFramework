module ssa::TestDominanceTree

import lang::jimple::toolkit::FlowGraph;
import lang::jimple::toolkit::ssa::DominanceTree;
import lang::jimple::core::Syntax;

test bool testDominanceTree() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));

	Statement s2 = ifStmt(cmp(local("v0"), iValue(booleanValue(false))), "label1:");
	Statement s3 = assign(localVariable("v1"), immediate(iValue(intValue(1))));
	Statement s4 = gotoStmt("label2:");

	Statement s5 = label("label1:");
	Statement s6 = assign(localVariable("v2"), immediate(iValue(intValue(2))));

	Statement s7 = label("label2:");
	Statement s8 = label("print");

	Statement s9 = returnStmt(local("v2"));

	list[Statement] stmts = [s1, s2, s3, s4, s5, s6, s7, s8, s9];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);

  	map[&T, set[&T]] expectation = (
  	  stmtNode(s6): { stmtNode(s9), exitNode() },
  	  entryNode(): {
  	    stmtNode(s6),
  	    stmtNode(s2),
  	    stmtNode(s9),
  	    stmtNode(s4),
  	    stmtNode(s1),
  	    stmtNode(s3),
  	    exitNode(),
  	    stmtNode(s8)
  	  },
  	  stmtNode(s2): {
  	    stmtNode(s6),
  	    stmtNode(s9),
  	    stmtNode(s4),
  	    stmtNode(s3),
  	    exitNode(),
  	    stmtNode(s8)
  	  },
  	  stmtNode(s9): {exitNode()},
  	  stmtNode(s4): {stmtNode(s8)},
  	  stmtNode(s1): {
  	    stmtNode(s6),
  	    stmtNode(s2),
  	    stmtNode(s9),
  	    stmtNode(s4),
  	    stmtNode(s3),
  	    exitNode(),
  	    stmtNode(s8)
  	  },
  	  stmtNode(s3): {
  	    stmtNode(s4),
  	    stmtNode(s8)
  	  },
  	  exitNode(): {},
	  stmtNode(s8): {}
	);

	return createDominanceTree(flowGraph) == expectation;
}


test bool testFindIdomForInitialNode() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));

	Statement s2 = ifStmt(cmp(local("v0"), iValue(booleanValue(false))), "label1:");
	Statement s3 = assign(localVariable("v1"), immediate(iValue(intValue(1))));
	Statement s4 = gotoStmt("label2:");

	Statement s5 = label("label1:");
	Statement s6 = assign(localVariable("v2"), immediate(iValue(intValue(2))));

	Statement s7 = label("label2:");
	Statement s8 = label("print");

	Statement s9 = returnStmt(local("v2"));

	list[Statement] stmts = [s1, s2, s3, s4, s5, s6, s7, s8, s9];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);

  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);

  	return findIdom(dominanceTree, stmtNode(s1)) == entryNode();
}

test bool testFindIdomForAMiddleNode() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));

	Statement s2 = ifStmt(cmp(local("v0"), iValue(booleanValue(false))), "label1:");
	Statement s3 = assign(localVariable("v1"), immediate(iValue(intValue(1))));
	Statement s4 = gotoStmt("label2:");

	Statement s5 = label("label1:");
	Statement s6 = assign(localVariable("v2"), immediate(iValue(intValue(2))));

	Statement s7 = label("label2:");
	Statement s8 = label("print");

	Statement s9 = returnStmt(local("v2"));

	list[Statement] stmts = [s1, s2, s3, s4, s5, s6, s7, s8, s9];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);

  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);

  	return findIdom(dominanceTree, stmtNode(s9)) == stmtNode(s6);
}
