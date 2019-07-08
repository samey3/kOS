/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Jobs;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import Graphs.*;
import java.awt.geom.Point2D;
import java.io.IOException;
import static java.lang.Math.abs;
import static java.lang.Math.round;
import java.nio.file.Files;
import java.nio.file.Paths;

public class pathFind {
    
    private static final String JOB_ROOT = System.getProperty("user.dir") + "\\Ships\\Script\\processing\\";
    private static final String BODY_DATA = JOB_ROOT + "body_data\\";
    
    public static String findPath (List<String> args) throws IOException{ //List<Node>    
        //0 LAT IS NORTH POLE. 180 LAT IS SOUTH POLE.
        
        String body = args.get(0);
        List<String> lines = Files.readAllLines(Paths.get(BODY_DATA + body + ".txt"));
        
        //Gets the precision of the map
        Double precision = Double.parseDouble(lines.get(0));
            lines.remove(0);
               
        //Finds the starting coordinates
        //Remember to toss the starting coords in the wraps incase, because in-game is -90 to 90, -180 to 180.
        Point2D start = new Point2D.Double(LTC(args.get(1), precision), LTC(args.get(2), precision)); //Lat,lng
        Point2D end = new Point2D.Double(LTC(args.get(3), precision), LTC(args.get(4), precision));
        
        double lat_start = start.getX();
        double lng_start = start.getY();
        
        double lat_end = end.getX();  
        double lng_end = end.getY();

        //WLAT here should always return the passed in values.
        double lat_f = WLAT(lat_end - lat_start);
        double lat_b = WLAT(lat_start - lat_end);
        double lat_diff = Math.min(lat_f, lat_b);
        
        double lng_f = WLNG(lng_end - lng_start);
        double lng_b = WLNG(lng_start - lng_end);
        double lng_diff = Math.min(lng_f, lng_b);
              
        //If latitude difference is smaller.
        //
        if(Math.min(lat_f, lat_b) < Math.min(lng_f, lng_b)){
            
        }
          
        double lat_step = (lat_f <= lat_b ? 1 : -1)*precision;
        double lng_step = (lng_f <= lng_b ? 1 : -1)*precision;
        
        double iterate_lat_start = (lat_f <= lat_b ? 0 : 180);
        //double iterate_lat_start = (lat_f <= lat_b ? 0 : lat_diff);
        double iterate_lng_start = (lng_f <= lng_b ? 0 : lng_diff);   
        
        double iterate_lat_end = (lat_f <= lat_b ? 180 : 0);
        //double iterate_lat_end = (lat_f <= lat_b ? lat_diff : 0);
        double iterate_lng_end = (lng_f <= lng_b ? lng_diff : 0);
        
        double record_lat_start = (lat_f <= lat_b ? lat_start : lat_end);
        double record_lng_start = (lng_f <= lng_b ? lng_start : lng_end);
        
        double p_mult = (1/precision);
        Node [][] bodyGraph = new Node[(int)(182*p_mult) + 1][(int)(lng_diff*p_mult) + 1];
        //Node [][] bodyGraph = new Node[(int)(lat_diff*p_mult) + 1][(int)(lng_diff*p_mult) + 1];
        for(double i = iterate_lat_start; i != (iterate_lat_end + lat_step); i+=lat_step ){
            for(double j = iterate_lng_start; j != (iterate_lng_end + lng_step); j+=lng_step ){
                bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)] = new Node(new Point2D.Double(i, WLNG(j+record_lng_start)), getNodeAltitude(i, WLNG(j+record_lng_start), precision, lines));
                //bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)] = new Node(new Point2D.Double(WLAT(i+record_lat_start), WLNG(j+record_lng_start)), getNodeAltitude(WLAT(i+record_lat_start), WLNG(j+record_lng_start), precision, lines));
            }
        }
        System.out.println("Created nodes.");
        
        //Links the nodes
        for(double i = iterate_lat_start; i != (iterate_lat_end + lat_step); i+=lat_step ){
            for(double j = iterate_lng_start; j != (iterate_lng_end + lng_step); j+=lng_step ){
                if(i+lat_step != (iterate_lat_end + lat_step)){ //+1 lat
                    bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)].addDestination(bodyGraph[(int)((i+lat_step)*p_mult)][(int)(j*p_mult)]); }
                if(i-lat_step != (iterate_lat_start - lat_step)){ //-1 lat
                    bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)].addDestination(bodyGraph[(int)((i-lat_step)*p_mult)][(int)(j*p_mult)]); }
                if(j+lng_step != (iterate_lng_end + lng_step)){ //+1 lng
                    bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)].addDestination(bodyGraph[(int)(i*p_mult)][(int)((j+lng_step)*p_mult)]); }
                if((i+lat_step != (iterate_lat_end + lat_step)) && (j+lng_step != (iterate_lng_end + lng_step))){ //+1 lat +1 lng
                    bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)].addDestination(bodyGraph[(int)((i+lat_step)*p_mult)][(int)((j+lng_step)*p_mult)]); }
                if((i-lat_step != (iterate_lat_start - lat_step)) && (j+lng_step != (iterate_lng_end + lng_step))){ //-1 lat +1 lng
                    bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)].addDestination(bodyGraph[(int)((i-lat_step)*p_mult)][(int)((j+lng_step)*p_mult)]); }
            }
        }
        System.out.println("Linked nodes.");
        
        //Adds nodes
        Graph graph = new Graph();
        for(double i = iterate_lat_start; i != (iterate_lat_end + lat_step); i+=lat_step ){
            for(double j = iterate_lng_start; j != (iterate_lng_end + lng_step); j+=lng_step ){
                graph.addNode(bodyGraph[(int)(i*p_mult)][(int)(j*p_mult)]);
            }
        }        
        System.out.println("Added nodes to graph.\n");
        

        System.out.println("Performing shortest path search.");
        Node startNode = bodyGraph[(int)(lat_start*p_mult)][(int)((lng_f <= lng_b ? 0 : lng_diff)*p_mult)];
        Node endNode = bodyGraph[(int)(lat_end*p_mult)][(int)((lng_f <= lng_b ? lng_diff : 0)*p_mult)];
        //Node startNode = bodyGraph[(int)((lat_f <= lat_b ? 0 : lat_diff)*p_mult)][(int)((lng_f <= lng_b ? 0 : lng_diff)*p_mult)];
        //Node endNode = bodyGraph[(int)((lat_f <= lat_b ? lat_diff : 0)*p_mult)][(int)((lng_f <= lng_b ? lng_diff : 0)*p_mult)];
        graph = calculateShortestPathFromSource(graph, startNode);        
        List<Node> path = endNode.getShortestPath();
        //List<String> returnPath = new LinkedList<>(); 
        String result = "";
        for(int i = 0; i < path.size(); i++){
            //returnPath.add(path.get(i).getName());
            result += ("\"" + path.get(i).getName() + "\",\n");
            System.out.println(path.get(i).getName());
        }
        result += ("\"" + endNode.getName() + "\"");
        System.out.println(endNode.getName());
        
        //Maybe add a bit for removing nodes in the path where weight=0?
        
        return result;
    }
        
        
    //----------------------------------------------------------------------------------------------------------------------\
    //                                                  Functions                                                           |
    //----------------------------------------------------------------------------------------------------------------------/ 
        
        
        public static void loadGraph(){
            /*Node nodeA = new Node("A");
            Node nodeB = new Node("B");
            Node nodeC = new Node("C");
            Node nodeD = new Node("D"); 
            Node nodeE = new Node("E");
            Node nodeF = new Node("F");

            nodeA.addUndirectedDestination(nodeB, 10);
            nodeA.addUndirectedDestination(nodeC, 15);

            nodeB.addUndirectedDestination(nodeD, 12);
            nodeB.addUndirectedDestination(nodeF, 15);

            nodeC.addUndirectedDestination(nodeE, 10);

            nodeD.addUndirectedDestination(nodeE, 2);
            nodeD.addUndirectedDestination(nodeF, 1);

            nodeF.addUndirectedDestination(nodeE, 5);

            Graph graph = new Graph();

            graph.addNode(nodeA);
            graph.addNode(nodeB);
            graph.addNode(nodeC);
            graph.addNode(nodeD);
            graph.addNode(nodeE);
            graph.addNode(nodeF);

            graph = calculateShortestPathFromSource(graph, nodeF);
            Node target = graph.getNode(nodeC);            
            List<Node> path = target.getShortestPath();
            for(int i = 0; i < path.size(); i++){
                System.out.println(path.get(i).getName());
            }*/
        }
        
        
        private static Graph calculateShortestPathFromSource(Graph graph, Node source) {
            source.setDistance(0.0);

            Set<Node> settledNodes = new HashSet<>();
            Set<Node> unsettledNodes = new HashSet<>();

            unsettledNodes.add(source);

            while (unsettledNodes.size() != 0) {
                //System.out.println("Nodes left : " + unsettledNodes.size());
                Node currentNode = getLowestDistanceNode(unsettledNodes);
                unsettledNodes.remove(currentNode);
                for (Entry < Node, Double> adjacencyPair: 
                  currentNode.getAdjacentNodes().entrySet()) {
                    Node adjacentNode = adjacencyPair.getKey();
                    Double edgeWeight = adjacencyPair.getValue();
                    if (!settledNodes.contains(adjacentNode)) {
                        CalculateMinimumDistance(adjacentNode, edgeWeight, currentNode);
                        unsettledNodes.add(adjacentNode);
                    }
                }
                settledNodes.add(currentNode);
            }
            return graph;
        }
        
        
        private static Node getLowestDistanceNode(Set < Node > unsettledNodes) {
            Node lowestDistanceNode = null;
            double lowestDistance = Double.MAX_VALUE;
            for (Node node: unsettledNodes) {
                double nodeDistance = node.getDistance();
                if (nodeDistance < lowestDistance) {
                    lowestDistance = nodeDistance;
                    lowestDistanceNode = node;
                }
            }
            return lowestDistanceNode;
        }

        private static void CalculateMinimumDistance(Node evaluationNode,
            Double edgeWeigh, Node sourceNode) {
            Double sourceDistance = sourceNode.getDistance();
            if (sourceDistance + edgeWeigh < evaluationNode.getDistance()) {
                evaluationNode.setDistance(sourceDistance + edgeWeigh);
                LinkedList<Node> shortestPath = new LinkedList<>(sourceNode.getShortestPath());
                shortestPath.add(sourceNode);
                evaluationNode.setShortestPath(shortestPath);
            }
        }
        
        private static double WLAT(double coordinate) {
            if(coordinate < 0) return (360 + coordinate);
            else if (coordinate > 180) return (coordinate - 360);
            else return coordinate;
        }
        
        private static double WLNG(double coordinate) {
            if(coordinate < 0) return (360 + coordinate);
            else if (coordinate > 360) return (coordinate - 360);
            else return coordinate;
        }
        
        private static double LTC (String line, double precision){        
            return round(Double.parseDouble(line)*(1/precision))/(1/precision);      
        }
        
        
        
        private static double getNodeAltitude(double lat, double lng, double precision, List<String> lines){
            double p_mult = (1/precision);
            //The squared makes sense, but why +2? 1 for precision, why the other?
            int index = (int)(lat*360*Math.pow(p_mult, 2) + lng*p_mult + 2) ; //*360 because 360 lngs for every lat
            //int index = (int)(lat*360*Math.pow(p_mult, 2) + lng*p_mult); //*360 because 360 lngs for every lat
            return Double.parseDouble(lines.get(index));
        }
}






