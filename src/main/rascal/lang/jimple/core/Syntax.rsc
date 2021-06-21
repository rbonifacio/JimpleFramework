module lang::jimple::core::Syntax

alias String = str;
alias Int = int; 
alias Long = int; 
alias Float = real;
alias Double = real;  
alias Name = str;
alias Label = str;
alias Identifier = str; 

data Value 
 = intValue(Int iv)
 | longValue(Long lv)
 | floatValue(Float fv)
 | doubleValue(Double fv)
 | stringValue(String sv)
 | booleanValue(bool bl)
 | methodValue(Type returnType, list[Type] formals)
 | classValue(str name)
 | methodHandle(MethodSignature methodSig)
 | fieldHandle(FieldSignature fieldSig)
 | nullValue()
 ; 
 
data Immediate 
 = local(String localName) 
 | iValue(Value v) 
 | caughtException()
 ; 
 
public data ClassOrInterfaceDeclaration 
 = classDecl(Type typeName,
     list[Modifier] modifiers,
     Type superClass,
     list[Type] interfaces,
     list[Field] fields,
     list[Method] methods
   ) 
 | interfaceDecl(Type typeName,
     list[Modifier] modifiers, 
     list[Type] interfaces, 
     list[Field] fields,
     list[Method] methods
   );    
 

public data Field 
  = field(list[Modifier] modifiers, Type fieldType, Name name)
  ;  

public data Method 
  = method(list[Modifier] modifiers, Type returnType, Name name, list[Type] formals, list[Type] exceptions, MethodBody body)
  ;
  
      
data MethodBody 
  = methodBody(list[LocalVariableDeclaration] localVariableDecls, list[Statement] stmts, list[CatchClause] catchClauses)
  | signatureOnly()
  ; 

data LocalVariableDeclaration 
  = localVariableDeclaration(Type varType, Identifier local)
  ; 

data CatchClause 
 = catchClause(Type exception, Label from, Label to, Label with)
 ; 
 
data Variable 
 = localVariable(Name local)
 | arrayRef(Name reference, Immediate idx)
 | fieldRef(Name reference, FieldSignature field)
 | staticFieldRef(FieldSignature field)
 ;  
 
data Statement(String methodSignature = "", int startLine = -1, int endLine = -1)  
  = label(Label label)  
  | breakpoint()
  | enterMonitor(Immediate immediate)
  | exitMonitor(Immediate immediate)
  | tableSwitch(Immediate immediate, int min, int max, list[CaseStmt] stmts)
  | lookupSwitch(Immediate immediate, list[CaseStmt] stmts)
  | identity(Name local, Name identifier, Type idType)
  | identityNoType(Name local, Name identifier)
  | assign(Variable var, Expression expression)
  | ifStmt(Expression exp, Label target)
  | retEmptyStmt()
  | retStmt(Immediate immediate)
  | returnEmptyStmt() 
  | returnStmt(Immediate immediate)
  | throwStmt(Immediate immediate)
  | invokeStmt(InvokeExp invokeExpression)
  | gotoStmt(Label target)
  | nop()
  ;        
 
 data CaseStmt 
   = caseOption(Int option, Label targetStmt) 
   | defaultOption(Label targetStmt)
   ; 

data Expression 
  = newInstance(Type instanceType)
  | newArray(Type baseType, list[ArrayDescriptor] dims)
  | cast(Type toType, Immediate immeadiate)
  | instanceOf(Type baseType, Immediate immediate)
  | invokeExp(InvokeExp expression)
  | arraySubscript(Name name, Immediate immediate)
  | stringSubscript(String string, Immediate immediate)
  | localFieldRef(Name local, Name className, Type fieldType, Name fieldName)
  | fieldRef(Name className, Type fieldType, Name fieldName)
  | and(Immediate lhs, Immediate rhs)
  | or(Immediate lhs, Immediate rhs)
  | xor(Immediate lhs, Immediate rhs)
  | reminder(Immediate lhs, Immediate rhs)
  | isNull(Immediate immediate)
  | isNotNull(Immediate immediate)
  | cmp(Immediate lhs, Immediate rhs) 
  | cmpg(Immediate lhs, Immediate rhs) 
  | cmpl(Immediate lhs, Immediate rhs)
  | cmpeq(Immediate lhs, Immediate rhs) 
  | cmpne(Immediate lhs, Immediate rhs) 
  | cmpgt(Immediate lhs, Immediate rhs) 
  | cmpge(Immediate lhs, Immediate rhs)
  | cmplt(Immediate lhs, Immediate rhs) 
  | cmple(Immediate lhs, Immediate rhs)
  | shl(Immediate lhs, Immediate rhs) 
  | shr(Immediate lhs, Immediate rhs) 
  | ushr(Immediate lhs, Immediate rhs)
  | plus(Immediate lhs, Immediate rhs) 
  | minus(Immediate lhs, Immediate rhs) 
  | mult(Immediate lhs, Immediate rhs) 
  | div(Immediate lhs, Immediate rhs)
  | lengthOf(Immediate immediate)
  | neg(Immediate immediate) 
  | immediate(Immediate immediate)
  | phiFunction(Variable variable, list[Variable] definitions)
  ;
  
data ArrayDescriptor 
  = fixedSize(Int size)
  | variableSize() 
  ;
  
data InvokeExp
  = specialInvoke(Name local, MethodSignature sig, list[Immediate] args)
  | virtualInvoke(Name local, MethodSignature sig, list[Immediate] args)
  | interfaceInvoke(Name local, MethodSignature sig, list[Immediate] args)
  | staticMethodInvoke(MethodSignature sig, list[Immediate] args)
  | dynamicInvoke(MethodSignature bsmSig, list[Immediate] bsmArgs, MethodSignature sig, list[Immediate] args)
  ;   

data FieldSignature 
  = fieldSignature(Name className, Type fieldType, Name fieldName)
  ; 
  
data MethodSignature 
  = methodSignature(Name className, Type returnType, Name methodName, list[Type] formals)
  ; 
  
data UnnamedMethodSignature 
  = unnamedMethodSignature(Type returnType, list[Type] formals)
  ;   
    
data Modifier 
  = Public()
  | Protected()
  | Private()  
  | Abstract()
  | Static()  
  | Final()
  | Synchronized()  
  | Native() 
  | Strictfp() 
  | Transient() 
  | Volatile() 
  | Enum() 
  | Annotation()
  | Synthetic()        // handle invoke dynamic call with lambda expressions.
  ;
  
/**
 * I think that we will have to review this 
 * type declaration.  
 */  
data Type
  = TByte()
  | TBoolean()
  | TShort()
  | TCharacter()
  | TInteger()
  | TFloat()
  | TDouble()
  | TLong()
  | TObject(Name name)  
  | TArray(Type baseType)
  | TVoid()
  | TString()
  | TMethodValue()
  | TClassValue()
  | TMethodHandle()
  | TFieldHandle()
  | TNull()
  | TUnknown()            // it might be useful in the first phase of Jimple Body creation 
  ;  
  
Type object() = TObject("java.lang.Object");