	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	//Variables		
		LOCAL airParameterLex IS LEXICON().
			//Basic parameters
			SET airParameterLex["action"] TO "takeoff". 								//takeoff, fly, land
			SET airParameterLex["fastbuild"] TO FALSE. 									//TRUE, FALSE
			SET airParameterLex["resetcontrols"] TO FALSE. 								//TRUE, FALSE
			
			//Takeoff
			SET airParameterLex["takeoffheading"] TO 90. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["climbaltitude"] TO 3000. 								//Altitude to climb to on takeoff
			SET airParameterLex["climbpitch"] TO 25. 									//Degrees off of horizon

	//Event listeners
		addListener("KERBIN_TAKEOFF_ENGINE_STARTUP", { STAGE. }, FALSE).
		
	//Mission steps:
		configureVessel("F22-Takeoff").
		RUNPATH("operations/air operations/airBuilder.ks", airParameterLex).