module ssa::SSAIntegrationTests::util::CreateClassfileSSAFlowGraph

import List;
import Type;
import Set;

import analysis::graphs::Graph;

import lang::jimple::decompiler::Decompiler;
import lang::jimple::decompiler::jimplify::ProcessLabels;
import lang::jimple::core::Context;
import lang::jimple::toolkit::FlowGraph;
import lang::jimple::core::Syntax;

import lang::jimple::toolkit::ssa::Generator;

public FlowGraph createClassFileSSAFlowGraph(loc classFilePath, int methodToReturn) {
	loc classFilePath = classFilePath;
	ClassOrInterfaceDeclaration classFileDeclaration = decompile(classFilePath);
	classFileDeclaration = processJimpleLabels(classFileDeclaration);
	list[Method] methodList = castMethodList(classFileDeclaration);	
	MethodBody methodBody = castMethodBody(methodList[methodToReturn]);
	
	return applySSATransformation(methodBody);
}

private list[Method] castMethodList(ClassOrInterfaceDeclaration declaration) {
	switch(declaration[5]) {
		case list[Method] methodList : return methodList;
	}
}

private MethodBody castMethodBody(Method method) {
	switch(method[5]) {
		case MethodBody methodBody : return methodBody;
	}
}