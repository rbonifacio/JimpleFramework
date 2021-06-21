module lang::jimple::decompiler::Decompiler

import lang::jimple::core::Syntax;
 
import IO;  

import Exception;

@javaClass{lang.jimple.internal.Decompiler}
@reflect{for stdout}
java ClassOrInterfaceDeclaration decompile(loc classFile) throws IO;



