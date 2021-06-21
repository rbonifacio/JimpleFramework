module ssa::TestVariableRenaming

import lang::jimple::toolkit::FlowGraph;
import lang::jimple::core::Syntax;
import lang::jimple::toolkit::ssa::DominanceTree;
import lang::jimple::toolkit::ssa::PhiFunctionInsertion;
import lang::jimple::toolkit::ssa::DominanceFrontier;
import lang::jimple::toolkit::ssa::VariableRenaming;

test bool testLeftHandSideImmediatesRename() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));
	Statement s2 = assign(localVariable("v1"), immediate(iValue(booleanValue(true))));

	list[Statement] stmts = [s1, s2];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);
  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);

	result = applyVariableRenaming(phiFunctionFlowGraph);

	return result == {
	  <entryNode(),stmtNode(assign(localVariable("v0_version-0"), immediate(iValue(booleanValue(false)))))>,
	  <stmtNode(assign(localVariable("v0_version-0"),immediate(iValue(booleanValue(false))))), stmtNode(assign(localVariable("v1_version-0"), immediate(iValue(booleanValue(true)))))>,
	  <stmtNode(assign(localVariable("v1_version-0"), immediate(iValue(booleanValue(true))))), exitNode()>
	};
}

test bool testRightHandSideImmediatesRename() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));
	Statement s2 = assign(localVariable("v1"), immediate(local("v0")));

	list[Statement] stmts = [s1, s2];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);
  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);

	result = applyVariableRenaming(phiFunctionFlowGraph);

	return result == {
	  <entryNode(),
	    stmtNode(assign( localVariable("v0_version-0"), immediate(iValue(booleanValue(false)))))>,
	  <stmtNode(assign(localVariable("v0_version-0"), immediate(iValue(booleanValue(false))))),
	    stmtNode(assign(localVariable("v1_version-0"), immediate(local("v0_version-0"))))>,
	  <stmtNode(assign(localVariable("v1_version-0"), immediate(local("v0_version-0")))),
	    exitNode()>
	};
}

test bool testRightHandMultipleImmediatesRename() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));
	Statement s2 = assign(localVariable("v0"), immediate(local("v0")));
	Statement s3 = assign(localVariable("v0"), immediate(local("v0")));

	list[Statement] stmts = [s1, s2];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);
  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);

	result = applyVariableRenaming(phiFunctionFlowGraph);

	return result == {
	  <entryNode(),
	      stmtNode(assign(localVariable("v0_version-0"),immediate(iValue(booleanValue(false)))))>,
	  <stmtNode(assign(localVariable("v0_version-0"),immediate(iValue(booleanValue(false))))),
	      stmtNode(assign(localVariable("v0_version-1"),immediate(local("v0_version-0"))))>,
	  <stmtNode(assign(localVariable("v0_version-1"),immediate(local("v0_version-0")))),
	      exitNode()>
	};
}

test bool testLeftHandMultipleImmediatesRename() {
	Statement s1 = assign(localVariable("v0"), immediate(iValue(booleanValue(false))));
	Statement s2 = assign(localVariable("v0"), immediate(iValue(booleanValue(true))));

	list[Statement] stmts = [s1, s2];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);
  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);

	result = applyVariableRenaming(phiFunctionFlowGraph);

	return result == {
	  <entryNode(),
	    stmtNode(assign(localVariable("v0_version-0"), immediate(iValue(booleanValue(false)))))>,
	  <stmtNode(assign(localVariable("v0_version-0"), immediate(iValue(booleanValue(false))))),
	    stmtNode(assign( localVariable("v0_version-1"), immediate(iValue(booleanValue(true)))))>,
	  <stmtNode(assign(localVariable("v0_version-1"), immediate(iValue(booleanValue(true))))),
	    exitNode()>
	};
}

test bool testPhiFunctionArgumentsRename() {
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
  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);

	result = applyVariableRenaming(phiFunctionFlowGraph);
	
	return result == {
	  <entryNode(),
	    stmtNode(assign(localVariable("v0_version-0"), immediate(iValue(booleanValue(false)))))>,
	
	  <stmtNode(assign(localVariable("v0_version-0"), immediate(iValue(booleanValue(false))))),
	    stmtNode(ifStmt(cmp(local("v0_version-0"), iValue(booleanValue(false))), "label1:"))>,
	
	  <stmtNode(ifStmt(cmp(local("v0_version-0"), iValue(booleanValue(false))), "label1:")),
	    stmtNode(assign(localVariable("v1_version-0"), immediate(iValue(intValue(2)))))>,
	
	  <stmtNode(assign(localVariable("v1_version-0"), immediate(iValue(intValue(2))))),
	    stmtNode(assign(localVariable("v1_version-1"), phiFunction( localVariable("v1"), [localVariable("v1_version-0"), localVariable("v1_version-2")])))>,
	
	  <stmtNode(ifStmt(cmp(local("v0_version-0"), iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(localVariable("v1_version-2"), immediate(iValue(intValue(1)))))>,
	  
	  <stmtNode(assign(localVariable("v1_version-2"), immediate(iValue(intValue(1))))),
	    stmtNode(assign(localVariable("v1_version-1"), phiFunction(localVariable("v1"), [localVariable("v1_version-0"), localVariable("v1_version-2")])))>,
	
	  <stmtNode(assign(localVariable("v1_version-1"),phiFunction(localVariable("v1"), [localVariable("v1_version-0"), localVariable("v1_version-2")]))),
	    stmtNode(gotoStmt("print"))>,
	      
	  <stmtNode(gotoStmt("print")),
	    stmtNode(returnStmt(local("v1_version-1")))>,
	
	  <stmtNode(returnStmt(local("v1_version-1"))),
	    exitNode()>
	};
}

test bool testPhiFunctionArrayArgumentsRename() {
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
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);

	result = applyVariableRenaming(phiFunctionFlowGraph);
	
	return result == {
	  <entryNode(),
	    stmtNode(assign(localVariable("v0_version-0"),immediate(iValue(intValue(1)))))>,
	
	  <stmtNode(assign(localVariable("v0_version-0"),immediate(iValue(intValue(1))))),
	    stmtNode(ifStmt(cmp(local("v0_version-0"),iValue(booleanValue(false))),"label1:"))>,
	
	  <stmtNode(ifStmt(cmp(local("v0_version-0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(arrayRef("v1_version-2",local("v0_version-0")),immediate(local("r0_version-0"))))>,
	  
	  <stmtNode(assign(arrayRef("v1_version-2",local("v0_version-0")),immediate(local("r0_version-0")))),
	    stmtNode(assign(arrayRef("v1_version-0",local("v0_version-0")),phiFunction(arrayRef("v1",local("v0")),[localVariable("v1_version-1"),localVariable("v1_version-2")])))>,
	
	  <stmtNode(ifStmt(cmp(local("v0_version-0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(arrayRef("v1_version-1",local("v0_version-0")),immediate(local("r1_version-0"))))>,
	
	  <stmtNode(assign(arrayRef("v1_version-1",local("v0_version-0")),immediate(local("r1_version-0")))),
	    stmtNode(assign(arrayRef("v1_version-0",local("v0_version-0")),phiFunction(arrayRef("v1",local("v0")),[localVariable("v1_version-1"),localVariable("v1_version-2")])))>,
	
	  <stmtNode(assign(arrayRef("v1_version-0",local("v0_version-0")),phiFunction(arrayRef("v1",local("v0")),[localVariable("v1_version-1"),localVariable("v1_version-2")]))),
	    stmtNode(gotoStmt("print"))>,
	
	  <stmtNode(gotoStmt("print")),
	    stmtNode(returnStmt(local("v2_version-0")))>,
	
	  <stmtNode(returnStmt(local("v2_version-0"))),
	    exitNode()>
	};
}


test bool testPhiFunctionArraySubsArgumentsRename() {
  	Statement s1 = assign(localVariable("v0"), immediate(iValue(intValue(1))));

	Statement s2 = ifStmt(cmp(local("v0"), iValue(booleanValue(false))), "label1:");
	Statement s3 = assign(arrayRef("v1", local("v0")), immediate(local("r0")));
	Statement s4 = gotoStmt("print");

	Statement s5 = label("label1:");
	Statement s6 = assign(arrayRef("v1", local("v0")), immediate(local("r1")));
  	Statement s7 = gotoStmt("print");

  	Statement s8 = label("print");
	Statement s9 = assign(localVariable("v3"), arraySubscript("v1", local("v0")));
  	Statement s10 = returnStmt(local("v3"));

	list[Statement] stmts = [s1, s2, s3, s4, s5, s6, s7, s8, s9, s10];

  	methodStatments = methodBody([], stmts, []);
  	flowGraph = forwardFlowGraph(methodStatments);
  	map[&T, set[&T]] dominanceTree = createDominanceTree(flowGraph);
  	map[&T, set[&T]] dominanceFrontier = createDominanceFrontier(flowGraph, dominanceTree);
	FlowGraph phiFunctionFlowGraph = insertPhiFunctions(flowGraph, dominanceFrontier);

	result = applyVariableRenaming(phiFunctionFlowGraph);
	
	return result == {
	  <entryNode(),
	    stmtNode(assign(localVariable("v0_version-0"),immediate(iValue(intValue(1)))))>,
	
	  <stmtNode(assign(localVariable("v0_version-0"),immediate(iValue(intValue(1))))),
	    stmtNode(ifStmt(cmp(local("v0_version-0"),iValue(booleanValue(false))),"label1:"))>,
	
	  <stmtNode(ifStmt(cmp(local("v0_version-0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(arrayRef("v1_version-2",local("v0_version-0")),immediate(local("r0_version-0"))))>,
	
	  <stmtNode(assign(arrayRef("v1_version-2",local("v0_version-0")),immediate(local("r0_version-0")))),
	    stmtNode(assign(arrayRef("v1_version-0",local("v0_version-0")),phiFunction(arrayRef("v1",local("v0")),[localVariable("v1_version-1"),localVariable("v1_version-2")])))>,
	
	  <stmtNode(ifStmt(cmp(local("v0_version-0"),iValue(booleanValue(false))),"label1:")),
	    stmtNode(assign(arrayRef("v1_version-1",local("v0_version-0")),immediate(local("r1_version-0"))))>,
	
	  <stmtNode(assign(arrayRef("v1_version-1",local("v0_version-0")),immediate(local("r1_version-0")))),
	    stmtNode(assign(arrayRef("v1_version-0",local("v0_version-0")),phiFunction(arrayRef("v1",local("v0")),[localVariable("v1_version-1"),localVariable("v1_version-2")])))>,
	
	  <stmtNode(assign(arrayRef("v1_version-0",local("v0_version-0")),phiFunction(arrayRef("v1",local("v0")),[localVariable("v1_version-1"),localVariable("v1_version-2")]))),
	    stmtNode(gotoStmt("print"))>,
	
	  <stmtNode(gotoStmt("print")),
	    stmtNode(assign(localVariable("v3_version-0"),arraySubscript("v1_version-0",local("v0_version-0"))))>,
	
	  <stmtNode(assign(localVariable("v3_version-0"),arraySubscript("v1_version-0",local("v0_version-0")))),
	    stmtNode(returnStmt(local("v3_version-0")))>,
	
	  <stmtNode(returnStmt(local("v3_version-0"))),
	    exitNode()>
	};
}