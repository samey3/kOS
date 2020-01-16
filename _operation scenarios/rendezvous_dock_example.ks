	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
		
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO VESSEL("dock_target").
			SET parameterLex["action"] TO "dock".
	
	//Event listeners

		
	//Mission steps:
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).
		