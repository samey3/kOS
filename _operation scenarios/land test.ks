	RUNONCEPATH("lib/config.ks").
	RUNONCEPATH("lib/eventListener.ks").
	RUNONCEPATH("lib/fileIO.ks").
	
	
	//Variables		
		LOCAL airParameterLex IS LEXICON().
			//Basic parameters
			SET airParameterLex["action"] TO "land". 									//takeoff, fly, land
			SET airParameterLex["fastbuild"] TO TRUE. 									//TRUE, FALSE
			SET airParameterLex["resetcontrols"] TO FALSE. 								//TRUE, FALSE
			
			//Takeoff
			SET airParameterLex["takeoffheading"] TO 90. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["climbaltitude"] TO 1000. 								//Altitude to climb to on takeoff
			SET airParameterLex["climbpitch"] TO 10. 									//Degrees off of horizon
			
			//Flying
			//SET airParameterLex["flylocation"] TO getCoordinates("Island runway").		//Geoposition to fly to
			SET airParameterLex["flyaltitude"] TO 5000.								//Altitude above the coordinates to fly to
			SET airParameterLex["flyspeed"] TO 400.										//Cruising speed of the craft
			SET airParameterLex["maxerror"] TO 400.										//Maximum error distance for the point to count as having been 'reached' by the craft
			
			//Landing
			//SET airParameterLex["landinglocation"] TO KERBIN:GEOPOSITIONLATLNG(-0.04859836, -74.7248366). 	//Geoposition, 0 (no coordinates, land anywhere)
			SET airParameterLex["landinglocation"] TO KERBIN:GEOPOSITIONLATLNG(-1.51803866831133,-71.9666837288002).			
			//SET airParameterLex["landingheading"] TO 90. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["landingheading"] TO 91.1403063534302. 								//North[0], East[90], South[180], West[270]
			SET airParameterLex["landingspeed"] TO 80. 									//Speed to land at, varies per craft and body
			SET airParameterLex["descentdistance"] TO 10000. 							//Distance from location for start of descent
//-0.2856, -67.5439
//-0.1024200459, -67.60161040 est coords
	//Event listeners
		addListener("KERBIN_TAKEOFF_ENGINE_STARTUP", { STAGE. }, FALSE).
		
	//Mission steps:
		configureVessel("F22-Flight").
		UNTIL(FALSE){
			RUNPATH("operations/air operations/airBuilder.ks", airParameterLex).
		}
		
		//Making the torque adjust factors smaller makes the craft do slower/smoother turns
		
		
		//KSC runway
		//-0.0486000632186788,-74.7244585950828
		//89.5953258303653
		
		//Island runway
		//-1.51803866831133,-71.9666837288002
		//91.1403063534302