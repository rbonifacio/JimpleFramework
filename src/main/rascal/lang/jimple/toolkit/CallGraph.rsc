module lang::jimple::toolkit::CallGraph

import lang::jimple::core::Context; 
import lang::jimple::Syntax; 

import List; 
import Map; 
import IO; 

alias MethodMap = map[str, str]; 

alias CG = rel[str, str];

data CGModel = CGModel(CG cg, MethodMap methodMap);

CGModel emptyModel = CGModel({}, ()); 

CGModel computeCallGraph(ExecutionContext ctx) {
   cg = emptyModel; 
   
   map[Type, list[Method]] methods = (); 
   
   top-down visit(ctx) {
     case classDecl(n, _, _, _, _, mss): methods[n] = mss; 
   }  
   
   for(c <- methods) {
     println("goo");
   	 cg = computeCallGraph(c, methods[c], cg);
   }  	
   	
   return cg;
}

CGModel computeCallGraph(_, [], CGModel model) = model;

CGModel computeCallGraph(TObject(cn), [method(_, _, mn, args, _, body), *ms], CGModel model) {
  
  mm = model.methodMap; 
  cg = model.cg; 
  
  str sig1 = methodSignature(cn, mn, args);
  
  if(! (sig1 in mm)) {
  	mm[sig1] = "M" + "<size(mm) + 1>"; 
  }
  
  top-down visit(body) {
    case virtualInvoke(_, sig, _): {
      sig2 = methodSignature(sig); 
      if(! (sig2 in mm)) {
        mm[sig2] = "M" + "<size(mm) + 1>"; 
      }
      cg = cg + <mm[sig1], mm[sig2]>;     
    } 
  }
  
  return computeCallGraph(TObject(cn), ms, CGModel(cg, mm)); 
}

str methodSignature(methodSignature(cn, _, mn, args)) = methodSignature(cn, mn, args); 

str methodSignature(Name cn, Name mn, args) =  "<cn>.<mn>(<intercalate(",", args)>)";