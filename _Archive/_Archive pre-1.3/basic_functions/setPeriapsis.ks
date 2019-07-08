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
			RUNPATH ("basic_functions/nodeBurn.ks", ETA:APOAPSIS, burnAmount, 1). }
		ELSE {
			RUNPATH ("basic_functions/nodeBurn.ks", ETA:APOAPSIS, -burnAmount, 2). }
	}

	IF(_precise){
		RUNPATH ("basic_functions/modVelocity.ks", SHIP:BODY, VCRS(VCRS(SHIP:POSITION - SHIP:BODY:POSITION, SHIP:VELOCITY:ORBIT), SHIP:POSITION - SHIP:BODY:POSITION):NORMALIZED*req_apoVel_mag, 0, 3). }
		
	IF(_ensureSpeed){
		RUNPATH ("basic_functions/modSpeed.ks", req_apoVel_mag, 0, 2). }