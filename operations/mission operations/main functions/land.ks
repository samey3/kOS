	@lazyglobal OFF.
	CLEARSCREEN.
	

//--------------------------------------------------------------------------\
//								 Parameters					   				|
//--------------------------------------------------------------------------/


	PARAMETER _parameterLex.
	

//--------------------------------------------------------------------------\
//								 Variables					   				|
//--------------------------------------------------------------------------/


	//Lexicon extraction
	LOCAL landingCoordinates IS 0.
		IF(_parameterLex:HASKEY("landingcoordinates")){ SET landingCoordinates TO _parameterLex["landingcoordinates"]. }
	LOCAL interceptAltitude IS (SHIP:BODY:RADIUS - 50000).
		IF(_parameterLex:HASKEY("interceptaltitude")){ SET interceptAltitude TO _parameterLex["interceptaltitude"]. }
	
	
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
		RUNPATH("operations/mission operations/intermediate functions/land.ks", landingCoordinates, interceptAltitude). //Second parameter is periapsis from body center

		
	throwEvent(SHIP:BODY:NAME + "_LAND_COMPLETE").