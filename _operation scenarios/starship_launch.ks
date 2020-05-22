	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["action"] TO "orbit".
			SET parameterLex["entity"] TO KERBIN.

			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO 1900000.
			SET parameterLex["eccentricity"] TO 0.63158.
			SET parameterLex["inclination"] TO 89.
			SET parameterLex["longitudeofascendingnode"] TO 0.
			SET parameterLex["argumentofperiapsis"] TO 0.
			SET parameterLex["trueanomaly"] TO 0.
	
	
	//Custom events

	
	//Event listeners
		//Liftoff
		addListener("KERBIN_LAUNCH_LIFTOFF", {
			handlePartAction("1", "activate engine").
			handlePartAction("1", "release clamp").
			IF(GEAR){
				GEAR OFF.
			}
		}, FALSE).	
		
		//Booster flameout
		addListener("KERBIN_LAUNCH_FLAMEOUT_9", {	
			handlePartAction("2", "decouple").						
			WAIT 0.01.
			handlePartAction("2", "activate engine").	
		}, FALSE).	
		
		//Booster flameout
		addListener("KERBIN_LAUNCH_COASTING", {	
			handlePartAction("2", "decouple").						
			WAIT 0.01.
			handlePartAction("2", "activate engine").	
		}, FALSE).
		
		
	//Mission steps:
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).