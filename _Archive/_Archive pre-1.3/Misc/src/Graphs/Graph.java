
package Graphs;

import java.util.HashSet;
import java.util.Set;

public class Graph { 
    private Set<Node> nodes = new HashSet<>();

    public void addNode(Node nodeA) {
        nodes.add(nodeA);
    }

    // getters and setters 
    public Node getNode(Node node){
        String name = node.getName();
        Object[] nodeArray = nodes.toArray();
        for (int i = 0; i < nodeArray.length; i++) {
            if(((Node)nodeArray[i]).getName() == name){
                return ((Node)nodeArray[i]);
            }
        }
        return null;
    }
}
