	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _paramLex.
	
	
//---------------------------------------------------------------------------------\
//				  					Variables									   |
//---------------------------------------------------------------------------------/


	//Lexicon extraction
	LOCAL landingLocation IS _paramLex["landinglocation"].
	LOCAL landingHeading IS _paramLex["landingheading"].
	LOCAL landingSpeed IS _paramLex["landingspeed"].
	LOCAL descentDistance IS _paramLex["descentdistance"].
	
	LOCAL flySpeed IS _paramLex["flyspeed"].
	
	//Descent points
	LOCAL descentStack IS STACK().
	LOCAL altitudeStack IS STACK().
	
	LOCAL startAltitude IS SHIP:ALTITUDE.
	
	LOCAL isLanding IS FALSE.
		
		
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	descentStack:PUSH(-3000). //Runway length
	altitudeStack:PUSH(70 + 20). //Runway alt
	FROM { LOCAL x IS 0. } UNTIL x >= descentDistance STEP { SET x TO x+1500.} DO {
		LOCAL altAtDistance IS startAltitude*(x/(2*descentDistance))^2 + KERBIN:GEOPOSITIONOF(landingLocation:POSITION):TERRAINHEIGHT + 20.
		descentStack:PUSH(x).
		altitudeStack:PUSH(altAtDistance).
	}
	

	//Fly to the starting point
	LOCAL startPoint IS KERBIN:GEOPOSITIONOF(landingLocation:POSITION - HEADING(landingHeading, 0):VECTOR*(descentDistance + 5000)).
	RUNPATH("operations/air operations/intermediate functions/flyToPoint.ks", startPoint, startAltitude + 2000, flySpeed, 500).
	
	UNTIL(descentStack:EMPTY = TRUE OR SHIP:STATUS = "LANDED"){
		LOCAL flyPoint IS KERBIN:GEOPOSITIONOF(landingLocation:POSITION - HEADING(landingHeading, 0):VECTOR*descentStack:POP()).
		LOCAL flyAlt IS altitudeStack:POP().
		IF(descentStack:LENGTH <= 1){ GEAR ON. }
		IF(descentStack:LENGTH <= 0){ BRAKES ON. SET landingSpeed TO 0. }		
		RUNPATH("operations/air operations/intermediate functions/flyToPoint.ks", flyPoint, flyAlt, landingSpeed, 200, isLanding).
		SET isLanding TO TRUE.
	}
	
	LOCK STEERING TO SHIP:FACING.	
	WAIT UNTIL(SHIP:VELOCITY:SURFACE:MAG < 1).
	
	
	
	
	
	
	
	
//How this will work:
//Calls the intermediate function flyToPoint several times
//E.g., queues up a list of points, calls the function for each.