	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO KERBIN. 										//Vessel("vessel name")
			SET parameterLex["action"] TO "orbit". 										//orbit, rendezvous, dock, land, launch
			SET parameterLex["fastbuild"] TO FALSE. 									//TRUE, FALSE
			SET parameterLex["resetcontrols"] TO TRUE. 									//TRUE, FALSE
			
			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO KERBIN:BODY:RADIUS + 185000.
			SET parameterLex["eccentricity"] TO 0.
			SET parameterLex["inclination"] TO 30.
			SET parameterLex["longitudeofascendingnode"] TO 0.
			SET parameterLex["argumentofperiapsis"] TO 0.
			SET parameterLex["trueanomaly"] TO 0.
			
	//Custom events
		//ON(){
			//Code
			//PRESERVE.
		//}

	
	//Event listeners
		addListener("KERBIN_LAUNCH_LIFTOFF", {
			handlePartAction("1", "activate engine").
			handlePartAction("1", "release clamp").
		}, FALSE).
	
		//First stage finished
		addListener("KERBIN_LAUNCH_FLAMEOUT_8", {		
			handlePartAction("2", "decouple").			
		}, FALSE).
		
		//Second stage finished
		addListener("KERBIN_LAUNCH_FLAMEOUT_13", {
			handlePartAction("3", "activate engine").
			WAIT 0.01.			
			handlePartAction("3", "decouple").							
		}, FALSE).

		addListener("KERBIN_LAUNCH_COMPLETE", {		
			handlePartAction("6", "activate engine").
			WAIT 0.01.
			handlePartAction("6", "decouple").
		
			handlePartAction("4", "decouple").
			WAIT 0.01.
			handlePartAction("4", "activate engine").
			WAIT 5.
			handlePartAction("panels", "extend solar panel").
		}, FALSE).
		
		
		//Some stage:
		// Bottom decoupler, top decoupler, escape tower engines
		
		//Abort:
		// Bottom decoupler, escape tower engines
		
		
		
		
	//Mission steps:
		configureVessel(). //Configured with a ship config. Call this again with a specific vessel name if e.g. rocket becomes a rover
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).
		
		WAIT 20.
		
		SET parameterLex["semimajoraxis"] TO KERBIN:BODY:RADIUS + 300000.
		//RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).