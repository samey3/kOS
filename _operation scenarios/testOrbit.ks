	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO VESSEL("mahfucka I").
			//SET parameterLex["action"] TO "orbit".
			SET parameterLex["action"] TO "rendezvous".
			
			//Docking
			SET parameterLex["docktag"] TO "".
			
			//Landing
			//SET parameterLex["landingcoordinates"] TO parameterLex["entity"]:GEOPOSITIONLATLNG(-0.0972078366335618,-74.5576783933035). //If not a vessel, set this
			//SET parameterLex["interceptaltitude"] TO 0.
			
			//Orbiting/launching
			SET parameterLex["semimajoraxis"] TO 1012500.
			SET parameterLex["eccentricity"] TO 0.0008050.
			SET parameterLex["inclination"] TO 51.6409.
			SET parameterLex["longitudeofascendingnode"] TO 334.8544.
			SET parameterLex["argumentofperiapsis"] TO 75.7779.
			SET parameterLex["trueanomaly"] TO 60.
	
	//Custom events

	
	//Event listeners
		addListener("BATTERIES_DEPLETED", {
			PRINT("hello").
		}, TRUE).
		
	//Mission steps:
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks").