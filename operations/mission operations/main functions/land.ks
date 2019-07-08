	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _landCoordinates.

	
//--------------------------------------------------------------------------\
//								Program run					   				|
//--------------------------------------------------------------------------/
	
	
	//----------------------------------------------------\
	//Move into equatorial orbit--------------------------|
		throwEvent(SHIP:BODY:NAME + "_LAND_PREPARE").
		//At a later point, create a script that can land from any orbit.
		//RUNPATH("operations/mission operations/intermediate functions/setOrbit.ks", maxTimes, orbitLex).
		
	//----------------------------------------------------\
	//Execute the landing script--------------------------|
		throwEvent(SHIP:BODY:NAME + "_LAND_START").
		RUNPATH("operations/mission operations/intermediate functions/land.ks", _landCoordinates). //Second parameter is periapsis from body center

		
	throwEvent(SHIP:BODY:NAME + "_LAND_COMPLETE").