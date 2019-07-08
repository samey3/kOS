	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
	
	//Mission staging:
		//Liftoff
		addEvent("KERBIN_LAUNCH_LIFTOFF", "0", LIST("activate engine", "release clamp")).		
		
		//First fireworks		
		addEvent("KERBIN_LAUNCH_ALT_5000", "2", "decouple").
		addEvent("KERBIN_LAUNCH_ALT_5000", "2", "activate engine").
		
		//Second fireworks		
		addEvent("KERBIN_LAUNCH_FLAMEOUT_4", "2", "decouple").
		addEvent("KERBIN_LAUNCH_FLAMEOUT_4", "2", "activate engine").
		
		//Third fireworks		
		addEvent("KERBIN_LAUNCH_FLAMEOUT_8", "3", "decouple").
		addEvent("KERBIN_LAUNCH_FLAMEOUT_8", "3", "activate engine").
		
		//Third fireworks		
		addEvent("KERBIN_LAUNCH_ALT_10000", "4", "decouple").
		addEvent("KERBIN_LAUNCH_ALT_10000", "4", "activate engine").
			
	//Mission steps:
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", KERBIN, "launch", 0, 0). //<This is using Kerbin's geocoordinates, fix in missionBuilder
