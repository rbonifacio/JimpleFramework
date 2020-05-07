package lang.jimple.internal.generated;

import java.util.List;

import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.IList;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import lang.jimple.internal.JimpleAbstractDataType; 

public abstract class MethodSignature extends JimpleAbstractDataType {
    public String className;
    public Type returnType;
    public List<Type> formals;
    
	
   @Override 
   public String getBaseType() { 
     return "MethodSignature";
   } 

   
   public static MethodSignature methodSignature(String className, Type returnType, List<Type> formals)  {
     return new c_methodSignature(className, returnType, formals);
   }
    

   
   public static class c_methodSignature extends MethodSignature {
     
     
   
     public c_methodSignature(String className, Type returnType, List<Type> formals) {
      
        this.className = className;  
      
        this.returnType = returnType;  
      
        this.formals = formals;  
        
     }
     
     @Override
     public IConstructor createVallangInstance(IValueFactory vf) {
   
       
       IValue iv_className = vf.string(className);
       
       IValue iv_returnType = returnType.createVallangInstance(vf);
       
       IList iv_formals = vf.list();
       
       for(Type v: formals) {
        iv_formals = iv_formals.append(v.createVallangInstance(vf));   
       }
               
       
       
       return vf.constructor(getVallangConstructor()
                
                , iv_className 
                
                , iv_returnType 
                
                , iv_formals 
                
                ); 
     }
     @Override
     public String getConstructor() {
       return "methodSignature";
     }
   }
    
}