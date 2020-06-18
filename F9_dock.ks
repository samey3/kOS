	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
		
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO VESSEL("ISS").
			SET parameterLex["action"] TO "dock".
			SET parameterLex["fastbuild"] TO TRUE.
			
			//Docking
			SET parameterLex["targdocktag"] TO "f9". 										//Empty, "random", "tag name"
			//SET parameterLex["selfdocktag"] TO "". 										//Empty, "random", "tag name"
	
	//Event listeners

		
	//Mission steps:
		configureVessel().
		RUNPATH("F9_land/missionBuilder_temp.ks", parameterLex).
		