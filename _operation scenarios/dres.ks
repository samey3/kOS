	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
		
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO MUN.
			SET parameterLex["action"] TO "land".
			
			//Landing
			SET parameterLex["landingcoordinates"] TO MUN:GEOPOSITIONLATLNG(0,0).
			SET parameterLex["interceptaltitude"] TO MUN:RADIUS + 2000.
	
	//Event listeners
		//Liftoff
		addListener("KERBIN_LAUNCH_LIFTOFF", {
			handlePartAction("1", "activate engine").
			handlePartAction("1", "release clamp").
			IF(GEAR){
				GEAR OFF.
			}
		}, FALSE).		
		
		//Boosters finished
		addListener("KERBIN_LAUNCH_FLAMEOUT_4", {		
			handlePartAction("srb", "activate engine").
			WAIT 0.01.
			handlePartAction("srb", "decouple").			
		}, FALSE).		
		
		//Circularization complete
		addListener("KERBIN_LAUNCH_COMPLETE", {
			handlePartAction("panels", "extend solar panel").
			handlePartAction("2", "decouple").
			WAIT 0.01.
			handlePartAction("2", "activate engine").
		}, FALSE).
		
		//Completed deorbit burn at Mun
		addListener("MUN_LAND_2", { //MUN_INJECT_CAPTURED
			handlePartAction("3", "activate engine").
			WAIT 0.01.
			handlePartAction("3", "decouple").
			WAIT 0.01.
		}, FALSE).
		
		//Mun liftoff
		addListener("MUN_LAUNCH_LIFTOFF", {
			IF(GEAR){ GEAR OFF. }
		}, FALSE).
		
		//Completed deorbit burn at Kerbin
		addListener("KERBIN_LAND_2", { //MUN_INJECT_CAPTURED
			handlePartAction("4", "decouple").
			WAIT 0.01.
			CHUTESSAFE ON.
			WAIT 0.01.
			CHUTES ON.
		}, FALSE).
		
	//Mission steps:
		//Lands on the Mun at (0,0)
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).
		
		//WAITs 5 minutes
		CLEARVECDRAWS().
		LOCAL liftoffTime IS TIME:SECONDS + 300.
		UNTIL(TIME:SECONDS >= liftoffTime){
			CLEARSCREEN.
			PRINT("Time until startup : " + ROUND((liftoffTime - TIME:SECONDS), 0) + "s").
			WAIT 0.01.
		}
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		
		//Lands back on Kerbin at the launch pad
		configureVessel("Atlas V lander").
			SET parameterLex["entity"] TO KERBIN.
			SET parameterLex["action"] TO "land".
			SET parameterLex["interceptaltitude"] TO KERBIN:RADIUS.
			SET parameterLex["landingcoordinates"] TO KERBIN:GEOPOSITIONLATLNG(-0.0972078366335618,-74.5576783933035).
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).