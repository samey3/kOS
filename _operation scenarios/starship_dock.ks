	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["action"] TO "dock".
			SET parameterLex["entity"] TO VESSEL("SN1").
									
			//Docking
			SET parameterLex["targdocktag"] TO "port".
			SET parameterLex["selfdocktag"] TO "port".
			SET parameterLex["standoffDistance"] TO 100.

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