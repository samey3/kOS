	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/config.ks").
	RUNONCEPATH("lib/fileIO.ks").
		
	//Variables
		LOCAL parameterLex IS LEXICON().
			//Basic parameters
			SET parameterLex["entity"] TO KERBIN.
			SET parameterLex["action"] TO "land".
			
			//Landing
			SET parameterLex["landingcoordinates"] TO getCoordinates("Launch pad").
			//SET parameterLex["interceptaltitude"] TO MUN:RADIUS + 2000.
	
		LOCAL boosterPart IS SHIP:PARTSTAGGED("")[0].
	
	//Event listeners

		
	//Mission steps:
	PRINT "AA".
		WAIT UNTIL boosterPart:DECOUPLEDIN = -1.
	PRINT "BB".
	WAIT 5.
		configureVessel().
		RUNPATH("operations/mission operations/missionBuilder.ks", parameterLex).