module ssa::TestPhiFunctionInsertion

import lang::jimple::toolkit::FlowGraph;
import lang::jimple::toolkit::ssa::DominanceFrontier;
import lang::jimple::toolkit::ssa::DominanceTree;
import lang::jimple::toolkit::ssa::PhiFunctionInsertion;
import lang::jimple::core::Syntax;

test bool testDoesNotInserntInSimpleAssigment() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));
	Statement s2 = assign(localVariable("v1"), immediate(local("v0")));

	list[Statement] stmts = [s1, s2];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);	
  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);

	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);
	
	return phiFunctionFlowGraph == flowGraph;
}

test bool testPhiFunctionInsertion() {
  	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));

	Statement s2 = ifStmt(cmp(local("v0"), iValue(booleanValue(false))), "label1:");
	Statement s3 = assign(localVariable("v1"), immediate(iValue(intValue(1))));
	Statement s4 = gotoStmt("print");

	Statement s5 = label("label1:");
  	Statement s6 = assign(localVariable("v1"), immediate(iValue(intValue(2))));
  	Statement s7 = gotoStmt("print");

  	Statement s8 = label("print");
  	Statement s9 = returnStmt(local("v1"));

	list[Statement] stmts = [s1, s2, s3, s4, s5, s6, s7, s8, s9];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);
  	dominanceTree = createDominanceTree(flowGraph);

	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	
	result = insertPhiFunctions(flowGraph, dominanceFrontier);

	return result == {
	  <entryNode(),
	    stmtNode(assign(localVariable("v0"),immediate(iValue(booleanValue(false)))))>,  
	    
	  <stmtNode(assign(localVariable("v0"),immediate(iValue(booleanValue(false))))),
	  	stmtNode(ifStmt(cmp(local("v0"),iValue(booleanValue(false))),"label1:"))>,
	  	
	  <stmtNode(ifStmt(cmp(local("v0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(localVariable("v1"),immediate(iValue(intValue(2)))))>,
	    
	  <stmtNode(ifStmt(cmp(local("v0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(localVariable("v1"),immediate(iValue(intValue(1)))))>,
	    
	  <stmtNode(assign(localVariable("v1"),immediate(iValue(intValue(1))))),
	    stmtNode(assign(localVariable("v1"),phiFunction(localVariable("v1"),[])))>,
	    
	  <stmtNode(assign(localVariable("v1"),immediate(iValue(intValue(2))))),
	    stmtNode(assign(localVariable("v1"),phiFunction(localVariable("v1"),[])))>,
	      
	  <stmtNode(assign(localVariable("v1"),phiFunction(localVariable("v1"),[]))),
	    stmtNode(gotoStmt("print"))>,
	    
	  <stmtNode(gotoStmt("print")),
	    stmtNode(returnStmt(local("v1")))>,
	    
	  <stmtNode(returnStmt(local("v1"))),
	    exitNode()>
	};
}

test bool testPhiFunctionInsertionForArray() {
  	Statement s1 = assign(localVariable("v0"), immediate(iValue(intValue(1))));

	Statement s2 = ifStmt(cmp(local("v0"), iValue(booleanValue(false))), "label1:");
	Statement s3 = assign(arrayRef("v1", local("v0")), immediate(local("r0")));
	Statement s4 = gotoStmt("print");

	Statement s5 = label("label1:");
	Statement s6 = assign(arrayRef("v1", local("v0")), immediate(local("r1")));
  	Statement s7 = gotoStmt("print");

  	Statement s8 = label("print");
  	Statement s9 = returnStmt(local("v2"));

	list[Statement] stmts = [s1, s2, s3, s4, s5, s6, s7, s8, s9];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);

	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	
	result = insertPhiFunctions(flowGraph, dominanceFrontier);

	return result == {
	  <stmtNode(assign(arrayRef("v1",local("v0")),phiFunction(arrayRef("v1",local("v0")),[]))),
	    stmtNode(gotoStmt("print"))>,
	    
	  <entryNode(),
	    stmtNode(assign(localVariable("v0"),immediate(iValue(intValue(1)))))>,
	
	  <stmtNode(returnStmt(local("v2"))),
	    exitNode()>,
	
	  <stmtNode(assign(localVariable("v0"),immediate(iValue(intValue(1))))),
	    stmtNode(ifStmt(cmp(local("v0"),iValue(booleanValue(false))),"label1:"))>,
	
	  <stmtNode(gotoStmt("print")),
	    stmtNode(returnStmt(local("v2")))>,
	
	  <stmtNode(ifStmt(cmp(local("v0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(arrayRef("v1",local("v0")),immediate(local("r1"))))>,
	
	  <stmtNode(ifStmt(cmp(local("v0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(arrayRef("v1",local("v0")),immediate(local("r0"))))>,
	
	  <stmtNode(assign(arrayRef("v1",local("v0")),immediate(local("r1")))),
	    stmtNode(assign(arrayRef("v1",local("v0")),phiFunction(arrayRef("v1",local("v0")),[])))>,
	
	  <stmtNode(assign(arrayRef("v1",local("v0")),immediate(local("r0")))),
	    stmtNode(assign(arrayRef("v1",local("v0")),phiFunction(arrayRef("v1",local("v0")),[])))>
	};
}
