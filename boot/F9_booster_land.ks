	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	RUNONCEPATH("lib/fileIO.ks").

	UNTIL(FALSE){
		SET cockpitList TO SHIP:PARTSTAGGED("topCockpit").
		PRINT cockpitList:LENGTH.
		WAIT 0.01.
		CLEARSCREEN.
		IF(cockpitList:LENGTH = 0) BREAK.
	}
	
	//Hold it steady after separation
	LOCK STEERING TO SHIP:FACING.

	PRINT "decoupled".
	WAIT 5.
	
	//Wait 2 seconds?
	WAIT 2.
		
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO KERBIN.
			SET parameterLex["action"] TO "land".
			
			//Landing
			SET parameterLex["landingcoordinates"] TO getCoordinates("Launch pad").
			//SET parameterLex["interceptaltitude"] TO MUN:RADIUS + 2000.
	
		
	
	//Event listeners
		addListener("KERBIN_LAND_2", {
			ag1.
			handlePartAction("fins", "extend fins").
			WAIT 6.
			handlePartAction("fins", "roll", TRUE).
		}, FALSE).
		
	//Mission steps:
		configureVessel().
		RUNPATH("F9_land/missionBuilder_temp.ks", parameterLex).