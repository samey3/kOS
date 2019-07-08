	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks"). //Run this between missions if it changes from rocket to rover or something
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
	
		//Execute steps	
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", TARGET, "dock", 0, 0). //<This is using Kerbin's geocoordinates, fix in missionBuilder