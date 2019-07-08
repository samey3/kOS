//Imports the burn functions
runoncepath("lib/burnManeuvers.ks").


FUNCTION setPeriapsis {
		CLEARSCREEN.

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _periapsis.
		PARAMETER _precise IS FALSE.
		PARAMETER _ensureSpeed IS FALSE.


	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/


		//Finds the current apoapsis
		LOCAL _apoapsis IS APOAPSIS + SHIP:BODY:RADIUS.	

		//Finds the required orbit parameters
		LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
		LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).	
		LOCAL req_apoVel_mag IS SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).
			
		//Finds the required amount of velocity to change at the apoapsis
		LOCAL apoVel_mag IS VELOCITYAT(SHIP,TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG.
		LOCAL burnAmount IS (req_apoVel_mag - apoVel_mag).


	//--------------------------------------------------------------------------\
	//								Program run					   				|
	//--------------------------------------------------------------------------/


		IF(ABS(_periapsis - (PERIAPSIS + SHIP:BODY:RADIUS)) > 300){
			IF(burnAmount > 0){
				nodeBurn(ETA:APOAPSIS, burnAmount, 1). }
			ELSE {
				nodeBurn(ETA:APOAPSIS, -burnAmount, 2). }
		}

		IF(_precise){
			modVelocity(SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_apoVel_mag, 0, 3). }
			
		IF(_ensureSpeed){
			modSpeed(req_apoVel_mag, 0, 2). }
}

FUNCTION setPeriapsisRCS {
		CLEARSCREEN.

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _periapsis.


	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/


		//Finds the current apoapsis
		LOCAL _apoapsis IS APOAPSIS + SHIP:BODY:RADIUS.	

		//Finds the required orbit parameters
		LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
		LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).	
		LOCAL req_apoVel_mag IS SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).
			
		//Finds the required amount of velocity to change at the apoapsis
		LOCAL apoVel_mag IS VELOCITYAT(SHIP,TIME:SECONDS + ETA:APOAPSIS):ORBIT:MAG.
		LOCAL burnAmount IS (req_apoVel_mag - apoVel_mag).


	//--------------------------------------------------------------------------\
	//								Program run					   				|
	//--------------------------------------------------------------------------/


		IF(burnAmount > 0){
			nodeBurn(ETA:APOAPSIS, burnAmount, 1). }
		ELSE {
			nodeBurn(ETA:APOAPSIS, -burnAmount, 2). }
}

FUNCTION setApoapsis {
		CLEARSCREEN.

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _apoapsis.
		PARAMETER _precise IS FALSE.
		PARAMETER _ensureSpeed IS FALSE.


	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/


		//Finds the current apoapsis
		LOCAL _periapsis IS PERIAPSIS + SHIP:BODY:RADIUS.	

		//Finds the required orbit parameters
		LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
		LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).
		LOCAL req_periVel_mag IS SQRT(((1 + req_eccentricity) / (1 - req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
		
		//Finds the required amount of velocity to change at the apoapsis
		LOCAL periVel_mag IS VELOCITYAT(SHIP,TIME:SECONDS + ETA:PERIAPSIS):ORBIT:MAG.
		LOCAL burnAmount IS req_periVel_mag - periVel_mag.

		
	//--------------------------------------------------------------------------\
	//								Program run					   				|
	//--------------------------------------------------------------------------/


		IF(ABS(_apoapsis - (APOAPSIS + SHIP:BODY:RADIUS)) > 300){
			IF(burnAmount > 0){ 
				nodeBurn(ETA:PERIAPSIS, burnAmount, 1). }
			ELSE {
				nodeBurn(ETA:PERIAPSIS, -burnAmount, 2). }
		}
		
		IF(_precise){
			modVelocity(SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_periVel_mag, 0, 3). }
			
		IF(_ensureSpeed){
			modSpeed(req_periVel_mag, 0, 2). }
}

FUNCTION setApoapsisRCS {
		CLEARSCREEN.

	//--------------------------------------------------------------------------\
	//								Parameters					   				|
	//--------------------------------------------------------------------------/


		PARAMETER _apoapsis.


	//--------------------------------------------------------------------------\
	//								Variables					   				|
	//--------------------------------------------------------------------------/


		//Finds the current apoapsis
		LOCAL _periapsis IS PERIAPSIS + SHIP:BODY:RADIUS.	

		//Finds the required orbit parameters
		LOCAL req_SMA IS (_apoapsis + _periapsis)/2.		
		LOCAL req_eccentricity IS (_apoapsis - _periapsis) / (_apoapsis + _periapsis).
		LOCAL req_periVel_mag IS SQRT(((1 + req_eccentricity) / (1 - req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
		
		//Finds the required amount of velocity to change at the apoapsis
		LOCAL periVel_mag IS VELOCITYAT(SHIP,TIME:SECONDS + ETA:PERIAPSIS):ORBIT:MAG.
		LOCAL burnAmount IS req_periVel_mag - periVel_mag.

		
	//--------------------------------------------------------------------------\
	//								Program run					   				|
	//--------------------------------------------------------------------------/

		IF(burnAmount > 0){ 
			nodeBurn(ETA:PERIAPSIS, burnAmount, 1). }
		ELSE {
			nodeBurn(ETA:PERIAPSIS, -burnAmount, 2). }
}

FUNCTION setRadius {
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
			nodeBurn(_timeToBurn, burnAmount, 1).
			
			IF(_precise){
			modVelocity(SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_periMag, 0, 2). }
		}
		ELSE { //Apoapsis maneuver, decreasing periapsis
			LOCAL req_ApoMag IS SQRT(((1 - req_eccentricity) / (1 + req_eccentricity)) * (SHIP:BODY:MU / req_SMA)).	
			LOCAL burnAmount IS ABS(req_ApoMag - VELOCITYAT(SHIP,TIME:SECONDS + _timeToBurn):ORBIT:MAG).
			nodeBurn(_timeToBurn, burnAmount, 2).
			
			IF(_precise){
			modVelocity(SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_apoMag, 0, 2). }
		}
}