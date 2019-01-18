	@lazyglobal OFF.
	SET STAGE_ID TO "LAND_MAIN".
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
		SET STAGE_ID TO "LAND_PREPARE".
		//At a later point, create a script that can land from any orbit.
		//RUNPATH("mission operations/intermediate functions/refineOrbit.ks", maxTimes, orbitLex).
		
	//----------------------------------------------------\
	//Execute the landing script--------------------------|
		SET STAGE_ID TO "LAND_START".
		RUNPATH("mission operations/intermediate functions/land.ks", _landCoordinates). //Second parameter is periapsis from body center

		
	SET STAGE_ID TO "LAND_COMPLETE".