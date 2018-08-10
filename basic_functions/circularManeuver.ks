//This script will set either its new apoapsis or periapsis to the given _radius.
//Starting with a circular orbit, checks whether _radius is smaller or greater than the current radius. Sets the new apoapsis or periapsis.
//Does this at a given time.

	CLEARSCREEN.
	
//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _radius.
	PARAMETER _timeToBurn is 0.
	PARAMETER _precise IS FALSE.
	
	
//---------------------------------------------------------------------------------\
//				  				Top-level function fix							   |
//---------------------------------------------------------------------------------/


	LOCK STEERING TO SHIP:FACING.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	UNLOCK THROTTLE.
	
	
//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/	
	
	
	LOCAL _periapsis IS 0.
	LOCAL _apoapsis IS 0.
	
	IF(_radius > SHIP:ORBIT:SEMIMAJORAXIS){
		SET _periapsis TO SHIP:ORBIT:SEMIMAJORAXIS.
		SET _apoapsis TO _radius.
	}
	ELSE {
		SET _periapsis TO _radius.
		SET _apoapsis TO SHIP:ORBIT:SEMIMAJORAXIS.
	}
	
	LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
	LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).
	
	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
	IF(_radius > SHIP:ORBIT:SEMIMAJORAXIS){ //Periapsis maneuver, increasing apoapsis
		LOCAL req_periMag IS SQRT(((1 + req_eccentricity) / (1 - req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
		LOCAL burnAmount IS ABS(req_periMag - VELOCITYAT(SHIP,TIME:SECONDS + _timeToBurn):ORBIT:MAG).
		RUNPATH ("basic_functions/nodeBurn.ks", _timeToBurn, burnAmount, 1).
		
		IF(_precise){
		RUNPATH ("basic_functions/modVelocity.ks", SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_periMag, 0, 2). }
	}
	ELSE { //Apoapsis maneuver, decreasing periapsis
		LOCAL req_ApoMag IS SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
		LOCAL burnAmount IS ABS(req_ApoMag - VELOCITYAT(SHIP,TIME:SECONDS + _timeToBurn):ORBIT:MAG).
		RUNPATH ("basic_functions/nodeBurn.ks", _timeToBurn, burnAmount, 2).
		
		IF(_precise){
		RUNPATH ("basic_functions/modVelocity.ks", SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_apoMag, 0, 2). }
	}