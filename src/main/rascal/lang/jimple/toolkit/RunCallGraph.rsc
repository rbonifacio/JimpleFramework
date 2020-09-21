module lang::jimple::toolkit::RunCallGraph

import IO;
import Map;
import Relation;
import Type;
import Set;
import List;
import util::Math;
import vis::Figure;
import vis::ParseTree;
import vis::Render;
import analysis::graphs::Graph;

import lang::jimple::core::Context;
import lang::jimple::toolkit::CallGraph;

/*
public void novo(){
    files = [|project://JimpleFramework/src/test/resources/samples/TestCallGraph.class|];
    es = ["execute"];//"samples.TestCallGraph.execute()":

    ExecutionContext ctx =  createExecutionContext(files,es);
}*/

public void main(){

    //files = [|project://JimpleFramework/src/test/resources/|];
    files = [|project://JimpleFramework/src/test/resources/samples/TestCallGraph.class|];
    es = ["A"];//"samples.TestCallGraph.execute()":
    
    //CGModel model = execute(files, es, Analysis(computeCallGraph));
    CGModel model = execute(files, es, Analysis(computeCallGraphNovo));
    println(model.cg);
    
    
    /*
    CG cg = model.cg;
    mm = invert(model.methodMap);
    println("\n\n");
    println(typeOf(cg));
    
    
    nCalls = size(model.cg);
    println("Number os calls: "+toString(nCalls));
    println("Calls: "+toString(model.cg));    
    
    procs = carrier(cg);    
    println("\nNumber of Procedures: "+toString(size(procs)));
    println("Procedures: "+toString(procs));
    
    entryPoints = top(cg);    
    println("\nNumber of Entry Points: "+toString(size(entryPoints)));
    println("Entry Points: "+toString(entryPoints));
    
    bottomCalls = bottom(cg);
    println("\nNumber of Bottom Calls (leaves): "+toString(size(bottomCalls)));
    println("Bottom Calls (leaves): "+toString(bottomCalls));
    
    closureCalls = cg+;
    println("\nIndirect Calls: "+toString(closureCalls));
    
    connections = connectedComponents(cg);
    println("\nConnected Components: "+toString(connections));
    
    procsList = toList(procs);
    //nodes = toList({box(text(name), id(name), size(50), fillColor("lightgreen")) | name <- procsList});    
    nodes = toList({box(text(name), id(nn), size(50), fillColor("lightgreen")) | nn <- procsList, name <- mm[nn]});
    //TODO: alterar CallGraph.rsc --> alias CG = rel[str from, str to];
    edges = [edge(c.from,c.to) | c <- cg];    
    render(graph(nodes, edges, hint("layered"), std(size(20)), gap(10)));
    */
    
    
    
   
    
    //http://tutor.rascal-mpl.org/Recipes/Recipes.html#/Recipes/Common/CallLifting/CallLifting.html
    // e no artigo EASY, secao 5.2
    //public rel[str,str] lift(rel[str,str] aCalls, rel[str,str] aPartOf){
    //    return { <C1, C2> | <str P1, str P2> <- aCalls, <str C1, str C2> <- aPartOf[P1] * aPartOf[P2]};
    //}
    

    /*
    nodes = [ box(text("A"), id("A"), size(50), fillColor("lightgreen")),
          box(text("B"), id("B"), size(60), fillColor("orange")),
          ellipse( text("C"), id("C"), size(70), fillColor("lightblue")),
          ellipse(text("D"), id("D"), size(200, 40), fillColor("violet")),
          box(text("E"), id("E"), size(50), fillColor("silver")),
      box(text("F"), id("F"), size(50), fillColor("coral"))
        ];
        println("\n\n");
    println(nodes);
    println(typeOf(nodes));
    
edges = [ edge("A", "B"), edge("B", "C"), edge("B", "D"), edge("A", "C"),
          edge("C", "E"), edge("C", "F"), edge("D", "E"), edge("D", "F"),
          edge("A", "F")
        ]; 
//render(graph(nodes, edges, hint("layered"), gap(100)));
*/
}
