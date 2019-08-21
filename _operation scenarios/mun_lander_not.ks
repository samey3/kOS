	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	
	
			
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			//SET parameterLex["entity"] TO DUNA. //Vessel("vessel name")
			//SET parameterLex["action"] TO "orbit". //Orbit, rendezvous, dock, land, launch
			
			SET parameterLex["entity"] TO DUNA. //Vessel("vessel name")
			SET parameterLex["action"] TO "land". //Orbit, rendezvous, dock, land, launch
			
			//Docking
			SET parameterLex["targdocktag"] TO "". //Empty, "random", "tag name"
			SET parameterLex["selfdocktag"] TO "". //Empty, "random", "tag name"
			SET parameterLex["standoffDistance"] TO 100.
			
			//Landing
			SET parameterLex["landingcoordinates"] TO DUNA:GEOPOSITIONLATLNG(0,0).
			SET parameterLex["interceptaltitude"] TO DUNA:RADIUS - 20000.
			
			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO 375000.
			SET parameterLex["eccentricity"] TO 0.001.
			SET parameterLex["inclination"] TO 0.
			SET parameterLex["longitudeofascendingnode"] TO 0.
			SET parameterLex["argumentofperiapsis"] TO 0.
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