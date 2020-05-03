module lang::jimple::internal::RascalJimpleConverter

import IO;
import Map; 
import List;
import String; 

import ParseTree; 
import lang::rascal::\syntax::Rascal; 

/**
 * from a Rascal module, it exports a set 
 * of Java classes corresponding to the algebraic 
 * data types. 
 */
public void generateJavaCode(loc location) {
  Module m = parse(#Module, location);
  map[str, str] aliases = collectAliases(m); 	
  generateCode(m, aliases);
}

private map[str, str] collectAliases(Module m) {
   map[str, str] aliases = (); 
   top-down visit(m) {
	 case (Declaration)`alias <UserType t> = <Type b>;`: aliases[unparse(t)] = unparse(b);
   }
   return aliases; 
}

private void generateCode(Module m, map[str, str] aliases) {
	top-down visit(m) {
	  case (Declaration)`<Visibility v> data <UserType t> = <{Variant "|"}+ variants>;`: generateClass(aliases, t, variants);
	}
}

private void generateClass(map[str, str] aliases, UserType t, {Variant "|"}+ variants) {
  str code = "package lang.jimple.internal.generated;
             '
             'import lang.jimple.internal.AbstractJimpleConstructor; 
             'import java.util.List; 
             'import java.util.HashMap;
             '
             'import io.usethesource.vallang.IConstructor;
             'import io.usethesource.vallang.IList;
             'import io.usethesource.vallang.IValue;
             'import io.usethesource.vallang.impl.fast.ValueFactory; 
             '
             'public abstract class <unparse(t)> extends AbstractJimpleConstructor {
             '   @Override 
             '   public String getBaseType() { 
             '     return \"<unparse(t)>\";
             '   } 
             '
             '   <for(Variant v <- variants) {>
             '   <generateFactory(aliases, unparse(t), v)>
             '   <}> 
             '
             '   <for(Variant v <- variants) {>
             '   <generateSubClass(aliases, unparse(t), v)>
             '   <}> 
             '}"; 
  
  str classFileName = unparse(t) + ".java"; 
  writeFile(|project://JimpleFramework/src/lang/jimple/internal/generated| + classFileName, code);            
}

private str generateFactory(map[str, str] aliases, str base, Variant v) {
   str code = ""; 
   switch(v) {
     case (Variant)`<Name n>(<{TypeArg ","}* arguments>)` : 
       code = "public static <base> <n>(<intercalate(", ", [generateAttribute(aliases, arg) | TypeArg arg <- arguments])>)  {
              '  return new c_<n>(<intercalate(", ", [generateAttributeName(arg) | TypeArg arg <- arguments])>);
              '}"; 
   }
   return code;  
}

private str generateSubClass(map[str, str] aliases, str base, Variant v) {
   str code = ""; 
   switch(v) {
     case (Variant)`<Name n>(<{TypeArg ","}* arguments>)` : 
       code = "static class c_<n> extends <base> {
              '  <for(TypeArg arg <- arguments){>
              '  <generateAttribute(aliases, arg)>;
              '  <}>
              '
              '  public c_<n>(<intercalate(", ", [generateAttribute(aliases, arg) | TypeArg arg <- arguments])>) {
              '   <for(TypeArg arg <-arguments){>
              '     this.<generateAttributeName(arg)> = <generateAttributeName(arg)>;  
              '   <}>  
              '  }
              '  
              '  @Override
              '  public IConstructor createVallangInstance(ValueFactory vf) {
              '    HashMap\<String, IValue\> map = new HashMap\<\>();
              '
              '    <for(TypeArg arg <- arguments){>
              '    <populateMap(aliases, arg)>
              '    <}>
              '    
              '    return vf.constructor(getVallangConstructor())
              '             .asWithKeywordParameters()
              '             .setParameters(map);
              '  }
              '  @Override
              '  public String getConstructor() {
              '    return \"<n>\";
              '  }
              '}"; 
   }
   return code; 
}

private str generateAttribute(map[str, str] aliases, TypeArg arg) { 
  switch(arg) {
    case (TypeArg)`<Type t> <Name n>`: return resolve(aliases, unparse(t)) + " " + unparse(n); 
    default: return ""; 
  } 
}

private str generateAttributeName(TypeArg arg) { 
  switch(arg) {
    case (TypeArg)`<Type _> <Name n>`: return unparse(n); 
    default: return ""; 
  } 
}

private str populateMap(map[str, str] aliases, TypeArg arg) {
  switch(arg) {
    case (TypeArg)`<Type t> <Name n>`: 
      switch(t) {
        case (Type)`str` : return populateBasicType("str", unparse(n));
        case (Type)`int` : return populateBasicType("int", unparse(n));
        case (Type)`bool`: return  populateBasicType("bool", unparse(n));
        case (Type)`real`: return populateBasicType("real", unparse(n));
        case (Type)`list[<TypeArg base>]`: return populateListType(aliases, unparse(base), unparse(n)); 
        default: return populateUserDefinedType(aliases, unparse(t), unparse(n)); 
      }
    default: return "error exporting the source code";  
  }
}

private str populateBasicType("str", str n)   = "map.put(\"<n>\", vf.string(<n>));";
private str populateBasicType("int", str n)   = "map.put(\"<n>\", vf.integer(<n>));";
private str populateBasicType("bool", str n)  = "map.put(\"<n>\", vf.bool(<n>));";
private str populateBasicType("real", str n)  = "map.put(\"<n>\", vf.real(<n>));";

private str populateUserDefinedType(map[str, str] aliases, str base, str n) {
 str val = ""; 
 switch(resolve(aliases, base)) {
   case "String"  : val = "vf.string(<n>)";
   case "Integer" : val = "vf.integer(<n>)";
   case "Boolean" : val = "vf.boolean(<n>)";
   case "Real"    : val = "vf.real(<n>)";
   default        : val = "<n>.createVallangInstance(vf)"; 
 }
 return "map.put(\"<n>\", <val>);"; 
}

private str populateListType(map[str, str] aliases, str base, str n) {
 str val = ""; 
 switch(resolve(aliases, base)) {
   case "String"  : val = "vf.string(v)";
   case "Integer" : val = "vf.integer(v)";
   case "Boolean" : val = "vf.boolean(v)";
   case "Real"    : val = "vf.real(v)";
   default        : val = "v.createVallangInstance(vf)"; 
 }
 return "IList <n>_list = vf.list();
        '
        'for(<base> v: <n>) {
        ' <n>_list = <n>_list.append(<val>);   
        '}
        'map.put(\"<n>\", <n>_list);
        "; 
}




private str resolve(map[str, str] aliases, str t) {
  if(t in aliases) {
    t = aliases[t]; 
  } 
  if(startsWith(t, "list["))  {
     t = replaceAll(t, "list[", "List\<");
     t = replaceAll(t, "]", "\>"); 
  }
  switch(t) {
    case "str" : return "String"; 
    case "int" : return "Integer";
    case "bool": return "Boolean";  
    case "real": return "Float"; 
    default: return replaceAll(t, "\\", "");
  }
}
