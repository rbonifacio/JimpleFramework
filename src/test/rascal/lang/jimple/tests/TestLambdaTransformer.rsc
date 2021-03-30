module lang::jimple::tests::TestLambdaTransformer

import lang::jimple::core::Syntax; 
import lang::jimple::decompiler::Decompiler;
import lang::jimple::decompiler::jimplify::LambdaTransformer;
import lang::jimple::util::JPrettyPrinter; 
 
import List; 
import IO;

loc classLocation = |project://JimpleFramework/target/test-classes/samples/SimpleLambdaExpression.class|;  
//loc classLocation = |project://JimpleFramework/target/test-classes/samples/arrays/ArrayExample.class|;

test bool testLambdaTransformer() { 
  ClassOrInterfaceDeclaration c = decompile(classLocation);
  
  println(prettyPrint(c));
  
  list[ClassOrInterfaceDeclaration] classes = lambdaTransformer(c);
  
  for(ClassOrInterfaceDeclaration aClass <- classes) {
  	println(prettyPrint(aClass));
  	println(aClass);	//abstract syntax tree
  }
  
  return size(classes) == 2; 
}