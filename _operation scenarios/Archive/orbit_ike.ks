	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").

	//Mission variables:
		LOCAL orbitLex IS LEXICON().
			//SET orbitLex["semimajoraxis"] TO 230000.
			SET orbitLex["semimajoraxis"] TO 63000.
			//SET orbitLex["semimajoraxis"] TO 350000.
			SET orbitLex["eccentricity"] TO 0.
			SET orbitLex["inclination"] TO 90.
			SET orbitLex["longitudeofascendingnode"] TO 0.
			SET orbitLex["argumentofperiapsis"] TO 0.
			SET orbitLex["trueanomaly"] TO 60.
	
	//Mission staging:
		//Liftoff
		addEvent("KERBIN_LAUNCH_LIFTOFF", "1", LIST("activate engine", "release clamp")).
		addEvent("KERBIN_READY", "4", "toggle rcs thrust"). //Disables the upper stage RCS thrusters
		
		//First decouple		
		addEvent("KERBIN_LAUNCH_FLAMEOUT_4", "2", "decouple").
		addEvent("KERBIN_LAUNCH_FLAMEOUT_4", "2", "activate engine").
		
		//Orbit circularization
		addEvent("KERBIN_LAUNCH_CIRCULARIZATION", "3", "decouple").
		addEvent("KERBIN_LAUNCH_CIRCULARIZATION", "3", "activate engine").	
		
		addEvent("KERBIN_ORBIT_EJECT", "4", LIST("activate engine", "decouple", "extend solar panel", "toggle rcs thrust")).
		
		//Fairing deploy
		addEvent("KERBIN_LAUNCH_ALT_60000", "fairing", "deploy").
			
	//Mission steps:	
		configureVessel().
		//RUNPATH("operations/mission operations/missionBuilder.ks", IKE, "orbit", 0, orbitLex).
		RUNPATH("operations/mission operations/missionBuilder.ks", GILLY, "orbit", 0, orbitLex).
		//RUNPATH("operations/mission operations/missionBuilder.ks", MOHO, "orbit", 0, orbitLex).