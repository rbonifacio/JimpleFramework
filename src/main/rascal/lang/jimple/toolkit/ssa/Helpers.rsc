module lang::jimple::toolkit::ssa::Helpers

import Node;
import Type;
import List;

import lang::jimple::toolkit::FlowGraph;
import lang::jimple::core::Syntax;

public Variable returnStmtVariable(Node graphNode) {
	assignStatement = returnStmtNodeBody(graphNode);
	variableArg = assignStatement[0];

	switch(variableArg) {
		case Variable variable: return variable;
	}
}

public Statement returnStmtNodeBody(Node stmtNode) {
	switch(stmtNode) {
		case stmtNode(stmtBody): return stmtBody;
	}
}

public Variable returnPhiFunctionLeftHandSide(Expression phiFunctionExpr) {
	switch(phiFunctionExpr) {
		case phiFunction(leftHandSide, _): return leftHandSide;
	}
}

public list[Variable] returnPhiFunctionRightHandSide(Expression phiFunctionExpr) {
	switch(phiFunctionExpr) {
		case phiFunction(_, rightHandSide): return rightHandSide;
	}
}

public Variable returnLeftHandSideVariable(Node stmtNode) {
	switch(stmtNode) {
		case stmtNode(assign(leftHandSide, _)): return leftHandSide;
	}
}

public Expression returnRightHandSideExpression(Node stmtNode) {
	switch(stmtNode) {
		case stmtNode(assign(_, rightHandSide)): return rightHandSide;
	}
}

public String returnVariableImmediateName(Immediate immediate) {
	switch(immediate) {
		case local(String localName): return localName;
		default: return "";
	}
}

public String returnImmediateName(Immediate immediate) {
	switch(immediate[0]) {
		case String immediateName: return immediateName;
	}
}

public list[Immediate] returnRightHandSideImmediates(Node variableNode) {
	rightHandSide = returnRightHandSideExpression(variableNode);
	typeOfVariableArg = typeOf(rightHandSide);

	if(typeOfVariableArg.name != "Expression") return [];

	list[Immediate] immediates = returnExpressionImmediates(rightHandSide);
	list[Immediate] localVariableImmediates = [ immediate | immediate <- immediates, returnVariableImmediateName(immediate) != ""];
	int variablesCount = size(localVariableImmediates);

	if(variablesCount != 0) return localVariableImmediates;

	return [];
}

public list[Immediate] returnExpressionImmediates(Expression expression) {
	switch(expression) {
	  case newInstance(Type instanceType): return [];
	  case newArray(Type baseType, list[ArrayDescriptor] dims): return [];
	  case cast(Type toType, local(name)): return [];
	  case instanceOf(Type baseType, local(name)): return [local(name)];
	  case invokeExp(_): return [];
	  case arraySubscript(Name arrayName, _): return [local(arrayName)];
	  case stringSubscript(String stringName, local(name)): return [local(stringName)];
	  case localFieldRef(Name local, Name className, Type fieldType, Name fieldName): return [];
	  case fieldRef(Name className, Type fieldType, Name fieldName): return [];
	  case and(lhs, rhs): return [lhs, rhs];
	  case or(lhs, rhs): return [lhs, rhs];
	  case xor(lhs, rhs): return [lhs, rhs];
	  case reminder(lhs, rhs): return [lhs, rhs];
	  case isNull(variable): return [variable];
	  case isNotNull(variable): return [variable];
	  case cmp(lhs, rhs): return [lhs, rhs];
	  case cmpg(lhs, rhs): return [lhs, rhs];
	  case cmpl(lhs, rhs): return [lhs, rhs];
	  case cmpeq(lhs, rhs): return [lhs, rhs];
	  case cmpne(lhs, rhs): return [lhs, rhs];
	  case cmpgt(lhs, rhs): return [lhs, rhs];
	  case cmpge(lhs, rhs): return [lhs, rhs];
	  case cmplt(lhs, rhs): return [lhs, rhs];
	  case cmple(lhs, rhs): return [lhs, rhs];
	  case shl(lhs, rhs): return [lhs, rhs];
	  case shr(lhs, rhs): return [lhs, rhs];
	  case ushr(lhs, rhs): return [lhs, rhs];
	  case plus(lhs, rhs): return [lhs, rhs];
	  case minus(lhs, rhs): return [lhs, rhs];
	  case mult(lhs, rhs): return [lhs, rhs];
	  case div(lhs, rhs): return [lhs, rhs];
	  case lengthOf(local(name)): return [local(name)];
	  case neg(local(name)): return [local(name)];
	  case immediate(local(name)): return [local(name)];
	  default: return [];
	}
}
