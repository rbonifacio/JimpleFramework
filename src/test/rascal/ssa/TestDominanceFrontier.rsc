module ssa::TestDominanceFrontier

import lang::jimple::toolkit::FlowGraph;
import lang::jimple::toolkit::ssa::DominanceFrontier;
import lang::jimple::toolkit::ssa::DominanceTree;
import lang::jimple::core::Syntax;

test bool testDominanceFrontier() {
  	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));

	Statement s2 = ifStmt(cmp(local("v0"), iValue(booleanValue(false))), "label1:");
	Statement s3 = assign(localVariable("v1"), immediate(iValue(intValue(1))));
	Statement s4 = gotoStmt("print");

	Statement s5 = label("label1:");
  	Statement s6 = assign(localVariable("v1"), immediate(iValue(intValue(2))));
  	Statement s7 = gotoStmt("print");

  	Statement s8 = label("print");
  	Statement s9 = returnStmt(local("v2"));

	list[Statement] stmts = [s1, s2, s3, s4, s5, s6, s7, s8, s9];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);
  	dominanceTree = createDominanceTree(flowGraph);

	result = createDominanceFrontier(flowGraph, dominanceTree);

	return result == (
	  stmtNode(assign(localVariable("v1"),immediate(iValue(intValue(2))))):{
	    stmtNode(gotoStmt("print"))
	  },
	  stmtNode(assign(localVariable("v1"),immediate(iValue(intValue(1))))):{
	    stmtNode(gotoStmt("print"))
	  }
	);
}
