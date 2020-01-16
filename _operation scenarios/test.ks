	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	
	
			
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			//SET parameterLex["entity"] TO DUNA. //Vessel("vessel name")
			//SET parameterLex["action"] TO "orbit". //Orbit, rendezvous, dock, land, launch
			
			SET parameterLex["entity"] TO JOOL. //Vessel("vessel name")
			SET parameterLex["action"] TO "orbit". //Orbit, rendezvous, dock, land, launch

			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO 6100000.
			SET parameterLex["eccentricity"] TO 0.
			SET parameterLex["inclination"] TO 90.
			SET parameterLex["longitudeofascendingnode"] TO 45.
			SET parameterLex["argumentofperiapsis"] TO 50.
			SET parameterLex["trueanomaly"] TO 0.
	
	//Custom events
		//ON(){
			//Code
			//PRESERVE.
		//}

	
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
		configureVessel(). //Configured with a ship config. Call this again with a specific vessel name if e.g. rocket becomes a rover
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).