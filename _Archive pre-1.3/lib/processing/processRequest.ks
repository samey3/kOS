
LOCAL requestPath IS "lib/processing/requests/job_request.kr".
LOCAL resultPath IS  "lib/processing/requests/job_result.kr".
LOCAL completePath IS  "lib/processing/requests/job_complete.kr".


//Lambert solver and related files obtained/interpreted from
//https://github.com/johnwhall/kos-scripts/blob/master/lib/libmainframe.ks
FUNCTION lambertOptimize {
	PARAMETER p_mu.
	PARAMETER p_r1.
	PARAMETER p_v1.
	PARAMETER p_r2.
	PARAMETER p_v2.
	PARAMETER p_tMin.
	PARAMETER p_tMax.
	PARAMETER p_tStep.
	PARAMETER p_dtMin.
	PARAMETER p_dtMax.
	PARAMETER p_dtStep.
	PARAMETER p_allowLob.
	PARAMETER p_optArrival.

	clean().
	SET job TO CREATE(requestPath).
		job:WRITELN("lambertOptimize").
		job:WRITELN("" + p_mu).
		
		job:WRITELN("" + p_r1:x).
		job:WRITELN("" + p_r1:y).
		job:WRITELN("" + p_r1:z).
		job:WRITELN("" + p_v1:x).
		job:WRITELN("" + p_v1:y).
		job:WRITELN("" + p_v1:z).
		
		job:WRITELN("" + p_r2:x).
		job:WRITELN("" + p_r2:y).
		job:WRITELN("" + p_r2:z).
		job:WRITELN("" + p_v2:x).
		job:WRITELN("" + p_v2:y).
		job:WRITELN("" + p_v2:z).
				
		job:WRITELN("" + p_tMin).
		job:WRITELN("" + p_tMax).
		job:WRITELN("" + p_tStep).
		
		job:WRITELN("" + p_dtMin).
		job:WRITELN("" + p_dtMax).
		job:WRITELN("" + p_dtStep).
		
		job:WRITELN("" + p_allowLob).
		job:WRITELN("" + p_optArrival).
		
		
	//Waits until a result is returned
	WAIT UNTIL (VOLUME(0):EXISTS(completePath)).
	
	//Loads the result into a lexicon
	LOCAL resLex IS LEXICON().
	SET resLex TO READJSON(resultPath).
	
	//Cleans again
	clean().
	
	//Returns the result
	RETURN resLex.
}



//Returns a queue structure
FUNCTION findPath {
	PARAMETER endPosition.	
	LOCAL startPosition IS SHIP:GEOPOSITION.
	CLEARSCREEN.
	clean().
	
	SET job TO CREATE(requestPath).
		job:WRITELN("pathFind").
		job:WRITELN("" + SHIP:BODY:NAME).
		job:WRITELN("" + ABS(90 - SHIP:GEOPOSITION:LAT)).
		job:WRITELN("" + SHIP:GEOPOSITION:LNG).
		job:WRITELN("" + ABS(90 - endPosition:LAT)).
		job:WRITELN("" + endPosition:LNG).
		
	//Waits until a result is returned
	WAIT UNTIL VOLUME(0):EXISTS(completePath).		
		
	//The queue for the strings to be read into
	LOCAL stringQueue IS QUEUE().	
	SET stringQueue TO READJSON(resultPath).
	
	//The geoposition queue
	LOCAL pathQueue IS QUEUE().
	
	UNTIL(stringQueue:EMPTY()){
		LOCAL coordinateString IS stringQueue:POP().
		LOCAL splitList IS coordinateString:SPLIT("_").
		LOCAL nodePosition IS LATLNG((90 - splitList[0]:TOSCALAR(-1)), splitList[1]:TOSCALAR(-1)).
		pathQueue:PUSH(nodePosition).		
	}
	pathQueue:PUSH(endPosition).
	
	//Cleans again
	clean().
	
	//Returns the queue
	RETURN pathQueue.
}

//Cleans up the processing results
FUNCTION clean {
  deletepath(requestPath).
  deletepath(resultPath).
  deletepath(completePath).
}