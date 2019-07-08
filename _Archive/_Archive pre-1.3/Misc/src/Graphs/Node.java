
package Graphs;

import java.awt.geom.Point2D;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class Node {    
    private String name;    
    private Point2D coordinates;
    private double altitude;
    private List<Node> shortestPath = new LinkedList<>();  
    private Double distance = Double.MAX_VALUE; 
    Map<Node, Double> adjacentNodes = new HashMap<>();

    public void addDestination(Node destination) {
        double dest_latFromPole = 90 - Math.abs(destination.getLatitude() - 90);
        double latitudeDiff = Math.abs(this.getLatitude() - destination.getLatitude());
        double longitudeDiff = Math.abs(this.getLongitude() - destination.getLongitude());
        double point_distance = Math.sqrt(Math.pow(latitudeDiff, 2) + Math.pow(longitudeDiff*(dest_latFromPole/90), 2));  
        double slope = Math.abs(this.getAltitude() - destination.getAltitude())/point_distance;
        
        int sm; //Slope multiplier
        if(this.getAltitude() > 0 && destination.getAltitude() > 0)
            if(slope > 0.25){
                sm = 10000; }
            else if(slope > 0.20){
                sm = 3000; }
            else if(slope > 0.15){
                sm = 200; }
            else if(slope > 0.10){
                sm = 50; }
            else {
                sm = 1; }
        else {
            sm = 99999; }
        
        //double weight = Math.abs(this.getAltitude() - destination.getAltitude());
        //System.out.println("Weight : " + weight*point_distance);
        adjacentNodes.put(destination, sm*point_distance);
        //adjacentNodes.put(destination, point_distance);
        
    }

    public Node(Point2D coordinates, double altitude) {
        this.name = (coordinates.getX() + "_" + coordinates.getY());
        this.coordinates = coordinates;
        this.altitude = altitude;
    }

    // getters and setters
    public String getName(){
        return name;
    }
    
    public double getAltitude(){
        return altitude;
    }
    
    public Double getDistance(){
        return distance;
    }

    public void setDistance(Double distance){
        this.distance = distance;
    }

    public List<Node> getShortestPath(){
        return shortestPath;
    }

    public void setShortestPath(LinkedList<Node> shortestPath){
        this.shortestPath = shortestPath;
    }

    public Map<Node, Double> getAdjacentNodes(){
        return adjacentNodes;
    }
    
    public double getLatitude(){
        return coordinates.getX();
    }
    
    public double getLongitude(){
        return coordinates.getY();
    }
}