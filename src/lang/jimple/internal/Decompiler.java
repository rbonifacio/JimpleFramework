package lang.jimple.internal;

import static lang.jimple.internal.JimpleObjectFactory.assignmentStmt;
import static lang.jimple.internal.JimpleObjectFactory.isInterface;
import static lang.jimple.internal.JimpleObjectFactory.methodSignature;
import static lang.jimple.internal.JimpleObjectFactory.modifiers;
import static lang.jimple.internal.JimpleObjectFactory.newArraySubscript;
import static lang.jimple.internal.JimpleObjectFactory.newDivExpression;
import static lang.jimple.internal.JimpleObjectFactory.newIntValueImmediate;
import static lang.jimple.internal.JimpleObjectFactory.newLocalImmediate;
import static lang.jimple.internal.JimpleObjectFactory.newMinusExpression;
import static lang.jimple.internal.JimpleObjectFactory.newMultExpression;
import static lang.jimple.internal.JimpleObjectFactory.newPlusExpression;
import static lang.jimple.internal.JimpleObjectFactory.newReminderExpression;
import static lang.jimple.internal.JimpleObjectFactory.objectConstructor;
import static lang.jimple.internal.JimpleObjectFactory.type;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Stack;

import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.FieldVisitor;
import org.objectweb.asm.Handle;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;
import org.objectweb.asm.tree.AbstractInsnNode;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.LocalVariableNode;
import org.objectweb.asm.tree.MethodNode;
import org.objectweb.asm.tree.TryCatchBlockNode;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.uri.URIResolverRegistry;

import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.ISourceLocation;
import io.usethesource.vallang.IValueFactory;
import lang.jimple.internal.generated.ArrayDescriptor;
import lang.jimple.internal.generated.CatchClause;
import lang.jimple.internal.generated.ClassOrInterfaceDeclaration;
import lang.jimple.internal.generated.Expression;
import lang.jimple.internal.generated.Field;
import lang.jimple.internal.generated.FieldSignature;
import lang.jimple.internal.generated.Immediate;
import lang.jimple.internal.generated.InvokeExp;
import lang.jimple.internal.generated.LocalVariableDeclaration;
import lang.jimple.internal.generated.Method;
import lang.jimple.internal.generated.MethodBody;
import lang.jimple.internal.generated.MethodSignature;
import lang.jimple.internal.generated.Modifier;
import lang.jimple.internal.generated.Statement;
import lang.jimple.internal.generated.Type;
import lang.jimple.internal.generated.Variable;

/**
 * Decompiler used to convert Java byte code into Jimple representation. This is
 * an internal class, which should only be used through its Rascal counterpart.
 *
 * @author rbonifacio
 */
public class Decompiler {
	private final IValueFactory vf;
	private IConstructor _class;

	public Decompiler(IValueFactory vf) {
		this.vf = vf;
	}

	/*
	 * decompiles a Java byte code at <i>classLoc</i> into a Jimple representation.
	 */
	public IConstructor decompile(ISourceLocation classLoc, IEvaluatorContext ctx) {
		try {
			ClassReader reader = new ClassReader(URIResolverRegistry.getInstance().getInputStream(classLoc));
			ClassNode cn = new ClassNode();
			reader.accept(cn, 0);
			reader.accept(new GenerateJimpleClassVisitor(cn), 0);
			return _class;
		} catch (IOException e) {
			throw RuntimeExceptionFactory.io(vf.string(e.getMessage()), null, null);
		}
	}

	/*
	 * an ASM class visitor that traverses a class byte code and generates a Jimple
	 * class.
	 */
	class GenerateJimpleClassVisitor extends ClassVisitor {
		private ClassNode cn;
		private List<Modifier> classModifiers;
		private Type type;
		private Type superClass;
		private List<Type> interfaces;
		private List<Field> fields;
		private List<Method> methods;
		private boolean isInterface;

		public GenerateJimpleClassVisitor(ClassNode cn) {
			super(Opcodes.ASM4);
			this.cn = cn;
		}

		@Override
		public void visit(int version, int access, String name, String signature, String superClass, String[] interfaces) {
			this.classModifiers = modifiers(access);
			this.type = objectConstructor(name);
			this.superClass = superClass != null ? objectConstructor(superClass) : objectConstructor("java.lang.Object");
			this.interfaces = new ArrayList<>();

			if (interfaces != null) {
				for (String anInterface : interfaces) {
					this.interfaces.add(objectConstructor(anInterface));
				}
			}

			this.fields = new ArrayList<>();
			this.methods = new ArrayList<>();

			isInterface = isInterface(access);
		}

		@Override
		public void visitEnd() {
			Iterator it = cn.methods.iterator();
			
			while(it.hasNext()) {
				visitMethod((MethodNode)it.next());
			}
			
			if (isInterface) {
				_class = ClassOrInterfaceDeclaration.interfaceDecl(type, classModifiers, interfaces, fields, methods)
						.createVallangInstance(vf);
			} else {
				_class = ClassOrInterfaceDeclaration
						.classDecl(type, classModifiers, superClass, interfaces, fields, methods)
						.createVallangInstance(vf);
			}
		}

		private void visitMethod(MethodNode mn) {
			List<Modifier> methodModifiers = modifiers(mn.access);
			Type methodReturnType = type(org.objectweb.asm.Type.getReturnType(mn.desc).getDescriptor());
			String methodName = mn.name;
			
			List<Type> methodFormalArgs = new ArrayList<>();
			List<Type> methodExceptions = new ArrayList();
			
			for(org.objectweb.asm.Type t: org.objectweb.asm.Type.getArgumentTypes(mn.desc)) {
				methodFormalArgs.add(type(t.getDescriptor()));
			}
			
			if(mn.exceptions != null) {
			  Iterator it = mn.exceptions.iterator();
			
			  while(it.hasNext()) {
			     String str = (String)it.next();
				 methodExceptions.add(objectConstructor(str));
			  }
			}
						
			HashMap<LocalVariableNode, LocalVariableDeclaration> localVariables = visitLocalVariables(mn.localVariables);
			
			List<LocalVariableDeclaration> decls = new ArrayList<>();
			List<Statement> stmts = new ArrayList<>();
			List<CatchClause> catchClauses = visitTryCatchBlocks(mn.tryCatchBlocks);
			
			
			for(LocalVariableDeclaration var: localVariables.values()) {
				decls.add(var);
			}
			
			//TODO: uncomment the following lines to decompile the instructions. 
			InstructionSetVisitor insVisitor = new InstructionSetVisitor(Opcodes.ASM4, localVariables);
			
			Iterator it2 = mn.instructions.iterator();
			
			while(it2.hasNext()) {
				AbstractInsnNode ins = (AbstractInsnNode)it2.next();
			}
			
			mn.instructions.accept(insVisitor);
			stmts = insVisitor.instructions;
			
			MethodBody methodBody = MethodBody.methodBody(decls, stmts, catchClauses); 
			
			methods.add(Method.method(methodModifiers, methodReturnType, methodName, methodFormalArgs, methodExceptions, methodBody));
		}

		@Override
		public FieldVisitor visitField(int access, String name, String descriptor, String signature, Object value) {
			List<Modifier> fieldModifiers = modifiers(access);
			Type fieldType = type(descriptor);

			fields.add(Field.field(fieldModifiers, fieldType, name));

			return super.visitField(access, name, descriptor, signature, value);
		}

		private HashMap<LocalVariableNode, LocalVariableDeclaration> visitLocalVariables(List<LocalVariableNode> nodes) {
			HashMap<LocalVariableNode, LocalVariableDeclaration> localVariables = new HashMap<>();
			
			if(nodes != null) {
				for(int i = 0; i < nodes.size(); i++) {
					LocalVariableNode var = nodes.get(i);
					Type type = type(var.desc);
				    String name = "l" + i;
				    localVariables.put(var, LocalVariableDeclaration.localVariableDeclaration(type, name));
				}
			}
			return localVariables;
		}

		private List<CatchClause> visitTryCatchBlocks(List<TryCatchBlockNode> nodes) {
			List<CatchClause> tryCatchBlocks = new ArrayList<>();
			for(TryCatchBlockNode node: nodes) {
			  String from = node.start.getLabel().toString();
			  String to = node.end.getLabel().toString();
			  String with = node.handler.getLabel().toString();
			
			  Type exception = objectConstructor(node.type);
			
			  tryCatchBlocks.add(CatchClause.catchClause(exception, from, to, with));
			}
			return tryCatchBlocks;
		}

	}

	class InstructionSetVisitor extends MethodVisitor {
		class Operand {
			Type type;
			Immediate immediate;

			Operand(Type type, Immediate immediate) {
				this.type = type;
				this.immediate = immediate;
			}

			Operand(LocalVariableDeclaration localDeclaration) {
				this.type = localDeclaration.varType;
				this.immediate = Immediate.local(localDeclaration.local);
			}
		}

		Stack<Operand> operandStack;
		List<LocalVariableDeclaration> auxiliarlyLocalVariables;
		HashMap<LocalVariableNode, LocalVariableDeclaration> localVariables;
		int locals;

		List<Statement> instructions;

		public InstructionSetVisitor(int version, HashMap<LocalVariableNode, LocalVariableDeclaration> localVariables) {
			super(version);
			this.localVariables = localVariables;
			operandStack = new Stack<>();
			auxiliarlyLocalVariables = new ArrayList<>();
			locals = localVariables.size();
			instructions = new ArrayList<>();
		}

		/*
		 * Visit a field instruction. The opcode must be one of: - GETSTATIC - PUTSTATIC
		 * - GETFIELD - PUTFIELD
		 */
		@Override
		public void visitFieldInsn(int opcode, String owner, String field, String descriptor) {
			switch (opcode) {
			 case Opcodes.GETSTATIC : getStaticIns(owner, field, descriptor); break;
			 case Opcodes.PUTSTATIC : putStaticIns(owner, field, descriptor); break; 
			 case Opcodes.GETFIELD  : getFieldIns(owner, field, descriptor);  break;
			 case Opcodes.PUTFIELD  : putFieldIns(owner, field, descriptor);  break; 
			 default: throw RuntimeExceptionFactory.illegalArgument(vf.string("invalid instruction " + opcode), null, null);
			}
			super.visitFieldInsn(opcode, owner, field, descriptor);
		}

		/*
		 * Visit an Int Increment Instruction. This instruction does not change the
		 * operand stack.
		 * 
		 * @param idx index of the local variable
		 * @increment ammount of the increment.
		 * 
		 * (non-Javadoc)
		 * @see org.objectweb.asm.MethodVisitor#visitIincInsn(int, int)
		 * @see
		 * https://docs.oracle.com/javase/specs/jvms/se9/html/jvms-6.html#jvms-6.5.iinc
		 */
		@Override
		public void visitIincInsn(int idx, int increment) {
			LocalVariableDeclaration local = findLocalVariable(idx);

			String var = local.local;

			Immediate lhs = newLocalImmediate(var);
			Immediate rhs = newIntValueImmediate(increment);
			Expression expression = newPlusExpression(lhs, rhs);

			instructions.add(assignmentStmt(Variable.localVariable(var), expression));
			
			super.visitIincInsn(idx, increment);
		}

		
		@Override
		public void visitInsn(int opcode) {
			switch (opcode) {
			 case Opcodes.NOP         : nopIns();                     break;
			 case Opcodes.ACONST_NULL : acconstNullIns();             break;
			 case Opcodes.ICONST_M1   : loadIntConstIns(-1,"I");      break;
			 case Opcodes.ICONST_0    : loadIntConstIns(0, "I");      break;
			 case Opcodes.ICONST_1    : loadIntConstIns(1, "I");      break;
			 case Opcodes.ICONST_2    : loadIntConstIns(2, "I");      break;
			 case Opcodes.ICONST_3    : loadIntConstIns(3, "I");      break;
			 case Opcodes.ICONST_4    : loadIntConstIns(4, "I");      break;
			 case Opcodes.ICONST_5    : loadIntConstIns(5, "I");      break; 
			 case Opcodes.LCONST_0    : loadIntConstIns(0, "J");      break;
			 case Opcodes.LCONST_1    : loadIntConstIns(1, "J");      break;
			 case Opcodes.FCONST_0    : loadRealConstIns(0.0F, "F");  break;
			 case Opcodes.FCONST_1    : loadRealConstIns(1.0F, "F");  break;
			 case Opcodes.FCONST_2    : loadRealConstIns(2.0F, "F");  break;
			 case Opcodes.DCONST_0    : loadRealConstIns(0.0F, "F");  break;
			 case Opcodes.DCONST_1    : loadRealConstIns(1.0F, "F");  break;
			 case Opcodes.IALOAD      : arraySubscriptIns();          break;
			 case Opcodes.LALOAD      : arraySubscriptIns();          break;
			 case Opcodes.FALOAD      : arraySubscriptIns();          break;
			 case Opcodes.DALOAD      : arraySubscriptIns();          break;
			 case Opcodes.AALOAD      : arraySubscriptIns();          break;
			 case Opcodes.BALOAD      : arraySubscriptIns();          break; 
			 case Opcodes.CALOAD      : arraySubscriptIns();          break; 
			 case Opcodes.SALOAD      : arraySubscriptIns();          break; 
			 case Opcodes.IASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.LASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.FASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.DASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.AASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.BASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.CASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.SASTORE     : storeIntoArrayIns();          break; 
			 case Opcodes.POP         : popIns();                     break;
			 case Opcodes.POP2        : pop2Ins();                    break; 
			 case Opcodes.DUP         : dupIns();                     break;
			 case Opcodes.DUP_X1      : dupX1Ins();                   break;
			 case Opcodes.DUP_X2      : dupX2Ins();                   break;
			 case Opcodes.DUP2        : dup2Ins();                    break;
			 case Opcodes.DUP2_X1     : dup2X1Ins();                  break;
			 case Opcodes.DUP2_X2     : dup2X2Ins();                  break;
			 case Opcodes.SWAP        : swapIns();                    break; 
			 case Opcodes.IADD        : binOperatorIns(type("I"), (l, r) -> newPlusExpression(l, r));  break;
			 case Opcodes.LADD        : binOperatorIns(type("J"), (l, r) -> newPlusExpression(l, r));  break;
			 case Opcodes.FADD        : binOperatorIns(type("F"), (l, r) -> newPlusExpression(l, r));  break;
			 case Opcodes.DADD        : binOperatorIns(type("D"), (l, r) -> newPlusExpression(l, r));  break;
			 case Opcodes.ISUB        : binOperatorIns(type("I"), (l, r) -> newMinusExpression(l, r)); break;
			 case Opcodes.LSUB        : binOperatorIns(type("J"), (l, r) -> newMinusExpression(l, r)); break;
			 case Opcodes.FSUB        : binOperatorIns(type("F"), (l, r) -> newMinusExpression(l, r)); break;
			 case Opcodes.DSUB        : binOperatorIns(type("D"), (l, r) -> newMinusExpression(l, r)); break;
			 case Opcodes.IMUL        : binOperatorIns(type("I"), (l, r) -> newMultExpression(l, r));  break;
			 case Opcodes.LMUL        : binOperatorIns(type("J"), (l, r) -> newMultExpression(l, r));  break;
			 case Opcodes.FMUL        : binOperatorIns(type("F"), (l, r) -> newMultExpression(l, r));  break;
			 case Opcodes.DMUL        : binOperatorIns(type("D"), (l, r) -> newMultExpression(l, r));  break;
			 case Opcodes.IDIV        : binOperatorIns(type("I"), (l, r) -> newDivExpression(l, r));  break;
			 case Opcodes.LDIV        : binOperatorIns(type("J"), (l, r) -> newDivExpression(l, r));  break;
			 case Opcodes.FDIV        : binOperatorIns(type("F"), (l, r) -> newDivExpression(l, r));  break;
			 case Opcodes.DDIV        : binOperatorIns(type("D"), (l, r) -> newDivExpression(l, r));  break;
			 case Opcodes.IREM        : binOperatorIns(type("I"), (l, r) -> newReminderExpression(l, r));  break;
			 case Opcodes.LREM        : binOperatorIns(type("J"), (l, r) -> newReminderExpression(l, r));  break;
			 case Opcodes.FREM        : binOperatorIns(type("F"), (l, r) -> newReminderExpression(l, r));  break;
			 case Opcodes.DREM        : binOperatorIns(type("D"), (l, r) -> newReminderExpression(l, r));  break;
			 case Opcodes.INEG        : negIns(type("I"));  break;
			 case Opcodes.LNEG        : negIns(type("J"));  break;
			 case Opcodes.FNEG        : negIns(type("F"));  break;
			 case Opcodes.DNEG        : negIns(type("D"));  break;
			 case Opcodes.ISHL        : binOperatorIns(type("I"), (l, r) -> Expression.shl(l, r));   break;
			 case Opcodes.LSHL        : binOperatorIns(type("J"), (l, r) -> Expression.shl(l, r));   break;
			 case Opcodes.ISHR        : binOperatorIns(type("I"), (l, r) -> Expression.shr(l, r));   break;
			 case Opcodes.LSHR        : binOperatorIns(type("J"), (l, r) -> Expression.shr(l, r));   break;
			 case Opcodes.IUSHR       : binOperatorIns(type("I"), (l, r) -> Expression.ushr(l, r));  break;
			 case Opcodes.LUSHR       : binOperatorIns(type("J"), (l, r) -> Expression.ushr(l, r));  break;
			 case Opcodes.IAND        : binOperatorIns(type("I"), (l, r) -> Expression.and(l, r));   break;
			 case Opcodes.LAND        : binOperatorIns(type("J"), (l, r) -> Expression.and(l, r));   break;
			 case Opcodes.IOR         : binOperatorIns(type("I"), (l, r) -> Expression.or(l, r));    break;
			 case Opcodes.LOR         : binOperatorIns(type("J"), (l, r) -> Expression.or(l, r));    break;
			 case Opcodes.IXOR        : binOperatorIns(type("I"), (l, r) -> Expression.xor(l, r));  break;
			 case Opcodes.LXOR        : binOperatorIns(type("J"), (l, r) -> Expression.xor(l, r));  break;
			 case Opcodes.I2L         : simpleCastIns(type("J")); break;
			 case Opcodes.I2F         : simpleCastIns(type("F")); break;
			 case Opcodes.I2D         : simpleCastIns(type("D")); break;
			 case Opcodes.L2I         : simpleCastIns(type("I")); break;
			 case Opcodes.L2F         : simpleCastIns(type("F")); break;
			 case Opcodes.L2D         : simpleCastIns(type("D")); break;
			 case Opcodes.F2I         : simpleCastIns(type("I")); break;
			 case Opcodes.F2L         : simpleCastIns(type("J")); break;
			 case Opcodes.F2D         : simpleCastIns(type("D")); break;
			 case Opcodes.D2I         : simpleCastIns(type("I")); break;
			 case Opcodes.D2L         : simpleCastIns(type("J")); break;
			 case Opcodes.D2F         : simpleCastIns(type("F")); break;
			 case Opcodes.I2B         : simpleCastIns(type("B")); break;
			 case Opcodes.I2C         : simpleCastIns(type("C")); break;
			 case Opcodes.I2S         : simpleCastIns(type("S")); break;
			 case Opcodes.LCMP        : binOperatorIns(type("I"), (l, r) -> Expression.cmp(l, r));  break;
			 case Opcodes.FCMPG       : binOperatorIns(type("I"), (l, r) -> Expression.cmpg(l, r)); break;	
			 case Opcodes.FCMPL       : binOperatorIns(type("I"), (l, r) -> Expression.cmpl(l, r)); break;	
			 case Opcodes.DCMPG       : binOperatorIns(type("I"), (l, r) -> Expression.cmpg(l, r)); break;	
			 case Opcodes.DCMPL       : binOperatorIns(type("I"), (l, r) -> Expression.cmpl(l, r)); break;	
			 case Opcodes.IRETURN     : returnIns(); break;
			 case Opcodes.LRETURN     : returnIns(); break;
			 case Opcodes.FRETURN     : returnIns(); break;
			 case Opcodes.DRETURN     : returnIns(); break;
			 case Opcodes.ARETURN     : returnIns(); break;
			 case Opcodes.RETURN      : returnVoidIns(); break; 
			 case Opcodes.ARRAYLENGTH : arrayLengthIns(); break; 
			 case Opcodes.ATHROW      : throwIns(); break; 
			 case Opcodes.MONITORENTER : monitorEnterIns(); break; 
			 case Opcodes.MONITOREXIT  : monitorExitIns(); break; 
			 default: throw RuntimeExceptionFactory.illegalArgument(vf.string("invalid instruction " + opcode), null, null);
			}
			super.visitInsn(opcode);
		}

		/*
		 * Visit a local variable instructions. 
		 * 
		 * (non-Javadoc)
		 * @see org.objectweb.asm.MethodVisitor#visitVarInsn(int, int)
		 */
		@Override
		public void visitVarInsn(int opcode, int var) {
			switch (opcode) {
			 case Opcodes.ILOAD : loadIns(var);  break;
			 case Opcodes.FLOAD : loadIns(var);  break;
			 case Opcodes.DLOAD : loadIns(var);  break;
			 case Opcodes.ALOAD : loadIns(var);  break;
			 case Opcodes.ISTORE: storeIns(var); break;
			 case Opcodes.LSTORE: storeIns(var); break;
			 case Opcodes.FSTORE: storeIns(var); break;
			 case Opcodes.DSTORE: storeIns(var); break;
			 case Opcodes.ASTORE: storeIns(var); break;
			 case Opcodes.RET   : retIns(var);   break; 
			 default: throw RuntimeExceptionFactory.illegalArgument(vf.string("invalid instruction " + opcode), null, null);
			}
			super.visitVarInsn(opcode, var);
		}
		
		/*
		 * Visit a type instruction. 
		 * 
		 * (non-Javadoc)
		 * @see org.objectweb.asm.MethodVisitor#visitTypeInsn(int, java.lang.String)
		 */
		@Override
		public void visitTypeInsn(int opcode, String type) {
			switch(opcode) {
			 case Opcodes.NEW        : newInstanceIns(type(type));  break;
			 case Opcodes.ANEWARRAY  : aNewArrayIns(type(type));    break;
			 case Opcodes.CHECKCAST  : simpleCastIns(type(type));   break;
			 case Opcodes.INSTANCEOF : instanceOfIns(type(type));   break; 
			 default: throw RuntimeExceptionFactory.illegalArgument(vf.string("invalid instruction " + opcode), null, null);
			}
			super.visitTypeInsn(opcode, type);
		}
		
		

		@Override
		public void visitIntInsn(int opcode, int operand) {
			switch(opcode) {
			 case Opcodes.BIPUSH : pushConstantValue(type("I"), Immediate.intValue(operand)); break;
			 case Opcodes.SIPUSH : pushConstantValue(type("I"), Immediate.intValue(operand)); break;
			 case Opcodes.NEWARRAY : createNewArrayIns(operand); break;
			 default: throw RuntimeExceptionFactory.illegalArgument(vf.string("invalid instruction " + opcode), null, null);
			}
			super.visitIntInsn(opcode, operand);
		}

		@Override
		public void visitMethodInsn(int opcode, String owner, String name, String descriptor, boolean isInterfaceInvoke) {
			switch(opcode) {
			 case Opcodes.INVOKEVIRTUAL   : invokeMethodIns(owner, name, descriptor, false, (r, s, args) -> InvokeExp.virtualInvoke(r, s, args)); break;
			 case Opcodes.INVOKESPECIAL   : invokeMethodIns(owner, name, descriptor, false, (r, s, args) -> InvokeExp.specialInvoke(r, s, args)); break; 
			 case Opcodes.INVOKESTATIC    : invokeMethodIns(owner, name, descriptor, true,  (r, s, args) -> InvokeExp.staticMethodInvoke(s, args)); break; 
			 case Opcodes.INVOKEINTERFACE : invokeMethodIns(owner, name, descriptor, false, (r, s, args) -> InvokeExp.interfaceInvoke(r, s, args)); break;
			 default: throw RuntimeExceptionFactory.illegalArgument(vf.string("invalid instruction " + opcode), null, null);
			}
		}
		
		@Override
		public void visitInvokeDynamicInsn(String name, String descriptor, Handle bootstrapMethodHandle, Object... bootstrapMethodArguments) {
			throw new RuntimeException("Invoke dynamic not implemented yet"); 
		}
		
		private void invokeMethodIns(String owner, String name, String descriptor, boolean isStatic, InvokeExpressionFactory factory) {
			MethodSignature signature = methodSignature(owner, descriptor);
			List<Immediate> args = new ArrayList<>();
			
			for(int i = 0; i < signature.formals.size(); i++) {
				args.add(operandStack.pop().immediate);
			}
			
			InvokeExp exp = null; 
			
			if(! isStatic) {
				String reference = ((Immediate.c_local)operandStack.pop().immediate).localName;
				exp = factory.createInvokeExpression(reference, signature, args); 	
			}
			else {
				exp = factory.createInvokeExpression(null, signature, args);
			}
			
			instructions.add(Statement.invokeStmt(exp));
		}

		
		private LocalVariableDeclaration findLocalVariable(int idx) {
			for (LocalVariableNode node : localVariables.keySet()) {
				if (node.index == idx) {
					return localVariables.get(node);
				}
			}
			throw new RuntimeException("local variable not found");
		}
		
		/*
		 * Load a local variable into the top of the 
		 * operand stack. 
		 */
		private void loadIns(int var) {
			LocalVariableDeclaration local = findLocalVariable(var);
			operandStack.push(new Operand(local));
		}

		/*
		 * Assign the expression at the top position of the stack into a variable.
		 */
		private void storeIns(int var) {
			LocalVariableDeclaration local = findLocalVariable(var);
			Immediate immediate = operandStack.pop().immediate;
			instructions.add(assignmentStmt(Variable.localVariable(local.local), Expression.immediate(immediate)));
		}

		/*
		 * Return from a subroutine. Not really clear the corresponding 
		 * Java code. It seems to me a more internal instruction from 
		 * the JVM. It is different from a return void call, for instance. 
		 */
		private void retIns(int var) {
			LocalVariableDeclaration local = findLocalVariable(var);
			instructions.add(Statement.retStmt(Immediate.local(local.local)));
		}
		
		private void newInstanceIns(Type type) {
			LocalVariableDeclaration newLocal = createLocal(type);
			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), Expression.newInstance(type)));
			operandStack.push(new Operand(newLocal));
		}
		
		private void aNewArrayIns(Type type) {
			Operand operand = operandStack.pop();
			LocalVariableDeclaration newLocal = createLocal(Type.TArray(type));
			Integer size = ((Immediate.c_intValue)operand.immediate).iValue;
			
			List<ArrayDescriptor> dims = new ArrayList<>();
			dims.add(ArrayDescriptor.fixedSize(size));	

			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), Expression.newArray(type, dims)));
			operandStack.push(new Operand(newLocal));
		}
		/*
		 * Add a nop instruction 
		 */
		private void nopIns() {
			instructions.add(Statement.nop());
		}

		/*
		 * Load a null value into the top of the 
		 * operand stack. 
		 */
		private void acconstNullIns() {
			operandStack.push(new Operand(Type.TNull(), Immediate.nullValue()));
		}

		/*
		 * Load an int const into the top of the 
		 * operand stack. 
		 */
		private void loadIntConstIns(int value, String descriptor) {
			operandStack.push(new Operand(type(descriptor), Immediate.intValue(value)));
		}

		/*
		 * Load a float const into the top of the 
		 * operand stack. 
		 */
		private void loadRealConstIns(float value, String descriptor) {
			operandStack.push(new Operand(type(descriptor), Immediate.floatValue(value)));
		}

		
		/*
		 * Neg instruction (INEG, LNEG, FNEG, DNEG)
		 */
		private void negIns(Type type) {
			Operand operand = operandStack.pop();
			
			LocalVariableDeclaration newLocal = createLocal(type);
			
			Expression expression = Expression.neg(operand.immediate);
			
			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), expression));
			
			operandStack.push(new Operand(newLocal));
		}
		
		/*
		 * Instructions supporting binarya operations. 
		 */
		private void binOperatorIns(Type type, BinExpressionFactory factory) {
			Operand lhs = operandStack.pop();
			Operand rhs = operandStack.pop();

			LocalVariableDeclaration newLocal = createLocal(type);
			
			Expression expression = factory.createExpression(lhs.immediate, rhs.immediate);

			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), expression));

			operandStack.push(new Operand(newLocal));
		}
		
		private void simpleCastIns(Type targetType) {
			Operand operand = operandStack.pop();
			LocalVariableDeclaration newLocal = createLocal(targetType);
			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), Expression.cast(targetType, operand.immediate)));
			operandStack.push(new Operand(newLocal));
		}
		
		private void instanceOfIns(Type type) {
			Operand operand = operandStack.pop();
			LocalVariableDeclaration newLocal = createLocal(Type.TBoolean());
			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), Expression.instanceOf(type, operand.immediate)));
			operandStack.push(new Operand(newLocal));
		}
		
		private void returnIns() {
			Operand operand = operandStack.pop();
			instructions.add(Statement.returnStmt(operand.immediate));
			// TODO: perhaps we should call an exit monitor here. 
			operandStack.empty();
		}
		
		private void returnVoidIns() {
			instructions.add(Statement.returnEmptyStmt());
			// TODO: perhaps we should call an exit monitor here. 
			operandStack.empty();
		}
		
		private void arrayLengthIns() {
			Operand arrayRef = operandStack.pop();
			LocalVariableDeclaration newLocal = createLocal("I");
			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), Expression.lengthOf(arrayRef.immediate)));
			operandStack.push(new Operand(newLocal));
		}
		
		private void throwIns() {
			Operand reference = operandStack.pop();
			instructions.add(Statement.throwStmt(reference.immediate));
			operandStack.empty();
			operandStack.push(reference);
		}
		
		private void monitorEnterIns() {
			Operand reference = operandStack.pop();
			instructions.add(Statement.enterMonitor(reference.immediate));
		}
		
		private void monitorExitIns() {
			Operand reference = operandStack.pop();
			instructions.add(Statement.exitMonitor(reference.immediate));
		}

	    
		/*
		 * Update the top of the operand stack with 
		 * the value of a specific indexed element of an 
		 * array. The index and the array's reference 
		 * are popped up from the stack.  
		 */
		private void arraySubscriptIns() {
			Operand idx = operandStack.pop();
			Operand ref = operandStack.pop();
			
			Type baseType = ref.type;
			
			if(baseType instanceof Type.c_TArray) {
			   baseType = ((Type.c_TArray)baseType).baseType;
			}
			
			LocalVariableDeclaration newLocal =createLocal(baseType);
			
			instructions.add(assignmentStmt(Variable.localVariable(newLocal.local), newArraySubscript(((Immediate.c_local)ref.immediate).localName,idx.immediate)));
			
			operandStack.push(new Operand(newLocal));
		}
		
		/*
		 * Updates a position of an array with a 
		 * value. The stack must be with the values:
		 * 
		 *  [ value ]
		 *  [  idx  ]
		 *  [ array ]
		 *  [ ...   ]  
		 *  _________
		 *  
		 *  After popping value, idx, and array, 
		 *  no value is introduced into the stack. 
		 */
		private void storeIntoArrayIns() {
			Immediate value = operandStack.pop().immediate;
			Immediate idx = operandStack.pop().immediate;
			Immediate arrayRef = operandStack.pop().immediate;
			
			Variable var = Variable.arrayRef(((Immediate.c_local)arrayRef).localName, idx);
			
			instructions.add(assignmentStmt(var, Expression.immediate(value)));
		}
		
		/*
		 * Removes an operand from the stack. 
		 */
		private void popIns() {
			operandStack.pop();
		}
		
		/*
		 * Removes either one or two operand from the 
		 * top of the stack. If the type of the first 
		 * operand is either a long or a double, it 
		 * removes just one operand. 
		 */
		private void pop2Ins() {
			Operand value = operandStack.pop(); 
			
			if(allCategory1(value.type)) {
				operandStack.pop();
			}
		}
		
		/*
		 * Duplicate the top operand stack value
		 */
		private void dupIns() {
			Operand value = operandStack.pop();
			
			operandStack.push(value);
			operandStack.push(value);
		}
		
		/*
		 * Duplicate the top operand stack value and insert 
		 * the copy two values down. 
		 */
		private void dupX1Ins() {
			assert operandStack.size() >= 2; 
			
			Operand value1 = operandStack.pop();
			Operand value2 = operandStack.pop();
			
			operandStack.push(value1);
			operandStack.push(value2);
			operandStack.push(value1); 
		}
		
		/*
		 * Duplicate the top operand stack value and insert 
		 * the copy two or three values down. 
		 */
		private void dupX2Ins() {
			assert operandStack.size() >= 2; 
			
			Operand value1 = operandStack.pop(); 
			
			if(allCategory1(value1.type)) {
				Operand value2 = operandStack.pop();
				Operand value3 = operandStack.pop();
				operandStack.push(value1);
				operandStack.push(value3);
				operandStack.push(value2);
				operandStack.push(value1);
			}
			else {
				Operand value2 = operandStack.pop();
				operandStack.push(value1);
				operandStack.push(value2);
				operandStack.push(value1); 
			}
		}
		
		/*
		 * Duplicate the top one or two operand stack values. 
		 * It duplicates the two top operand stack values (v1 and v2) 
		 * if both have types of category1. Otherwise, it 
		 * duplicates just the first value. 
		 */
		private void dup2Ins() {
			assert operandStack.size() >= 2; 
			
			Operand value1 = operandStack.pop();
			Operand value2 = operandStack.pop();
			
			if(allCategory1(value1.type, value2.type)) {
				operandStack.push(value2);
				operandStack.push(value1);
				operandStack.push(value2);
				operandStack.push(value1);
			}
			else {
				operandStack.push(value2);
				operandStack.push(value1);
				operandStack.push(value1); 
			}
		}
		
		/*
		 * Duplicate the top one or two operand stack values and 
		 * insert two or three values down, depending on the 
		 * type category of the values.
		 */
		private void dup2X1Ins() {
			assert operandStack.size() >= 3;
			
			Operand value1 = operandStack.pop();
			Operand value2 = operandStack.pop();
			Operand value3 = operandStack.pop();
			
			if(allCategory1(value1.type, value2.type, value3.type)) {
				operandStack.push(value2);
				operandStack.push(value1); 
				operandStack.push(value3);
				operandStack.push(value2);
				operandStack.push(value1); 
			}
			else if((allCategory2(value1.type)) && allCategory1(value2.type)){
				operandStack.push(value3);
				operandStack.push(value1);
				operandStack.push(value2);
				operandStack.push(value1); 
			}
		}

		/*
		 * Duplicate the top one or two operand stack values and insert two, three, or four values down
		 */
		private void dup2X2Ins() {
			assert operandStack.size() >= 4; 
			
			Operand value1 = operandStack.pop();
			Operand value2 = operandStack.pop(); 
			Operand value3 = operandStack.pop(); 
			Operand value4 = operandStack.pop();
					
			if(allCategory1(value1.type, value2.type, value3.type, value4.type)) { 
				operandStack.push(value2);
				operandStack.push(value1);
				operandStack.push(value4);
				operandStack.push(value3);
				operandStack.push(value2);
				operandStack.push(value1);
			}
			else if((allCategory2(value1.type)) && allCategory1(value2.type, value3.type)) {  
				operandStack.push(value4);
				operandStack.push(value1);
				operandStack.push(value3);
				operandStack.push(value2);
				operandStack.push(value1);
			}
			else if(allCategory1(value1.type, value2.type) && (allCategory2(value3.type))) {
				operandStack.push(value4);
				operandStack.push(value2);
				operandStack.push(value1);
				operandStack.push(value3);
				operandStack.push(value2);
				operandStack.push(value1);
			}
			else if((!allCategory2(value1.type, value2.type))) {
				operandStack.push(value4);
				operandStack.push(value3);
				operandStack.push(value1);
				operandStack.push(value2);
				operandStack.push(value1);
			}
			
		}
		
		private void swapIns() {
			assert operandStack.size() >= 2; 
			
			Operand value1 = operandStack.pop();
			Operand value2 = operandStack.pop();
			
			operandStack.push(value1);
			operandStack.push(value2); 
		}
		
		/*
		 * Load the value of a static field into the top 
		 * of the operand stack. 
		 * 
		 * @param owner the field's owner class. 
		 * @param field the name of the field. 
		 * @param descriptor use to compute the field's type. 
		 */
		private void getStaticIns(String owner, String field, String descriptor) {
			LocalVariableDeclaration newLocal = createLocal(descriptor);
			Type fieldType = type(descriptor);
			Expression fieldRef = Expression.fieldRef(owner, fieldType, field);
		
			instructions.add(Statement.assign(Variable.localVariable(newLocal.local), fieldRef));

			operandStack.push(new Operand(newLocal));
		}
		
		private void putStaticIns(String owner, String field, String descriptor) {
			Operand value = operandStack.pop();
			FieldSignature signature = FieldSignature.fieldSignature(owner, type(descriptor), field);
			instructions.add(assignmentStmt(Variable.staticFieldRef(signature), Expression.immediate(value.immediate))); 
		}
		
		private void putFieldIns(String owner, String field, String descriptor) {
			Operand value = operandStack.pop();
			Operand operand = operandStack.pop();
			
			String reference = ((Immediate.c_local)operand.immediate).localName;
			
			FieldSignature signature = FieldSignature.fieldSignature(owner, type(descriptor), field);
			
			instructions.add(assignmentStmt(Variable.fieldRef(reference, signature), Expression.immediate(value.immediate)));
		}

		/*
		 * Load the value of an instance field into the top 
		 * of the operand stack. The instance object is popped 
		 * from the stack. 
		 * 
		 * @param owner the field's owner class. 
		 * @param field the name of the field. 
		 * @param descriptor use to compute the field's type. 
		 */
		private void getFieldIns(String owner, String field, String descriptor) {
			Immediate instance = operandStack.pop().immediate;
			
			LocalVariableDeclaration newLocal = createLocal(descriptor);
			
			Type fieldType = type(descriptor);
			
			Expression fieldRef = Expression.localFieldRef(((Immediate.c_local)instance).localName, 
					owner, fieldType, field); 
			
			instructions.add(Statement.assign(Variable.localVariable(newLocal.local), fieldRef)); 
			
			operandStack.push(new Operand(newLocal));
		}

		private LocalVariableDeclaration createLocal(String descriptor) {
			return createLocal(type(descriptor));
		}

		private LocalVariableDeclaration createLocal(Type type) {
			String name = "l" + locals++;
			LocalVariableDeclaration local = LocalVariableDeclaration.localVariableDeclaration(type, name);
			auxiliarlyLocalVariables.add(local);
			return local;
		}
		
		private boolean allCategory1(Type ... types) {
			for(Type t: types) {
				if(t instanceof Type.c_TDouble || t instanceof Type.c_TLong) {
					return false;
				}
			}
			return true; 
		}
		
		private boolean allCategory2(Type ... types) {
			for(Type t: types) {
				if(!(t instanceof Type.c_TDouble || t instanceof Type.c_TLong)) {
					return false;
				}
			}
			return true; 
		}
		
		private void pushConstantValue(Type type, Immediate immediate) {
			operandStack.push(new Operand(type, immediate));
		}
		
		private void createNewArrayIns(int aType) {
			Type type = null; 
			switch(aType) {
			  case 4 : type = type("Z"); break;
			  case 5 : type = type("C"); break;
			  case 6 : type = type("F"); break;
			  case 7 : type = type("D"); break;
			  case 8 : type = type("B"); break;
			  case 9 : type = type("S"); break;
			  case 10: type = type("I"); break;
			  case 11: type = type("J"); break;
			}
			aNewArrayIns(type);
		}
	}
}
