
LOCAL requestPath IS "processing/requests/job_request.kr".
LOCAL resultPath IS  "processing/requests/job_result.kr".



function request{

}


//Returns a queue structure
function findPath {
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
	WAIT UNTIL VOLUME(0):EXISTS(resultPath).		
		
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
function clean {
  deletepath(requestPath).
  deletepath(resultPath).
}