	//Once this one is fleshed out, create a generic version that others can be based off of
	
	
	
	RUNONCEPATH("lib/mission.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
	
	
	
	//Mission variables:
		LOCAL orbitLex IS LEXICON().
			SET orbitLex["semimajoraxis"] TO 1686750.
			SET orbitLex["eccentricity"] TO 0.60.
			SET orbitLex["inclination"] TO 10.
			SET orbitLex["longitudeofascendingnode"] TO 30.
			SET orbitLex["argumentofperiapsis"] TO 20.
			SET orbitLex["trueanomaly"] TO 60.
	
	//Mission staging:
		addEvent("0_LAUNCH_LIFTOFF", "1", LIST("release clamp", "activate engine")).		
		addEvent("0_LAUNCH_FLAMEOUT_1", "2", LIST("decouple", "activate engine")).
		
	
	//Mission steps:
	
		configureVessel().
		RUNPATH("mission operations/missionBuilder.ks", DUNA, "land", LATLNG(0, -146.5116), 0). //<This is using Kerbin's geocoordinates, fix in missionBuilder
		//configureVessel("someName"). //This will create a new entry right now
		//RUNPATH("ground operations/groundBuilder.ks", DUNA, "drive", LATLNG(0, 0)).
		
		
		
