	//SET vess TO VESSEL("vessel name").
	//SET conn TO vess:CONNECTION.
	
	
	
	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	
	
	
	//Mission variables:
	
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
		
		
		
		addEvent("KERBIN_LAND_5", "parachute", "deploy").
		
		
		//Deploy chutes
		//Release bottom
		//Release rover, activate engines
		//--Suicide burn
		//--event for surface touchdown immediately?
		//Decouple


		//Non-part events? e.g. set throttle
		
	
	//Mission steps:
	
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", DUNA, "land", LATLNG(0, -146.5116), 0).