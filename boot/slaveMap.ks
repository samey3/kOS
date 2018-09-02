	CLEARSCREEN.
	SWITCH TO 0.

	
//--------------------------------------------------------------------------\
//								 Variables					   				|
//--------------------------------------------------------------------------/


	PRINT("W1").
	WAIT UNTIL NOT CORE:MESSAGES:EMPTY.	
		LOCAL precision IS CORE:MESSAGES:POP:CONTENT().
	PRINT("W2").
	WAIT UNTIL NOT CORE:MESSAGES:EMPTY.	
		LOCAL coreNumber IS CORE:MESSAGES:POP:CONTENT().
	PRINT("W3").
	WAIT UNTIL NOT CORE:MESSAGES:EMPTY.	
		LOCAL startStep IS CORE:MESSAGES:POP:CONTENT().
	PRINT("W4").
	WAIT UNTIL NOT CORE:MESSAGES:EMPTY.	
		LOCAL stopStep IS CORE:MESSAGES:POP:CONTENT().

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/

	
	//PRINT("Loc : " + CORE:VOLUME:ROOT).
	//SET testOutput TO CREATE("mapData/testOutput_" + coreNumber + "_.txt").
	//	testOutput:WRITELN("Precision : " + precision).
	//	testOutput:WRITELN("Core : " + coreNumber).
	//	testOutput:WRITELN("Start : " + startStep).
	//	testOutput:WRITELN("Stop : " + stopStep).
	
	//Makes sure precision is proper
	SET precision TO ROUND(precision*100)/100.
	

	//Creates the file, adds the header info
	SET mapOutput TO CREATE("mapData/heightMap_" + SHIP:BODY:NAME + "_" + precision + "_" + coreNumber + ".txt").

	//Starts mapping
	SET startTime TO TIME:SECONDS.
	FROM { LOCAL i IS startStep. } UNTIL (i >= stopStep) STEP { SET i TO ROUND((i + precision)*10)/10. } DO { 
		mapOutput:WRITELN("" + LATLNG(90 - FLOOR(i/360)*precision, i):TERRAINHEIGHT). //Can just use i here since kOS auto wraps coordinates. Makes it slightly faster //:TERRAINHEIGHT
	}
	PRINT("Time : " + (TIME:SECONDS - startTime)).

	
	