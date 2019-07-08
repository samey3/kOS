/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package kos_processor;

//import static Jobs.pathFind.findPath;
//import static Jobs.lambertOptimize.solveLambert;
import Jobs.*;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Stephen
 */
public class Main {

    private static final String JOB_ROOT = System.getProperty("user.dir") + "\\requests\\"; //Will be in a 'processing' directory under scripts
    private static final Path JOB_REQUEST = Paths.get(JOB_ROOT + "job_request.kr");
    private static final Path JOB_RESULT = Paths.get(JOB_ROOT + "job_result.kr");
    
    public static void main(String[] args) throws InterruptedException, FileNotFoundException, IOException {
        System.out.println("Root : " + JOB_ROOT);
        
        //Keeps looping, waiting for more job requests
        while(true){
            while (!Files.exists(JOB_REQUEST)) {
		Thread.sleep(1000);
            }
            
            //Waits once more to ensure kOS has finished writing data
            System.out.println("Saw job request, beginning processing.");
            //Thread.sleep(1000);
            
            //Reads in all lines
            List<String> lines = Files.readAllLines(JOB_REQUEST);
            
            //Gets the request type and arguments
            String requestType = lines.get(0);
            List<String> requestArgs = lines.subList(1, lines.size());

            System.out.println("Received request: " + requestType);           
            String result = "";
            switch (requestType) {
                case "pathFind":
                    //Returns result as a queue of coordinates to follow
                    result += "{\n\"items\": [\n";
                    result += pathFind.findPath(requestArgs);
                    result += "\n],\n \"$type\": \"kOS.Safe.Encapsulation.QueueValue\"\n }";
                    
                    //Outputs the result data
                    try (PrintWriter writer = new PrintWriter(JOB_RESULT.toString())) {
                        writer.write(result);
                    }
            
                    //Break from case
                    break;
                case "lambertOptimize":
                    //Output the result
                    try (PrintWriter pw = new PrintWriter(JOB_RESULT.toString())) {
			Utils.MapOutput.writeMap(lambertOptimize.solveLambert(requestArgs), pw, "");
                    }
                    
                    //Break from case
                    break;
                default:
                    System.out.println("Unknown request type: " + requestType);
                    throw new IllegalArgumentException("Unknown request type: " + requestType);
            }
            
            //Deletes the request
            Files.delete(JOB_REQUEST);
        }
    }    
}