	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	
	
			
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO KERBIN. //Vessel("vessel name")
			SET parameterLex["action"] TO "orbit". //Orbit, rendezvous, dock, land, launch
			
			//Docking
			SET parameterLex["targdocktag"] TO "". //Empty, "random", "tag name"
			SET parameterLex["selfdocktag"] TO "". //Empty, "random", "tag name"
			SET parameterLex["standoffDistance"] TO 100.
			
			//Landing
			SET parameterLex["landingcoordinates"] TO KERBIN:GEOPOSITIONLATLNG(0,0).
			SET parameterLex["interceptaltitude"] TO 0.
			
			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO 1000750.
			SET parameterLex["eccentricity"] TO 0.60.
			SET parameterLex["inclination"] TO 85.
			SET parameterLex["longitudeofascendingnode"] TO 30.
			SET parameterLex["argumentofperiapsis"] TO 20.
			SET parameterLex["trueanomaly"] TO 60.
	
	//Custom events
		//ON(){
			//Code
			//PRESERVE.
		//}

	
	//Event listeners
		//addListener("BATTERIES_DEPLETED", {
		//	PRINT("hello").
		//}, TRUE). //True preserves the eventListener (it can handle the event again). False means it will only handle it once
		
	//Mission steps:
		configureVessel(). //Configured with a ship config. Call this again with a specific vessel name if e.g. rocket becomes a rover
		RUNPATH("operations/mission operations/missionBuilder.ks").