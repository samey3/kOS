	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
	
	//Mission variables:
		LOCAL orbitLex IS LEXICON().
			SET orbitLex["semimajoraxis"] TO 1012500.
			SET orbitLex["eccentricity"] TO 0.0008050.
			SET orbitLex["inclination"] TO 51.6409.
			SET orbitLex["longitudeofascendingnode"] TO 334.8544.
			SET orbitLex["argumentofperiapsis"] TO 75.7779.
			SET orbitLex["trueanomaly"] TO 60.
	
	//Mission staging:
	
		//Liftoff
		addEvent("KERBIN_LAUNCH_LIFTOFF", "1", LIST("activate engine", "release clamp")).		
		
		//First decouple		
		addEvent("KERBIN_LAUNCH_FLAMEOUT_2", "2", "decouple").
		addEvent("KERBIN_LAUNCH_FLAMEOUT_2", "2", "activate engine").

		//Orbit set
		addEvent("KERBIN_LAUNCH_FLAMEOUT_3", "3", LIST("decouple", "activate engine", "extend solar panel", "extend antenna")). //Incase it finishes beforehand
		addEvent("KERBIN_ORBIT_SET", "3", LIST("decouple", "activate engine", "extend solar panel", "extend antenna")).
		
		//Fairing deploy
		addEvent("KERBIN_LAUNCH_ALT_65000", "fairing", "deploy"). //4
	
	
		//Instead for a staging fix,
		//shut down engines at 65000,stage
		//Next one light next set of engines (this avoids collisions during the 5k coast)
	
	//Mission steps:
		
		
		//UNCOMMENT THESE FOR THE SEQUENTIAL STATION PARTS
		
		//define target station
		//LOCAL stationName IS "aaa".
		//LOCAL targStation IS 0.
		
		//Find the station
		//LOCAL shipList IS LIST().
		//LIST TARGETS IN shipList.
		//FOR vssl IN shipList {
		//	IF (vssl:NAME = stationName){
		//		SET targStation TO vssl.
		//		BREAK.
		//	}
		//}
		
		//Execute steps	
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", KERBIN, "orbit", 0, orbitLex). //<This is using Kerbin's geocoordinates, fix in missionBuilder