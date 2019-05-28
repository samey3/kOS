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
		//DO NOT USE A LIST CONTAINGING DECOUPLE AND A PART ACTIVATION WHEN THE ACTIVATION IS ON THE DECOUPLED PART
		//Instead, use two addEvents and do them in the proper order
		
		//Liftoff
		addEvent("0_LAUNCH_LIFTOFF", "1", LIST("activate engine", "release clamp")).		
		
		//First decouple
		addEvent("0_LAUNCH_FLAMEOUT_2", "2", "activate engine").
		addEvent("0_LAUNCH_FLAMEOUT_2", "2", "decouple").
		
		//Orbit circularization
		addEvent("0_LAUNCH_CIRC", "3", "decouple").
		addEvent("0_LAUNCH_CIRC", "3", "activate engine").
		
		//Fairing deploy
		addEvent("0_LAUNCH_ALT_60000", "fairing", "deploy"). //4
		
		//Landing engine
		addEvent("1_LAND_2", "5", LIST("activate engine", "decouple")). //1 Because we completed a transfer
		
	
	//Mission steps:
	
		configureVessel().
		RUNPATH("mission operations/missionBuilder.ks", MUN, "land", MUN:GEOPOSITIONLATLNG(2.4633, 81.531), 0). //<This is using Kerbin's geocoordinates, fix in missionBuilder
		//configureVessel("someName"). //This will create a new entry right now
		//RUNPATH("ground operations/groundBuilder.ks", DUNA, "drive", LATLNG(0, 0)).
		
		
		//Apparently circularManeuver is dying
