	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
	
	//Mission staging:
		//DO NOT USE A LIST CONTAINGING DECOUPLE AND A PART ACTIVATION WHEN THE ACTIVATION IS ON THE DECOUPLED PART
		//Instead, use two addEvents and do them in the proper order
		
		//Liftoff
		addEvent("KERBIN_LAUNCH_LIFTOFF", "1", LIST("activate engine", "release clamp")).		
		
		//First decouple		
		addEvent("KERBIN_LAUNCH_FLAMEOUT_q", "2", "decouple").
		addEvent("KERBIN_LAUNCH_FLAMEOUT_q", "2", "activate engine").		
	
	//Mission steps:
	
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", KERBIN, "launch", 0, 0). //<This is using Kerbin's geocoordinates, fix in missionBuilder
		RUNPATH("operations/mission operations/missionBuilder.ks", KERBIN, "land", LATLNG(-0.0972078366335618, -74.5576783933035), 0). //<This is using Kerbin's geocoordinates, fix in missionBuilder
		
		
		//Apparently circularManeuver is dying
