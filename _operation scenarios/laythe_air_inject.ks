	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	RUNONCEPATH("lib/fileIO.ks").
		
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO LAYTHE.
			SET parameterLex["action"] TO "land".
			SET parameterLex["reenteronly"] TO TRUE.
			
			//Landing
			SET parameterLex["landingcoordinates"] TO 0. // Immediatelly land anywhere
	
		LOCAL airParameterLex IS LEXICON().
			//Basic parameters
			SET airParameterLex["action"] TO "fly". 									//takeoff, fly, land
			SET airParameterLex["fastbuild"] TO TRUE. 									//TRUE, FALSE
			SET airParameterLex["resetcontrols"] TO TRUE. 								//TRUE, FALSE
			
			//Takeoff
			SET airParameterLex["takeoffheading"] TO 90. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["climbaltitude"] TO 1000. 								//Altitude to climb to on takeoff
			SET airParameterLex["climbpitch"] TO 10. 									//Degrees off of horizon
			
			//Flying
			//SET airParameterLex["flylocation"] TO getCoordinates("Island runway").		//Geoposition to fly to
			SET airParameterLex["flyaltitude"] TO 5000.								//Altitude above the coordinates to fly to
			SET airParameterLex["flyspeed"] TO 400.										//Cruising speed of the craft
			SET airParameterLex["maxerror"] TO 400.										//Maximum error distance for the point to count as having been 'reached' by the craft
	
			//Landing
			SET airParameterLex["landinglocation"] TO LAYTHE:GEOPOSITIONLATLNG(39.5947, -283.0518). 	//Geoposition, 0 (no coordinates, land anywhere)
			SET airParameterLex["landingheading"] TO 308.539. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["landingspeed"] TO 80. 									//Speed to land at, varies per craft and body
			SET airParameterLex["descentdistance"] TO 10000. 							//Distance from location for start of descent
	
	//Event listeners
		// Liftoff
		addListener("LAYTHE_BUILT", {
			handlePartAction("1", "activate engine").
			handlePartAction("1", "extend solar panel").
		}, FALSE).			
		
		// Injection
		addListener("LAYTHE_LAND_1", {
			handlePartAction("2", "activate engine").
			
		}, FALSE).	
		
	//Mission steps:
		// Run space ops and deorbit
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).
		
		WAIT 5.
		LOCK STEERING TO SHIP:VELOCITY:FACING.
		RCS ON.
		WAIT 15.
		RCS OFF.
		
		configureVessel("F22-Raptor kOS").
		RUNPATH("operations/air operations/airBuilder.ks", airParameterLex).