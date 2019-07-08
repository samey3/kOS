	CLEARSCREEN.

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _radius.
	PARAMETER _precise IS FALSE.


//--------------------------------------------------------------------------\
//								Variables					   				|
//--------------------------------------------------------------------------/


	//LOCAL _periapsis IS SHIP:BODY:RADIUS + SHIP:ORBIT:PERIAPSIS.
	LOCAL _apoapsis IS SHIP:BODY:RADIUS + SHIP:ORBIT:APOAPSIS.	


//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/


	IF(_radius > _apoapsis){
		RUNPATH ("basic_functions/setApoapsis.ks", _radius, _precise).
		RUNPATH ("basic_functions/setPeriapsis.ks", _radius, _precise).
	}
	ELSE {
		RUNPATH ("basic_functions/setPeriapsis.ks", _radius, _precise).
		RUNPATH ("basic_functions/setApoapsis.ks", _radius, _precise).
	}