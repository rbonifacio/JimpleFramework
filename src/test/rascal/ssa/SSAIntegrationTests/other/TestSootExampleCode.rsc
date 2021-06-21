module ssa::SSAIntegrationTests::other::TestSootExampleCode

import Set;
import lang::jimple::toolkit::FlowGraph;
import ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph;

test bool testSootSampleCodeMethod() {
	loc classFilePath = |project://JimpleFramework/target/test-classes/samples/ssa/other/SootExampleCode.class|;
	int methodToTest = 1;
	FlowGraph result = createClassFileSSAFlowGraph(classFilePath, methodToTest);

	return {
	  <entryNode(),
	    stmtNode(identity("r0","@this",TObject("samples.ssa.other.SootExampleCode")))>,
	    
	  <stmtNode(identity("r0","@this",TObject("samples.ssa.other.SootExampleCode"))),
	    stmtNode(assign(localVariable("r1_version-0"), phiFunction(localVariable("r1"),[localVariable("r1_version-1")])))>,
	
	  <stmtNode(assign(localVariable("r1_version-0"),phiFunction(localVariable("r1"),[localVariable("r1_version-1")]))),
	    stmtNode(assign(localVariable("r1_version-2"),immediate(iValue(intValue(100)))))>,
	    
	  <stmtNode(assign(localVariable("r1_version-0"),phiFunction(localVariable("r1"),[localVariable("r1_version-1")]))),
	    stmtNode(ifStmt(cmpeq(local("r1_version-0"),iValue(intValue(100))),"label1"))>,
	
	  <stmtNode(ifStmt(cmpeq(local("r1_version-0"),iValue(intValue(100))),"label1")),
	    stmtNode(gotoStmt("label3"))>,
	    
	  <stmtNode(ifStmt(cmpeq(local("r1_version-0"),iValue(intValue(100))),"label1")),
	    stmtNode(returnStmt(local("r1_version-2")))>,
	    
	  <stmtNode(ifStmt(cmpeq(local("r1_version-0"),iValue(intValue(100))),"label1")),
	    stmtNode(ifStmt(cmpge(local("r1_version-0"),iValue(intValue(200))),"label2"))>,
	
	  <stmtNode(assign(localVariable("r1_version-2"),immediate(iValue(intValue(100))))),
	    stmtNode(gotoStmt("label3"))>,
	
	  <stmtNode(assign(localVariable("r1_version-2"),immediate(iValue(intValue(100))))),
	    stmtNode(assign(localVariable("r1_version-0"),phiFunction(localVariable("r1"),[localVariable("r1_version-1")])))>,
	
	  <stmtNode(ifStmt(cmpge(local("r1_version-0"),iValue(intValue(200))),"label2")),
	    stmtNode(assign(localVariable("r1_version-1"),immediate(iValue(intValue(200)))))>,
	    
	  <stmtNode(ifStmt(cmpge(local("r1_version-0"),iValue(intValue(200))),"label2")),
	    stmtNode(assign(localVariable("r1_version-0"),phiFunction(localVariable("r1"),[localVariable("r1_version-1")])))>,
	
	  <stmtNode(assign(localVariable("r1_version-1"),immediate(iValue(intValue(200))))),
	    stmtNode(assign(localVariable("r1_version-0"),phiFunction(localVariable("r1"),[localVariable("r1_version-1")])))>,
	
	  <stmtNode(gotoStmt("label3")),
	    stmtNode(returnStmt(local("r1_version-2")))>,
	    
	  <stmtNode(returnStmt(local("r1_version-2"))),
	    exitNode()>
	};
}