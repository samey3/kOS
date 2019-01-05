	CLEARSCREEN.
	
	//----------------------------------------------|
	//	 precision 	|	    time		|	 size	|
	//		1.0 	|	208.5s (3.5m)	|	1037kB	|
	//----------------------------------------------|
	// At base precision, it takes 3.5m .			|
	// For n-times accuracy, time and precision are |
	// multiplied by n^2.							|
	//												|
	// E.g. 4x accuracy, time = 3.5m * 4^2,			|
	// size = 1037kB * 4^2							|
	//----------------------------------------------/
	//4x, 3354.6s, 18.3mB
	
	
	//Passing in a request:
	//Lat : 90 - lat(-90 to 90), always results in positive 0->180
	//Lng: Use a wrap, if -, add 360.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _precision IS 1.
	PARAMETER startStep IS 0.
	PARAMETER stopStep IS 0.
	

//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	//Creates the file, adds the header info
	SET mapOutput TO CREATE("heightMap_" + SHIP:BODY:NAME + "_" + _precision + ".txt").
		mapOutput:WRITELN("" + _precision).

	//Starts mapping
	SET startTime TO TIME:SECONDS.
	IF(stopStep = 0){
		SET stopStep TO 182*360*(1/_precision). //181*, stops it right before it reaches 182, but does 1-181 (0-180) and their full 360's
	}
	FROM { LOCAL i IS startStep. } UNTIL (i = stopStep) STEP { SET i TO (i + _precision). } DO { 
		mapOutput:WRITELN("" + LATLNG(90 - FLOOR(i/360)*_precision, i):TERRAINHEIGHT). //Can just use i here since kOS auto wraps coordinates. Makes it slightly faster
	}
	PRINT("Time : " + (TIME:SECONDS - startTime)).
	
	//Do a double for up to 181/360
	
	