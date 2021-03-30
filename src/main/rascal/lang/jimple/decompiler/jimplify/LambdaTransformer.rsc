module lang::jimple::decompiler::jimplify::LambdaTransformer

import lang::jimple::core::Syntax;

import String;
import List;

alias CID = ClassOrInterfaceDeclaration;

str bootstrapMethod = "bootstrap$";

public list[ClassOrInterfaceDeclaration] lambdaTransformer(ClassOrInterfaceDeclaration c) {
  list[ClassOrInterfaceDeclaration] classes = [];
  
  c = visit(c) {	//add LambdaMetafactory verification(in the indy's first argument)
    	
    //Accumulating Transformer: traverse the tree, collect information and also transform tree.
	case dynamicInvoke(_, bsmArgs, sig, args): {
		classes += generateBootstrapClass(bsmArgs, sig);
		MethodSignature mh = methodSignature(bsmArgs[1]);
		//iValue(methodHandle(mh)) := bsmArgs[1];
		insert generateStaticInvokeExp(mh, sig, args);
	}
	
  }
  classes += c;
  return classes; 
}

private InvokeExp generateStaticInvokeExp(MethodSignature sig1, MethodSignature sig2, list[Immediate] args) {
  MethodSignature sig = methodSignature("<split("/", className(sig1))[1]>$<methodName(sig1)>", returnType(sig2), bootstrapMethod, formals(sig2)); 
    
  return staticMethodInvoke(sig, args);
}

private CID generateBootstrapClass(list[Immediate] bsmArgs, MethodSignature bsmSig) {
	
	MethodSignature targetSig = methodSignature(bsmArgs[1]);	
	
	str bsmClassName = "<split("/", className(targetSig))[1]>$<methodName(targetSig)>";
	
	MethodSignature bootstrapSig = methodSignature(bsmClassName, TVoid(), "\<init\>", formals(bsmSig)); 
	
	MethodSignature initSig = methodSignature("java.lang.Object", TVoid(), "\<init\>", []);
	
	list[Immediate] lambdaArgs = [];
			
	//MethodBody local variable declarations	
	list[LocalVariableDeclaration] bsmLocals = generateLocalVarDecls(formals(bsmSig), 0)	//class attribute vars
											   + generateLocalVarDecls([TObject(bsmClassName)], size(formals(bsmSig))); //thisClass var
												
	list[LocalVariableDeclaration] initLocals = generateLocalVarDecls([TObject(bsmClassName)], 0)	//thisClass var
												+ generateLocalVarDecls(formals(bsmSig), 1);	//class attribute vars
	
	list[LocalVariableDeclaration] targetLocals = generateLocalVarDecls([TObject(bsmClassName)], 0)		//thisClass var
												  + generateLocalVarDecls(valueFormals(bsmArgs[0]), 1)		//method param vars (Object)
												  + generateLocalVarDecls(valueFormals(bsmArgs[2]), size(valueFormals(bsmArgs[0]))+1)		//method param true type vars
												  + generateLocalVarDecls(formals(bsmSig), size(valueFormals(bsmArgs[0]))+size(valueFormals(bsmArgs[2]))+1);		//class attribute vars
	if(returnType(targetSig) != TVoid())
		targetLocals += [localVariableDeclaration(returnType(targetSig), "$i0")];
	
	//MethodBody statements
	//instantiation "fase"
	list[Statement] bsmStmts = instantiateParameters(formals(bsmSig), 0) 
								+ [assign(localVariable("$r<size(formals(bsmSig))>"), newInstance(TObject(bsmClassName)))];
	
	list[Statement] initStmts = [identity("$r0", "@this", TObject(bsmClassName))] 
								+ instantiateParameters(formals(bsmSig), 1);
	
	list[Statement] targetStmts = [identity("$r0", "@this", TObject(bsmClassName))] 
								+ instantiateParameters(valueFormals(bsmArgs[0]), 1);
	
	//BSM STATEMENTS
	list[Immediate] bsmParams = [local(localVariable(decl))|decl <- prefix(bsmLocals)];
	
	bsmStmts += invokeStmt(specialInvoke(localVariable(last(bsmLocals)), bootstrapSig, bsmParams));
	bsmStmts += returnStmt(local(localVariable(last(bsmLocals))));
	
	//INIT STATEMENTS
	initStmts += invokeStmt(specialInvoke("$r0", initSig, []));
	//fieldRef assignment
	list[Immediate] initParams = [local(localVariable(decl))|decl <- tail(initLocals)];
	
	for(int i <- [0..size(initParams)]) {
		FieldSignature fieldSig = fieldSignature(bsmClassName, formals(bsmSig)[i], "cap<i>");
		initStmts += assign(fieldRef("$r0", fieldSig), immediate(initParams[i]));
	}
	
	initStmts += returnEmptyStmt();
	//TARGET STATEMENTS
	//1st cast 							
	for(int i <- [0..size(valueFormals(bsmArgs[2]))]) {
		targetStmts += assign(localVariable("$r<i+size(valueFormals(bsmArgs[0])+1)>"), cast(valueFormals(bsmArgs[2])[i], local("$r<i+1>")));
		lambdaArgs += local("$r<i+size(valueFormals(bsmArgs[0])+1)>");
	}
	
	//2nd localFieldRef
	int n = size(valueFormals(bsmArgs[2]))*2;
	for(int i <- [0..size(formals(bsmSig))]){
		Expression lfr = localFieldRef("$r0", bsmClassName, formals(bsmSig)[i], "cap<i>");
		targetStmts += assign(localVariable("$r<n+1>"), lfr);
		lambdaArgs += local("$r<i+size(valueFormals(bsmArgs[0])+1)>");
	}
	
	//invoke lambdaMethod
	if(returnType(methodSignature(bsmArgs[1]))==TVoid()){
		targetStmts += invokeStmt(staticMethodInvoke(methodSignature(bsmArgs[1]), lambdaArgs));
		targetStmts += returnEmptyStmt();
	} else {
		targetStmts += assign(localVariable("$i0"), invokeExp(staticMethodInvoke(methodSignature(bsmArgs[1]), lambdaArgs)));
		targetStmts += returnStmt(local("$i0"));
	}
	
	
	//Method bodies
	MethodBody bsmBody = methodBody(bsmLocals, bsmStmts, []);
	MethodBody initBody = methodBody(initLocals, initStmts, []);
	MethodBody targetBody = methodBody(targetLocals, targetStmts, []);
	
	//Methods
	Method bsm = method([Public(), Static()],	// list[Modifiers] modifiers
						returnType(bsmSig),		// Type returnType
						"bootstrap$", 			// Name name
						formals(bsmSig), 		// list[Type] formals
						[], 					// list[Type] exceptions	//TODO!
						bsmBody);				// MethodBody body
	
	Method initMethod = method([Public(), Static()], 
						TVoid(), 
						"\<init\>", 
						formals(bsmSig),
						[],
						initBody);
	
						
	Method targetMethod = method([Public(), Static()], 
						  returnType(targetSig), 
						  methodName(bsmSig), 
						  valueFormals(bsmArgs[0]),
						  [],
						  targetBody);
	
		
	CID bsmClass = classDecl(TObject(bsmClassName), // Type typeName
							[Public(), Final()],	// list[Modifiers] modifiers
							object(), 				// Type superClass
							[returnType(bsmSig)],	// list[Type] interfaces
							getFields(bsmSig),		// list[Fields] fields
							[bsm, initMethod, targetMethod]);		// list[Method] methods

	return bsmClass;
}

list[Field] getFields(MethodSignature sig){
	list[Field] fields = [];
	
	for(int i <- [0..size(formals(sig))]){
		fields += field([], formals(sig)[i], "cap<i>");
	}
	
	return fields;
}

list[LocalVariableDeclaration] generateLocalVarDecls(list[Type] frmls, int n){
	list[LocalVariableDeclaration] localVarDecls = [];
	
	for(int i <- [0..size(frmls)]){
		localVarDecls += localVariableDeclaration(frmls[i], "$r<i+n>");
	}
	
	return localVarDecls;
}

list[Statement] instantiateParameters(list[Type] frmls, int n){
	list[Statement] stmts = [];
	
	for(int i <- [0..size(frmls)]){
		stmts += identity("$r<i+n>", "@parameter<i>", frmls[i]);
	}
	
	return stmts;
}


private str className(methodSignature(name, _, _, _)) = name;
private str methodName(methodSignature(_, _, name,_)) = name;
private Type returnType(methodSignature(_, aType, _, _)) = aType; 
private list[Type] formals(methodSignature(_, _, _, formalArgs)) = formalArgs;
private list[Type] valueFormals(iValue(methodValue(_, formalArgs))) = formalArgs;
private MethodSignature methodSignature(iValue(methodHandle(mh))) = mh;
private Identifier localVariable(localVariableDeclaration(_, local)) = local;


