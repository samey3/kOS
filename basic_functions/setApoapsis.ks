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
			RUNPATH ("basic_functions/nodeBurn.ks", ETA:PERIAPSIS, burnAmount, 1). }
		ELSE {
			RUNPATH ("basic_functions/nodeBurn.ks", ETA:PERIAPSIS, -burnAmount, 2). }
	}
	
	IF(_precise){
		RUNPATH ("basic_functions/modVelocity.ks", SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_periVel_mag, 0, 3). }
		
	IF(_ensureSpeed){
		RUNPATH ("basic_functions/modSpeed.ks", req_periVel_mag, 0, 2). }
	