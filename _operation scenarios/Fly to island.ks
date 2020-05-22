	RUNONCEPATH("lib/config.ks").
	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/fileIO.ks").
	
	
	//Variables		
		LOCAL airParameterLex IS LEXICON().
			//Basic parameters
			SET airParameterLex["action"] TO "fly". 									//takeoff, fly, land
			SET airParameterLex["fastbuild"] TO TRUE. 									//TRUE, FALSE
			SET airParameterLex["resetcontrols"] TO FALSE. 								//TRUE, FALSE
			
			//Takeoff
			SET airParameterLex["takeoffheading"] TO 90. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["climbaltitude"] TO 1000. 								//Altitude to climb to on takeoff
			SET airParameterLex["climbpitch"] TO 10. 									//Degrees off of horizon
			
			//Flying
			SET airParameterLex["flylocation"] TO getCoordinates("Island runway").		//Geoposition to fly to
			SET airParameterLex["flyaltitude"] TO 10000.								//Altitude above the coordinates to fly to
			SET airParameterLex["flyspeed"] TO 200.										//Cruising speed of the craft
			SET airParameterLex["maxerror"] TO 400.										//Maximum error distance for the point to count as having been 'reached' by the craft

	//Event listeners
		addListener("KERBIN_TAKEOFF_ENGINE_STARTUP", { STAGE. }, FALSE).
		
	//Mission steps:
		configureVessel("F22-Flight").
		//RUNPATH("operations/air operations/airBuilder.ks", airParameterLex).
		
		UNTIL(FALSE){
			SET airParameterLex["flyaltitude"] TO 10000.
			SET airParameterLex["flylocation"] TO getCoordinates("Island runway").
			RUNPATH("operations/air operations/airBuilder.ks", airParameterLex).
			SET airParameterLex["flyaltitude"] TO 3000.
			SET airParameterLex["flylocation"] TO getCoordinates("Launch pad").
			RUNPATH("operations/air operations/airBuilder.ks", airParameterLex).
		}